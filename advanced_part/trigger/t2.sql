create or replace function benchmark.protect_completed_runs()
returns trigger 
language plpgsql
as $$
begin
    if old.status = 'completed' then
        raise exception 'удаление запрещено';
    end if;

    return old;
end;
$$;

drop trigger if exists trg_protect_completed on benchmark.experiment_runs;

create trigger trg_protect_completed
before delete on benchmark.experiment_runs
for each row
execute function benchmark.protect_completed_runs();


-- проверка
insert into benchmark.experiment_runs (
    id, status, start_time, project_id, user_id, algorithm_id, function_id, oracle_id, config_id
) 
values (
    9004, 'completed', current_timestamp, 1, 1, 1, 1, 1, 1
)
on conflict do nothing;

delete from benchmark.experiment_runs where id = 9004;