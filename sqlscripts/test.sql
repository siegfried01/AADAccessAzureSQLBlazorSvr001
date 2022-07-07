DROP TABLE IF EXISTS TEST
CREATE TABLE TEST (id INT IDENTITY(1,1) PRIMARY KEY, name VARCHAR(255), created DATETIME DEFAULT GETDATE());
INSERT INTO TEST (name) VALUES ('Siegfried')
INSERT INTO TEST (name) VALUES ('Constance')
INSERT INTO TEST (name) VALUES ('Sieglinde')
INSERT INTO TEST (name) VALUES ('Kerry')
INSERT INTO TEST (name) VALUES ('Linda')
INSERT INTO TEST (name) VALUES ('Rusty')
INSERT INTO TEST (name) VALUES ('LaVern')
INSERT INTO TEST (name) VALUES ('Mike')
INSERT INTO TEST (name) VALUES ('Debbie')
