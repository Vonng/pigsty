-------------------------------------------------------------------------
-- 放置于SCHEMA covid 下
-------------------------------------------------------------------------
DROP SCHEMA IF EXISTS covid CASCADE;
CREATE SCHEMA IF NOT EXISTS covid;
SET search_path TO covid,public;

DROP TABLE IF EXISTS covid.country_history;
CREATE TABLE covid.country_history
(
    date         DATE,
    country_code VARCHAR(2) NOT NULL,
    country      TEXT,
    who_region   TEXT,
    new_cases    INTEGER,
    cum_cases    INTEGER,
    new_death    INTEGER,
    cum_death    INTEGER,
    PRIMARY KEY (date, country_code)
);
COMMENT ON TABLE covid.country_history IS 'WHO Coronavirus Disease (COVID-19) Historic Data by country';

CREATE INDEX ON covid.country_history (date);
CREATE INDEX ON covid.country_history (country_code);
CREATE INDEX ON covid.country_history (date, country_code);


CREATE TABLE covid.country_latest
(
    name              text PRIMARY KEY,
    who_region        text,
    cum_cases         NUMERIC,
    cum_cases_ratio   NUMERIC,
    new_cases_7       NUMERIC,
    new_cases_7_ratio NUMERIC,
    new_cases_1       NUMERIC,
    cum_death         NUMERIC,
    cum_death_ratio   NUMERIC,
    new_death_7       NUMERIC,
    new_death_7_ratio NUMERIC,
    new_death_1       NUMERIC,
    trans_class       text
);

COMMENT ON TABLE covid.country_latest IS 'WHO Coronavirus Disease (COVID-19) Latest Data by country';

COMMENT ON COLUMN covid.country_history.date IS 'date';
COMMENT ON COLUMN covid.country_history.country_code IS 'country code in 2 char';
COMMENT ON COLUMN covid.country_history.country IS 'country name (english)';
COMMENT ON COLUMN covid.country_history.who_region IS 'WHO region';
COMMENT ON COLUMN covid.country_history.new_cases IS 'newly increased cases';
COMMENT ON COLUMN covid.country_history.cum_cases IS 'cumulative cases';
COMMENT ON COLUMN covid.country_history.new_death IS 'newly increased cases';
COMMENT ON COLUMN covid.country_history.cum_death IS 'cumulative death';
COMMENT ON COLUMN covid.country_latest.name IS 'country name';
COMMENT ON COLUMN covid.country_latest.who_region IS 'who region';
COMMENT ON COLUMN covid.country_latest.cum_cases IS 'cumulative total cases';
COMMENT ON COLUMN covid.country_latest.cum_cases_ratio IS 'cumulative total cases per 100k population';
COMMENT ON COLUMN covid.country_latest.new_cases_7 IS 'newly reported cases in last 7 days';
COMMENT ON COLUMN covid.country_latest.new_cases_7_ratio IS 'newly reported cases in last 7 days per 100k population';
COMMENT ON COLUMN covid.country_latest.new_cases_1 IS 'newly reported cases in last 24h';
COMMENT ON COLUMN covid.country_latest.cum_death IS 'cumulative death';
COMMENT ON COLUMN covid.country_latest.cum_death_ratio IS 'cumulative death per 100k population';
COMMENT ON COLUMN covid.country_latest.new_death_7 IS 'newly reported death in 7 days';
COMMENT ON COLUMN covid.country_latest.new_death_7_ratio IS 'cumulative death per 100k population';
COMMENT ON COLUMN covid.country_latest.new_death_1 IS 'newly reported death in last 24h';
COMMENT ON COLUMN covid.country_latest.trans_class IS 'transmission class';


-- COPY covid.country_history FROM 'data/history.csv' CSV HEADER;
-- COPY covid.country_latest  FROM 'data/latest.csv' CSV HEADER;