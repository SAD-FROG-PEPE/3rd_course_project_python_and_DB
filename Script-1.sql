CREATE EXTENSION IF NOT EXISTS pgcrypto;

DROP TABLE IF EXISTS organization CASCADE;
DROP TABLE IF EXISTS client CASCADE;
DROP TABLE IF EXISTS furniture CASCADE;
DROP TABLE IF EXISTS contract CASCADE;
DROP TABLE IF EXISTS emp_position CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS task_priority CASCADE;
DROP TABLE IF EXISTS task CASCADE;

CREATE TABLE organization (
	organization_id SERIAL PRIMARY KEY, 
	name VARCHAR(60) NOT NULL, 
	address VARCHAR(150) NOT NULL,
	email VARCHAR(100) NOT NULL
);

CREATE TABLE client (
	client_id SERIAL PRIMARY KEY,
	name VARCHAR(30) NOT NULL,
	middle_name VARCHAR(40),
	surname VARCHAR(50) NOT NULL,
	phone_number VARCHAR(16) NOT NULL,
	address VARCHAR(150) NOT NULL,
	email VARCHAR(100) NOT NULL,
	organization_id SERIAL NOT NULL REFERENCES organization (organization_id)
);

CREATE TABLE furniture (
	furniture_id BIGSERIAL PRIMARY KEY,
	furniture_name VARCHAR(60) NOT NULL,
	furniture_material VARCHAR(30) NOT NULL,
	furniture_cost NUMERIC(8, 2) NOT NULL
);

CREATE TABLE contract (
	contract_id SERIAL PRIMARY KEY,
	contract_description VARCHAR(350) NOT NULL,
	furniture_id BIGSERIAL NOT NULL REFERENCES furniture (furniture_id),
	organization_id SERIAL NOT NULL REFERENCES organization (organization_id)
);

CREATE TABLE emp_position (
	emp_position_id SERIAL PRIMARY KEY,
	position_name VARCHAR(60) NOT NULL
);

CREATE TABLE employee (
	employee_id SERIAL PRIMARY KEY,
	name VARCHAR(30) NOT NULL,
	middle_name VARCHAR(40),
	surname VARCHAR(50) NOT NULL,
	phone_number VARCHAR(16) NOT NULL,
	email VARCHAR(100) NOT NULL,
	emp_position_id SERIAL NOT NULL REFERENCES emp_position (emp_position_id)
);

CREATE TABLE users(
	user_id SERIAL PRIMARY KEY,
	login VARCHAR(50) NOT NULL,
	pass VARCHAR(50) NOT NULL,
	is_authenticated BOOLEAN NOT NULL,
	is_active BOOLEAN NOT NULL,
	is_anonymous BOOLEAN NOT NULL,
	emp_id SERIAL NOT NULL REFERENCES employee (employee_id)
);


CREATE TABLE task_priority (
	task_priority_id SMALLSERIAL PRIMARY KEY,
	priority_name VARCHAR(20) NOT NULL
);

CREATE TABLE task (
	task_id BIGSERIAL PRIMARY KEY,
	task_name VARCHAR(50) NOT NULL,
	task_description VARCHAR(350) NOT NULL,
	creation_date DATE NOT NULL,
	execution_date DATE,
	deadline_date DATE NOT NULL,
	task_status BOOLEAN NOT NULL,
	author_id SERIAL NOT NULL REFERENCES employee (employee_id),
	executor_id INTEGER REFERENCES employee (employee_id),
	task_priority_id SMALLSERIAL NOT NULL REFERENCES task_priority (task_priority_id),
	client_id SERIAL NOT NULL REFERENCES client (client_id),
	contract_id INTEGER NULL REFERENCES contract (contract_id)
);

INSERT INTO organization(name, address, email) VALUES 
	('Саня компани', 'г. Аткарск, ул. Коммунистическая 2, кв. 69', 'sanya@mail.ru'),
	('Данил Земля', 'г. Вольск, ул. Гагарина 56', 'zemlya@mail.ru'),
	('Даниил Комар', 'г. Москва, ул. Альуфьева 2', 'techies@mail.ru');

