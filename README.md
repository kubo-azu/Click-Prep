# 🛟 Click-Prep: Data Preparation Tool for Click-qPCR (version 1.2.1)

Click-Prep is an interactive R/Shiny application that converts tabular qPCR instrument output into the standardized input format required by [Click-qPCR](https://kubo-azu.shinyapps.io/Click-qPCR/). It supports relative qPCR workflows for gene expression and DNA copy number analysis.

[日本語版のユーザーガイドはこちら (Read this document in Japanese)](README_jp.md)

Click-Prep provides a browser-based workflow for importing instrument output, mapping columns, assigning experimental groups, reviewing technical-replicate measurements, calculating mean Cq values, and combining compatible datasets from multiple qPCR plates. The hosted application is available at <https://kubo-azu.shinyapps.io/Click-Prep/>. No local installation is required to use the hosted version.

## Notice and citation

The manuscript describing Click-Prep is currently in preparation. Citation information will be added here after the manuscript or preprint becomes publicly available.

Click-Prep prepares input data for Click-qPCR. For the downstream analysis application, please cite:

> Kubota, A. and Tajima, A. (2025). Click-qPCR: A Simple Tool for Interactive qPCR Data Analysis. *Bio-protocol*, 15(22): e5513. <https://doi.org/10.21769/BioProtoc.5513>

When reporting analyses performed with Click-Prep, please record the application version, access date, and whether the hosted or local version was used.

## 🌟 Key features

- **Flexible file import:** Imports `.csv`, `.txt`, `.tsv`, `.xls`, and `.xlsx` files. Leading instrument-generated metadata rows can be omitted before parsing the column headers.
- **Interactive column mapping:** Maps instrument-specific columns to the required `sample`, `group`, `gene`, and `Cq` fields.
- **Manual group assignment:** Defines and assigns experimental groups when the instrument output does not contain a group column. A three-column input containing sample, target, and Cq information is sufficient for this workflow.
- **Manual review of replicate measurements:** Displays replicate-level measurements and allows selected rows to be excluded. Click-Prep does not automatically detect or classify outliers.
- **Mean Cq calculation:** Calculates the arithmetic mean of retained Cq values for each `sample`–`group`–`gene` combination.
- **Validated CSV combination:** Combines compatible formatted CSV files, such as mean Cq datasets from different qPCR plates, after checking their required columns and values.
- **Click-qPCR-ready output:** Exports standardized CSV files with the columns `sample`, `group`, `gene`, and `Cq`.

The `gene` field may contain a gene name for expression analysis or a target genomic locus for DNA copy number analysis.

## 📖 Workflow

The application contains four tabs.

### Introduction

Provides an overview of the workflow and information about data handling.

### Import and Column Mapping

1. Upload a qPCR instrument output file in CSV, TXT, TSV, XLS, or XLSX format.
2. If necessary, use **Skip first N rows (metadata)** to omit instrument-generated information above the column headers.
3. Map the relevant source columns to `sample`, `group`, `gene`, and `Cq`.
4. If the file lacks group information, select **[Assign groups manually]**, define the experimental groups, and assign every sample to a group.
5. Verify the formatted-data preview. The replicate-level standardized CSV can be downloaded at this stage.

TXT and TSV files are interpreted as tab-delimited files. Each source column can be mapped to only one Click-qPCR field. Missing or nonnumeric Cq values are displayed as `NA` with a warning so that users can review them before mean calculation. The `sample`, `group`, and `gene` fields must be complete.

### Manual Data Review and Mean Cq Calculation

1. Inspect the replicate-level measurements displayed in the table.
2. Review any missing or nonnumeric Cq values shown as `NA`. Select and exclude affected measurements or restart with a revised input file. Other measurements should be excluded only when justified by predefined quality-control criteria.
3. Optionally download the retained replicate-level dataset.
4. Click **Calculate Mean Cq** to calculate one mean for each `sample`–`group`–`gene` combination.
5. Download the resulting mean Cq dataset for analysis in Click-qPCR.

Click-Prep does not automatically identify outliers or determine whether a measurement meets experimental quality criteria. Mean calculation is blocked while missing or invalid Cq values remain. Users remain responsible for documenting the rationale for exclusions. Technical replicates must not be treated as independent biological replicates.

### Combine Formatted CSV Files

1. Upload one or more compatible formatted CSV files.
2. Confirm the loaded filenames and inspect the combined-data preview.
3. Download the combined CSV file.

All files must contain exactly `sample`, `group`, `gene`, and `Cq`, in that order. Do not combine mean Cq datasets with replicate-level datasets.

## Input and output format

| Column | Description |
|---|---|
| `sample` | Sample identifier. Identifiers should uniquely represent biological samples across the combined dataset. |
| `group` | Experimental condition or comparison group. |
| `gene` | Target gene or genomic locus. |
| `Cq` | Numeric quantification-cycle value. |

The output is a comma-separated CSV file with these four columns. Empty, nonnumeric, or nonfinite Cq values trigger warnings during data review and must be resolved before mean calculation; they are never silently omitted from the calculation.

## Important scope and limitations

- Click-Prep processes tabular Cq output; it does not process raw fluorescence or amplification-curve data.
- Click-Prep does not directly import proprietary qPCR experiment files, RDML/XML files, or report files. Results must first be exported as a comma-delimited CSV, tab-delimited TXT/TSV, or XLS/XLSX file containing sample identifiers, target names, and Cq values.
- It does not assess amplification efficiency, melting curves, controls, reference-target suitability, or assay validity.
- It does not automatically detect outliers or define exclusion thresholds.
- Use of Click-Prep does not by itself establish compliance with the MIQE guidelines. Experimental design, assay validation, quality control, analysis choices, and reporting remain the user's responsibility.

## 🔒 Data handling and privacy

Uploaded data are processed within the active application session. Click-Prep does not intentionally write uploaded qPCR data to persistent application storage. Temporary files created by the application are removed when they are no longer required or when the session ends.

Click-Prep does not intentionally transmit uploaded qPCR data to third parties. Use of the hosted application is also subject to the hosting provider's applicable data-handling and logging policies. Users working with confidential, clinical, regulated, or otherwise sensitive data should review those policies and, where appropriate, run Click-Prep locally in an approved environment.

## Local installation

For reproducible local execution, use R 4.6.1, Git, and `renv`. RStudio is optional but provides a convenient way to open and run the project.

### 1. Clone the repository

Run the following commands in a terminal:

```sh
git clone https://github.com/kubo-azu/Click-Prep.git
cd Click-Prep
```

### 2. Open the project with R 4.6.1

If using RStudio, open `Click-Prep.Rproj` in the cloned directory. If multiple R versions are installed, confirm that R 4.6.1 is active.

The active R version can be checked in the R console:

```r
R.version.string
```

### 3. Restore the package environment

Run the following commands in the R console. Install `renv` first only if it is not already available.

```r
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}
renv::restore()
```

This installs the package versions recorded in `renv.lock` into the project library.

### 4. Launch Click-Prep

After restoration is complete, run:

```r
shiny::runApp()
```

Open the displayed local URL in a web browser. When using RStudio, the application will normally open automatically in the Viewer or browser.

### Quick launch directly from GitHub

To try Click-Prep without cloning the repository, run:

```r
if (!requireNamespace("shiny", quietly = TRUE)) {
  install.packages("shiny")
}
shiny::runGitHub("kubo-azu/Click-Prep")
```

Because `shiny::runGitHub()` does not restore the package versions recorded in `renv.lock`, cloning the repository and using `renv::restore()` is recommended for reproducible local execution.

### Troubleshooting local execution

If the application fails to start or `renv` reports that the project library and lockfile are out of sync, first confirm that R 4.6.1 is active.

If multiple R versions are installed, a version manager such as `rig` can be used to launch the project with R 4.6:

```sh
rig rstudio 4.6 Click-Prep.Rproj
```

Then check and restore the project environment:

```r
renv::restore()
renv::status()
```

If `renv` itself is inconsistent, run the following command, restart R, and then repeat `renv::restore()`:

```r
renv::restore(packages = "renv")
```

## 🔧 License

Click-Prep is distributed under the MIT License.

## ✉️ Contact

Questions and feedback are welcome in [GitHub Discussions](https://github.com/kubo-azu/Click-Prep/discussions).
