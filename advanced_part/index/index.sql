create index if not exists idx_configs_hyperparameters_gin 
on benchmark.experiment_configs using gin (hyperparameters);

-- GIN работает как b-tree но ссылается на пачку значений

create index if not exists idx_iteration_logs_grad_norm 
on benchmark.iteration_logs using btree (grad_norm);

create index if not exists idx_runs_status_completed 
on benchmark.experiment_runs (status) 
where status = 'completed'
using hash (status);

-- будет хранить заверешенные раны


		