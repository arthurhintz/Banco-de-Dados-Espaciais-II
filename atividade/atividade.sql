CREATE EXTENSION postgis

-- O nome do bairro e das farmácias existentes em cada
--bairro. Utilize a função ST_CONTAINS.

SELECT b.nome as bairro, f.nome as farmacia
FROM bairros b, farmacia f
WHERE ST_Contains(b.geom, f.geom)



-- Calcule a área dos bairros e ordene o resultado em ordem
-- decrescente pela área.

SELECT nome, ST_Area(st_transform(geom, 31982)) AS area_m2
FROM bairros
ORDER BY area_m2 DESC;


-- 3) Calcule a distância entre as farmácias. A consulta deverá
-- mostrar o código, o nome de cada farmácia com a respectiva distância


SELECT f1.cod AS cod_farmacia_1, f1.nome AS farmacia_1,
    f2.cod AS cod_farmacia_2, f2.nome AS farmacia_2,
    ST_Distance(st_transform(f1.geom,31982), st_transform(f2.geom,31982)) AS distancia_m
FROM farmacia f1, farmacia f2
WHERE f1.cod < f2.cod;



-- 4) Calcule a área em hectares do município.

SELECT ST_Area(st_transform(geom,31982)) / 10000 AS area_ha
FROM municipio;


-- 5) Calcule a distância do hospital da Unimed em relação às farmácias. 

SELECT f.cod, f.nome,
    ST_Distance(st_transform(h.geom,31982), st_transform(f.geom,31982)) AS distancia_m
FROM farmacia f, hospital h
WHERE h.nome Like 'Unimed%'
ORDER BY distancia_m;




