
CREATE TABLE departamento(num_dept integer primary key, 
				nome varchar(30), ramal decimal(10,2));

CREATE TABLE empregado(num_emp integer primary key, 
				nome_emp varchar(30), salario decimal(10,2),
				num_dept integer,
				FOREIGN KEY(num_dept) REFERENCES departamento(num_dept))


INSERT INTO departamento(num_dept, nome, ramal)
VALUES(21, 'Pessoal', 142);
INSERT INTO departamento(num_dept, nome, ramal)
VALUES(25, 'Financeiro', 143);
INSERT INTO departamento(num_dept, nome, ramal)
VALUES(28, 'Tecnico', 144);

INSERT INTO empregado(num_emp, nome_emp, salario, num_dept)
VALUES(32, 'J Silva', 3800, 21);
INSERT INTO empregado(num_emp, nome_emp, salario, num_dept)
VALUES(74, 'M Reis', 4000, 25);
INSERT INTO empregado(num_emp, nome_emp, salario, num_dept)
VALUES(89, 'C Melo', 5200, 28);
INSERT INTO empregado(num_emp, nome_emp, salario, num_dept)
VALUES(92, 'R Silva', 4800, 25);
INSERT INTO empregado(num_emp, nome_emp, salario, num_dept)
VALUES(112, 'R Pinto', 3900, 21);
INSERT INTO empregado(num_emp, nome_emp, salario, num_dept)
VALUES(121, 'V Simao', 1905, 28);
INSERT INTO empregado(num_emp, nome_emp, salario, num_dept)
VALUES(130, 'J Neves', 6400, 28);

--Criar um gatilho para a tabela auditoria (operacao, usuario, data e hora, número
--do departamento) para que se tenham os dados de quando um departamento recebeu um
--empregado novo. 

CREATE TABLE auditoria(operacao varchar(1), usuario varchar(30),
					DATA timestamp, num_dept integer)


create function audit_func() returns trigger as $$
begin
	if (tg_op = 'DELETE') then
		insert into auditoria values('E', user, now(), old.num_dept);
		return old;
	elseif (tg_op = 'UPDATE') then
		insert into auditoria values('A', user, now(), old.num_dept);
		return new;
	elseif (tg_op = 'INSERT') then
		insert into auditoria values('I', user, now(), new.num_dept);
		return new;
	end if;
	return null;
end;
$$ language plpgsql;


create trigger empregado_audit
after insert or update or delete on empregado
for each row execute procedure audit_func();


INSERT INTO empregado(num_emp, nome_emp, salario, num_dept)
VALUES (132, 'L Hint', 3500, 28)

SELECT * FROM auditoria






