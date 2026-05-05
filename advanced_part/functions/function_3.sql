create or replace procedure benchmark.restart_failed_experiments(p_project_id int)
language plpgsql
as $$
declare
    v_updated_count int;
begin
    update benchmark.experiment_runs
    set status = 'running',
        start_time = null,
        end_time = null,
        total_time_seconds = null
    where project_id = p_project_id 
      and status = 'failed';

    get diagnostics v_updated_count = row_count;
    
    raise notice 'успешно сброшено экспериментов для перезапуска %', v_updated_count;
end;
$$;

call benchmark.restart_failed_experiments(2);