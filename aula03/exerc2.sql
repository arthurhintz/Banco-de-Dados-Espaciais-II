CREATE TABLE automovel(placa varchar(30) primary key, 
				marca varchar(30), modelo varchar(30),
				cor varchar (30));

CREATE TABLE pessoa(cod_pessoa varchar(30) primary key, 
				nome varchar(30), endereco varchar(30),
				sexo varchar (30));

CREATE TABLE propriedade(cod_propriedade varchar(30) primary key, 
				placa varchar(30), cod_pessoa varchar(30));


INSERT INTO automovel (placa, marca, modelo, cor)
VALUES('A1', 'Honda', 'Fit', 'Prata');
INSERT INTO automovel(placa, marca, modelo, cor)
VALUES('A2', 'Chevrolet', 'Astra', 'Branca');

INSERT INTO propriedade(cod_propriedade, placa, cod_pessoa)
VALUES('1', 'a1', 'P1');
INSERT INTO propriedade(cod_propriedade, placa, cod_pessoa)
VALUES('2', 'a2', 'P2');

INSERT INTO pessoa(cod_pessoa, nome, endereco, sexo)
VALUES ('p1', 'A', 'E1', 'M');
INSERT INTO pessoa(cod_pessoa, nome, endereco, sexo)
VALUES ('p2', 'b', 'E2', 'F');


-- 1) Criar um gatilho para a tabela auditoria (operacao, usuario, data e hora, código da
--propriedade) para que se tenham os dados referentes ao carro que foi adquirido
--por uma pessoa.

CREATE TABLE auditoria(operacao varchar(1), usuario varchar(30),
					DATA timestamp, cod_propriedade varchar(30));


create function audit_func() returns trigger as $$
begin
	if (tg_op = 'DELETE') then
		insert into auditoria values('E', user, now(), old.cod_propriedade);
		return old;
	elseif (tg_op = 'UPDATE') then
		insert into auditoria values('A', user, now(), old.cod_propriedade);
		return new;
	elseif (tg_op = 'INSERT') then
		insert into auditoria values('I', user, now(), new.cod_propriedade);
		return new;
	end if;
	return null;
end;
$$ language plpgsql;


create trigger empregado_audit
after insert or update or delete on propriedade
for each row execute procedure audit_func();


-- 2) Cadastre um novo automóvel na respectiva tabela: automovel 

INSERT INTO automovel(placa, marca, modelo, cor)
VALUES('A3', 'Fiat', 'Palio', 'Preto')

--3) Insira os dados abaixo para testar o gatilho: 

INSERT INTO propriedade(cod_propriedade, placa, cod_pessoa)
VALUES (3, 'A3', 'p2')


SELECT * FROM auditoria

