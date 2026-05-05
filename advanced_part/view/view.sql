create or replace view benchmark.v_experiment_details as
select 
    r.id as run_id,
    p.name as project_name,
    u.username as researcher,
    a.name as algorithm,
    f.name as objective_function,
    r.status,
    r.total_time_seconds,
    r.start_time
from benchmark.experiment_runs r
join benchmark.projects p on r.project_id = p.id
join benchmark.users u on r.user_id = u.id
join benchmark.algorithms a on r.algorithm_id = a.id
join benchmark.objective_functions f on r.function_id = f.id;

-- не материализовано для актуальности данных и так как не выполняется сложных агр. функций

drop materialized view if exists benchmark.mv_algo_benchmarks;

create materialized view benchmark.mv_algo_benchmarks as
select 
    a.name as algorithm_name,
    count(r.id) as total_runs,
    round(avg(r.total_time_seconds)::numeric, 2) as avg_execution_time,
    max(r.total_oracle_calls) as max_oracle_load
from benchmark.algorithms a
join benchmark.experiment_runs r on a.id = r.algorithm_id
where r.status = 'completed'
group by a.id, a.name;

-- материализовано так как требуется вычисление сложной функции

-- для ускорения работы с представлением индекс
create index idx_mv_algo_name on benchmark.mv_algo_benchmarks(algorithm_name);

select * from benchmark.v_experiment_details 
where status = 'completed' 
order by total_time_seconds asc;

select * from benchmark.mv_algo_benchmarks 
where total_runs > 0 
order by avg_execution_time asc;