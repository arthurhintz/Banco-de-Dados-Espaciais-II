
-- funçao para verificar o nome da pessoa não é nulo

CREATE FUNCTION verifica() returns trigger as  $$
begin 
	if new.nome is null then 
		raise exception 'o nome do funcionario não pode ser nulo';
	end if;
	return new;
end;
$$ language plpgsql


CREATE TRIGGER novo_func before insert or update on func
for each row execute procedure verifica()

-- testando a trigger

INSERT INTO func(cod, salario, comissao) 
VALUES (2, 2400, 700)

INSERT INTO func(cod,nome, salario, comissao) 
VALUES (2, 'Paulo', 2400, 700)

