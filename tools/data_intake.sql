/*
data_intake.sql
Author: Zeezee
Date: 05/10/2022

A file that will create a database, schema, and tables for the sample pitchbook data.
All data was ingested originally using PosgreSQL.
*/


-- drop database if currently exists
DROP DATABASE if exists pitchbook_data;
DROP SCHEMA if exists pitchbook;
DROP TABLE if exists deals;
DROP TABLE if exists employee_hist;
DROP TABLE if exists companies;

-- create new database for data
CREATE DATABASE pitchbook_data ENCODING 'UTF8';

-- connect to database
-- NOTE: Only works on LOCAL clients
\c pitchbook_data;

-- create new database for local files
CREATE SCHEMA pitchbook;

-- create DEALS table
CREATE TABLE pitchbook.deals (
    deal_id text,
    co_id text,
    co_name text,
    co_hq text,
    co_city text,
    co_state text,
    co_verticals text[],
    deal_date date,
    deal_vintage double precision,
    deal_number bigint,
    deal_series text,
    deal_vc_round text,
    deal_type text,
    deal_premoney double precision,
    deal_postmoney double precision,
    deal_size double precision,
    deal_pct_acq double precision,
    deal_investor_count double precision,
    investor_id text[],
    investor_name text[],
    investor_gp_id text[],
    investor_gp text[],
    fund_id text[],
    fund_name text[]
);

-- create COMPANIES table
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

-- Create EMPLOYEE HIST table
CREATE TABLE pitchbook.employee_hist (
    co_id text,
    co_name text,
    co_ticker text,
    co_city text,
    co_state text,
    co_year_founded bigint,
    co_business_status text,
    co_financing_status text,
    co_ownership_status text,
    co_primary_industry text,
    co_primary_industry_group text,
    co_primary_industry_sector text,
    co_industries text[],
    co_verticals text[],
    co_keywords text[],
    co_description text,
    co_employee_hist text[]
);


-- COPY data
-- NOTE: Relative path from human_capital_flows_project/tools'
\COPY pitchbook.deals FROM '../data/deals_sample.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
\COPY pitchbook.companies FROM '../data/companies_sample.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
\COPY pitchbook.employee_hist FROM '../data/employeeHistory_sample.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';

-- set universal encoding standard
SET client_encoding TO 'UTF8';