INSERT INTO client(name, middle_name, surname, phone_number, address, email, organization_id) VALUES
	('Дмитрий', 'Алексеевич', 'Куплинов', '+79279018212', 'Мальдивы, ул. Снайперская 2', 'kuplinov@mail.ru', 1),
	('Александр', 'Николаевич', 'Симонин', '+79379018612', 'Нью-Йорк, ул. Мстителей 512', 'halk@mail.ru', 2),
	('Макар', 'Сергеевич', 'Шалунов', '+79772262721', 'Москва, ул. Победы 251', 'yra_pobeda@mail.ru', 3);

INSERT INTO furniture(furniture_name, furniture_material, furniture_cost) VALUES 
	('Стол', 'Мрамор', 150250.35),
	('Шкаф', 'Дуб', 10499.90),
	('Кровать', 'Клен', 7799.99);
	
INSERT INTO contract(contract_description, furniture_id, organization_id)  VALUES
	('Сборка шкафа', 2, 3),
	('Контракт 2', 1, 1),
	('Контракт 3', 3, 2);

INSERT INTO emp_position(position_name) VALUES 
	('Рядовой сотрудник'),
	('Менеджер');
	
INSERT INTO employee(name, middle_name, surname, phone_number, email, emp_position_id) VALUES 
	('Тайлер', 'Джекович', 'Дерден', '+79889127733', 'whereismymind@gmail.com', 1),
	('Кирилл', 'Лысович', 'Стадник', '+79282157621', 'warface@gmail.com', 2),
	('Артем', 'Мвзелов', 'Полный', '+79282157621', 'warface@gmail.com', 2),
	('Данил', 'Геральдович', 'Всадников', '+79282157621', 'warface@gmail.com', 1);


INSERT INTO users(login, pass, is_authenticated, is_active, is_anonymous, emp_id) VALUES 
	('whoami', crypt('21japs1sk', gen_salt('md5')), false, true, false, 1),
	('berreta_imba', crypt('41kja91-s', gen_salt('md5')), false, true, false, 2),
	('sanya', crypt('papdkkop1-0!?', gen_salt('md5')), false, true, false, 3),
	('sanyas', crypt('ooeqils10sa;1', gen_salt('md5')), false, true, false, 4);

INSERT INTO task_priority(priority_name) VALUES
	('низкий'), ('средний'), ('высокий');


INSERT INTO task(task_name, task_description, creation_date, execution_date, deadline_date, task_status, author_id, executor_id,
				task_priority_id, client_id, contract_id) VALUES
	('Помыть стол', 'Берешь тряпки, моешь.', '2021-06-30', '2021-07-01', '2021-07-01', true,2, 1, 3, 1, NULL),
	('Собрать кровать', 'Молоток и гвозди в руки и строишь.', '2021-06-30', NULL, '2021-09-01', false, 2, 4, 1, 2, NULL),
	('Собрать диван', 'Молоток и гвозди в руки и строишь.', '2021-08-15', '2021-10-01', '2021-11-01', true, 2, 1, 1, 2, NULL),
	('Собрать зеркало', 'Стекло и печь тебе в помощь.', '2021-08-17', NULL, '2022-12-01', false, 2,4, 1, 2, NULL),
	('Собрать колодец', 'Кирпичи и уемент лучшие дурзья.', '2021-08-16', '2022-10-01', '2021-11-01', true, 2, 1, 1, 2, NULL),
	('Собрать пуфик', 'Молоток и гвозди в руки и строишь.', '2021-08-13', '2022-10-01', '2021-11-01', true, 2, 4, 1, 2, NULL),
	('Собрать бутылку', 'Из подручных средств.', '2021-08-12', NULL, '2021-11-01', false, 3, 1, 1, 2, NULL),
	('Собрать фанту в тезнологическом шкафу', 'Молоток и гвозди в руки и строишь.', '2021-08-11', NULL, '2022-11-01', false,3, 4, 1, 2, NULL),
	('Собрать колу в технологической тумбочке', 'Молоток и гвозди в руки и строишь.', '2021-08-30', NULL, '2022-11-01', false, 3, 1, 1, 2, NULL),
	('Собрать молоко', 'Молоток и гвозди в руки и строишь.', '2021-06-30', NULL, '2023-11-01', false, 3, 4, 1, 2, NULL),
	('Собрать клубнику с органичной мебели', 'Семечки, почва, руки.', '2021-06-30', NULL, '2024-11-01', false, 3, 1, 1, 2, NULL),
	('Собрать клубнику с органичной мебели', 'Семечки, почва, руки.', '2021-06-30', NULL, '2024-11-01', false, 3, 4, 1, 2, NULL),
	('Моя задача', 'Пока не придумала.', '2021-06-30', NULL, '2024-11-01', false, 3, 3, 1, 2, NULL),
	('Собрать шкаф', 'Молоток и гвозди в руки и строишь.', '2021-06-30', '2022-01-01', '2021-12-31', true, 3, 1, 2, 3, 1);


