select a.agent_number,a.display_name, a.agent_type,a.agent_id as source_agent_id,a.client_id as source_agent_client_id,
a.national_producer_number,a.nasd_finra_number,a.hire_date,a.termination_date,a.status,
case when a.start_timestamp < a.effective_timestamp then a.start_timestamp
else a.effective_timestamp end as effective_timestamp,
case when a.end_timestamp < a.expiration_timestamp then a.end_timestamp
else a.expiration_timestamp end as expiration_timestamp
from silver_s2.agent_base_current a 
left join silver_s2.client_base_current cb
on a.client_id = cb.client_id;