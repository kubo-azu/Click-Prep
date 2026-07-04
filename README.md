# 🛟 Click-Prep: Data Formatter for Click-qPCR
Click-Prep is an interactive web application built with R and Shiny, designed to easily reformat and clean raw data files exported from qPCR machines into the standardized input format required for the downstream relative quantification analysis tool, [Click-qPCR](https://kubo-azu.shinyapps.io/Click-qPCR/).

By providing an intuitive GUI, Click-Prep eliminates tedious data preprocessing steps—such as error-prone copy-pasting in Excel or manually merging multiple plate datasets—allowing experimental biologists to prepare their data safely, accurately, and efficiently.

This tool is readily accessible via a web browser at <https://kubo-azu.shinyapps.io/Click-Prep/>, requiring no local installation for end-users.

### <ins>Notice</ins>

This repository contains the source code for the Shiny app accompanying the paper as follows:

Kubota, A. and Tajima, A. (2025). *Bio-protocol*, 15(1384). <https://doi.org/10.21769/BioProtoc.5513>.

**Please <ins>cite this paper</ins> if you use this app or code in your research.**

## 🌟 Key Features
Interactive Column Mapping: Easily link machine-specific column headers to the required standard categories (Sample, Group, Gene, Cq) using simple drop-down menus.

Manual Group Assignment: If your raw data lacks a 'Group' column, you can interactively define experimental conditions and assign them to your samples directly within the app.

Mean Cq Calculation: Automatically calculates the mean Cq values for technical replicates (identical sample and gene combinations), safely handling missing values (NAs) without crashing.

Advanced CSV Integration: Seamlessly merge (row-bind) multiple pre-formatted CSV files into a single, unified dataset, which is perfect for large-scale analyses spanning multiple qPCR plates.


## 📖 Workflow
The application is structured into four sequential tabs to guide you through the data formatting process:

#### <b>Introduction:</b>

Review the app's overview, basic instructions, and privacy/security policy.

#### <b>File Trimming:</b>

Upload your raw qPCR output file (.csv, .txt, .tsv, .xlsx). Use the 'Skip' option to bypass any machine metadata rows at the top. Map your columns to the required format and, if needed, assign groups manually. A status panel will notify you when all mapping requirements are met.

#### <b>Mean Cq Calculation & Download:</b>

Once column mapping is fully completed, proceed to this tab to preview the calculated results. You can download either the "Formatted CSV (All Reps)" or the averaged "Mean Cq CSV".

#### <b>Advanced - Input CSV Integration:</b>

Upload multiple previously formatted CSV files (e.g., from separate experimental runs) to merge them into a single, large-scale dataset ready for Click-qPCR analysis.


## 🔒 Privacy & Security Policy
Click-Prep is designed with strict data privacy in mind to safely handle highly sensitive research data, including clinical samples and proprietary corporate data.

#### <b>In-Memory Processing:</b>

Uploaded files are processed exclusively in the server's active memory for the duration of your session. No files are permanently stored on the server.

#### <b>Automatic Data Purge:</b>

All temporary files and cached data are automatically and completely destroyed immediately after processing or when you close your browser tab.

#### <b>Zero Tracking & Sharing:</b>

Your input data, analytical conditions, and formatting results remain strictly confidential. No data is collected, logged, or shared with any third parties.


## 🔧 Licence
This tool is under MIT licence.


## ✉️ Contact
Feel free to use [GitHub Discussions](https://github.com/kubo-azu/Click-Prep/discussions).
