from flask import render_template, request, redirect, flash, url_for
from flask import session
from psycopg2 import OperationalError
import psycopg2
from . import app


@app.route('/', methods=['POST', 'GET'])
def index():
    user = {'is_authenticated': False}
    manager = False
    context = None
    if request.method == 'POST':
        client_id = request.form.get('search')
        return redirect(url_for('show_client', client_id=client_id))

    else:
        if 'current_user' in session:
            conn = psycopg2.connect(database='furniture_company',
                                    user='postgres', password='1234',
                                    host='localhost', port=5432)

            tasks = None
            user['username'] = session.get('current_user', 'secret')[1]
            user['is_authenticated'] = True
            with conn:
                with conn.cursor() as cur:
                    cur.execute(f'''SELECT emp_position_id FROM employee WHERE employee_id = 
                                    {session.get('current_user', 'secret')[6]}''')
                    manager = True if cur.fetchone()[0] == 2 else False
                    cur.execute('SELECT * FROM task ORDER BY task_id DESC')
                    tasks = cur.fetchall()

            conn = psycopg2.connect(database='furniture_company',
                                    user=f'''{session.get('current_user', 'secret')[1]}''',
                                    password=f'''{session.get('user_password', 'secret')}''',
                                    host='localhost', port=5432)
            with conn:
                with conn.cursor() as cur:
                    cur.execute('SELECT * FROM task ORDER BY task_id DESC')
                    tasks = cur.fetchall()

            return render_template('index.html', tasks=tasks, user=user, manager=manager)

        else:
            return render_template('index.html', user=user)


@app.route('/login', methods=['GET', 'POST'])
def login_page():
    login = request.form.get('login')
    entered_password = request.form.get('password')

    if request.method == 'POST':
        if login and entered_password:
            conn = psycopg2.connect(database='furniture_company',
                                    user='postgres', password='1234',
                                    host='localhost', port=5432)

            user = None
            is_password_right = None

            with conn:
                with conn.cursor() as cur:
                    cur.execute(f'''SELECT * FROM users WHERE login = '{login}' ''')
                    user = cur.fetchone()
                    cur.execute(f'''SELECT pass = crypt('{entered_password}', pass)
                                    FROM users WHERE login = '{login}' ''')
                    is_password_right = cur.fetchone()[0]

            if is_password_right:
                user = None
                with conn:
                    with conn.cursor() as cur:
                        cur.execute(f'''UPDATE users SET is_authenticated = true
                                        WHERE login = '{login}' ''')
                        cur.execute(f'''SELECT * FROM users WHERE login = '{login}' ''')
                        user = cur.fetchone()
                        session['current_user'] = user
                        session['user_password'] = entered_password

                return redirect(url_for('index'))
            else:
                flash('Пожалуйста введите корректные данные')
                return redirect(url_for('login_page'))

    else:
        return render_template('login.html')


@app.route('/register', methods=['GET', 'POST'])
def register():
    login = request.form.get('login')
    password = request.form.get('password')
    password2 = request.form.get('password2')
    name = request.form.get('name')
    middle_name = request.form.get('middle_name')
    surname = request.form.get('surname')
    email = request.form.get('email')
    phone_number = request.form.get('phone_number')
    role = request.form.get('position')

    if request.method == 'POST':
        if not (login or password or password2 or name or middle_name or surname or email
                or phone_number or role):
            flash('Пожалуйста, заполните все данные')
            return redirect(url_for('register'))
        elif password != password2:
            flash('Введенные пароли не равны')
            return redirect(url_for('register'))
        elif any(char in ".,:;!_*+()/#¤%&1234567890)" for char in name) or any(
                char in ".,:;!_*+()/#¤%&1234567890)" for char in middle_name) or any(
            char in ".,:;!_*+()/#¤%&1234567890)" for char in surname):
            flash('Введите верную информацию о ФИО')
            return redirect(url_for('register'))
        elif any(char in ".,:;!_*/#¤%&" for char in phone_number) or len(phone_number) < 8:
            flash('Такого номера телефона не существует')
            return redirect(url_for('register'))
        elif email.count("@") != 1:
            flash('Такой электронной почты не существует')
            return redirect(url_for('register'))
        else:
            conn = psycopg2.connect(database='furniture_company',
                                    user='postgres', password='1234',
                                    host='localhost', port=5432)
            with conn:
                with conn.cursor() as cur:
                    cur.execute(f'''CALL create_user('{name}', '{middle_name}', '{surname}', '{phone_number}',
                                    '{email}', '{login}', '{password}', '{role}')''')

            return redirect(url_for('login_page'))

    else:
        return render_template('register.html')


