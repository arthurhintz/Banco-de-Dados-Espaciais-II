CREATE EXTENSION postgis

-- Adicionando a chave estrangeira na tabela bairro
alter table bairro add column cod_cidade integer;

alter table bairro add constraint cod_cidade_fk
FOREIGN KEY(cod_cidade) REFERENCES cidade(cod_cidade);

UPDATE bairro
SET cod_cidade = 1;


-- Craiando a tabela RUA

CREATE TABLE rua( 
	cod_rua integer PRIMARY KEY,
	nome character varying(30),
	cod_bairro integer,
	FOREIGN KEY(cod_bairro) REFERENCES bairro(cod_bairro));


-- Tabela dos pontos turisticos
CREATE TABLE ponto_turistico( 
	cod_ponto integer PRIMARY KEY,
	nome character varying(30),
	numero integer,
	descricao character varying(30),
	geom GEOMETRY(POINT, 4326),
	cod_rua integer,
	FOREIGN KEY(cod_rua) REFERENCES rua(cod_rua));



-- Inserindo valores das ruas
INSERT INTO rua (cod_rua, nome, cod_bairro)
VALUES (2, 'AV RIO BRANCO', 18);
INSERT INTO rua (cod_rua, nome, cod_bairro)
VALUES (1, 'AV Nossa Senhora Medianeira', 14);
INSERT INTO rua (cod_rua, nome, cod_bairro)
VALUES (3, 'Nossa Sra das Dores', 23);

-- Inserindo ponto turísticos

INSERT INTO ponto_turistico(cod_ponto, nome, numero, descricao, geom, cod_rua)
VALUES (1, 'Santuario Basílica NSM', 1, 'Lugar Sagrado',
		ST_GeomFromText('POINT(-53.81073280657928 -29.69972602996447)', 4326), 2);

INSERT INTO ponto_turistico(cod_ponto, nome, numero, descricao, geom, cod_rua)
VALUES (2, 'Catedral Santa MAria', 2, 'Seja Louvado',
		ST_GeomFromText('POINT(-53.80804667169472 -29.68487385661013)', 4326), 1);

INSERT INTO ponto_turistico(cod_ponto, nome, numero, descricao, geom, cod_rua)
VALUES (3, 'Igreja Sra das Dores', 3, 'Igreja de Cristo',
		ST_GeomFromText('POINT(-53.79468341262765 -29.68908913536697)', 4326), 3);






