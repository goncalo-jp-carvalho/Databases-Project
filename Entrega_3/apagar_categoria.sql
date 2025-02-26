DELETE Planograma WHERE Planograma.ean IN (
SELECT Tem_categoria.ean FROM Tem_categoria
  WHERE Tem_categoria.nome = 'Barras de Cereais');