@app.route('/logout', methods=['GET', 'POST'])
def logout():
    login = session.get('current_user', 'secret')[1]
    conn = psycopg2.connect(database='furniture_company',
                            user='postgres', password='1234',
                            host='localhost', port=5432)
    with conn:
        with conn.cursor() as cur:
            cur.execute(f'''UPDATE users SET is_authenticated = false
                                           WHERE login = '{login}' ''')

    session.clear()
    return redirect(url_for('index'))


@app.route('/task/<int:task_id>')
def show_task(task_id):
    task = None
    user = None

    if 'current_user' in session:
        user = {'is_authenticated': True,
                'username': session.get('current_user', 'secret')[1]}
        conn = psycopg2.connect(database='furniture_company',
                                user=f'''{session.get('current_user', 'secret')[1]}''',
                                password=f'''{session.get('user_password', 'secret')}''',
                                host='localhost', port=5432)
        with conn:
            with conn.cursor() as cur:
                cur.execute(f'''SELECT * FROM task WHERE task_id = '{task_id}' ''')
                task = cur.fetchone()

        return render_template('task.html', task=task, user=user)


@app.route('/change_task/<int:task_id>', methods=['GET', 'POST'])
def change_task(task_id):
    task = None
    user = None

    conn = None

    if 'current_user' in session:
        user = {'is_authenticated': True,
                'username': session.get('current_user', 'secret')[1]}
        conn = psycopg2.connect(database='furniture_company',
                                user=f'''{session.get('current_user', 'secret')[1]}''',
                                password=f'''{session.get('user_password', 'secret')}''',
                                host='localhost', port=5432)

    if request.method == 'POST':
        task_name = request.form.get('name')
        task_description = request.form.get('description')
        date_creation = request.form.get('date_creation')
        date_execution = 'null' if request.form.get(
            'date_execution') == 'None' else f''' '{request.form.get('date_execution')}' '''
        deadline = request.form.get('deadline_date')
        status = request.form.get('status')
        executor = request.form.get('executor')
        priority = request.form.get('priority')
        client = request.form.get('client')
        contract = 'null' if request.form.get('contract') == 'None' else request.form.get('contract')

        if not (task_name or task_description or date_execution or date_creation or deadline
                or status or executor or priority or client or contract):
            flash('Пожалуйста, заполните все данные')
        else:
            with conn:
                with conn.cursor() as cur:
                    if session.get('current_user') == "manager":
                        cur.execute(f'''UPDATE task SET task_name = '{task_name}',
                                        task_description = '{task_description}',
                                        execution_date = {date_execution},
                                        task_status = '{status}',
                                        executor_id = '{executor}',
                                        task_priority_id = '{priority}', 
                                        client_id = '{client}', 
                                        contract_id = {contract},
                                        deadline_date={deadline}
                                        WHERE task_id = '{task_id}' ''')
                    else:
                        cur.execute(f'''UPDATE task SET task_name = '{task_name}',
                                                               task_description = '{task_description}',
                                                               execution_date = {date_execution},
                                                               task_status = '{status}'
                                                               WHERE task_id = '{task_id}' ''')
            return redirect(url_for('show_task', task_id=task_id))

    else:
        with conn:
            with conn.cursor() as cur:
                cur.execute(f'''SELECT * FROM task WHERE task_id = '{task_id}' ''')
                task = cur.fetchone()
        return render_template('change_task.html', task=task, user=user)


