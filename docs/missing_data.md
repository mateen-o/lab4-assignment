\# Task 4: Missing data





\*\* I did not drop ant patients or make up any values.  \*\* all 566 patients are present in the feature table. \*\* Note: A gene count of `0` means that there was no protein altering mutation in that gene.



\## So what did I do for each gap?

| Gap | Patients | What I did | Coded as |

|---|---|---|---|

| Sex not recorded | 52 | Kept the patient, left sex blank | `NA` |

| Age at diagnosis not recorded | 71 | Kept the patient, nothing filled in | `NA` |

| Stage not recorded | 54 | Kept the patient, no "Unknown" label | `NA` |

| No protein-altering mutation in a gene | 279 (TP53) to 497 (EGFR) | Counted as zero mutations | `0` |

| Tumor has no mutation calls at all | 4 | Kept as 0, flagged with `has\_mutation\_calls = 0` | `0` |



\## Where the gaps come from

The missing values are split between sites.

&#x20;\*\* Washington University: \*\* All its patients (52) have no sex, age or stage recorded.

&#x20;\*\* Two OCICR sites: \*\* All 19 patients have missing age.

&#x20;\*\* Two patients are missing only the stage

Dropping every row with a missing value would

remove all of Washington University. So I kept the NAs, and each analysis can decide what to

do with them.



\## Patient counts before and after each join



Output of `python scripts/build\_feature\_table.py`. The script stops with an error if any

count doesn't match.



```

Query 3: patient base: expected 566, got 566

Query 1: gene counts, long format: expected 2830, got 2830

Repeated patient-gene pairs (must be none): expected 0, got 0

Gene counts after pivot to wide: expected 566, got 566

Feature table after join: expected 566, got 566

Tumors with no mutation calls (kept as 0, flagged): 4



Missing values (NA) per column:

patient\_id                       0

sex                             52

age\_at\_diagnosis                71

stage                           54

tissue\_source\_site               0

tmb\_nonsynonymous                0

has\_mutation\_calls               0

tp53\_protein\_altering\_count      0

kras\_protein\_altering\_count      0

egfr\_protein\_altering\_count      0

stk11\_protein\_altering\_count     0

keap1\_protein\_altering\_count     0

```



\## How I checked these numbers



I re-checked every number above by hand in DB Browser instead of relying only on the script provided by Claude Opus 5.5



| Claim | How I checked it | Result |

|---|---|---|

| 52 / 71 / 54 missing sex, age, stage | `COUNT(\*) - COUNT(column)` on the patients table | Matched |

| Zero counts per gene | Counted patients with 0 per gene from Query 1 | TP53 279, KRAS 398, EGFR 497, STK11 492, KEAP1 464 |

| Gaps come from a few sites | Missing values per site with `SUM(column IS NULL)` | Washington University 52 / 52 / 52, OICR sites age only |

| Washington University would be lost entirely | Counted its patients in samples | 52 total, all missing clinical data |

| The 4 tumors are listed as sequenced | Searched the cBioPortal sequenced list for each ID | All 4 found |

| Patients are kept, not dropped | Spot-checked TCGA-17-Z023 in the TSV | sex, age, stage `NA`; TP53 = 1 |

| No-call tumors kept as 0 and flagged | Spot-checked TCGA-64-1678 in the TSV | `has\_mutation\_calls` = 0, all gene counts 0 |



