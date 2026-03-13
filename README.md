# 100 Communities Local News Database
Creating and exploring a database of journalism sources and content in 100 U.S. communities using R, SQLite, and PostgreSQL.

This project involved cleaning, normalizing, and analyzing a dataset of over 16,000 local news stories to build a structured, queryable database for deeper insights into the state of U.S. local journalism. It's part of my portfolio to demonstrate my data wrangling, SQL, and data integration skills.

## 🚀 Motivation
This project began as part of my work at the DeWitt Wallace Center for Media and Democracy and reflects my interest in transforming messy, real-world data into structured insights that support decision-making in media and beyond. Local news data is often fragmented and hard to analyze at scale; this project demonstrates how raw content data can be structured for strategic insight.

## 🧰 Tools & Technologies
- **R**: Data cleaning, transformation, and database interaction
- **SQLite**: Original relational database engine for lightweight, portable storage
- **PostgreSQL**: Production-grade database for analysis and querying
- **RSQLite + DBI + RPostgres**: R interfaces for database interaction
- **RMarkdown**: Reproducible workflow documentation
- **GitHub**: Version control and sharing

## 🗂️ Project Workflow
1. **Data Cleaning**
   - Handled duplicates, missing values, inconsistent formats
   - Re-coded categorical variables and standardized text fields
   - Scripts: `Rmd files/database_cleaning.Rmd`

2. **Schema Design & Normalization**
   - Created separate tables for `communities`, `outlets`, and `stories`
   - Foreign keys link stories to outlets and outlets to communities
   - Schema: `SQL scripts/create_tables.sql`

3. **Data Loading**
   - Built and populated the SQLite database using R and `RSQLite`
   - Script: `Rmd files/load_data.Rmd`

4. **Migration to PostgreSQL**
   - Audited and cleaned data prior to migration, including recovering missing foreign keys and resolving data type inconsistencies
   - Migrated from SQLite to PostgreSQL with enforced constraints, proper data types, and validated foreign key relationships
   - Scripts: `Rmd files/postgres_migration_cleaning.Rmd`, `Rmd files/sqlite_postgres_migration.Rmd`

5. **Exploration & Querying**
   - Sample SQL queries used to explore story counts, outlet types, and coverage across locations

6. **Market Analyses**  (In Progress)
   - Market Concentration in Local News: Which communities are underserved relative to their peers, and does outlet type explain it?
   - Coverage Gaps in Local News: Which critical information needs are going unmet in local communities, and which outlet types are filling — or 
     failing to fill — them?
   - Outlet Type Distribution Across Market Sizes: How does the mix of outlet types vary across community sizes, and where do opportunities exist       for new entrants?

## 📁 Repo Structure
local_news_100_communities/  
├── data/  
│   ├── raw/                          # Original source files  
│   └── processed/                    # Cleaned, final CSVs  
├── Rmd files/  
│   ├── database_cleaning.Rmd  
│   ├── load_data.Rmd  
│   ├── postgres_migration_cleaning.Rmd  
│   └── sqlite_postgres_migration.Rmd  
├── local_news_100_communities.db  
├── SQL scripts/   
│   └── create_tables.sql  
|   └── market_analysis_1.sql  
└── README.md

## 🔍 Example Query
```sql
-- Number of stories per community
SELECT c.city, c.state, COUNT(s.story_id) AS story_count
FROM stories s
JOIN outlets o ON s.outlet_id = o.outlet_id
JOIN communities c ON o.community_id = c.community_id
GROUP BY c.city, c.state
ORDER BY story_count DESC;
```

## 📝 License & Attribution
Dataset originally from [Who's Producing Local Journalism?](https://github.com/jessmahone/local_news_100_communities/blob/main/Whos%20Producing%20Local%20Journalism_FINAL.pdf)

👤 Author
Jessica Mahone, Ph.D.  
Researcher turned Analytics Engineer  
📧 [jessmahonecodes@gmail.com](mailto:jessmahonecodes@gmail.com)  
🔗 [LinkedIn](https://www.linkedin.com/in/jessica-mahone/)
