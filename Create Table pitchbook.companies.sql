-- DDL generated by Postico 1.5.20
-- Not all database features are supported. Do not use for backup.

-- Table Definition ----------------------------------------------

CREATE TABLE pitchbook.companies (
    co_id text,
    co_name text,
    co_hq text,
    co_city text,
    co_state text,
    co_year_founded bigint,
    co_revenue double precision,
    co_business_status text,
    co_financing_status text,
    co_ownership_status text,
    co_primary_industry text,
    co_primary_industry_group text,
    co_primary_industry_sector text,
    co_industries text[],
    co_verticals text[],
    co_keywords text[],
    co_description text
);

