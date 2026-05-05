create or replace function benchmark.get_algorithm_success_rate(p_algorithm_id int)
returns numeric
language plpgsql
as $$
declare
    v_total int;
    v_success int;
begin
    select count(*) into v_total
    from benchmark.experiment_runs
    where algorithm_id = p_algorithm_id;

    if v_total = 0 then
        return 0.00;
    end if;

    select count(*) into v_success
    from benchmark.experiment_runs
    where algorithm_id = p_algorithm_id and status = 'completed';

    return round((v_success::numeric / v_total::numeric) * 100, 2);
end;
$$;

select benchmark.get_algorithm_success_rate(4);