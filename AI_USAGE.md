\# AI usage



\*\*Model:\*\* Claude Opus 5.5 (Anthropic), used through the Claude app.



\## How I used it



I built my the solution in this repo from scratch, using Claude as a step-by-step tutor. For each step, Claude explained the concept, then gave me an SQL query and code drafts or fill-in-the-blank versions, and reviewed what

I ran. I ran every query and script myself, fixed the errors, and made the decisions.



\*\*What Claude wrote or drafted:\*\*

\- Query 1 (gene counts per patient), plus the fixes to my Query 2 and Query 3. I filled in most of Query 2 and wrote the first version of Query 3 myself based on Query 1.

\- First drafts of `docs/schema.md`, `docs/missing\_data.md`, `docs/data\_dictionary.md`, and this README, built from my query results. I made sure to double check what was written and fixed any errors.



\*\*What I decided or did myself:\*\*

\- Ran every query in DB Browser and recorded the expected and actual row counts.

\- Chose to keep the 4 tumors with no mutation calls as 0 in the gene columns, with a `has\_mutation\_calls` flag, instead of NA. Claude had recommended NA. I chose 0 because cBioPortal lists those tumors as sequenced with a tumor mutation burden of 0.

\- Found and fixed errors along the way: a wrong column name (`site` instead of `tissue\_source\_site`), a missing Silent filter, a missing `.dropna()` in the age check, and VS Code running the wrong Python.



\## How I checked the SQL



I didn't treat "it ran without errors" as proof. My checks:



1\. \*\*Expected vs. actual row counts, decided before running.\*\* Query 1: 2,830 (566 × 5).

&#x20;  Query 2: 142, counted separately with `SELECT DISTINCT`, and the counts add up to 566.

&#x20;  Query 3: 566.

2\. \*\*I ran the wrong versions on purpose.\*\* A plain join gave 700 rows instead of 2,830,

&#x20;  because patients with no mutation in a gene disappeared. Moving the Silent filter from

&#x20;  `ON` to `WHERE` also gave 700.

3\. \*\*I learned that row counts alone aren't enough.\*\* A version with no Silent filter still

&#x20;  returned 2,830 rows but with wrong counts. So the Python script also checks that each

&#x20;  gene column's total equals a direct count of that gene's non-Silent mutations: TP53 305,

&#x20;  KRAS 172, EGFR 85, STK11 81, KEAP1 103.

4\. \*\*Hand checks in DB Browser:\*\* missing counts (52 / 71 / 54), zero counts per gene,

&#x20;  missing values by site, and two patients looked up in the TSV (TCGA-17-Z023 and

&#x20;  TCGA-64-1678). Details are in `docs/missing\_data.md`.

5\. \*\*Two separate builds agree.\*\* The R script builds the table on its own and confirms it

&#x20;  matches the Python table value for value.

