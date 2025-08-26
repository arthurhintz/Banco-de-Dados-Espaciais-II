CREATE EXTENSION postgis

CREATE TABLE quadra (cod int PRIMARY KEY,
					geom geometry(polygon, 4326));

-- INSERIR DADOS NA TABELA REFERENTE A QUADRA DO PLANETÁRIO:
INSERT INTO quadra (cod, geom) VALUES(1, ST_GeometryFromText('POLYGON
((-53.71755281454674 -29.72078228807198, -53.7164004950836 -29.72063672084071, -53.71661952242427 -29.71950925324215,
-53.71774350898254 -29.71966376647713, -53.71755281454674 -29.72078228807198 ))',4326));

alter table quadra add column area decimal(10,2);
alter table quadra add column perimetro decimal(10,2);

-- Se deixar todas as casas decimais das medidas
--alter table quadra add column area float;
--alter table quadra add column perimetro float;

update quadra set area = st_area(st_transform(geom, 31982))--::decimal(10,2);
update quadra set perimetro = st_perimeter(st_transform(geom, 31982))--::decimal(10,2);

select * from quadra


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


select * from quadra


-- Crie um gatilho para a tabela auditoria(operacao, usuario, data e hora, codigo da quadra)
--para que se tenha estes dados para cada código de quadra que seja manipulado na tabela quadra.
--Para testar o gatilho gere polígonos para duas quadras da UFSM a partir do Google Earth e armazene os dados na tabela quadra(cod, geom).

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
after insert or update or delete on quadra
for each row execute procedure audit_func();


INSERT INTO quadra (cod, geom) VALUES(2, ST_GeometryFromText('POLYGON
((-53.71617709264098 -29.71395467619807, 
	-53.71784935161741 -29.71416282592885, 
	-53.71755421692204 -29.71541477012698,
	-53.71592765770917 -29.71515251149921,
	-53.71617709264098 -29.71395467619807))',4326));


INSERT INTO quadra (cod, geom) VALUES(3, ST_GeometryFromText('POLYGON
(( -53.7188913390887 -29.72361707811206,
	-53.71725347539785 -29.72338386274055,
	-53.71749963749826 -29.72196765303488,
	-53.71906985152598 -29.72215822915445,
	-53.7188913390887 -29.72361707811206))',4326));



SELECT * FROM auditoria
SELECT * FROM quadra




