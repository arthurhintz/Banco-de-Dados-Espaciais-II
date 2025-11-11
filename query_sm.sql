CREATE EXTENSION postgis

--1) Qual a distância entre as feiras e a feira da Avenida Roraima no bairro de Camobi?

-- Exemplo: assumindo que o SRID correto seja 4326
UPDATE mercados
SET geom = ST_SetSRID(geom, 4326)
WHERE ST_SRID(geom) = 0;

SELECT DISTINCT ST_SRID(geom) FROM mercados;

SELECT m1.endereco, m2.endereco, st_distance(st_Transform(m1.geom, 31982),
st_Transform(m2.geom, 31982)) AS distancia
FROM mercados as m1, mercados as m2
WHERE m1.cod = 1

--2) Encontre o nome e a geometria das feiras por bairro? Utilize a função ST_CONTAINS.

SELECT m.nome AS nome_feira, m.geom AS geom_feira,
	b.nome AS nome_bairro
FROM mercados AS m, bairro AS b
WHERE ST_Contains(b.geom, m.geom);

--3) Quantas feiras existem por bairro?

SELECT b.nome AS nome_bairro, COUNT(m.*) AS total_feiras
FROM mercados AS m, bairro AS b
WHERE ST_Contains(b.geom, m.geom)
GROUP BY b.nome;

--4) Quantas feiras existem no bairro Centro?

SELECT b.nome AS nome_bairro, COUNT(m.*) AS total_feiras
FROM mercados AS m, bairro AS b
WHERE ST_Contains(b.geom, m.geom) and b.nome = 'Centro'
GROUP BY b.nome

--5) Qual a área dos bairros?

SELECT st_area(st_transform(b.geom, 31982))/1000000 as area_bairro_km2, b.nome
FROM bairro as b
ORDER BY area_bairro_km2

--6) Qual o perímetro dos bairros?

SELECT b.nome AS nome_bairro, ST_Perimeter(ST_Transform(b.geom, 31982)) AS perimetro_metros
FROM bairro AS b
ORDER BY perimetro_metros

--7) Listar os campos gid, name e geom de todas as feiras e ordene pelo name. Utilize
--o comando st_astext para listar a coluna geom.

SELECT cod, nome, st_astext(geom)
FROM mercados
ORDER BY nome

-- 8) Distância média entre as feiras e o centróide do município
SELECT AVG(st_distance(st_transform(f.geom,31982), st_transform(st_centroid(m.geom), 31982))) as distancia_media_metros
FROM mercados f, cidade m

-- 9) Feiras mais próximas da feira da Avenida Roraima (bairro Camobi)
SELECT f2.nome as feira_proxima, st_distance(st_transform(f1.geom, 31982), st_transform(f2.geom, 31982)) as distancia_metros
FROM mercados f1, mercados f2
WHERE f1.endereco ilike 'Avenida Roraima'
and f1.nome <> f2.nome
order by distancia_metros ASC
limit 1;

--10) feiras dentro de um buffer de 500m da feira da Avenida Roraima
SELECT f2.nome as feira_proxima, st_distance(st_transform(f1.geom, 31982), st_transform(f2.geom, 31982)) as distancia_metros
FROM mercados f1, mercados f2
WHERE f1.endereco ilike 'Avenida Roraima' and st_dwithin(st_transform(f1.geom, 31982), st_transform(f2.geom, 31982), 500)
and f1.cod <> f2.cod

--11) Feiras próximas à fronteira entre dois bairos
SELECT f.nome as feira, st_astext(f.geom), b1.nome as bairro1, b2.nome as bairro2
FROM bairro b1, bairro b2, mercados f
WHERE b1.cod_bairro < b2.cod_bairro
and st_touches(st_transform(b1.geom, 31982), st_transform(b2.geom, 31982))
and st_dwithin(st_transform(f.geom, 31982), st_transform(st_intersection(b1.geom, b2.geom), 31982), 50)


