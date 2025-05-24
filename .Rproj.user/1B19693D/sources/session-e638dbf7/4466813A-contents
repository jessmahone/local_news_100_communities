-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

PRAGMA foreign_keys = ON;

CREATE TABLE communities (
  community_id INTEGER PRIMARY KEY,
  city TEXT,
  state TEXT,
  population INTEGER,
  area_sqm REAL,
  density_pop_per_sqm REAL,
  closest_large_media_market TEXT,
  distance_from_lmm INTEGER,
  pct_white REAL,
  pct_black REAL,
  pct_hislat REAL,
  universities_count INTEGER,
  county_seat TEXT,
  state_capital TEXT
);

CREATE TABLE outlets (
  outlet_id INTEGER PRIMARY KEY,
  outlet_name TEXT,
  url TEXT,
  outlet_type TEXT,
  community_id INTEGER,
  FOREIGN KEY (community_id) REFERENCES communities(community_id)
);

CREATE TABLE stories(
  story_id INTEGER PRIMARY KEY,
  publication_date DATE,
  headline TEXT,
  outlet_id INTEGER,
  original TEXT,
  local TEXT,
  critical_info_need TEXT,
  community_id INTEGER,
  FOREIGN KEY (outlet_id) REFERENCES outlets(outlet_id),
  FOREIGN KEY (community_id) REFERENCES communities(community_id)
);
