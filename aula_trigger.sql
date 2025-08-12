CREATE TABLE func(cod integer primary key, 
				nome varchar(30), salario decimal(10,2),
				comissao decimal(10,2))


CREATE TABLE func_auditoria(operacao varchar(1), usuario varchar(30),
					DATA timestamp, nome_func varchar(40),
					salario decimal(10,2))


-- funcao para armazenar as observações que forem deletadas ou alteradas ou inseridas.
create function processa_audit_func() returns trigger as $$
begin
	if (tg_op = 'DELETE') then
		insert into func_auditoria values('E', user, now(), old.nome, old.salario);
		return old;
	elseif (tg_op = 'UPDATE') then
		insert into func_auditoria values('A', user, now(), old.nome, old.salario);
		return new;
	elseif (tg_op = 'INSERT') then
		insert into func_auditoria values('I', user, now(), new.nome, new.salario);
		return new;
	end if;
	return null;
end;
$$ language plpgsql;

--trigger
create trigger funcionario_audit
after insert or update or delete on func
for each row execute procedure processa_audit_func()


-- Testando a execução

INSERT INTO func VALUES(1, 'João', 1800, 500) 

UPDATE func SET salario = 2000 WHERE cod = 1

DELETE FROM func
WHERE cod = 1
















