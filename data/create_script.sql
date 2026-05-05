CREATE SCHEMA IF NOT EXISTS benchmark;
SET search_path TO benchmark;

DROP TABLE IF EXISTS "iteration_logs" CASCADE;
DROP TABLE IF EXISTS "experiment_runs" CASCADE;
DROP TABLE IF EXISTS "experiment_configs" CASCADE;
DROP TABLE IF EXISTS "environments" CASCADE;
DROP TABLE IF EXISTS "oracles" CASCADE;
DROP TABLE IF EXISTS "algorithms" CASCADE;
DROP TABLE IF EXISTS "objective_functions" CASCADE;
DROP TABLE IF EXISTS "datasets" CASCADE;
DROP TABLE IF EXISTS "projects" CASCADE;
DROP TABLE IF EXISTS "users" CASCADE;

CREATE TABLE "users" (
    "id" SERIAL PRIMARY KEY, 
    "username" varchar UNIQUE NOT NULL, 
    "email" varchar UNIQUE
);

CREATE TABLE "projects" (
    "id" SERIAL PRIMARY KEY, 
    "name" varchar NOT NULL, 
    "description" text, 
    "user_id" integer REFERENCES "users"("id") ON DELETE SET NULL
);

CREATE TABLE "datasets" (
    "id" SERIAL PRIMARY KEY, 
    "name" varchar NOT NULL, 
    "file_path" varchar, 
    "n_samples" integer CHECK ("n_samples" > 0), 
    "n_features" integer CHECK ("n_features" > 0), 
    "author_id" integer REFERENCES "users"("id") ON DELETE SET NULL
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
    "dataset_id" integer REFERENCES "datasets"("id") ON DELETE SET NULL, 
    "author_id" integer REFERENCES "users"("id") ON DELETE SET NULL
);

CREATE TABLE "algorithms" (
    "id" SERIAL PRIMARY KEY, 
    "name" varchar NOT NULL, 
    "description" text, 
    "author_id" integer REFERENCES "users"("id") ON DELETE SET NULL
);

CREATE TABLE "oracles" (
    "id" SERIAL PRIMARY KEY, 
    "name" varchar NOT NULL, 
    "oracle_type" varchar NOT NULL, 
    "batch_size" integer CHECK ("batch_size" > 0), 
    "noise_variance" float CHECK ("noise_variance" >= 0), 
    "author_id" integer REFERENCES "users"("id") ON DELETE SET NULL
);

CREATE TABLE "environments" (
    "id" SERIAL PRIMARY KEY, 
    "name" varchar NOT NULL, 
    "hardware_type" varchar, 
    "precision" varchar, 
    "author_id" integer REFERENCES "users"("id") ON DELETE SET NULL
);

CREATE TABLE "experiment_configs" (
    "id" SERIAL PRIMARY KEY, 
    "max_iterations" integer NOT NULL CHECK ("max_iterations" > 0), 
    "tolerance_epsilon" float CHECK ("tolerance_epsilon" >= 0), 
    "init_seed" integer, 
    "init_strategy" varchar, 
    "hyperparameters" jsonb NOT NULL, 
    "author_id" integer REFERENCES "users"("id") ON DELETE SET NULL
);

CREATE TABLE "experiment_runs" (
    "id" SERIAL PRIMARY KEY, 
    "status" varchar NOT NULL DEFAULT 'pending' CHECK ("status" IN ('pending', 'running', 'completed', 'failed')), 
    "project_id" integer REFERENCES "projects"("id") ON DELETE CASCADE, 
    "user_id" integer REFERENCES "users"("id") ON DELETE SET NULL, 
    "algorithm_id" integer NOT NULL REFERENCES "algorithms"("id") ON DELETE RESTRICT, 
    "function_id" integer NOT NULL REFERENCES "objective_functions"("id") ON DELETE RESTRICT, 
    "oracle_id" integer NOT NULL REFERENCES "oracles"("id") ON DELETE RESTRICT, 
    "config_id" integer NOT NULL REFERENCES "experiment_configs"("id") ON DELETE RESTRICT, 
    "environment_id" integer REFERENCES "environments"("id") ON DELETE SET NULL, 
    "start_time" timestamp, 
    "end_time" timestamp, 
    "total_time_seconds" float CHECK ("total_time_seconds" >= 0), 
    "total_oracle_calls" integer CHECK ("total_oracle_calls" >= 0)
);

