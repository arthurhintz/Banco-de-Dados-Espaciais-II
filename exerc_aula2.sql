-- Criando as tabelas
CREATE TABLE marin(mid integer primary key, 
				mnome varchar(30), status integer,
				idade numeric(10,2));

CREATE TABLE barcos(bid integer primary key, 
				bnome varchar(30), cor varchar(30));

CREATE TABLE reservas(rid integer primary key, mid integer,
					bid integer, dia date)


-- Os dados serão inserindo pelo arquivo csv




-- 1) Criar um gatilho para a tabela auditoria(operacao, usuário, data e hora, codigo do
-- marinheiro) para ver qual usuário fez a reserva e em que data e horário.


CREATE TABLE func_auditoria(operacao varchar(1), usuario varchar(30),
					DATA timestamp, mid integer)


-- 2) Criar um gatilho que antes da inserção na tabela MARIN verifica se o nome do
-- marinheiro é nulo.

create function processa_audit_func() returns trigger as $$
begin
	if (tg_op = 'DELETE') then
		insert into func_auditoria values('E', user, now(), old.mid);
		return old;
	elseif (tg_op = 'UPDATE') then
		insert into func_auditoria values('A', user, now(), old.mid);
		return new;
	elseif (tg_op = 'INSERT') then
		insert into func_auditoria values('I', user, now(), new.mid);
		return new;
	end if;
	return null;
end;
$$ language plpgsql;


CREATE FUNCTION verifica() returns trigger as  $$
begin 
	if new.mnome is null then 
		raise exception 'o nome do marinheiro não pode ser nulo';
	end if;
	return new;
end;
$$ language plpgsql


--trigger

create trigger funcionario_audit
after insert or update or delete on reservas
for each row execute procedure processa_audit_func();

CREATE TRIGGER novo_func before insert on marin
for each row execute procedure verifica()

-- verificando a função

INSERT INTO marin(mid, status, idade)
VALUES (30, 3, 20)

