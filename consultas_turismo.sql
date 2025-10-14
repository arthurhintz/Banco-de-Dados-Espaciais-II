-- 1) Qual a distância entre o Santuário Basílica Nossa Senhora da Medianeira e os
-- pontos de hospedagem?

SELECT pt.nome, hl.nome, st_distance(st_Transform(pt.geom, 31982),
st_Transform(hl.geom, 31982)) AS distancia
FROM ponto_turistico as pt, hospedagem as hl
WHERE pt.cod_ponto = 1
ORDER BY distancia ASC

-- 2) Qual a distância entre os pontos turísticos Santuário Basílica e a Catedral?

SELECT pt.nome, pt2.nome, st_distance(st_Transform(pt.geom, 31982),
st_Transform(pt2.geom, 31982)) AS distancia
FROM ponto_turistico as pt, ponto_turistico as pt2
WHERE pt.cod_ponto = 1 and pt2.cod_ponto = 2

--3) Busque o nome e a coordenada dos pontos turísticos e o nome das ruas onde
--estão localizados.

SELECT pt.nome, rua.nome, pt.geom
FROM ponto_turistico as pt, rua 
WHERE pt.cod_rua = rua.cod_rua

--4) Recuperar os diferentes códigos de rua da tabela ponto_turistico.

SELECT pt.nome, pt.cod_rua
FROM ponto_turistico as pt

--5) Recuperar os pontos turísticos que seu nome inicie com a letra S.

SELECT *
FROM ponto_turistico as pt
WHERE pt.nome LIKE 'S%'

--6) Encontrar quantos pontos turísticos tem por rua.

SELECT COUNT(cod_rua), pt.cod_rua
FROM ponto_turistico as pt
GROUP BY pt.cod_rua

--7)Encontrar quantas hospedagens tem por rua.

SELECT COUNT(hl.cod_rua), hl.cod_rua
FROM hospedagem as hl
GROUP BY hl.cod_rua

--8) Listar os pontos turísticos em ordem crescente pelo nome.

SELECT *
FROM ponto_turistico as pt
ORDER BY pt.nome ASC

--9) Listar os pontos turísticos em ordem decrescente pelo nome.

SELECT *
FROM ponto_turistico as pt
ORDER BY pt.nome DESC

--10) Liste os bairros com código entre 15 e 30.

SELECT * 
FROM bairro as b
WHERE b.cod_bairro between 15 and 30

