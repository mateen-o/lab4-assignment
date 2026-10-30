\# Task 5: Data dictionary for output/feature\_table.tsv



\*\*One row is one patient.\*\* Missing values are written as `NA`.



| Column | Meaning | Units / values | Missing (`NA`) | Source table |

|---|---|---|---|---|

| `patient\_id` | TCGA patient ID. Unique, one per row | Text, e.g. `TCGA-05-4244` | Never missing | `patients.patient\_id` |

| `sex` | Patient sex as recorded | `female` (275), `male` (239) | 52 patients (all from Washington University) | `patients.sex` |

| `age\_at\_diagnosis` | Age when the cancer was diagnosed | Whole \*\*years\*\*, 33 to 88 | 71 patients | `patients.age\_at\_diagnosis` |

| `stage` | AJCC pathologic tumor stage | `I`, `IA`, `IB`, `II`, `IIA`, `IIB`, `IIIA`, `IIIB`, `IV` | 54 patients | `patients.stage` |

| `tissue\_source\_site` | Institution that collected the tumor sample | Text, 34 sites | Never missing | `samples.tissue\_source\_site` |

| `tmb\_nonsynonymous` | Tumor mutation burden | \*\*Mutations per megabase\*\*, 0 to 69.53 | Never missing | `samples.tmb\_nonsynonymous` |

| `has\_mutation\_calls` | Whether the tumor has any rows in the mutations table | `1` = yes (562), `0` = none (4) | Never missing | Built from `mutations` (Query 3) |

| `tp53\_protein\_altering\_count` | Number of protein-altering TP53 mutations in the patient's tumor | \*\*Count of mutations\*\*, 0 to 2 | Never missing | `mutations`, joined through `samples` |

| `kras\_protein\_altering\_count` | Same, for KRAS | \*\*Count of mutations\*\*, 0 to 2 | Never missing | `mutations`, joined through `samples` |

| `egfr\_protein\_altering\_count` | Same, for EGFR | \*\*Count of mutations\*\*, 0 to 3 | Never missing | `mutations`, joined through `samples` |

| `stk11\_protein\_altering\_count` | Same, for STK11 | \*\*Count of mutations\*\*, 0 to 2 | Never missing | `mutations`, joined through `samples` |

| `keap1\_protein\_altering\_count` | Same, for KEAP1 | \*\*Count of mutations\*\*, 0 to 2 | Never missing | `mutations`, joined through `samples` |



\## What the gene count columns count



A mutation is counted if it is in that gene and its `variant\_classification` is anything

except `Silent`.



\- \*\*Counted:\*\* Missense\_Mutation, Nonsense\_Mutation, Frame\_Shift\_Del, Frame\_Shift\_Ins,

&#x20; In\_Frame\_Del, In\_Frame\_Ins, Splice\_Site, Translation\_Start\_Site, Nonstop\_Mutation

\- \*\*Excluded:\*\* Silent (it changes the DNA but not the protein)



\*\*What 0 means:\*\* no protein-altering mutation was found in that gene. The 4 tumors with

`has\_mutation\_calls = 0` also show 0; see `docs/missing\_data.md` for why.



A count above 1 means the same gene has several separate mutations in one tumor. It is

still one row for that patient.

