CREATE EXTENSION postgis

-- Desenvolva um banco de dados que será formado pelas tabelas bairro, quadra, supermercado, auditoria.

CREATE TABLE quadra (cod_q int PRIMARY KEY, cod_bairro int,
					geom geometry(polygon, 4326),
					area decimal(10,2),
					perimetro decimal(10,2));


CREATE TABLE supermercado (cod_super int PRIMARY KEY, 
							nome varchar(30), cod_q integer,
							geom geometry(point, 4326));


CREATE TABLE auditoria(operacao varchar(1), usuario varchar(30),
					DATA timestamp, cod_super integer);

--Crie uma trigger para calcular a área e o perímetro da quadra

create or replace function fun_area_perimetro()
returns trigger as $$
begin
	new.area = st_area((st_transform(new.geom, 31982)))::decimal(10,2);
	new.perimetro = st_perimeter((st_transform(new.geom, 31982)))::decimal(10,2);
	
return new;
end;
$$
language 'plpgsql';

drop trigger if exists trg_area_perimetro on quadra;

create trigger trg_area_perimetro before insert or update
on quadra for each row execute procedure fun_area_perimetro();



--Na tabela supermercado crie um trigger para a tabela auditoria
--para que se tenha estes dados para cada código de supermercado que 
--seja incluído, alterado ou excluído na tabela supermercado, 

create function audit_func() returns trigger as $$
begin
	if (tg_op = 'DELETE') then
		insert into auditoria values('E', user, now(), old.cod_super);
		return old;
	elseif (tg_op = 'UPDATE') then
		insert into auditoria values('A', user, now(), old.cod_super);
		return new;
	elseif (tg_op = 'INSERT') then
		insert into auditoria values('I', user, now(), new.cod_super);
		return new;
	end if;
	return null;
end;
$$ language plpgsql;

drop trigger if exists tgr_super on supermercado;

create trigger tgr_super
after insert or update or delete on supermercado
for each row execute procedure audit_func();

-- Inserindo os dados

INSERT INTO quadra (cod_q, cod_bairro, geom) VALUES(1, 25, ST_GeometryFromText('POLYGON
(( -53.72225710082825 -29.70399668252264,
	-53.72224039933351 -29.70512137728255,
	-53.7215023933497 -29.70510710556664,
	-53.72152919446899 -29.70398152799388,
	-53.72225710082825 -29.70399668252264))',4326));

INSERT INTO quadra (cod_q, cod_bairro, geom) VALUES(2, 25, ST_GeometryFromText('POLYGON
(( -53.72310972336886 -29.70163167944245,
	-53.72306680944541 -29.7027203517324,
	-53.72242582381362 -29.70269684841508,
	-53.72247085580674 -29.70160796562403,
	-53.72310972336886 -29.70163167944245))',4326));

INSERT INTO quadra (cod_q, cod_bairro, geom) VALUES(3, 25, ST_GeometryFromText('POLYGON
(( -53.71895310633209 -29.7013767882367,
	-53.71820270938376 -29.70151136046411,
	-53.71842832133942 -29.69843231572172,
	-53.71918506265767 -29.69842772380483,
	-53.71895310633209 -29.7013767882367))',4326));

SELECT * FROM quadra

-- inserindo mercados

INSERT INTO supermercado (cod_super, nome, cod_q, geom) VALUES
(1, 'Beltrame', 1, ST_GeometryFromText('POINT
(-53.72175074624747 -29.70446849050046)', 4326));

INSERT INTO supermercado (cod_super, nome, cod_q, geom) VALUES
(2, 'Peruzzo', 2, ST_GeometryFromText('POINT
(-53.72267274197953 -29.70215813056025)', 4326));

INSERT INTO supermercado (cod_super, nome, cod_q, geom) VALUES
(3, 'Rede_Super', 3, ST_GeometryFromText('POINT
(-53.71880064257468 -29.70129052432226)', 4326));

SELECT * FROM supermercado
SELECT * FROM auditoria