DROP OWNED BY manager CASCADE;
DROP OWNED BY worker CASCADE;
DROP ROLE IF EXISTS worker;
DROP ROLE IF EXISTS manager;
CREATE ROLE worker;
CREATE ROLE manager;

				
--CREATE USER whoami WITH PASSWORD '21japs1sk';
GRANT worker TO whoami;
--CREATE USER berreta_imba WITH PASSWORD '41kja91-s';
GRANT manager TO berreta_imba;
--CREATE USER sanya WITH PASSWORD 'papdkkop1-0!?';
GRANT manager TO sanya;
--CREATE USER sanyas WITH PASSWORD 'ooeqils10sa;1';
GRANT worker TO sanyas;
	


-- Необходимо для того, чтобы созданные политики действовали
ALTER TABLE task ENABLE ROW LEVEL SECURITY;

-- Просматривать таблицы могут все работники
GRANT SELECT ON ALL TABLES IN SCHEMA public
	TO worker, manager;
	
GRANT CONNECT ON DATABASE furniture_company TO worker, manager;

-- Необходимо для возможности генерировать автоматически id задач
GRANT UPDATE ON task_task_id_seq
	TO manager;
	
 	
-- Добавлять новые задания могут только менеджеры
GRANT INSERT ON client, contract, furniture, organization, task
	TO manager;

GRANT DELETE ON task
	TO manager, worker;


GRANT UPDATE ON task TO manager, worker;

SELECT * FROM employee;

CREATE POLICY insert_task ON task
	FOR INSERT
	TO manager 
	WITH CHECK (true);

-- Обновлять задачу может только автор

-- Политика для автора, чтобы изменять задание 
-- В начале делается проверка на то, что задание еще не выполнено, так как выполненные задания изменять нельзя

CREATE POLICY update_by_author ON task AS PERMISSIVE
FOR UPDATE
TO manager, worker
USING (true)
WITH CHECK (((( SELECT users.login AS login FROM users
			  WHERE (task.author_id = users.emp_id)))::text = CURRENT_USER));


CREATE POLICY update_by_executor ON task AS PERMISSIVE
FOR UPDATE 
TO manager, worker
USING (true)
WITH CHECK (((( SELECT users.login AS login FROM users
			  WHERE (task.executor_id = users.emp_id)))::text = CURRENT_USER));

			 
-- Политика для исполнителя и автора, чтобы изменять статус, дату завершения и приоритет
 CREATE POLICY update_task ON task
 	FOR UPDATE
 	TO manager, worker
 	USING (
 		task.task_status = false
 		AND 
 		(
 			(
 				SELECT login FROM users
 				WHERE (emp_id = task.author_id)
 			) = CURRENT_USER
 			OR
 			(
 				SELECT login FROM users
 				WHERE (emp_id = task.executor_id)
 			) = CURRENT_USER
 		)
 	)
 	WITH CHECK (
 		(task.task_status = true)
 	);

