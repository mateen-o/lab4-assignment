# Building the Feature table in R: Same SQL file as python

library(DBI)
library(RSQLite)
library(dplyr)
library(tidyr)
library(readr)

db_path <- file.path("data", "raw", "cohort.db")
sql_folder <- "sql"
expected_patient_count <- 566
target_genes <- c("TP53", "KRAS", "EGFR", "STK11", "KEAP1")

# Read a .sql file as one block of text, so R runs the exact same queries as Python.
read_sql_file <- function(file_name) paste(readLines(file.path(sql_folder, file_name), warn = FALSE), collapse = "\n")

check_row_count <- function(step_description, expected_count, actual_count) {
  # Print both numbers so the output is a record of every check, and stop the script if they don't match.
  cat(step_description, ": expected ", expected_count, ", got ", actual_count, "\n", sep = "")
  if (expected_count != actual_count) stop("Row count check failed at: ", step_description, call. = FALSE)
}

# Open the database read-only so this script can never change the course data.
database_connection <- dbConnect(RSQLite::SQLite(), db_path, flags = RSQLite::SQLITE_RO)

patient_base <- dbGetQuery(database_connection, read_sql_file("03_patient_base.sql"))
check_row_count("Query 3: patient base", expected_patient_count, nrow(patient_base))

gene_counts_long <- dbGetQuery(database_connection, read_sql_file("01_gene_counts_per_patient.sql"))
check_row_count("Query 1: gene counts, long format", expected_patient_count * length(target_genes), nrow(gene_counts_long))

dbDisconnect(database_connection)

repeated_patient_gene_pairs <- sum(duplicated(gene_counts_long[, c("patient_id", "gene_symbol")]))
check_row_count("Repeated patient-gene pairs (must be none)", 0, repeated_patient_gene_pairs)

# Long to wide: one row per patient, one column per gene
gene_counts_wide <- pivot_wider(gene_counts_long, names_from = gene_symbol, values_from = protein_altering_count)
gene_counts_wide <- gene_counts_wide[, c("patient_id", target_genes)]
names(gene_counts_wide) <- c("patient_id", paste0(tolower(target_genes), "_protein_altering_count"))
check_row_count("Gene counts after pivot to wide", expected_patient_count, nrow(gene_counts_wide))

# Keep every patient
feature_table <- left_join(patient_base, gene_counts_wide, by = "patient_id", relationship = "one-to-one")
check_row_count("Feature table after join", expected_patient_count, nrow(feature_table))

# Ages are whole years stored as decimals.
recorded_ages <- na.omit(feature_table$age_at_diagnosis)
if (any(recorded_ages != round(recorded_ages))) stop("age_at_diagnosis has fractional values", call. = FALSE)
feature_table$age_at_diagnosis <- as.integer(feature_table$age_at_diagnosis)

cat("Missing values (NA) per column:\n")
print(colSums(is.na(feature_table)))

write_tsv(feature_table, file.path("output", "feature_table_r.tsv"), na = "NA")
cat("Wrote feature_table_r.tsv:", nrow(feature_table), "rows x", ncol(feature_table), "columns\n")

# Read both tables back and compare every value
python_table <- read_tsv(file.path("output", "feature_table.tsv"), show_col_types = FALSE)
r_table <- read_tsv(file.path("output", "feature_table_r.tsv"), show_col_types = FALSE)
if (!isTRUE(all.equal(as.data.frame(python_table), as.data.frame(r_table)))) stop("R and Python tables differ", call. = FALSE)
cat("R table matches the Python table\n")
