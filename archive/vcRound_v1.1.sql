with deal_info as (
	select 	deal_id
			,co_id
			,deal_vintage
			,deal_number
			,deal_series
			,deal_vc_round
			,case 
				when substring(deal_vc_round, 1, 1) != 'A' then substring(deal_vc_round, 1, 1)::numeric
				when deal_vc_round isnull then null
				else 0
			end deal_vc_round_int
			,log(deal_size + 0.0001) deal_size
	from pitchbook.deals d
),

/*
select 	*
from	deal_info
where	deal_vc_round notnull
order by co_id, deal_vc_round_int;
*/

emp_hist as (
select 	co_id
		,co_primary_industry_sector 
		,co_verticals
		,split_part(unnest(co_employee_hist), ': ', 1)::numeric emp_cnt_yr
		,log(split_part(unnest(co_employee_hist), ': ', 2)::numeric + 0.001) emp_cnt
from	pitchbook.employee_hist eh
)

select	d.*
		,e.co_primary_industry_sector
		,e.co_verticals
		,e.emp_cnt_yr
		,e.emp_cnt
from	deal_info d
left join emp_hist e on e.co_id = d.co_id and e.emp_cnt_yr = d.deal_vintage
order by co_id, deal_vintage;