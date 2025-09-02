CREATE EXTENSION postgis

--Crie um banco de dados para armazenar os polígonos da Área Experimental da UFSM, indicados na figura,
--os quais devem ser digitalizados no Google Earth para obtenção das coordenadas.
--Crie uma trigger para calcular a área e o perímetro dos talhões a serem inseridos no banco de dados.

CREATE TABLE talhao (cod int PRIMARY KEY, cod_area integer,
					geom geometry(polygon, 4326));


alter table talhao add column area decimal(10,2);
alter table talhao add column perimetro decimal(10,2);

create or replace function fun_area_perimetro()
returns trigger as $$
begin
	new.area = st_area((st_transform(new.geom, 31982)))::decimal(10,2);
	new.perimetro = st_perimeter((st_transform(new.geom, 31982)))::decimal(10,2);
	
return new;
end;
$$
language 'plpgsql';

drop trigger if exists trg_area_perimetro on talhao;

create trigger trg_area_perimetro before insert or update
on talhao for each row execute procedure fun_area_perimetro();


-- Inserindo dados

INSERT INTO talhao (cod, cod_area,geom) VALUES(1, 1,ST_GeometryFromText('POLYGON
(( -53.73368974181002 -29.71721494817317,
		-53.73398320187583 -29.71898631813294,
		-53.73359919220663 -29.71914284800592,
		-53.73315909232581 -29.71920004497157,
		-53.73210130029255 -29.71859090024241,
		-53.73235463241621 -29.71693541409159,
		-53.73368974181002 -29.71721494817317))',4326));


INSERT INTO talhao (cod, cod_area, geom) VALUES(2,1, ST_GeometryFromText('POLYGON
(( -53.73475985798689 -29.71752220003811,
	-53.73526135146454 -29.71763978506916, 
	-53.73531974872429 -29.71788825409705,
	-53.73530739393839 -29.71813213963011,
	-53.73544653602769 -29.71843611184721,
	-53.73462677001177 -29.71859720977528,
	-53.73462111707556 -29.71807040519297,
	-53.73475985798689 -29.71752220003811))',4326));

INSERT INTO talhao (cod,cod_area, geom) VALUES(3,1, ST_GeometryFromText('POLYGON
(( -53.73550977916403 -29.71857791189412,
	-53.73607993512331 -29.72035846241499,
	-53.73534705789088 -29.72030851148511,
	-53.73507413474995 -29.72045358684376,
	-53.73487543057054 -29.72072174085852,
	-53.734389389942 -29.71934934487121,
	-53.7346618740963 -29.71883048172944,
	-53.73550977916403 -29.71857791189412))',4326));
	
INSERT INTO talhao (cod,cod_area, geom) VALUES(4,1, ST_GeometryFromText('POLYGON
(( -53.73333362394837 -29.7196134197456,
	-53.73221524139083 -29.72060712578091,
	-53.73163286951691 -29.72177745605734,
	-53.7299350173342 -29.72171867800326,
	-53.72938600559303 -29.72108157183076,
	-53.73088954550719 -29.71892528786184, 
	-53.73137060946071 -29.71838691656466,
	-53.73174453319184 -29.71852279982906, 
	-53.7314437430197 -29.71909578247441,
	-53.73228278884112 -29.71957408420064,
	-53.73333362394837 -29.7196134197456))',4326));


INSERT INTO talhao (cod,cod_area, geom) VALUES(5,1, ST_GeometryFromText('POLYGON
(( -53.73433510839314 -29.71938941928779,
	-53.73486019978724 -29.72083524548091,
	-53.73475399988761 -29.72140753599267,
	-53.73280732587624 -29.72166989601095,
	-53.73260951440932 -29.72112440443989,
	-53.73303769737456 -29.72033311714463,
	-53.73433510839314 -29.71938941928779))',4326));

SELECT * from talhao
