# 🧹 Data Cleaning in MySQL — Tech Layoffs Dataset

## 📌 Project Overview

This project focuses on cleaning a real-world dataset of tech industry layoffs using MySQL. The raw dataset contained duplicates, inconsistent formatting, encoding errors, null values, and incorrect data types, all common issues found in production data.

The goal was to transform the raw data into a clean, analysis-ready table using structured SQL queries.


## 📂 Dataset

- **Source:** Layoffs Dataset from AlexTheAnalyst
- **Rows:** ~2,361 records
- **Columns:** company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
- **Time Period:** Tech layoffs from 2022–2023


## 🛠️ Tools Used

- **MySQL:** all data cleaning performed in SQL
- **MySQL Workbench:** query execution and table management


## 🔍 Data Cleaning Steps

1. **Created a Staging Table**
    - Preserved the original raw data by working on a copy (layoffs_staging), ensuring the source data remained untouched.

1. **Removed Duplicates**
    - Used ROW_NUMBER() with PARTITION BY across all relevant columns to identify and delete exact duplicate rows.

1. **Standardized Data**
    - Trimmed whitespace from company names using TRIM()
    - Unified industry labels: consolidated variations like Crypto Currency, CryptoCurrency → Crypto
    - Fixed encoding errors: corrected DÃ¼sseldorf → Dusseldorf
    - Cleaned country names: removed trailing periods from United States.

1. **Fixed Data Types**
    - Converted the date column from TEXT to proper DATE format using STR_TO_DATE() and ALTER TABLE.

1. **Handled NULL Values**
    - Identified rows where both total_laid_off and percentage_laid_off were NULL (unusable records) and deleted them
    - Used a self-JOIN to populate missing industry values from other rows of the same company

1. **Removed Unnecessary Columns**
     - Dropped the helper row_num column after it was no longer needed.


## 💡 Key SQL Concepts Demonstrated

- **Window Functions:** ROW_NUMBER() OVER (PARTITION BY ...)
- **CTEs:** Isolating duplicates with WITH clause
- **String Functions:** TRIM(), LIKE, STR_TO_DATE(), TRIM(TRAILING ...)
- **Self JOIN:** Filling NULL industry values from matching rows
- **DDL (Data Definition Language):** CREATE, ALTER TABLE, MODIFY COLUMN, DROP COLUMN
- **DML (Data Manipulation Language):** SELECT, UPDATE, DELETE, INSERT INTO


## 🚀 How to Reproduce

1. Import data/layoffs.csv into MySQL as a table called layoffs
1. Open sql/data_cleaning.sql in MySQL Workbench
1. Run the script from top to bottom — each section is clearly commented
1. The final cleaned table will be layoffs_staging2


## 👤 Author

### Sofia Costa

https://www.linkedin.com/in/sofiassvcosta/

https://github.com/soda-sil
