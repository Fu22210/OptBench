create extension if not exists plpython3u;

create or replace function benchmark.analyze_loss_curve(p_run_id int)
returns text
language plpython3u
as $$
    query = f"select f_value from benchmark.iteration_logs where run_id = {p_run_id} order by iteration_number"
    rv = plpy.execute(query)
    
    if len(rv) < 3:
        return "not enough data"
        
    losses = [row['f_value'] for row in rv]
    
    if losses[-1] > losses[0] * 2:
        return "расходится"
        
    increases = sum(1 for i in range(1, len(losses)) if losses[i] > losses[i-1])
    oscillation_rate = increases / len(losses)
    
    if oscillation_rate > 0.3:
        return f"колеблется, шум = {oscillation_rate}"
        
    return "плавно сходится"
$$;

select id, benchmark.analyze_loss_curve(id) from benchmark.experiment_runs;