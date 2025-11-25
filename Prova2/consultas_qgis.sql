-- 1. Listar todos os silos com seus códigos, nome, geom, ordenados pelo nome.
select cod, nome, geom
from silo
order by nome

-- 2. Encontrar propriedades agrícolas que estão dentro do limite do município.
select f.gid as Propriedades, f.geom 
from municipio m, fazendas f
where st_contains(m.geom, f.geom)

-- 3. Quais propriedades agrícolas estão até uma distância 7,5 km do silo.
select f.gid as propriedade, f.geom
from silo s, fazendas f
where st_dwithin(st_transform(s.geom, 31982), st_transform(f.geom, 31982), 7500)

-- 4. Apresente o código, a geometria e a área das propriedades agrícolas
select f.gid, f.geom, ST_Area(st_transform(f.geom, 31982)) AS area_m2
from fazendas f
order by area_m2

-- 5. Apresente o código, a geometria e o perímetro das propriedades agrícolas.
select f.gid, f.geom, st_perimeter(st_transform(f.geom, 31982)) AS perimetro
from fazendas f
order by perimetro

-- 6. Calcule a distância entre o centróide do município e o silo.
select st_distance(st_transform(silo.geom, 31982), st_transform(st_centroid(m.geom), 31982)) as distancia_metros
from silo, municipio m

-- 7. Encontre o número de propriedades agrícolas dos distritos que possuem propriedades
select d.gid as distrito, d.nome, count(f.gid) as total_propriedades
from distritos d, fazendas f
where st_contains(d.geom, f.geom)
group by d.gid, d.nome


