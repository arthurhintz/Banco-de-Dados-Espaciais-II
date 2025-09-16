CREATE EXTENSION postgis

CREATE TABLE linha_onibus( 
	id_linha SERIAL PRIMARY KEY,
	nome VARCHAR(100),
	geom GEOMETRY(LINESTRING, 4326)
);

CREATE TABLE parada_onibus (
	id_parada SERIAL PRIMARY KEY,
	nome VARCHAR(100),
	id_linha INT REFERENCES linha_onibus(id_linha),
	geom GEOMETRY(POINT, 4326)
);


-- Trigger para verificar se a parada de onibus está próxima ao trajeto
CREATE OR REPLACE FUNCTION verifica_parada_proxima_linha()
RETURNS TRIGGER AS $$
BEGIN 
	IF NOT ST_DWithin(
		ST_Transform(NEW.geom,31982),
		(SELECT ST_Transform(geom, 31982) FROM linha_onibus WHERE id_linha = NEW.id_linha), 100
	) THEN
		RAISE EXCEPTION 'Parada está muito distante da linha de ônibus';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

drop trigger if exists trg_verifica_parada_proxima on parada_onibus;

CREATE TRIGGER trg_verifica_parada_proxima
BEFORE INSERT OR UPDATE ON parada_onibus
FOR EACH ROW
EXECUTE FUNCTION verifica_parada_proxima_linha();


-- Inserir uma linha de ônibus
INSERT INTO linha_onibus(nome, geom)
VALUES ('UFSM-HUSM', ST_GeomFromText('LINESTRING(-53.71615454616517 -29.71280273246447, -53.71610962288146 -29.71303206459795,
-53.71609775097248 -29.71320740245474, -53.71606427867503 -29.71339064835554, -53.71604920481091 -29.71353760188954,
-53.71600258996475 -29.71372226013384, -53.71596596779 -29.71401108688228, -53.71593178497088 -29.71427000562524,
-53.71588774256542 -29.71452377938434, -53.71585833773688 -29.71472787996321, -53.71584019264601 -29.71488056512124,
-53.71577901243793 -29.71520166491032)', 4326));

-- Inserir uma parada válida (próxima à linha)
INSERT INTO parada_onibus(nome, id_linha, geom)
VALUES ('Parada HUSM', 1, ST_GeomFromText('POINT(-53.71584975236306 -29.71409913951251)', 4326));

-- Inserir uma parada inválida (muito distante)
INSERT INTO parada_onibus(nome, id_linha, geom)
VALUES ('Parada Centro de Educação', 1, ST_GeomFromText('POINT(-53.71748720048853 -29.71410536759238)', 4326));


SELECT * FROM linha_onibus
--

ALTER TABLE linha_onibus ADD COLUMN extensao_km NUMERIC(12,2);

CREATE OR REPLACE FUNCTION atualiza_extensao_linha()
RETURNS TRIGGER AS $$
BEGIN 
	NEW.extensao_km := ST_Length(ST_Transform(NEW.geom, 31982)) / 1000;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_atualiza_extensao
BEFORE INSERT OR UPDATE ON linha_onibus
FOR EACH ROW
EXECUTE FUNCTION atualiza_extensao_linha();



-- Inserir uma linha de ônibus Planetário - HUV
INSERT INTO linha_onibus(nome, geom)
VALUES ('Planetário-HUV', ST_GeomFromText('LINESTRING(-53.71777833881656 -29.71968590528665, -53.7173096425444 -29.72239909165825,
-53.71692249693199 -29.72471994549975, -53.71674517005655 -29.72620861708758,
-53.71659080805203 -29.72697357349546)', 4326));


-- Trigger para gerar uma auditoria quando uma parada for movida
CREATE TABLE auditoria_parada
	(id SERIAL PRIMARY KEY,
	id_parada INT,
	data_movimento TIMESTAMP DEFAULT NOW(),
	geom_antiga GEOMETRY(POINT, 4326),
	geom_nova GEOMETRY(POINT, 4326));

CREATE OR REPLACE FUNCTION auditoria_movimento_parada()
RETURNS TRIGGER AS $$
BEGIN
	IF ST_Equals(OLD.geom, NEW.geom) = FALSE THEN
 		INSERT INTO auditoria_parada(id_parada, geom_antiga, geom_nova)
 		VALUES (OLD.id_parada, OLD.geom, NEW.geom);
	END IF;
 	RETURN NEW;
END;
$$ LANGUAGE plpgsql; 

CREATE TRIGGER trg_auditoria_movimento
AFTER UPDATE ON parada_onibus
FOR EACH ROW
EXECUTE FUNCTION auditoria_movimento_parada();


--Atualização com o valor correto da parada
UPDATE parada_onibus
SET geom = ST_GeomFromText('POINT(-53.71584975236306 -29.71409913951251)', 4326)
WHERE id_parada = 4;

--Atualização da parada do HUSM para uma posição errada para testar a trigger
UPDATE parada_onibus
SET geom = ST_GeomFromText('POINT(-53.7160824503211 -29.71293731538709)', 4326)
WHERE id_parada = 4;

SELECT * FROM auditoria_parada;
SELECT * FROM parada_onibus

