\# Lab 4: Database-Driven Feature Table



PUBH 6854, Fall 2026. Abdulmateen Oyediran.



This repo turns `cohort.db` (566 lung adenocarcinoma patients from the TCGA PanCancer Atlas,

via cBioPortal) into a feature table with one row per patient. The columns are sex, age at

diagnosis, stage, tissue source site, tumor mutation burden, and a count of protein-altering

mutations in each of TP53, KRAS, EGFR, STK11, and KEAP1.



SQL does the joining and counting. Python reshapes the counts to wide format. An R script

builds the same table separately and checks that it matches.



\# How to run



Set up the environment once:



```

conda env create -f environment.yml

conda activate pubh6854-lab4

```



Then, from this folder, this command rebuilds the feature table from `cohort.db`:



```

python scripts/build\_feature\_table.py

```



For the R version

```

Rscript scripts/build\_feature\_table.R

```



Both scripts should print the expected and actual row count at every step and stop with an error if any count doesn't match.





\## What it produces



| File | Made by | Contents |

|---|---|---|

| `output/feature\_table.tsv` | Python script | \*\*The feature table\*\*: 566 rows, 12 columns, tab-separated, missing values written as `NA` |

| `output/feature\_table\_r.tsv` | R script | The same table built in R. It matches the Python file value for value |



\## Queries: expected vs. actual row counts



| Query | File | Expected | Got |

|---|---|---|---|

| 1. Protein-altering mutations per patient per gene | `sql/01\_gene\_counts\_per\_patient.sql` | 2,830 (566 × 5) | 2,830 |

| 2. Patients per tissue source site per stage | `sql/02\_patients\_per\_site\_and\_stage.sql` | 142 | 142 (counts add up to 566) |

| 3. Patient base table for the feature table | `sql/03\_patient\_base.sql` | 566 | 566 |



To run Query 2 on its own, open `cohort.db` in DB Browser for SQLite and run the file in the

Execute SQL tab. Each SQL file's header comment explains why its row count is what it is.



\## Where each task is



| Task | File |

|---|---|

| 1. Schema: tables, keys, grain, relationships | `docs/schema.md` |

| 2. SQL queries with expected vs. actual counts | `sql/` and the table above |

| 3. Feature table | `scripts/` and `output/feature\_table.tsv` |

| 4. Missing data | `docs/missing\_data.md` |

| 5. Data dictionary | `docs/data\_dictionary.md` |

| AI use | `AI\_USAGE.md` |



\## Folder layout



```

lab4-assignment/

├── README.md

├── AI\_USAGE.md

├── environment.yml

├── data/raw/cohort.db

├── sql/        three queries

├── scripts/    build\_feature\_table.py and build\_feature\_table.R

├── output/     the feature table TSVs

└── docs/       schema, missing data, data dictionary

```



