
CREATE TABLE IF NOT EXISTS "Authors" (
    author_id SERIAL PRIMARY KEY,   
    name VARCHAR(255) NOT NULL,
    nationality VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS "Publishers" (
    publisher_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS "Genres" (
    genre_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS "Books" (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    isbn VARCHAR(20) NOT NULL,
    author_id INTEGER NOT NULL REFERENCES "Authors"(author_id),
    publisher_id INTEGER NOT NULL REFERENCES "Publishers"(publisher_id),
    publication_year INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS "Book_Genres" (
    book_genre_id SERIAL PRIMARY KEY,
    book_id INTEGER NOT NULL REFERENCES "Books"(book_id) ON DELETE CASCADE,
    genre_id INTEGER NOT NULL REFERENCES "Genres"(genre_id) ON DELETE CASCADE,
    UNIQUE (book_id, genre_id)
);

-- Insertar datos de autores
INSERT INTO "Authors" (name, nationality) VALUES
('Gabriel García Márquez', 'Colombian'),
('Isabel Allende', 'Chilean'),
('Jane Austen', 'British'),
('Paulo Coelho', 'Brazilian'),
('Aleksandr Pushkin', 'Russian'),
('William Shakespeare', 'British'),
('Leon Tolstoy', 'Russian'),
('Pablo Neruda', 'Chilean'),
('Jorge Luis Borges', 'Argentinian'),
('Miguel de Cervantes', 'Spanish')
ON CONFLICT DO NOTHING;

-- Insertar editoriales
INSERT INTO "Publishers" (name) VALUES
('RELX group'),
('ThomsonReuters'),
('Bertelsmann'),
('Pearson'),
('Wolters Kluwer'),
('Springer Nature'),
('Cengage Learning'),
('McGraw-Hill Education'),
('Hachette Livre'),
('AST')
ON CONFLICT DO NOTHING;

-- Insertar géneros
INSERT INTO "Genres" (name) VALUES
('Realismo Mágico'),
('Ficción Histórica'),
('Romance Clásico'),
('Ficción Filosófica'),
('Poesía'),
('Drama'),
('Novela Épica'),
('Cuento Corto'),
('Aventura')
ON CONFLICT DO NOTHING;

-- Insertar libros
INSERT INTO "Books" (title, isbn, author_id, publisher_id, publication_year) VALUES
('Cien años de soledad', '9780307474728', 1, 1, 1967),
('La casa de los espíritus', '9780553273916', 2, 2, 1982),
('Orgullo y prejuicio', '9780141439518', 3, 3, 1813),
('El alquimista', '9780061122415', 4, 4, 1988),
('Eugene Onegin', '9780140449129', 5, 5, 1833),
('Hamlet', '9780743477123', 6, 6, 1603),
('Guerra y paz', '9780199232765', 7, 7, 1869),
('Veinte poemas de amor y una canción desesperada', '9788491050463', 8, 8, 1924),
('Ficciones', '9780142437476', 9, 9, 1944),
('Don Quijote de la Mancha', '9788491050258', 10, 10, 1605)
ON CONFLICT DO NOTHING;

-- Insertar relaciones libro-género
INSERT INTO "Book_Genres" (book_id, genre_id) VALUES
    (1, 1),  -- Cien años de soledad: Realismo Mágico
    (2, 2),  -- La casa de los espíritus: Ficción Histórica
    (3, 3),  -- Orgullo y prejuicio: Romance Clásico
    (4, 4),  -- El alquimista: Ficción Filosófica
    (5, 5),  -- Eugene Onegin: Poesía
    (6, 6),  -- Hamlet: Drama
    (7, 7),  -- Guerra y paz: Novela Épica
    (8, 5),  -- Veinte poemas de amor: Poesía
    (9, 8),  -- Ficciones: Cuento Corto
    (10, 9)  -- Don Quijote: Aventura
ON CONFLICT DO NOTHING;

-- Crear usuario para la aplicación (si no existe)
DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'seminar_user') THEN
      CREATE USER seminar_user WITH PASSWORD 'Toro1234';
   END IF;
END
$$;

-- Crear usuario de prueba adicional (opcional para la Tarea 7)
DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'test_user') THEN
      CREATE USER test_user WITH PASSWORD 'test123';
   END IF;
END
$$;

-- Conceder permisos de conexión
GRANT CONNECT ON DATABASE seminario_db TO seminar_user, test_user;

-- Conceder permisos de uso en schema public
GRANT USAGE ON SCHEMA public TO seminar_user, test_user;

-- Conceder permisos en tablas existentes
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO seminar_user, test_user;

-- Conceder permisos en secuencias
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO seminar_user, test_user;

-- Asegurar permisos para tablas futuras
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO seminar_user, test_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT USAGE, SELECT ON SEQUENCES TO seminar_user, test_user;