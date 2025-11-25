CREATE EXTENSION postgis

-- Criando a tabela silo para armazenar a cooperativa COTRIJUC
CREATE TABLE silo( 
	cod SERIAL PRIMARY KEY,
	nome VARCHAR(100),
	endereco VARCHAR(100),
	numero int,
	cep varchar(12),
	geom GEOMETRY(POINT, 4326)
);

INSERT INTO silo(nome, endereco, numero, cep, geom)
VALUES ('COTRIJUC', 'R. Cel. Severo Barros', 247, '98130-000', 
ST_GeomFromText('POINT(-53.66923745799949 -29.23490133159603)', 4326));
