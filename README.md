# 🛟 Click-Prep: Data Formatter for Click-qPCR
Click-Prep is an interactive web application built with R and Shiny, designed to easily reformat and clean raw data files exported from qPCR machines into the standardized input format required for the downstream relative quantification analysis tool, Click-qPCR.

By providing an intuitive GUI, Click-Prep eliminates tedious data preprocessing steps—such as error-prone copy-pasting in Excel or manually merging multiple plate datasets—allowing experimental biologists to prepare their data safely, accurately, and efficiently.

## 🌟 Key Features
Interactive Column Mapping: Easily link machine-specific column headers to the required standard categories (Sample, Group, Gene, Cq) using simple drop-down menus.

Manual Group Assignment: If your raw data lacks a 'Group' column, you can interactively define experimental conditions and assign them to your samples directly within the app.

Mean Cq Calculation: Automatically calculates the mean Cq values for technical replicates (identical sample and gene combinations), safely handling missing values (NAs) without crashing.

Advanced CSV Integration: Seamlessly merge (row-bind) multiple pre-formatted CSV files into a single, unified dataset, which is perfect for large-scale analyses spanning multiple qPCR plates.

## 📖 Workflow
The application is structured into four sequential tabs to guide you through the data formatting process:

Introduction:
Review the app's overview, basic instructions, and privacy/security policy.

File Trimming:
Upload your raw qPCR output file (.csv, .txt, .tsv, .xlsx). Use the 'Skip' option to bypass any machine metadata rows at the top. Map your columns to the required format and, if needed, assign groups manually. A status panel will notify you when all mapping requirements are met.

Mean Cq Calculation & Download:
Once column mapping is fully completed, proceed to this tab to preview the calculated results. You can download either the "Formatted CSV (All Reps)" or the averaged "Mean Cq CSV".

Advanced - Input CSV Integration:
Upload multiple previously formatted CSV files (e.g., from separate experimental runs) to merge them into a single, large-scale dataset ready for Click-qPCR analysis.

## 🔒 Privacy & Security Policy
Click-Prep is designed with strict data privacy in mind to safely handle highly sensitive research data, including clinical samples and proprietary corporate data.

1. In-Memory Processing: Uploaded files are processed exclusively in the server's active memory for the duration of your session. No files are permanently stored on the server.

2. Automatic Data Purge: All temporary files and cached data are automatically and completely destroyed immediately after processing or when you close your browser tab.

3. Zero Tracking & Sharing: Your input data, analytical conditions, and formatting results remain strictly confidential. No data is collected, logged, or shared with any third parties.
