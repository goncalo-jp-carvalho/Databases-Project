CREATE VIEW Vendas(ean,cat,ano,trimestre,mes,dia_mes,dia_semana,distrito,concelho,unidades)
AS
SELECT er.ean,p.cat,EXTRACT(YEAR FROM er.instante),EXTRACT(Quarter FROM er.instante),
EXTRACT(MONTH FROM er.instante),EXTRACT(DAY FROM er.instante), EXTRACT(DOW FROM er.instante),pr.distrito,pr.concelho,er.unidades
  FROM Evento_reposicao er
  NATURAL JOIN produto p
  JOIN Instalada_em ie on er.num_serie = ie.num_serie and er.fabricante = ie.fabricante
  JOIN Ponto_de_retalho pr on ie.local = pr.nome;
