# 100 Communities Local News Database (SQLite Version)

Creating and exploring a database of journalism sources and content in 100 U.S. communities using R and SQLite.

This project involved cleaning, normalizing, and analyzing a dataset of over 16,000 local news stories to build a structured, queryable database for deeper insights into the state of U.S. local journalism. It's part of my portfolio to demonstrate my data wrangling, SQL, and data integration skills.

## 🚀 Motivation

This project began as part of my work at the DeWitt Wallace Center for Media and Democracy and reflects my interest in transforming messy, real-world data into structured insights that support decision-making in media and beyond. Local news data is often fragmented and hard to analyze at scale; this project demonstrates how raw content data can be structured for strategic insight.

## 🧰 Tools & Technologies

- **R**: Data cleaning, transformation, and database interaction
- **SQLite**: Relational database engine for lightweight, portable storage
- **RSQLite + DBI**: Interface to connect R with SQLite
- **RMarkdown**: Reproducible workflow documentation
- **GitHub**: Version control and sharing

## 🗂️ Project Workflow

1. **Data Cleaning**  
   - Handled duplicates, missing values, inconsistent formats
   - Re-coded categorical variables and standardized text fields
   - Scripts: `database_cleaning.Rmd`

2. **Schema Design & Normalization**  
   - Created separate tables for `communities`, `outlets`, and `stories`
   - Foreign keys link stories to both communities and outlets
   - Schema: `create_tables.sql`

3. **Data Loading**  
   - Built and populated the database using R and `RSQLite`
   - Script: `load_data.Rmd`

4. **Exploration & Querying**  
   - Sample SQL queries used to explore story counts, outlet types, and coverage across locations

## 📁 Repo Structure

local_news_100_communities/  
├── data/  
 │ ├── raw/ # Original source files  
 │ └── processed/ # Cleaned, final CSVs  
├── local_news_100_communities.db  
├── create_tables.sql  
├── database_cleaning.Rmd  
├── load_data.Rmd  
├── README.md


## 🔍 Example Query

```sql
-- Number of stories per community
SELECT c.community_name, COUNT(s.story_id) AS story_count
FROM stories s
JOIN communities c ON s.community_id = c.community_id
GROUP BY c.community_name
ORDER BY story_count DESC;
```

## 📝 License & Attribution
Dataset originally from [Who’s Producing Local Journalism?](https://github.com/jessmahone/local_news_100_communities/blob/main/Whos%20Producing%20Local%20Journalism_FINAL.pdf)


👤 Author
Jessica Mahone, Ph.D.  
Analytics Engineer/Content Insights Architect | Media & Tech Research  
📧 [jessmahonecodes@gmail.com](mailto:jessmahonecodes@gmail.com)  
🔗 [LinkedIn](https://www.linkedin.com/in/jessica-mahone/)
