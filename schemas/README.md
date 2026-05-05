### Таблица `users`
| Название | Описание | Тип данных | Ограничения |
| :--- | :--- | :--- | :--- |
| **id** | Идентификатор пользователя (PK) | serial | NOT NULL |
| **username** | Логин пользователя | varchar | UNIQUE, NOT NULL |
| **email** | Контактный email | varchar | UNIQUE, DEFAULT NULL |

### Таблица `projects`
| Название | Описание | Тип данных | Ограничения |
| :--- | :--- | :--- | :--- |
| **id** | Идентификатор проекта (PK) | serial | NOT NULL |
| **name** | Название экспериментального проекта | varchar | NOT NULL |
| **description** | Текстовое описание целей исследования | text | DEFAULT NULL |
| **user_id** | Ссылка на автора проекта (FK -> `users.id`) | integer | ON DELETE SET NULL, DEFAULT NULL |

### Таблица `datasets`
| Название | Описание | Тип данных | Ограничения |
| :--- | :--- | :--- | :--- |
| **id** | Идентификатор набора данных (PK) | serial | NOT NULL |
| **name** | Название (например, "a9a", "CIFAR-10") | varchar | NOT NULL |
| **file_path** | Путь к файлу на сервере/S3 | varchar | DEFAULT NULL |
| **n_samples** | Количество объектов в выборке | integer | CHECK (n_samples > 0), DEFAULT NULL |
| **n_features** | Количество признаков | integer | CHECK (n_features > 0), DEFAULT NULL |
| **author_id** | Ссылка на автора (FK -> `users.id`) | integer | ON DELETE SET NULL, DEFAULT NULL |

### Таблица `objective_functions`
| Название | Описание | Тип данных | Ограничения |
| :--- | :--- | :--- | :--- |
| **id** | Идентификатор функции (PK) | serial | NOT NULL |
| **name** | Название функции (напр., "LogReg_L2") | varchar | NOT NULL |
| **dimension** | Размерность пространства | integer | NOT NULL, CHECK (dimension > 0) |
| **is_convex** | Признак выпуклости функции | boolean | DEFAULT false |
| **mu_strong_convexity** | Константа сильной выпуклости | float | CHECK (mu_strong_convexity >= 0), DEFAULT NULL |
| **lipschitz_l** | Константа Липшица градиента | float | CHECK (lipschitz_l > 0), DEFAULT NULL |
| **optimal_value** | Оптимальное значение f* | float | DEFAULT NULL |
| **formula_latex** | Формула для рендеринга | text | DEFAULT NULL |
| **dataset_id** | Ссылка на набор данных (FK -> `datasets.id`) | integer | ON DELETE SET NULL, DEFAULT NULL |
| **author_id** | Ссылка на автора (FK -> `users.id`) | integer | ON DELETE SET NULL, DEFAULT NULL |

### Таблица `algorithms`
| Название | Описание | Тип данных | Ограничения |
| :--- | :--- | :--- | :--- |
| **id** | Идентификатор алгоритма (PK) | serial | NOT NULL |
| **name** | Название метода (напр., "Adam") | varchar | NOT NULL |
| **description** | Описание метода | text | DEFAULT NULL |
| **author_id** | Ссылка на автора (FK -> `users.id`) | integer | ON DELETE SET NULL, DEFAULT NULL |

### Таблица `oracles`
| Название | Описание | Тип данных | Ограничения |
| :--- | :--- | :--- | :--- |
| **id** | Идентификатор оракула (PK) | serial | NOT NULL |
| **name** | Название оракула | varchar | NOT NULL |
| **oracle_type** | Тип (exact, stochastic, compressed) | varchar | NOT NULL |
| **batch_size** | Размер мини-батча | integer | CHECK (batch_size > 0), DEFAULT NULL |
| **noise_variance** | Дисперсия шума | float | CHECK (noise_variance >= 0), DEFAULT NULL |
| **author_id** | Ссылка на автора (FK -> `users.id`) | integer | ON DELETE SET NULL, DEFAULT NULL |

