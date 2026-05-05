CREATE TABLE "users" (
  "id" SERIAL PRIMARY KEY,
  "username" varchar UNIQUE NOT NULL,
  "email" varchar UNIQUE
);

CREATE TABLE "projects" (
  "id" SERIAL PRIMARY KEY,
  "name" varchar NOT NULL,
  "description" text,
  "user_id" integer
);

CREATE TABLE "datasets" (
  "id" SERIAL PRIMARY KEY,
  "name" varchar NOT NULL,
  "file_path" varchar,
  "n_samples" integer CHECK ("n_samples" > 0),
  "n_features" integer CHECK ("n_features" > 0),
  "author_id" integer
);

CREATE TABLE "objective_functions" (
  "id" SERIAL PRIMARY KEY,
  "name" varchar NOT NULL,
  "dimension" integer NOT NULL CHECK ("dimension" > 0),
  "is_convex" boolean DEFAULT false,
  "mu_strong_convexity" float CHECK ("mu_strong_convexity" >= 0),
  "lipschitz_l" float CHECK ("lipschitz_l" > 0),
  "optimal_value" float,
  "formula_latex" text,
  "dataset_id" integer,
  "author_id" integer
);

CREATE TABLE "algorithms" (
  "id" SERIAL PRIMARY KEY,
  "name" varchar NOT NULL,
  "description" text,
  "author_id" integer
);

CREATE TABLE "oracles" (
  "id" SERIAL PRIMARY KEY,
  "name" varchar NOT NULL,
  "oracle_type" varchar NOT NULL,
  "batch_size" integer CHECK ("batch_size" > 0),
  "noise_variance" float CHECK ("noise_variance" >= 0),
  "author_id" integer
);

CREATE TABLE "environments" (
  "id" SERIAL PRIMARY KEY,
  "name" varchar NOT NULL,
  "hardware_type" varchar,
  "precision" varchar,
  "author_id" integer
);

CREATE TABLE "experiment_configs" (
  "id" SERIAL PRIMARY KEY,
  "max_iterations" integer NOT NULL CHECK ("max_iterations" > 0),
  "tolerance_epsilon" float CHECK ("tolerance_epsilon" >= 0),
  "init_seed" integer,
  "init_strategy" varchar,
  "hyperparameters" jsonb NOT NULL,
  "author_id" integer
);

CREATE TABLE "experiment_runs" (
  "id" SERIAL PRIMARY KEY,
  "status" varchar NOT NULL DEFAULT 'pending' CHECK ("status" IN ('pending', 'running', 'completed', 'failed')),
  "project_id" integer,
  "user_id" integer,
  "algorithm_id" integer NOT NULL,
  "function_id" integer NOT NULL,
  "oracle_id" integer NOT NULL,
  "config_id" integer NOT NULL,
  "environment_id" integer,
  "start_time" timestamp,
  "end_time" timestamp,
  "total_time_seconds" float CHECK ("total_time_seconds" >= 0),
  "total_oracle_calls" integer CHECK ("total_oracle_calls" >= 0)
);

CREATE TABLE "iteration_logs" (
  "id" SERIAL PRIMARY KEY,
  "run_id" integer NOT NULL,
  "iteration_number" integer NOT NULL CHECK ("iteration_number" >= 0),
  "f_value" float NOT NULL,
  "grad_norm" float NOT NULL CHECK ("grad_norm" >= 0),
  "step_size" float NOT NULL,
  "oracle_calls_so_far" integer NOT NULL CHECK ("oracle_calls_so_far" >= 0)
);

ALTER TABLE "projects" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE SET NULL;
ALTER TABLE "datasets" ADD FOREIGN KEY ("author_id") REFERENCES "users" ("id") ON DELETE SET NULL;
ALTER TABLE "objective_functions" ADD FOREIGN KEY ("dataset_id") REFERENCES "datasets" ("id") ON DELETE SET NULL;
ALTER TABLE "objective_functions" ADD FOREIGN KEY ("author_id") REFERENCES "users" ("id") ON DELETE SET NULL;
ALTER TABLE "algorithms" ADD FOREIGN KEY ("author_id") REFERENCES "users" ("id") ON DELETE SET NULL;
ALTER TABLE "oracles" ADD FOREIGN KEY ("author_id") REFERENCES "users" ("id") ON DELETE SET NULL;
ALTER TABLE "environments" ADD FOREIGN KEY ("author_id") REFERENCES "users" ("id") ON DELETE SET NULL;
ALTER TABLE "experiment_configs" ADD FOREIGN KEY ("author_id") REFERENCES "users" ("id") ON DELETE SET NULL;

ALTER TABLE "experiment_runs" ADD FOREIGN KEY ("project_id") REFERENCES "projects" ("id") ON DELETE CASCADE;
ALTER TABLE "experiment_runs" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE SET NULL;
ALTER TABLE "experiment_runs" ADD FOREIGN KEY ("algorithm_id") REFERENCES "algorithms" ("id") ON DELETE RESTRICT;
ALTER TABLE "experiment_runs" ADD FOREIGN KEY ("function_id") REFERENCES "objective_functions" ("id") ON DELETE RESTRICT;
ALTER TABLE "experiment_runs" ADD FOREIGN KEY ("oracle_id") REFERENCES "oracles" ("id") ON DELETE RESTRICT;
ALTER TABLE "experiment_runs" ADD FOREIGN KEY ("config_id") REFERENCES "experiment_configs" ("id") ON DELETE RESTRICT;
ALTER TABLE "experiment_runs" ADD FOREIGN KEY ("environment_id") REFERENCES "environments" ("id") ON DELETE SET NULL;

ALTER TABLE "iteration_logs" ADD FOREIGN KEY ("run_id") REFERENCES "experiment_runs" ("id") ON DELETE CASCADE;
