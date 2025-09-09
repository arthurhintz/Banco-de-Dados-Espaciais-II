CREATE EXTENSION postgis

--  Crie um banco de dados para armazenar o polígono do campus da UFSM, a ser obtido por meio do QuickOSM no QGIS 
--e gerado um shapefile para ser importado no banco de dados.


--Crie uma tabela predio com os campos número, nome e a geometria referente ao polígono do prédio.
CREATE TABLE predio (cod_pred int PRIMARY KEY, nome varchar(30),
					geom geometry(polygon, 4326));

					

--Crie uma trigger para calcular a área e o perímetro de 
--3 prédios que contenham restaurantes, lanchonetes ou café próximos ao Politécnico, que serão inseridos no banco de dados.

alter table predio add column area decimal(10,2);
alter table predio add column perimetro decimal(10,2);

create or replace function fun_area_perimetro()
returns trigger as $$
begin
	new.area = st_area((st_transform(new.geom, 31982)))::decimal(10,2);
	new.perimetro = st_perimeter((st_transform(new.geom, 31982)))::decimal(10,2);
	
return new;
end;
$$
language 'plpgsql';

drop trigger if exists trg_area_perimetro on predio;

create trigger trg_area_perimetro before insert or update
on predio for each row execute procedure fun_area_perimetro();


INSERT INTO predio (cod_pred,nome, geom) VALUES(1, 'Poli', ST_GeometryFromText('POLYGON
(( -53.71812034861461 -29.72273250543835,
	-53.71810478901037 -29.72281485731515,
	-53.71793813208609 -29.72279310632616,
	-53.7179562887961 -29.72271305631778,
	-53.71812034861461 -29.72273250543835))',4326));

INSERT INTO predio (cod_pred,nome, geom) VALUES(2, 'Letras', ST_GeometryFromText('POLYGON
(( -53.71966511722918 -29.71949680771266,
	-53.71964199535156 -29.71959454232726,
	-53.71935052577443 -29.7195493097168,
	-53.71938640278759 -29.71945291676392,
	-53.71966511722918 -29.71949680771266))',4326));

INSERT INTO predio (cod_pred,nome, geom) VALUES(3, 'RU', ST_GeometryFromText('POLYGON
(( -53.714911923931 -29.71708532245609,
	-53.71483270120692 -29.71751420605882,
	-53.71427888828813 -29.71743716748482,
	-53.71433198701757 -29.71700636577072,
	-53.714911923931 -29.71708532245609))',4326));

SELECT * FROM predio

-- Gere pontos para 3 restaurantes, lanchonetes ou café próximos ao Politécnico a partir do Google Earth e
--armazene na tabela restaurante(cod, nome, geom).


CREATE TABLE restaurante (cod int PRIMARY KEY, nome varchar(30), cod_pred int,
					geom geometry(point, 4326));

INSERT INTO restaurante (cod, nome, cod_pred, geom) VALUES
(1, 'cantina_poli', 1, ST_GeometryFromText('POINT
(-53.71703950180549 -29.72235080149314)', 4326));

INSERT INTO restaurante (cod, nome, cod_pred, geom) VALUES
(2, 'oba', 2, ST_GeometryFromText('POINT
(-53.71804450184371 -29.71962883128456)', 4326));


--Posteriormente, crie um gatilho para a tabela auditoria(operacao, usuario, data e hora, codigo do restaurante)
--para que se tenha estes dados para cada código de restaurante que seja manipulado na tabela restaurante.

CREATE TABLE auditoria(operacao varchar(1), usuario varchar(30),
					DATA timestamp, cod integer);


create function audit_func() returns trigger as $$
begin
	if (tg_op = 'DELETE') then
		insert into auditoria values('E', user, now(), old.cod);
		return old;
	elseif (tg_op = 'UPDATE') then
		insert into auditoria values('A', user, now(), old.cod);
		return new;
	elseif (tg_op = 'INSERT') then
		insert into auditoria values('I', user, now(), new.cod);
		return new;
	end if;
	return null;
end;
$$ language plpgsql;

create trigger gatilho_quadra
after insert or update or delete on restaurante
for each row execute procedure audit_func();

-- Teste

INSERT INTO restaurante (cod, nome, geom) VALUES
(3, 'ru', 3, ST_GeometryFromText('POINT
(-53.71419867794467 -29.71897564631017)', 4326));


SELECT * FROM auditoria


-- No banco de dados criado para realização do exercício 3 da aula 4, 
--acrescente à tabela restaurante o código do prédio e crie um gatilho
--para verificar se a geometria do restaurante está dentro do polígono do prédio.


CREATE OR REPLACE FUNCTION valida_resta_predio()
RETURNS TRIGGER AS $$
DECLARE
    geometria_area GEOMETRY;
BEGIN
    -- 1. Verifica se um CÓDIGO de area foi fornecido
    IF NEW.cod_pred IS NULL THEN
        RAISE EXCEPTION 'Um  código da area experimental deve ser fornecido para o talhao.';
    END IF;

    -- 2. Busca a geometria da quadra correspondente ao cod_area
    SELECT geom INTO geometria_area
    FROM predio
    WHERE cod_pred = NEW.cod_pred;

    -- 3. Valida se a quadra existe e se a geometria do supermercado está dentro dela
    IF geometria_area IS NULL THEN
        RAISE EXCEPTION 'O código de quadra % não foi encontrado.', NEW.cod_pred;
    ELSEIF NOT ST_Within(NEW.geom, geometria_area) THEN
        RAISE EXCEPTION 'A localização do restaurante não está contida no polígono do predio %.', NEW.cod_pred;
    END IF;

    -- Se todas as validações passarem, permite a operação
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_valida_resta_predio
BEFORE INSERT OR UPDATE ON restaurante
FOR EACH ROW
EXECUTE FUNCTION valida_resta_predio();


-- Teste

INSERT INTO restaurante (cod, nome, cod_pred, geom) VALUES
(3, 'ru', 2, ST_GeometryFromText('POINT
(-53.71473506671047 -29.71729529023116)', 4326));

INSERT INTO restaurante (cod, nome, cod_pred, geom) VALUES
(3, 'ru', 3, ST_GeometryFromText('POINT
(-53.71473506671047 -29.71729529023116)', 4326));