### Таблица `environments`
| Название | Описание | Тип данных | Ограничения |
| :--- | :--- | :--- | :--- |
| **id** | Идентификатор окружения (PK) | serial | NOT NULL |
| **name** | Название окружения (напр., "Mac M2") | varchar | NOT NULL |
| **hardware_type** | Тип железа (CPU, GPU_T4) | varchar | DEFAULT NULL |
| **precision** | Точность вычислений (float32, float64) | varchar | DEFAULT NULL |
| **author_id** | Ссылка на автора (FK -> `users.id`) | integer | ON DELETE SET NULL, DEFAULT NULL |

### Таблица `experiment_configs`
| Название | Описание | Тип данных | Ограничения |
| :--- | :--- | :--- | :--- |
| **id** | Идентификатор конфигурации (PK) | serial | NOT NULL |
| **max_iterations** | Лимит шагов алгоритма | integer | NOT NULL, CHECK (max_iterations > 0) |
| **tolerance_epsilon** | Критерий остановки по градиенту | float | CHECK (tolerance_epsilon >= 0), DEFAULT NULL |
| **init_seed** | Random seed | integer | DEFAULT NULL |
| **init_strategy** | Стратегия начальной точки | varchar | DEFAULT NULL |
| **hyperparameters** | Специфичные гиперпараметры | jsonb | NOT NULL |
| **author_id** | Ссылка на автора (FK -> `users.id`) | integer | ON DELETE SET NULL, DEFAULT NULL |

### Таблица `experiment_runs`
| Название | Описание | Тип данных | Ограничения |
| :--- | :--- | :--- | :--- |
| **id** | Идентификатор запуска (PK) | serial | NOT NULL |
| **status** | Состояние эксперимента | varchar | NOT NULL, DEFAULT 'pending', CHECK IN ('pending', 'running', 'completed', 'failed') |
| **project_id** | Ссылка на проект (FK -> `projects.id`) | integer | ON DELETE CASCADE, DEFAULT NULL |
| **user_id** | Ссылка на пользователя (FK -> `users.id`) | integer | ON DELETE SET NULL, DEFAULT NULL |
| **algorithm_id** | Ссылка на алгоритм (FK -> `algorithms.id`) | integer | NOT NULL, ON DELETE RESTRICT |
| **function_id** | Ссылка на функцию (FK -> `objective_functions.id`) | integer | NOT NULL, ON DELETE RESTRICT |
| **oracle_id** | Ссылка на оракул (FK -> `oracles.id`) | integer | NOT NULL, ON DELETE RESTRICT |
| **config_id** | Ссылка на конфиг (FK -> `experiment_configs.id`) | integer | NOT NULL, ON DELETE RESTRICT |
| **environment_id** | Ссылка на окружение (FK -> `environments.id`) | integer | ON DELETE SET NULL, DEFAULT NULL |
| **start_time** | Время начала эксперимента | timestamp | DEFAULT NULL |
| **end_time** | Время окончания эксперимента | timestamp | DEFAULT NULL |
| **total_time_seconds** | Итоговое время выполнения | float | CHECK (total_time_seconds >= 0), DEFAULT NULL |
| **total_oracle_calls** | Итоговое кол-во вызовов оракула | integer | CHECK (total_oracle_calls >= 0), DEFAULT NULL |

### Таблица `iteration_logs`
| Название | Описание | Тип данных | Ограничения |
| :--- | :--- | :--- | :--- |
| **id** | Идентификатор лога (PK) | serial | NOT NULL |
| **run_id** | Ссылка на запуск (FK -> `experiment_runs.id`) | integer | NOT NULL, ON DELETE CASCADE |
| **iteration_number** | Номер текущей итерации | integer | NOT NULL, CHECK (iteration_number >= 0) |
| **f_value** | Значение функции | float | NOT NULL |
| **grad_norm** | Норма градиента | float | NOT NULL, CHECK (grad_norm >= 0) |
| **step_size** | Размер шага | float | NOT NULL |
| **oracle_calls_so_far** | Накопленные вызовы оракула | integer | NOT NULL, CHECK (oracle_calls_so_far >= 0) |