@app.route('/add_task', methods=['GET', 'POST'])
def add_task():
    task = None
    user = None

    conn = None
    if 'current_user' in session:
        conn = psycopg2.connect(database='furniture_company',
                                user=f'''{session.get('current_user', 'secret')[1]}''',
                                password=f'''{session.get('user_password', 'secret')}''',
                                host='localhost', port=5432)
        user = {'is_authenticated': True,
                'username': session.get('current_user', 'secret')[1]}

    if request.method == 'POST':
        task_name = request.form.get('name')
        task_description = request.form.get('description')
        date_creation = request.form.get('date_creation')
        deadline = request.form.get('deadline_date')
        status = request.form.get('status')
        executor = request.form.get('executor')
        priority = request.form.get('priority')
        client = request.form.get('client')
        contract = request.form.get('contract_id')

        author_id = session.get('current_user', 'secret')[6]

        if not (task_name or task_description or date_creation or deadline
                or status or executor or priority or client or contract):
            flash('Пожалуйста, заполните все данные')
        else:
            with conn:
                with conn.cursor() as cur:
                    cur.execute(f'''INSERT INTO task (task_name, task_description, creation_date, 
				        execution_date, deadline_date, task_status, author_id, executor_id,
					    task_priority_id, client_id, contract_id) VALUES (
					    '{task_name}',
					    '{task_description}',
					    '{date_creation}',
					    null,
					    '{deadline}',
					    false,
					    '{author_id}',
					    '{executor}',
					    '{priority}',
					    '{client}',
					    {contract}) ''')

            return redirect(url_for('index'))

    return render_template('add_task.html', user=user)


@app.route('/client/<int:client_id>')
def show_client(client_id):
    user = {}
    client = None
    record = None

    if 'current_user' in session:
        conn = psycopg2.connect(database='furniture_company',
                                user='postgres', password='1234',
                                host='localhost', port=5432)

        user['is_authenticated'] = True
        user['username'] = session.get('current_user', 'secret')[1]

        with conn:
            with conn.cursor() as cur:
                cur.execute(f'SELECT * FROM client WHERE client_id={client_id}')
                record = cur.fetchone()

    return render_template('client.html', record=record, user=user)


@app.route('/report_tasks', methods=['POST', 'GET'])
def generate_tasks():
    user = {}

    directory = request.form.get('directory')

    if 'current_user' in session:
        if request.method == 'POST':
            conn = psycopg2.connect(database='furniture_company',
                                    user='postgres', password='1234',
                                    host='localhost', port=5432)
            with conn:
                with conn.cursor() as cur:
                    cur.execute(f'''CALL generate_json_report('{directory}')''')
            return redirect(url_for('index'))

        else:
            user['is_authenticated'] = True
            user['username'] = session.get('current_user', 'secret')[1]

            return render_template('report_tasks.html', user=user)


@app.route('/report_emp', methods=['POST', 'GET'])
def generate_report_emps():
    user = {}

    emp_id = request.form.get('emp_id')
    start_period = request.form.get('start_period')
    end_period = request.form.get('end_period')
    directory = request.form.get('directory')

    if 'current_user' in session:
        if request.method == 'POST':
            conn = psycopg2.connect(database='furniture_company',
                                    user='postgres', password='1234',
                                    host='localhost', port=5432)
            with conn:
                with conn.cursor() as cur:
                    cur.execute(
                        f'''CALL generate_report('{emp_id}', '{start_period}', '{end_period}', '{directory}')''')
            return redirect(url_for('index'))

        else:
            user['is_authenticated'] = True
            user['username'] = session.get('current_user', 'secret')[1]

            return render_template('report_emp.html', user=user)
