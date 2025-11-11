select mercados.geom from bairro, mercados

where st_contains(bairro.geom, mercados.geom)

and bairro.nome = 'Camobi'