CREATE POLICY change_executor ON task
 	FOR UPDATE
 	TO manager
 	USING (
 		(
 			SELECT position_name FROM emp_position
 			WHERE emp_position_id = (
 				SELECT employee_id FROM employee
 				WHERE employee_id = task.executor_id
 		)
 		) = 'Рядовой сотрудник'
 	)
 	WITH CHECK (true);

-- Политика для того, чтобы работник и менеджер могли просматривать свои задания.
CREATE POLICY browse_my_tasks ON task
	FOR SELECT
	TO worker, manager
	USING (
		(
			SELECT login FROM users
			WHERE (emp_id = author_id)
		) = CURRENT_USER
		OR
		(
			SELECT login FROM users
			WHERE (emp_id = executor_id)
		) = CURRENT_USER
	);

-- Политика для менеджеров, которая позволяет просматривать задания рядовых сотрудников
CREATE POLICY browse_tasks_manager ON task
	FOR SELECT
	TO manager
	USING (
		(
			SELECT position_name FROM emp_position
			WHERE emp_position_id = (
				SELECT employee_id FROM employee
				WHERE employee_id = executor_id
		)
		) = 'Рядовой сотрудник'
	);

-- Процедура на добавление нового задания
CREATE OR REPLACE PROCEDURE add_task(task_name varchar, task_description varchar, creation_date date, 
									  deadline_date date, 
									  executor_id int4, author_id int4, task_priority_id int2, client_id int4, 
									  contract_id int4) AS $$
DECLARE
BEGIN	
	EXECUTE format('INSERT INTO task (task_name, task_description, creation_date, 
				    execution_date, deadline_date, task_status, author_id, executor_id,
					task_priority_id, client_id, contract_id)
				   	VALUES (%L, %L, %L, %L, %L, %L, %L, %L, %L, %L)',
				  	task_name, task_description, creation_date, null, deadline_date, false,
				  	author_id, executor_id, task_priority_id, client_id, contract_id);
	
END;
$$ LANGUAGE plpgsql;

-- Разрешаем использовать эту функцию только менеджеру
GRANT EXECUTE ON PROCEDURE add_task TO manager;

-- Создаем процедуру для создания пользователей и назначения им ролей

CREATE OR REPLACE PROCEDURE create_user(name varchar, middle_name varchar, surname varchar,
									   	phone_number varchar, email varchar, login varchar, 
										emp_password text, emp_role varchar) AS $$
DECLARE
	emp_id int4;
	emp_position_id int4;
BEGIN
	IF (SELECT COUNT(*) FROM pg_roles WHERE rolname = login) THEN
		RAISE EXCEPTION 'Такой пользователь уже существует.';
	ELSE
		
		IF (emp_role = 'worker') THEN
			emp_position_id := 1;
			ELSE IF (emp_role = 'manager') THEN
				emp_position_id := 2;
			END IF;
		END IF;
			
		
		EXECUTE format('INSERT INTO employee(name, middle_name, surname, 
					   	phone_number, email, emp_position_id)
					    VALUES (%L, %L, %L, %L, %L, %L)',
					  	name, middle_name, surname, phone_number, email, emp_position_id);
		
		SELECT MAX(employee_id) INTO emp_id FROM employee;
		
		EXECUTE format('INSERT INTO users(login, pass, is_authenticated, 
					   	is_active, is_anonymous, emp_id)
					    VALUES (%L, crypt(%L, gen_salt(''md5'')), %L, %L, %L, %L)',
					  	login, emp_password, false, true, false, emp_id);
						
		EXECUTE format('CREATE ROLE %I WITH LOGIN PASSWORD %L', login, emp_password);
		EXECUTE format('GRANT %I TO %I', emp_role, login);
		EXECUTE format('GRANT CONNECT ON DATABASE furniture_company TO %I', login);
	END IF;
END;
$$ LANGUAGE plpgsql;

-- Функция для удаления роли при удалении пользователей

