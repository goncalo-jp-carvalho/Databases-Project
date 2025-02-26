/* 7.1 */

/*
 Esta query pode ser otimizada ao criar-se um índice hash sobre o atributo tin da tabela retalhista. 
 Isto permite que o join das tabelas possa usar um inner index scan.
 É possível também melhorar a query com um outro indíce hash sobre o atributo nome_cat da tabela responsavel_por. 
 Isto permite usar um index only scan para verificar a igualdade.
 O facto das condições serem igualdades torna o uso de índices hash preferível.
*/
CREATE INDEX IX_retalhista_tin ON retalhista USING HASH(tin);

CREATE INDEX IX_responsavel_por_nome_cat ON responsavel_por USING HASH(nome_cat);

/* 7.2 */

/*
Esta query pode ser otimizada ao criar-se um índice hash sobre o atributo cat da tabela produto,
facilitando o join entre as duas tabelas. 
Pode-se também criar um segundo índice B+ Tree no atributo descr do produto, pois a operação "like 'A%'"
é tornada mais eficiente quando as descrições do produto já se encontram agrupadas alfabeticamente.
*/

CREATE INDEX IX_produto_cat ON produto USING HASH(cat);

CREATE INDEX IX_produto_descr ON produto(descr);
