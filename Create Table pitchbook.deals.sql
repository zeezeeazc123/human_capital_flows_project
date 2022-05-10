-- DDL generated by Postico 1.5.20
-- Not all database features are supported. Do not use for backup.

-- Table Definition ----------------------------------------------

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
    deal_investor_count bigint,
    investor_id text[],
    investor_name text[],
    investor_gp_id text[],
    investor_gp text[],
    fund_id text[],
    fund_name text[]
);
