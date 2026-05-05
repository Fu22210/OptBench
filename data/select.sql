SET search_path TO benchmark;

select 
a.name as algorithm_name, 
count(r.id) as total_successful_runs, 
round(AVG(r.total_time_seconds)::numeric, 2) as avg_time_seconds
from experiment_runs r
join algorithms a on r.algorithm_id = a.id
where r.status = 'completed'
group by a.id, a.name
order by avg_time_seconds asc;

select
r.id as run_id,
a.name as algorithm,
(c.hyperparameters->>'lr')::float AS learning_rate
from experiment_runs r
join experiment_configs c on r.config_id = c.id
join algorithms a on r.algorithm_id = a.id
where c.hyperparameters ? 'lr' and (c.hyperparameters->>'lr')::float < 0.05;


select
p.name as project_name,
a.name as algorithm_name,
r.total_time_seconds
from experiment_runs r
join projects p ON r.project_id = p.id
join algorithms a ON r.algorithm_id = a.id
where r.status = 'completed';

select 
name as dataset_name, 
n_samples, 
n_features,
round((n_samples::numeric / n_features), 2) as samples_per_feature_ratio
from datasets
where n_samples is not null and n_features is not null
order by samples_per_feature_ratio desc;

select 
run_id, 
iteration_number, 
f_value, 
grad_norm
from iteration_logs
where grad_norm between 10.0 and 50.0
order by run_id, iteration_number;

select 
u.username,
count(r.id) as total_runs,
count(r.id) filter (where r.status = 'completed') as completed_runs,
count(r.id) filter (where r.status = 'failed') as failed_runs,
count(r.id) filter (where r.status = 'running') as running_runs
from users u 
join experiment_runs r on u.id = r.user_id
group by u.username 
order by total_runs desc;

# на чем не запускались
select 
e.name as environment_name, 
e.hardware_type
from environments e
left join experiment_runs r on e.id = r.environment_id
where r.id is null;

select
r.id as run_id, 
a.name as algorithm, 
min(l.f_value) as best_f_value
from experiment_runs r
join algorithms a on r.algorithm_id = a.id
join iteration_logs l on r.id = l.run_id
where r.status = 'completed'
group by r.id, a.name
order by best_f_value

select  
p.name as project_name, 
string_agg(distinct a.name, ', ') as used_algorithms
from projects p
join experiment_runs r on p.id = r.project_id
join algorithms a on r.algorithm_id = a.id
group by p.name;

select 
name as oracle_name, 
oracle_type, 
noise_variance
from oracles
where noise_variance > 0
order by noise_variance desc;

