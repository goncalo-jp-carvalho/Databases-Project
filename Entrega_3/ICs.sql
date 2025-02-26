/* Neste ficheiro estao  as restricoes referentes ao ponto 2 do projeto*/

drop function if exists check_diferentes_categorias() cascade;
drop function if exists get_numero_maximo_de_unidades_planograma(
  ean CHAR(13), nro INTEGER, num_serie NUMERIC(8,0), fabricante VARCHAR(255)) cascade;
drop function if exists check_numero_valido_de_unidades() cascade;
drop function if exists check_categorias_coincidentes(
  ean CHAR(13), nro INTEGER, num_serie NUMERIC(8,0), fabricante VARCHAR(255)) cascade;
drop function if exists check_produto_pode_ser_reposto_na_prateleira() cascade;

drop trigger if exists categoria_NOT_contida_nela_mesma ON Tem_outra;
drop trigger if exists evento_reposicao_valido ON Evento_reposicao;
drop trigger if exists prateleira_valida_reposicao ON Evento_reposicao;

/* (RI-1) Uma categoria nao pode estar contida nela propria*/

CREATE FUNCTION check_diferentes_categorias()
RETURNS TRIGGER
AS
$$
BEGIN
  IF NEW.categoria = NEW.super_categoria THEN
    RAISE EXCEPTION 'Categoria e super categoria sao iguais';
  END IF;
  RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER categoria_NOT_contida_nela_mesma
BEFORE INSERT ON Tem_outra
FOR EACH ROW EXECUTE FUNCTION check_diferentes_categorias();

/* (RI-4) O numero de unidades repostas num Evento de Reposicao nao pode exceder
 o numero de unidades especificado no Planograma */

CREATE FUNCTION get_numero_maximo_de_unidades_planograma(
  ean_arg CHAR(13), nro_arg INTEGER, num_serie_arg NUMERIC(8,0), fabricante_arg VARCHAR(255))
  RETURNS INTEGER
  AS
  $$
  DECLARE num_unidades INTEGER;
  BEGIN
    SELECT SUM(Planograma.unidades) INTO num_unidades
      FROM Planograma
      WHERE (Planograma.ean = ean_arg AND Planograma.nro = nro_arg AND Planograma.num_serie = num_serie_arg
          AND Planograma.fabricante = fabricante_arg);
    RETURN num_unidades;
  END
  $$
  LANGUAGE plpgsql;

CREATE FUNCTION check_numero_valido_de_unidades()
RETURNS TRIGGER
AS
$$
BEGIN
  IF get_numero_maximo_de_unidades_planograma(NEW.ean,NEW.nro,NEW.num_serie,NEW.fabricante)
   < NEW.unidades THEN
    RAISE EXCEPTION 'Numero de unidades repostas excede as previstas';
  END IF;
  RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER evento_reposicao_valido
BEFORE INSERT ON Evento_reposicao
FOR EACH ROW EXECUTE FUNCTION check_numero_valido_de_unidades();

/* (RI-5) Um Produto so pode ser reposto numa Prateleira que apresente (pelo menos)
 uma das Categorias desse produto */

CREATE FUNCTION check_categorias_coincidentes(
  ean_arg CHAR(13), nro_arg INTEGER, num_serie_arg NUMERIC(8,0), fabricante_arg VARCHAR(255))
  RETURNS INTEGER
  AS
  $$
  DECLARE num_categorias_coincidentes INTEGER;
  BEGIN
    SELECT COUNT(*) INTO num_categorias_coincidentes
      FROM ((SELECT Tem_categoria.nome
        FROM Tem_categoria
        WHERE Tem_categoria.ean = ean_arg) AS categorias_do_produto
        INNER JOIN (
          SELECT Prateleira.nome
            FROM Prateleira
            WHERE (Prateleira.nro = nro_arg AND Prateleira.num_serie = num_serie_arg AND
            Prateleira.fabricante = fabricante_arg)) AS categorias_da_prateleira ON
            categorias_da_prateleira.nome = categorias_do_produto.nome) AS categorias_coincidentes;
    RETURN num_categorias_coincidentes;
  END
  $$
  LANGUAGE plpgsql;

CREATE FUNCTION check_produto_pode_ser_reposto_na_prateleira()
RETURNS TRIGGER AS
$$
BEGIN
  IF check_categorias_coincidentes(NEW.ean, NEW.nro,NEW.num_serie,NEW.fabricante) = 0 THEN
    RAISE EXCEPTION 'Prateleira nao pode armazenar o produto selecionado';
  END IF;
  RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER prateleira_valida_reposicao
BEFORE INSERT ON Evento_reposicao
FOR EACH ROW EXECUTE FUNCTION check_produto_pode_ser_reposto_na_prateleira();
