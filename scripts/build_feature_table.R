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
print(head(gene_counts_long, 10))