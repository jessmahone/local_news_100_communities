# 100 Communities Local News SQLite Project

This project builds a clean, relational SQLite database from a cleaned dataset of 100 U.S. communities, their local news outlets, and stories produced by those outlets. 
The goal is to create a queryable structure for analyzing local journalism coverage and critical information needs.

[INSERT INFO ABOUT DATA ORIGINS HERE - TAKE FROM REPORT]

## 📁 What's in this repo

- `data/`: Cleaned CSV files for communities, outlets, and stories
- `create_tables.sql`: SQL schema for creating normalized tables
- `load_data.Rmd`: Loads cleaned data into SQLite using R
- `local_news_100_communities.db`: Final SQLite database
- `databse_cleaning.Rmd`: Original RMarkdown used to clean raw data

## 🧰 Tools Used

- **R** and **RMarkdown** for data cleaning and automation
- **RSQLite** and **DBI** for database interaction
- **SQLite** for lightweight, portable relational storage
- **Git & GitHub** for version control and publishing
