# app.py - NUEVO ARCHIVO para Tarea 7 (basado en Tarea 3)
from flask import Flask, session, render_template, request, redirect, url_for
import psycopg2
from psycopg2 import sql
import os
import logging
from datetime import datetime
import time

app = Flask(__name__)
app.secret_key = os.urandom(24)

# Configuración de logging (Requisito 2 - failed logins)
logging.basicConfig(
    filename=os.getenv('APP_LOG_PATH', 'app.log'),
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

class DatabaseManager:
    """CLASE REUTILIZADA DE TU TAREA 3 - Conexión directa a PostgreSQL"""
    def __init__(self, user, password, host="db", database="seminario_db"):
        self.user = user
        self.password = password
        self.host = host
        self.database = database
        self.connection = None
    
    def connect(self):
        """Connect to PostgreSQL (como en tu Tarea 3)"""
        try:
            self.connection = psycopg2.connect(
                host=self.host,
                port="5432",
                database=self.database,
                user=self.user,
                password=self.password
            )
            return True
        except Exception as e:
            logging.error(f"Connection error: {e}")
            return False
    
    def view_table(self, table_name):
        """6.1.1 SELECT * FROM table (sin filtro)"""
        try:
            query = sql.SQL("SELECT * FROM {}").format(sql.Identifier(table_name))
            with self.connection.cursor() as cursor:
                cursor.execute(query)
                columns = [desc[0] for desc in cursor.description]
                rows = cursor.fetchall()
                return columns, rows
        except Exception as e:
            logging.error(f"Error viewing table {table_name}: {e}")
            return None, None
    
    def filter_single_value(self, table_name, column, value):
        """6.1.2 Filtrar por un valor: SELECT * FROM table WHERE column = value"""
        try:
            query = sql.SQL("SELECT * FROM {} WHERE {} = %s").format(
                sql.Identifier(table_name),
                sql.Identifier(column)
            )
            with self.connection.cursor() as cursor:
                cursor.execute(query, (value,))
                columns = [desc[0] for desc in cursor.description]
                rows = cursor.fetchall()
                return columns, rows
        except Exception as e:
            logging.error(f"Error filtering table {table_name}: {e}")
            return None, None
    
    def filter_multiple_values(self, table_name, column1, value1, column2, value2):
        """6.1.3 Filtrar por múltiples valores: SELECT * FROM table WHERE col1 = val1 AND col2 = val2"""
        try:
            query = sql.SQL("SELECT * FROM {} WHERE {} = %s AND {} = %s").format(
                sql.Identifier(table_name),
                sql.Identifier(column1),
                sql.Identifier(column2)
            )
            with self.connection.cursor() as cursor:
                cursor.execute(query, (value1, value2))
                columns = [desc[0] for desc in cursor.description]
                rows = cursor.fetchall()
                return columns, rows
        except Exception as e:
            logging.error(f"Error in multi-filter: {e}")
            return None, None
    
    def insert_book(self, title, author_id, publisher_id, year, isbn):
        """6.3.1 Insertar una fila en books"""
        try:
            query = """
                INSERT INTO "Books" (title, author_id, publisher_id, year, isbn)
                VALUES (%s, %s, %s, %s, %s) RETURNING id
            """
            with self.connection.cursor() as cursor:
                cursor.execute(query, (title, author_id, publisher_id, year, isbn))
                self.connection.commit()
                return cursor.fetchone()[0]
        except Exception as e:
            self.connection.rollback()
            logging.error(f"Error inserting book: {e}")
            return None
    
    def insert_related(self, title, author_name, author_birth, publisher_name, genre_names):
        """6.3.2 Insertar en tablas relacionadas (books + authors + publishers + book_genres)"""
        try:
            with self.connection.cursor() as cursor:
                # Insertar autor si no existe
                cursor.execute(
                    'INSERT INTO "Authors" (name, birth_year) VALUES (%s, %s) ON CONFLICT DO NOTHING RETURNING id',
                    (author_name, author_birth)
                )
                author_result = cursor.fetchone()
                if author_result:
                    author_id = author_result[0]
                else:
                    cursor.execute('SELECT id FROM "Authors" WHERE name = %s', (author_name,))
                    author_id = cursor.fetchone()[0]
                
                # Insertar editorial si no existe
                cursor.execute(
                    'INSERT INTO "Publishers" (name) VALUES (%s) ON CONFLICT DO NOTHING RETURNING id',
                    (publisher_name,)
                )
                publisher_result = cursor.fetchone()
                if publisher_result:
                    publisher_id = publisher_result[0]
                else:
                    cursor.execute('SELECT id FROM "Publishers" WHERE name = %s', (publisher_name,))
                    publisher_id = cursor.fetchone()[0]
                
                # Insertar libro
                cursor.execute(
                    'INSERT INTO "Books" (title, author_id, publisher_id, year, isbn) VALUES (%s, %s, %s, %s, %s) RETURNING id',
                    (title, author_id, publisher_id, 2024, f"ISBN-{int(time.time())}")
                )
                book_id = cursor.fetchone()[0]
                
                # Insertar géneros
                for genre_name in genre_names:
                    cursor.execute(
                        'INSERT INTO "Genres" (name) VALUES (%s) ON CONFLICT DO NOTHING',
                        (genre_name,)
                    )
                    cursor.execute('SELECT id FROM "Genres" WHERE name = %s', (genre_name,))
                    genre_id = cursor.fetchone()[0]
                    
                    cursor.execute(
                        'INSERT INTO "Book_Genres" (book_id, genre_id) VALUES (%s, %s)',
                        (book_id, genre_id)
                    )
                
                self.connection.commit()
                return book_id
                
        except Exception as e:
            self.connection.rollback()
            logging.error(f"Error in related insert: {e}")
            return None

# Rutas de la aplicación
@app.route('/')
def index():
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        # Intentar conexión directa a PostgreSQL
        db = DatabaseManager(user=username, password=password)
        
        if db.connect():
            # Guardar credenciales en sesión
            session['logged_in'] = True
            session['db_user'] = username
            session['db_password'] = password
            
            # LOG de éxito
            logging.info(f"Successful login - User: {username}, IP: {request.remote_addr}")
            return redirect(url_for('home'))
        else:
            # REQUISITO 2: Log de intentos fallidos
            logging.warning(f"Failed login attempt - User: {username}, IP: {request.remote_addr}")
            return render_template('login.html', error="Invalid credentials")
    
    return render_template('login.html')

@app.route('/home')
def home():
    if not session.get('logged_in'):
        return redirect(url_for('login'))
    return render_template('home.html')

@app.route('/view_tables')
def view_tables():
    if not session.get('logged_in'):
        return redirect(url_for('login'))
    
    db = DatabaseManager(
        user=session['db_user'],
        password=session['db_password']
    )
    db.connect()
    
    tables = ["Authors", "Publishers", "Genres", "Books", "Book_Genres"]
    all_data = {}
    
    for table in tables:
        columns, rows = db.view_table(table)
        if columns and rows is not None:
            all_data[table] = {
                'columns': columns,
                'rows': rows
            }
    
    return render_template('view_tables.html', tables=all_data)

@app.route('/filter', methods=['GET', 'POST'])
def filter_data():
    if not session.get('logged_in'):
        return redirect(url_for('login'))
    
    if request.method == 'POST':
        db = DatabaseManager(
            user=session['db_user'],
            password=session['db_password']
        )
        db.connect()
        
        filter_type = request.form['filter_type']
        table = request.form['table']
        
        if filter_type == 'single':
            column = request.form['column']
            value = request.form['value']
            columns, rows = db.filter_single_value(table, column, value)
            return render_template('filter_results.html', 
                                 columns=columns, 
                                 rows=rows, 
                                 table=table)
        
        elif filter_type == 'multiple':
            column1 = request.form['column1']
            value1 = request.form['value1']
            column2 = request.form['column2']
            value2 = request.form['value2']
            columns, rows = db.filter_multiple_values(table, column1, value1, column2, value2)
            return render_template('filter_results.html', 
                                 columns=columns, 
                                 rows=rows, 
                                 table=table)
    
    # GET request - mostrar formulario de filtro
    tables = ["Authors", "Publishers", "Genres", "Books", "Book_Genres"]
    return render_template('filter.html', tables=tables)

@app.route('/add_book', methods=['GET', 'POST'])
def add_book():
    if not session.get('logged_in'):
        return redirect(url_for('login'))
    
    if request.method == 'POST':
        db = DatabaseManager(
            user=session['db_user'],
            password=session['db_password']
        )
        db.connect()
        
        # 6.3.1 Insertar un libro
        book_id = db.insert_book(
            title=request.form['title'],
            author_id=request.form['author_id'],
            publisher_id=request.form['publisher_id'],
            year=request.form['year'],
            isbn=request.form['isbn']
        )
        
        if book_id:
            return f"Book added successfully with ID: {book_id}"
        else:
            return "Error adding book"
    
    return render_template('add_book.html')

@app.route('/add_complete_book', methods=['GET', 'POST'])
def add_complete_book():
    if not session.get('logged_in'):
        return redirect(url_for('login'))
    
    if request.method == 'POST':
        db = DatabaseManager(
            user=session['db_user'],
            password=session['db_password']
        )
        db.connect()
        
        # 6.3.2 Insertar en tablas relacionadas
        genres = request.form['genres'].split(',')
        genres = [g.strip() for g in genres]
        
        book_id = db.insert_related(
            title=request.form['title'],
            author_name=request.form['author_name'],
            author_birth=request.form['author_birth'],
            publisher_name=request.form['publisher_name'],
            genre_names=genres
        )
        
        if book_id:
            return f"Complete book entry added successfully! Book ID: {book_id}"
        else:
            return "Error adding complete book"
    
    return render_template('add_complete_book.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)