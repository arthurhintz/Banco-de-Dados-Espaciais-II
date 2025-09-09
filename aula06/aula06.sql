
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


