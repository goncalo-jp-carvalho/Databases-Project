
/* Query 1 */
/* Qual o nome do retalhista (ou retalhistas) responsáveis pela reposição do maior número de 
categorias? */

SELECT nome
FROM retalhista
JOIN (SELECT tin
	    FROM (SELECT tin, COUNT(nome_cat) AS n_ocorrencias
	  		    FROM responsavel_por
	  	      GROUP BY tin) AS aux_table
	    WHERE n_ocorrencias = (SELECT MAX(n_ocorrencias) 
					  		            FROM(SELECT tin, COUNT(nome_cat) AS n_ocorrencias
	  				 			              FROM responsavel_por
	  							          GROUP BY tin) AS aux_table2)) AS aux_table3
  ON retalhista.tin = aux_table3.tin;

/* Query 2 */
/* Qual o nome do ou dos retalhistas que são responsáveis por todas as categorias simples? */

SELECT nome
FROM (SELECT responsavel_por.nome_cat, tin
      FROM responsavel_por
      INNER JOIN  categoria_simples
      ON responsavel_por.nome_cat = categoria_simples.nome
      GROUP BY responsavel_por.nome_cat,tin) AS aux_table
INNER JOIN retalhista
ON aux_table.tin = retalhista.tin
GROUP BY nome;


/* Query 3 */
/* Quais os produtos (ean) que nunca foram repostos? */

SELECT ean
FROM produto
WHERE ean NOT IN (SELECT ean
                  FROM evento_reposicao);

/* Query 4 */
/* Quais os produtos (ean) que foram repostos sempre pelo mesmo retalhista? */

SELECT ean
FROM (SELECT ean, count(ean) as n_ocorrencias
	    FROM (SELECT ean, tin
     	      FROM evento_reposicao
            GROUP BY ean, tin) AS aux_table1 
	    GROUP by ean) AS aux_table2
WHERE n_ocorrencias = 1;