CREATE OR REPLACE FUNCTION delete_user() RETURNS trigger AS $$
BEGIN
	EXECUTE format('DROP ROLE $I', OLD.login);
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_delete_role
AFTER DELETE ON employee
FOR EACH ROW 
EXECUTE FUNCTION delete_user();

-- Создание функции на удаление задания через 12 месяцев
CREATE OR REPLACE FUNCTION delete_task_after_year() RETURNS trigger AS $$
BEGIN
	DELETE FROM task
	WHERE (task_status = true) AND AGE(CURRENT_DATE, execution_date) > INTERVAL '12 months';
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;
	
CREATE TRIGGER delete_task_after_year_trigger 
BEFORE INSERT OR UPDATE ON task
FOR EACH STATEMENT
EXECUTE FUNCTION delete_task_after_year();

CREATE INDEX organization_name_idx ON organization (name);
CREATE INDEX organization_email_idx ON organization (email);
CREATE INDEX client_name_idx ON client (name);
CREATE INDEX client_phone_number_idx ON client (phone_number);
CREATE INDEX client_email_idx ON client (email);
CREATE INDEX task_name_idx ON task (task_name);
CREATE INDEX task_author_idx ON task (author_id);
CREATE INDEX task_executor_idx ON task (executor_id);
CREATE INDEX employee_name_idx ON employee (name);
CREATE INDEX emp_phone_number_idx ON employee (phone_number);
CREATE INDEX emp_email_idx ON employee (email);

CREATE OR REPLACE PROCEDURE generate_report(employee_id int4, start_period date, end_period date,
											directory varchar) AS $$
DECLARE
	total_tasks int4;
	tasks_in_time int4;
	tasks_completed_overdue int4;
	tasks_not_completed_overdue int4;
	tasks_not_completed int4;
BEGIN
	SELECT COUNT(*) INTO total_tasks FROM task
	WHERE (executor_id = employee_id) AND (creation_date >= start_period) AND (creation_date <= end_period)
	GROUP BY executor_id;
	
	SELECT COUNT(*) INTO tasks_in_time FROM task
	WHERE (executor_id = employee_id) AND (execution_date <= deadline_date) AND (task_status = true)
			AND (creation_date >= start_period) AND (creation_date <= end_period)
	GROUP BY executor_id;
	
	SELECT COUNT(*) INTO tasks_completed_overdue FROM task
	WHERE (executor_id = employee_id) AND (execution_date > deadline_date) AND (task_status = true)
			AND (creation_date >= start_period) AND (creation_date <= end_period)
	GROUP BY executor_id;
	
	
	SELECT COUNT(*) INTO tasks_not_completed_overdue FROM task
	WHERE (executor_id = employee_id) AND (CURRENT_DATE > deadline_date) AND (task_status = false)
			AND (execution_date IS NULL)
			AND (creation_date >= start_period) AND (creation_date <= end_period)
	GROUP BY executor_id;

	SELECT COUNT(*) INTO tasks_not_completed FROM task
	WHERE (executor_id = employee_id) AND (CURRENT_DATE < deadline_date) AND (task_status = false)
			AND (execution_date IS NULL)
			AND (creation_date >= start_period) AND (creation_date <= end_period)
	GROUP BY executor_id;
	
	EXECUTE format('COPY (SELECT %L AS total_tasks, %L AS tasks_in_time, %L AS tasks_completed_overdue,
				  				 %L AS tasks_not_completed_overdue, %L AS tasks_not_completed)
				   TO %L CSV HEADER',
				  total_tasks, tasks_in_time, tasks_completed_overdue, tasks_not_completed_overdue,
				  tasks_not_completed, directory);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE generate_json_report(directory text) AS $$
BEGIN
	EXECUTE format('COPY (
		SELECT json_agg(row_to_json(tab)) 
		FROM (SELECT * FROM task) AS tab) TO %L', directory);
END;
$$ LANGUAGE plpgsql;

CALL generate_json_report('C:\Personal\MIREA\JSON_FOR_DB\furniture_company.json');



