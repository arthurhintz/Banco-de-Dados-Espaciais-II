-- 1) Quais os nomes e a geometria das hospedagens localizadas na rua Nossa Senhora das Dores?

select h.nome, h.geom
from hospedagem h, rua
where h.cod_rua = 'Avenida Nossa Senhora das Dores'

-- 2) Quais os nomes e a geometria das hospedagens localizados no bairro Cerrito?

select h.nome, h.geom
from hospedagem h, bairro b
where st_contains(b.geom, h.geom) and b.nome = 'Cerrito'

-- 3) Quais os nomes e a geometria das hospedagens localizados no bairro Camobi?

select h.nome, h.geom
from hospedagem h, bairro b
where st_contains(b.geom, h.geom) and b.nome = 'Camobi'

-- Quais os nomes e a geometria dos pontos turísticos localizados na rua Nossa Senhora das Dores

select pt.nome, pt.geom
from ponto_turistico pt
where pt.cod_rua = 3

-- Quais os nomes e a geometria das hospedagens que estão à 5 km de Camobi?

select h.nome, h.geom
from hospedagem h, bairro b
where st_dwithin(st_transform(h.geom, 31982), st_transform(b.geom, 31982), 5000) and b.nome = 'Camobi'




