--acrescente a tabela area_exper com os campos cod_area, nome, geom, onde deverá ser 
--armazenado o polígono que contém a área total da área experimental Coxilha-UFSM.
--Posteriormente, acrescente na tabela talhao, o campo cod_area referente a área experimental.


CREATE TABLE area_exper (cod_area int PRIMARY KEY, nome varchar(30),
					geom geometry(polygon, 4326));


INSERT INTO area_exper (cod_area, nome, geom)
VALUES(1, 'Coxilha_UFSM',
		ST_GeometryFromText('POLYGON
	(( -53.73519920855001 -29.71758906756581,
	-53.73607191843379 -29.72047129272804,
	-53.73292026016089 -29.72176234594686,
	-53.72917692576969 -29.72147725436166,
	-53.73227643928092 -29.71686409624039,
	-53.73519920855001 -29.71758906756581))',4326));



	
CREATE OR REPLACE FUNCTION valida_talhao_em_area()
RETURNS TRIGGER AS $$
DECLARE
    geometria_area GEOMETRY;
BEGIN
    -- 1. Verifica se um CÓDIGO de area foi fornecido
    IF NEW.cod_area IS NULL THEN
        RAISE EXCEPTION 'Um  código da area experimental deve ser fornecido para o talhao.';
    END IF;

    -- 2. Busca a geometria da quadra correspondente ao cod_area
    SELECT geom INTO geometria_area
    FROM area_exper
    WHERE cod_area = NEW.cod_area;

    -- 3. Valida se a quadra existe e se a geometria do supermercado está dentro dela
    IF geometria_area IS NULL THEN
        RAISE EXCEPTION 'O código de quadra % não foi encontrado.', NEW.cod_area;
    ELSEIF NOT ST_Within(NEW.geom, geometria_area) THEN
        RAISE EXCEPTION 'A localização do talhao não está contida no polígono da area_exper %.', NEW.cod_area;
    END IF;

    -- Se todas as validações passarem, permite a operação
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_valida_talhao_em_area
BEFORE INSERT OR UPDATE ON talhao
FOR EACH ROW
EXECUTE FUNCTION valida_talhao_em_area();


-- TESTE, inserindo uma quadra que não pertence a area experimental

INSERT INTO talhao (cod, cod_area, geom) VALUES(8, 1, ST_GeometryFromText('POLYGON
(( -53.71895310633209 -29.7013767882367,
	-53.71820270938376 -29.70151136046411,
	-53.71842832133942 -29.69843231572172,
	-53.71918506265767 -29.69842772380483,
	-53.71895310633209 -29.7013767882367))',4326));



