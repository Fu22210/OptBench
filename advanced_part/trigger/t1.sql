create or replace function benchmark.check_run_limit()
returns trigger 
language plpgsql
as $$
declare
    v_running_count int;
begin
    if new.status != 'running' then
        return new;
    end if;

    select count(*) into v_running_count
    from benchmark.experiment_runs
    where user_id = new.user_id and status = 'running';

    if v_running_count >= 2 then
        raise exception 'Сервер перегружен';
    end if;

    return new;
end;
$$;

drop trigger if exists trg_limit_runs on benchmark.experiment_runs;

create trigger trg_limit_runs
before insert or update on benchmark.experiment_runs
for each row
execute function benchmark.check_run_limit();


-- проверка
delete from benchmark.experiment_runs where id in (9001, 9002, 9003);

select count(*) from benchmark.experiment_runs
where status = 'running';

insert into benchmark.experiment_runs (id, status, start_time, project_id, user_id, algorithm_id, function_id) 
values (9001, 'running', current_timestamp, 1, 1, 1, 1);

insert into benchmark.experiment_runs (id, status, start_time, project_id, user_id, algorithm_id, function_id) 
values (9002, 'running', current_timestamp, 1, 1, 1, 1);

insert into benchmark.experiment_runs (id, status, start_time, project_id, user_id, algorithm_id, function_id) 
values (9003, 'running', current_timestamp, 1, 1, 1, 1);

delete from benchmark.experiment_runs where id in (9001, 9002);