CREATE TABLE "iteration_logs" (
    "id" SERIAL PRIMARY KEY, 
    "run_id" integer NOT NULL REFERENCES "experiment_runs"("id") ON DELETE CASCADE, 
    "iteration_number" integer NOT[118;1:3u NULL CHECK ("iteration_number" >= 0), 
    "f_value" float NOT NULL, 
    "grad_norm" float NOT NULL CHECK ("grad_norm" >= 0), 
    "step_size" float NOT NULL, 
    "oracle_calls_so_far" integer NOT NULL CHECK ("oracle_calls_so_far" >= 0)
);

INSERT INTO "users" ("username", "email") VALUES 
    ('tkaryagin', 'timofey@mipt.ru'), ('alice_ml', 'alice@yandex.ru'), ('bob_researcher', 'bob@sber.ru'), 
    ('charlie_opt', 'charlie@gmail.com'), ('david_math', 'david@mit.edu'), ('eve_hacker', 'eve@stanford.edu'), 
    ('frank_dev', 'frank@mail.ru'), ('grace_ai', 'grace@google.com'), ('heidi_data', 'heidi@vk.com'), 
    ('ivan_ds', 'ivan@tinkoff.ru'), ('judy_science', 'judy@berkeley.edu'), ('kevin_sys', 'kevin@amazon.com'), 
    ('laura_stat', 'laura@cmu.edu'), ('mike_dl', 'mike@deepmind.com'), ('nina_cv', 'nina@openai.com'), 
    ('oscar_nlp', 'oscar@meta.com'), ('peggy_rl', 'peggy@mila.quebec'), ('quinn_eng', 'quinn@nvidia.com'), 
    ('rupert_arch', 'rupert@intel.com'), ('sybil_test', 'sybil@apple.com');

INSERT INTO "projects" ("name", "description", "user_id") VALUES 
    ('Курсовая 2026: (L0, L1)-гладкость', 'Исследование', 1), ('Сходимость Proximal SGD', 'Бенчмарк', 1), 
    ('SberDevices Task', 'GigaCode', 1), ('ШАД Подготовка', 'Алгебра', 1), 
    ('ImageNet ResNet50', 'Глубокие сети', 2), ('Transformer Finetuning', 'NLP', 2), 
    ('RL_Atari', 'RL', 3), ('Convex Opt', 'Теория', 4), ('Non-convex', 'Анализ', 5), 
    ('GAN stability', 'Генерация', 6), ('Diffusion', 'Score Matching', 7), ('Med Image', 'МРТ', 8), 
    ('Time Series', 'ARIMA', 9), ('RecSys', 'Факторизации', 10), ('GNNs', 'Соцсети', 11), 
    ('AutoML', 'Сравнение', 12), ('Fed Learning', 'Приватность', 13), ('QML', 'Кванты', 14), 
    ('Causal Inference', 'A/B', 15), ('Edge AI', 'Сжатие', 16);

INSERT INTO "datasets" ("name", "file_path", "n_samples", "n_features", "author_id") VALUES 
    ('a9a', '/data/a9a', 32561, 123, 1), ('w8a', '/data/w8a', 49749, 300, 1), 
    ('CIFAR-10', '/data/cifar', 60000, 3072, 2), ('MNIST', '/data/mnist', 70000, 784, 3), 
    ('ImageNet', '/data/imagenet', 1281167, 150528, 4), ('KDD99', '/data/kdd', 4898431, 41, 5), 
    ('HIGGS', '/data/higgs', 11000000, 28, 1), ('SUSY', '/data/susy', 5000000, 18, 1), 
    ('covtype', '/data/cov', 581012, 54, 6), ('phishing', '/data/phis', 11055, 68, 7), 
    ('mushrooms', '/data/mush', 8124, 112, 8), ('ijcnn1', '/data/ij', 49990, 22, 9), 
    ('news20', '/data/news', 19996, 1355191, 10), ('rcv1', '/data/rcv', 20242, 47236, 11), 
    ('real-sim', '/data/real', 72309, 20958, 12), ('epsilon', '/data/eps', 400000, 2000, 13), 
    ('URL', '/data/url', 2396130, 3231961, 14), ('SVHN', '/data/svhn', 73257, 3072, 15), 
    ('F-MNIST', '/data/fmnist', 70000, 784, 16), ('IMDB', '/data/imdb', 50000, 10000, 17);

INSERT INTO "objective_functions" ("name", "dimension", "is_convex", "mu_strong_convexity", "lipschitz_l", "dataset_id", "author_id") VALUES 
    ('LogReg_a9a', 123, true, 0.01, 0.25, 1, 1), ('LogReg_w8a', 300, true, 0.0, 0.25, 2, 1), 
    ('LinReg_HIGGS', 28, true, 0.0, 10.5, 7, 1), ('SVM_cov', 54, true, 0.1, 1.0, 9, 2), 
    ('Rosen_2D', 2, false, 0.0, 100.0, NULL, 3), ('Rosen_100D', 100, false, 0.0, 1000.0, NULL, 4), 
    ('Rastrigin', 10, false, 0.0, 50.0, NULL, 5), ('Ackley', 5, false, 0.0, 20.0, NULL, 6), 
    ('LogReg_ijcnn', 22, true, 0.001, 0.25, 12, 7), ('ResNet18', 11173962, false, 0.0, 1000.0, 3, 8), 
    ('MLP_MNIST', 100500, false, 0.0, 50.0, 4, 9), ('Beale', 2, false, 0.0, 15.0, NULL, 10), 
    ('Booth', 2, true, 2.0, 10.0, NULL, 11), ('Bukin', 2, false, 0.0, 100.0, NULL, 12), 
    ('CrossInTray', 2, false, 0.0, 50.0, NULL, 13), ('Easom', 2, false, 0.0, 10.0, NULL, 14), 
    ('Eggholder', 2, false, 0.0, 1000.0, NULL, 15), ('Goldstein', 2, false, 0.0, 1000.0, NULL, 16), 
    ('Himmelblau', 2, false, 0.0, 50.0, NULL, 17), ('Matyas', 2, true, 0.26, 1.0, NULL, 18);

INSERT INTO "algorithms" ("name", "description", "author_id") VALUES 
    ('SGD', 'Stochastic', 1), ('Momentum', 'Heavy Ball', 1), ('Nesterov', 'NAG', 2), 
    ('Adam', 'Adaptive', 3), ('AdamW', 'Weight decay', 4), ('RMSprop', 'RMS', 5), 
    ('Adagrad', 'Ada', 6), ('Adadelta', 'Delta', 7), ('Nadam', 'Nesterov Adam', 8), 
    ('Proximal SGD', 'Prox', 1), ('FISTA', 'Fast ISTA', 9), ('ISTA', 'ISTA', 10), 
    ('L-BFGS', 'Quasi-Newton', 11), ('BFGS', 'Full BFGS', 12), ('Newton-CG', 'Hessian-free', 13), 
    ('SAGA', 'Variance reduction', 14), ('SVRG', 'SVRG', 15), ('SARAH', 'SARAH', 16), 
    ('Katyusha', 'Accelerated', 17), ('SPIDER', 'SPIDER', 18);

INSERT INTO "oracles" ("name", "oracle_type", "batch_size", "noise_variance", "author_id") VALUES 
    ('Exact', 'exact', NULL, 0.0, 1), ('SGD_1', 'stochastic', 1, 1.0, 1), 
    ('SGD_10', 'stochastic', 10, 0.1, 2), ('SGD_32', 'stochastic', 32, 0.05, 3), 
    ('SGD_64', 'stochastic', 64, 0.02, 4), ('SGD_128', 'stochastic', 128, 0.01, 5), 
    ('SGD_256', 'stochastic', 256, 0.005, 6), ('TopK_1', 'compressed', 32, 0.0, 7), 
    ('TopK_10', 'compressed', 32, 0.0, 8), ('RandK_5', 'compressed', 64, 0.1, 9), 
    ('Gauss_High', 'stochastic', NULL, 5.0, 10), ('Gauss_Low', 'stochastic', NULL, 0.1, 11), 
    ('Zero_2pt', 'stochastic', NULL, 0.5, 12), ('Zero_1pt', 'stochastic', NULL, 1.0, 13), 
    ('Mini_1024', 'stochastic', 1024, 0.001, 14), ('Mini_2048', 'stochastic', 2048, 0.0005, 15), 
    ('EF21', 'compressed', 128, 0.0, 1), ('Diana', 'compressed', 128, 0.5, 16), 
    ('Exact_Hess', 'exact', NULL, 0.0, 17), ('Sub_Hess', 'stochastic', 512, 0.2, 18);

INSERT INTO "environments" ("name", "hardware_type", "precision", "author_id") VALUES 
    ('Mac', 'CPU', 'float64', 1), ('Node1', 'CPU', 'float64', 1), ('T4', 'GPU', 'float32', 2), 
    ('Colab', 'GPU', 'float32', 3), ('V100', 'GPU', 'float32', 4), ('A100', 'GPU', 'float32', 5), 
    ('AWS_V100', 'GPU', 'float32', 6), ('AWS_A100', 'GPU', 'float16', 7), ('GCP', 'CPU', 'float64', 8), 
    ('Yandex', 'CPU', 'float64', 9), ('DataSphere', 'GPU', 'float32', 10), ('DGX', 'GPU', 'float64', 11), 
    ('RTX3090', 'GPU', 'float32', 12), ('RTX4090', 'GPU', 'float32', 13), ('TPUv2', 'TPU', 'bfloat16', 14), 
    ('TPUv3', 'TPU', 'bfloat16', 15), ('MI250', 'GPU', 'float32', 16), ('Xeon', 'CPU', 'float64', 17), 
    ('Pi4', 'CPU', 'float32', 18), ('MIPT', 'GPU', 'float64', 1);

INSERT INTO "experiment_configs" ("max_iterations", "tolerance_epsilon", "init_seed", "init_strategy", "hyperparameters", "author_id") VALUES 
    (10000, 1e-6, 42, 'zeros', '{"lr": 0.01}', 1), (50000, 1e-8, 42, 'random', '{"lr": 0.001}', 1), 
    (10000, 1e-5, 123, 'random', '{"lr": 0.05}', 2), (100000, 1e-7, 777, 'zeros', '{"lr_strategy": "armijo"}', 3), 
    (2000, 1e-4, NULL, 'ones', '{"lr": 0.1}', 4), (15000, 1e-6, 42, 'zeros', '{"lr": 0.005}', 5), 
    (500, 1e-8, 0, 'random', '{"history_size": 10}', 6), (100000, 1e-9, 42, 'zeros', '{"lr": 0.01}', 7), 
    (30000, 1e-6, 99, 'zeros', '{"lr": 0.2}', 8), (10000, 1e-5, 42, 'random', '{"lr": 0.001}', 9), 
    (1000, 1e-4, 1, 'zeros', '{"lr": 1.0}', 10), (50000, 1e-8, 42, 'random', '{"lr": 0.01}', 11), 
    (20000, 1e-7, 42, 'zeros', '{"lr": 0.05}', 12), (10000, 1e-5, 2026, 'random', '{"lr": 0.0001}', 13), 
    (5000, 1e-6, 42, 'zeros', '{"lr": 0.1}', 14), (100000, 1e-8, 1234, 'zeros', '{"lr": 0.02}', 15), 
    (50000, 1e-6, 42, 'random', '{"lr": 0.001}', 16), (25000, 1e-7, 0, 'zeros', '{"lr": 0.01}', 17), 
    (10000, 1e-5, 42, 'random', '{"lr": 0.1}', 18), (5000, 1e-6, 42, 'zeros', '{"lr": 0.05}', 19);

INSERT INTO "experiment_runs" 
("status", "project_id", "user_id", "algorithm_id", "function_id", "oracle_id", "config_id", "environment_id", "start_time", "end_time", "total_time_seconds", "total_oracle_calls") 
VALUES 
('completed', 1, 1, 1, 1, 2, 1, 1, '2026-04-12 10:00:00', '2026-04-12 10:05:12', 312.5, 10000),
('running', 1, 1, 4, 2, 8, 2, 2, '2026-04-12 11:00:00', NULL, NULL, 500),
('failed', 2, 1, 15, 5, 19, 4, 3, '2026-04-12 12:00:00', '2026-04-12 12:01:05', 65.2, 150),
('completed', 3, 1, 10, 10, 5, 6, 4, '2026-04-12 13:00:00', '2026-04-12 15:30:00', 9000.0, 15000),
('completed', 4, 1, 3, 3, 1, 11, 1, '2026-04-12 14:00:00', '2026-04-12 14:00:10', 10.1, 1000),
('completed', 5, 2, 1, 10, 5, 2, 5, '2026-04-11 09:00:00', '2026-04-11 18:00:00', 32400.0, 50000),
('running', 6, 2, 5, 11, 6, 3, 6, '2026-04-12 08:00:00', NULL, NULL, 45000),
('completed', 7, 3, 6, 9, 7, 10, 7, '2026-04-10 10:00:00', '2026-04-10 11:45:00', 6300.5, 10000),
('completed', 8, 4, 13, 6, 19, 12, 8, '2026-04-12 09:00:00', '2026-04-12 09:15:00', 900.0, 5000),
('failed', 9, 5, 2, 7, 11, 8, 9, '2026-04-12 10:30:00', '2026-04-12 10:31:00', 60.0, 100),
('completed', 10, 6, 4, 10, 15, 9, 10, '2026-04-11 20:00:00', '2026-04-11 23:30:00', 12600.0, 30000),
('completed', 11, 7, 7, 12, 12, 5, 11, '2026-04-12 11:15:00', '2026-04-12 11:20:00', 300.0, 2000),
('running', 12, 8, 8, 14, 14, 13, 12, '2026-04-12 12:45:00', NULL, NULL, 15000),
('completed', 13, 9, 9, 13, 3, 14, 13, '2026-04-12 07:00:00', '2026-04-12 07:10:00', 600.0, 10000),
('completed', 14, 10, 14, 15, 13, 7, 14, '2026-04-11 15:00:00', '2026-04-11 15:05:00', 300.0, 500),
('failed', 15, 11, 16, 16, 1, 15, 15, '2026-04-12 14:20:00', '2026-04-12 14:20:10', 10.0, 50),
('completed', 16, 12, 17, 17, 4, 18, 16, '2026-04-12 08:30:00', '2026-04-12 09:30:00', 3600.0, 25000),
('completed', 17, 13, 18, 18, 18, 17, 17, '2026-04-11 10:00:00', '2026-04-11 12:00:00', 7200.0, 50000),
('running', 18, 14, 19, 19, 17, 16, 18, '2026-04-12 13:10:00', NULL, NULL, 80000),
('completed', 19, 15, 20, 20, 20, 20, 19, '2026-04-12 09:00:00', '2026-04-12 09:45:00', 2700.0, 5000);


INSERT INTO "iteration_logs" ("run_id", "iteration_number", "f_value", "grad_norm", "step_size", "oracle_calls_so_far") VALUES 
(1, 0, 100.5, 50.2, 0.01, 1), (1, 100, 75.3, 30.1, 0.01, 101), (1, 200, 50.0, 15.5, 0.01, 201), (1, 300, 25.1, 5.2, 0.01, 301), (1, 400, 10.0, 0.5, 0.01, 401),
-- Run 2
(2, 0, 80.0, 40.0, 0.05, 1), (2, 100, 60.5, 25.0, 0.05, 101), (2, 200, 45.2, 18.2, 0.05, 201), (2, 300, 30.1, 10.0, 0.05, 301), (2, 400, 20.5, 6.1, 0.05, 401),
-- Run 3 (Failed - расходится)
(3, 0, 10.0, 5.0, 1.0, 1), (3, 10, 100.0, 50.0, 1.0, 11), (3, 20, 1000.0, 500.0, 1.0, 21), (3, 30, 10000.0, 5000.0, 1.0, 31), (3, 40, 100000.0, 50000.0, 1.0, 41),
-- Run 4
(4, 0, 120.0, 60.0, 0.001, 1), (4, 100, 90.0, 45.0, 0.001, 101), (4, 200, 65.0, 30.0, 0.001, 201), (4, 300, 40.0, 15.0, 0.001, 301), (4, 400, 20.0, 5.0, 0.001, 401),
-- Run 5
(5, 0, 50.0, 20.0, 0.1, 1), (5, 10, 25.0, 10.0, 0.1, 11), (5, 20, 12.5, 5.0, 0.1, 21), (5, 30, 6.2, 2.5, 0.1, 31), (5, 40, 3.1, 1.2, 0.1, 41),
-- Run 6
(6, 0, 2.3, 1.5, 0.01, 1), (6, 1000, 1.8, 1.0, 0.01, 1001), (6, 2000, 1.2, 0.7, 0.01, 2001), (6, 3000, 0.8, 0.4, 0.01, 3001), (6, 4000, 0.5, 0.2, 0.01, 4001),
-- Run 7
(7, 0, 5.0, 3.0, 0.005, 1), (7, 100, 4.2, 2.5, 0.005, 101), (7, 200, 3.5, 2.0, 0.005, 201), (7, 300, 2.9, 1.6, 0.005, 301), (7, 400, 2.4, 1.2, 0.005, 401),
-- Run 8
(8, 0, 15.0, 8.0, 0.02, 1), (8, 100, 10.0, 5.0, 0.02, 101), (8, 200, 6.5, 3.2, 0.02, 201), (8, 300, 4.0, 1.8, 0.02, 301), (8, 400, 2.5, 0.9, 0.02, 401),
-- Run 9
(9, 0, 100.0, 50.0, 0.01, 1), (9, 100, 50.0, 25.0, 0.01, 101), (9, 200, 25.0, 12.5, 0.01, 201), (9, 300, 12.5, 6.2, 0.01, 301), (9, 400, 6.2, 3.1, 0.01, 401),
-- Run 10 (Failed - NaN/Infinity simulation)
(10, 0, 10.0, 5.0, 0.5, 1), (10, 10, 50.0, 25.0, 0.5, 11), (10, 20, 250.0, 125.0, 0.5, 21), (10, 30, 1250.0, 625.0, 0.5, 31), (10, 40, 6250.0, 3125.0, 0.5, 41),
-- Run 11
(11, 0, 200.0, 100.0, 0.001, 1), (11, 100, 150.0, 75.0, 0.001, 101), (11, 200, 100.0, 50.0, 0.001, 201), (11, 300, 50.0, 25.0, 0.001, 301), (11, 400, 25.0, 12.5, 0.001, 401),
-- Run 12
(12, 0, 30.0, 15.0, 0.1, 1), (12, 100, 20.0, 10.0, 0.1, 101), (12, 200, 12.0, 6.0, 0.1, 201), (12, 300, 7.0, 3.5, 0.1, 301), (12, 400, 4.0, 2.0, 0.1, 401),
-- Run 13
(13, 0, 40.0, 20.0, 0.05, 1), (13, 100, 30.0, 15.0, 0.05, 101), (13, 200, 22.0, 11.0, 0.05, 201), (13, 300, 16.0, 8.0, 0.05, 301), (13, 400, 11.0, 5.5, 0.05, 401),
-- Run 14
(14, 0, 55.0, 27.5, 0.02, 1), (14, 100, 40.0, 20.0, 0.02, 101), (14, 200, 28.0, 14.0, 0.02, 201), (14, 300, 19.0, 9.5, 0.02, 301), (14, 400, 12.0, 6.0, 0.02, 401),
-- Run 15
(15, 0, 60.0, 30.0, 0.01, 1), (15, 100, 45.0, 22.5, 0.01, 101), (15, 200, 32.0, 16.0, 0.01, 201), (15, 300, 22.0, 11.0, 0.01, 301), (15, 400, 14.0, 7.0, 0.01, 401),
-- Run 16 (Failed)
(16, 0, 5.0, 2.5, 2.0, 1), (16, 10, 15.0, 7.5, 2.0, 11), (16, 20, 45.0, 22.5, 2.0, 21), (16, 30, 135.0, 67.5, 2.0, 31), (16, 40, 405.0, 202.5, 2.0, 41),
-- Run 17
(17, 0, 90.0, 45.0, 0.005, 1), (17, 100, 70.0, 35.0, 0.005, 101), (17, 200, 50.0, 25.0, 0.005, 201), (17, 300, 35.0, 17.5, 0.005, 301), (17, 400, 22.0, 11.0, 0.005, 401),
-- Run 18
(18, 0, 110.0, 55.0, 0.001, 1), (18, 100, 85.0, 42.5, 0.001, 101), (18, 200, 60.0, 30.0, 0.001, 201), (18, 300, 40.0, 20.0, 0.001, 301), (18, 400, 25.0, 12.5, 0.001, 401),
-- Run 19
(19, 0, 150.0, 75.0, 0.002, 1), (19, 100, 115.0, 57.5, 0.002, 101), (19, 200, 85.0, 42.5, 0.002, 201), (19, 300, 60.0, 30.0, 0.002, 301), (19, 400, 40.0, 20.0, 0.002, 401),
-- Run 20
(20, 0, 250.0, 125.0, 0.001, 1), (20, 100, 190.0, 95.0, 0.001, 101), (20, 200, 140.0, 70.0, 0.001, 201), (20, 300, 100.0, 50.0, 0.001, 301), (20, 400, 70.0, 35.0, 0.001, 401);
