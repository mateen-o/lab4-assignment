import sqlite3
from pathlib import Path
import pandas as pd

project_folder = Path(__file__).resolve().parent.parent
database_path = project_folder / "data" / "raw" / "cohort.db"
sql_folder = project_folder / "sql"

expected_patient_count = 566
target_genes = ["TP53", "KRAS", "EGFR", "STK11", "KEAP1"]


def read_sql_file(file_name):
    return (sql_folder / file_name).read_text(encoding="utf-8")


def check_row_count(step_description, expected_count, actual_count):
    # Print both numbers so the output is a record of every check, and stop the script if they don't match.
    print(f"{step_description}: expected {expected_count}, got {actual_count}")
    if expected_count != actual_count:
        raise SystemExit(f"Row count check failed at: {step_description}")


database_connection = sqlite3.connect(f"{database_path.as_uri()}?mode=ro", uri=True)

patient_base = pd.read_sql_query(read_sql_file("03_patient_base.sql"), database_connection)
check_row_count("Query 3: patient base", expected_patient_count, len(patient_base))

gene_counts_long = pd.read_sql_query(read_sql_file("01_gene_counts_per_patient.sql"), database_connection)
check_row_count("Query 1: gene counts, long format", expected_patient_count * len(target_genes), len(gene_counts_long))

repeated_patient_gene_pairs = int(gene_counts_long.duplicated(subset=["patient_id", "gene_symbol"]).sum())
check_row_count("Repeated patient-gene pairs (must be none)", 0, repeated_patient_gene_pairs)

gene_counts_wide = gene_counts_long.pivot(index="patient_id", columns="gene_symbol", values="protein_altering_count")
gene_counts_wide = gene_counts_wide[target_genes]
gene_counts_wide.columns = [f"{gene_symbol.lower()}_protein_altering_count" for gene_symbol in target_genes]
gene_counts_wide = gene_counts_wide.reset_index()
check_row_count("Gene counts after pivot to wide", expected_patient_count, len(gene_counts_wide))

# pandas' version of a LEFT JOIN. validate="one_to_one" raises an error if either table repeats a patient, instead of multiplying rows.
feature_table = patient_base.merge(gene_counts_wide, on="patient_id", how="left", validate="one_to_one")
check_row_count("Feature table after join", expected_patient_count, len(feature_table))

# The 4 tumors with no mutation calls keep 0 in the gene columns.
print(f"Tumors with no mutation calls (kept as 0, flagged): {int((feature_table['has_mutation_calls'] == 0).sum())}")

# Ages are stored as decimals (70.0) but are whole years.
recorded_ages = feature_table["age_at_diagnosis"].dropna()
if not (recorded_ages == recorded_ages.round()).all():
    raise SystemExit("age_at_diagnosis has fractional values; not converting to whole years")
feature_table["age_at_diagnosis"] = feature_table["age_at_diagnosis"].astype("Int64")

# Count missing values per column, for the Task 4 write-up.
print("Missing values (NA) per column:")
print(feature_table.isna().sum())

output_path = project_folder / "output" / "feature_table.tsv"
feature_table.to_csv(output_path, sep="\t", index=False, na_rep="NA")
print(f"Wrote {output_path.name}: {len(feature_table)} rows x {feature_table.shape[1]} columns")
print(feature_table.head())

# Row counts can't catch wrong values
for gene_symbol in target_genes:
    direct_mutation_count = database_connection.execute("SELECT COUNT(*) FROM mutations WHERE gene_symbol = ? AND variant_classification <> 'Silent'", (gene_symbol,)).fetchone()[0]
    check_row_count(f"{gene_symbol} mutations counted in the table", direct_mutation_count, int(feature_table[f"{gene_symbol.lower()}_protein_altering_count"].sum()))

database_connection.close()
