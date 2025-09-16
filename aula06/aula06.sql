
-- trigger para verificar se a contrução está dentro do bairro certo

CREATE TABLE construcao (id_const SERIAL PRIMARY kEY,
							nome character varying(50),
							rua character varying(50),
							numero integer,
							cod_bairro INT REFERENCES bairro(cod_bairro),
							geom GEOMETRY(POINT, 4326));


CREATE OR REPLACE FUNCTION  verifica_construcao_dentro_zona()
RETURNS TRIGGER AS $$
BEGIN
	IF NOT ST_Contains(
		(SELECT geom FROM bairro WHERE cod_bairro = NEW.cod_bairro),
		NEW.geom
	) THEN 
		RAISE EXCEPTION 'Contrução fora do beirro informado';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;


create trigger trg_verifica_construcao
before insert or update or delete on construcao
for each row execute function verifica_construcao_dentro_zona();


-- Verificando se os locais pertencem ao bairro de Camobi
INSERT INTO construcao (nome, rua, numero, cod_bairro, geom) VALUES
('Clube Bela Vista', ' Rodolfo Behr', 1630, 25,ST_GeometryFromText('POINT
(-53.71826883301429 -29.70909521039305)', 4326));

INSERT INTO construcao (nome, rua, numero, cod_bairro, geom) VALUES
('Facas Peão', 'Arroio Grande', 00, 25, ST_GeometryFromText('POINT
(-53.66017133528313 -29.66880382989322)', 4326));

-- TRIGGER AUDITORIA PARA SALVAR AS ALTERACOES DA TABELA


CREATE TABLE auditoria_zona(
	id SERIAL PRIMARY KEY,
	nome character varying(50),
	cod_bairro integer,
	tipo_operacao VARCHAR(10),
	data_operacao TIMESTAMP DEFAULT NOW(),
	geom GEOMETRY(POINT, 4326)
);


CREATE OR REPLACE FUNCTION auditoria_zona_func()
RETURNS TRIGGER AS $$
BEGIN
	IF	TG_OP = 'INSERT' THEN
		INSERT INTO auditoria_zona(nome,cod_bairro, tipo_operacao, geom)
		VALUES (NEW.nome, NEW.cod_bairro, 'INSERT', new.geom);
	ELSIF	TG_OP = 'UPDATE' THEN
		INSERT INTO auditoria_zona(nome, cod_bairro, tipo_operacao, geom)
		VALUES (NEW.nome, NEW.cod_bairro, 'UPDATE', new.geom);
	ELSIF	TG_OP = 'DELETE' THEN
		INSERT INTO auditoria_zona(nome,cod_bairro, tipo_operacao, geom)
		VALUES (OLD.nome, OLD.cod_bairro, 'DELETE', OLD.geom);
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER tgr_auditoria_zona
AFTER INSERT OR UPDATE OR DELETE ON construcao
FOR EACH ROW
EXECUTE FUNCTION auditoria_zona_func()



INSERT INTO construcao(nome, rua, numero, cod_bairro, geom)
VALUES ('Rótula Papelaria','Rod. RST-287', 7715,25, ST_GeomFromText('POINT(-53.7172552559166 -29.70541513216279)', 4326));


SELECT * FROM auditoria_zona





