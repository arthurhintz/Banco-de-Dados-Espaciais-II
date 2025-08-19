CREATE TABLE cliente(cod_cliente integer primary key, 
				nome varchar(30), cpf varchar(14));

CREATE TABLE conta(num_cta integer primary key, 
				saldo decimal(10,2), limite decimal(10,2),
				cod_cliente integer,
				FOREIGN KEY(cod_cliente) REFERENCES cliente(cod_cliente));

INSERT INTO cliente(cod_cliente, nome, cpf)
VALUES(1, 'Jose', 21875638735);
INSERT INTO cliente(cod_cliente, nome, cpf)
VALUES(2, 'Maria', 30045667856);

INSERT INTO conta(num_cta, saldo, limite, cod_cliente)
VALUES(1, 1000, 500, 1);
INSERT INTO conta(num_cta, saldo, limite, cod_cliente)
VALUES(2, 2000, 700, 2)

--Criar um gatilho para a tabela auditoria (operacao, usuario, data e hora, número
--da conta) para que se tenham os dados da conta onde o limite foi alterado

CREATE TABLE auditoria(operacao varchar(1), usuario varchar(30),
					DATA timestamp, num_cta integer);


create function audit_func() returns trigger as $$
begin
	if (tg_op = 'DELETE') then
		insert into auditoria values('E', user, now(), old.num_cta);
		return old;
	elseif (tg_op = 'UPDATE') then
		insert into auditoria values('A', user, now(), old.num_cta);
		return new;
	elseif (tg_op = 'INSERT') then
		insert into auditoria values('I', user, now(), new.num_cta);
		return new;
	end if;
	return null;
end;
$$ language plpgsql;


create trigger empregado_audit
after insert or update or delete on conta
for each row execute procedure audit_func();

--2)Altere o limite da conta do cliente 2 para testar o gatilho: 

UPDATE conta SET limite = 3000 WHERE cod_cliente = 2

SELECT * FROM auditoria


