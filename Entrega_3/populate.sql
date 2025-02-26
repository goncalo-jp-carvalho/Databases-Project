drop function if exists in_super_categoria(name VARCHAR(255)) cascade;
drop function if exists in_categoria_simples(name VARCHAR(255)) cascade;
drop function if exists in_tem_outra(super_category varchar(255)) cascade;
drop function if exists in_tem_categoria(ean_aux CHAR(13)) cascade;
drop function if exists insert_super_categoria() cascade;
drop function if exists insert_categoria() cascade;
drop function if exists delete_categoria() cascade;
drop function if exists delete_Retalhista() cascade;

drop trigger if exists exists_super_categoria ON Tem_outra;
drop trigger if exists insert_into_categoria ON Categoria_simples;
drop trigger if exists erase_categoria ON Categoria;
drop trigger if exists erase_retalhista ON Retalhista;

drop table if exists categoria cascade;
drop table if exists categoria_simples cascade;
drop table if exists Evento_reposicao cascade;
drop table if exists instalada_em cascade;
drop table if exists ivm cascade;
drop table if exists planograma cascade;
drop table if exists ponto_de_retalho cascade;
drop table if exists prateleira cascade;
drop table if exists produto cascade;
drop table if exists responsavel_por cascade;
drop table if exists retalhista cascade;
drop table if exists super_categoria cascade;
drop table if exists tem_categoria cascade;
drop table if exists tem_outra cascade;

/* Functions*/

CREATE FUNCTION in_super_categoria(name varchar(255))
RETURNS INTEGER
AS
$$
DECLARE pertence_a_super INTEGER;
BEGIN
  SELECT COUNT(Super_categoria.nome) INTO pertence_a_super
    FROM Super_categoria
    WHERE Super_categoria.nome = name;
  RETURN pertence_a_super;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION in_categoria_simples(name varchar(255))
RETURNS INTEGER
AS
$$
DECLARE pertence_a_super INTEGER;
BEGIN
  SELECT COUNT(Categoria_simples.nome) INTO pertence_a_super
    FROM Categoria_simples
    WHERE Categoria_simples.nome = name;
  RETURN pertence_a_super;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION in_tem_outra(super_category varchar(255))
RETURNS INTEGER
AS
$$
DECLARE num_sub_categorias INTEGER;
BEGIN
    SELECT COUNT(Tem_outra.super_categoria) INTO num_sub_categorias
      FROM Tem_outra
      WHERE Tem_outra.super_categoria = super_category;
    RETURN num_sub_categorias;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION in_tem_categoria(ean_aux CHAR(13))
RETURNS INTEGER
AS
$$
DECLARE num_categorias_a_que_pertence INTEGER;
BEGIN
  SELECT COUNT(Tem_categoria.ean) INTO num_categorias_a_que_pertence
    FROM Tem_categoria
    WHERE Tem_categoria.ean = ean_aux;
  RETURN num_categorias_a_que_pertence;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION insert_super_categoria()
RETURNS TRIGGER
AS
$$
BEGIN
  IF in_super_categoria(NEW.super_categoria) = 0 THEN
    INSERT INTO Super_categoria VALUES(
      NEW.super_categoria
    );
  END IF;
  IF in_categoria_simples(NEW.super_categoria) != 0 THEN
    DELETE FROM Categoria_simples
    WHERE Categoria_simples.nome = NEW.super_categoria;
  END IF;
  RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION insert_categoria()
RETURNS TRIGGER
AS
$$
BEGIN
  INSERT INTO Categoria VALUES(
    NEW.nome
  );
  RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION delete_categoria()
RETURNS TRIGGER
AS
$$
BEGIN
  DELETE FROM Evento_reposicao WHERE Evento_reposicao.ean IN( SELECT Tem_categoria.ean FROM Tem_categoria
      WHERE Tem_categoria.nome = OLD.nome);
  DELETE FROM Planograma WHERE Planograma.ean IN( SELECT Tem_categoria.ean FROM Tem_categoria
    WHERE Tem_categoria.nome = OLD.nome);
  DELETE FROM Tem_categoria WHERE Tem_categoria.nome = OLD.nome;
  DELETE FROM Tem_outra WHERE (Tem_outra.categoria = OLD.nome OR Tem_outra.super_categoria = OLD.nome);
  DELETE FROM Prateleira WHERE Prateleira.nome = OLD.nome;
  DELETE FROM Produto WHERE Produto.cat = OLD.nome;
  DELETE FROM Responsavel_por WHERE Responsavel_por.nome_cat = OLD.nome;
  DELETE FROM Categoria_simples WHERE Categoria_simples.nome = OLD.nome;
  DELETE FROM Super_categoria WHERE Super_categoria.nome = OLD.nome;

  RETURN OLD;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION delete_Retalhista()
RETURNS TRIGGER
AS
$$
BEGIN
 DELETE FROM Responsavel_por WHERE Responsavel_por.tin = OLD.tin;
 DELETE FROM Evento_reposicao WHERE Evento_reposicao.tin = OLD.tin;
 RETURN OLD;
END
$$ LANGUAGE plpgsql;

CREATE TABLE Categoria (
  nome VARCHAR(255) NOT NULL,
  PRIMARY KEY(nome));

CREATE TABLE Super_categoria (
  nome VARCHAR(255) NOT NULL,
  PRIMARY KEY(nome),
  FOREIGN KEY (nome) REFERENCES Categoria(nome)
);

CREATE TABLE Categoria_simples (
  nome VARCHAR(255) NOT NULL,
  PRIMARY KEY(nome),
  FOREIGN KEY (nome) REFERENCES Categoria(nome),
  CONSTRAINT NOT_super_categoria CHECK (in_super_categoria(nome) = 0)
);

CREATE TABLE Tem_outra(
  super_categoria VARCHAR(255) NOT NULL,
  categoria VARCHAR(255) NOT NULL,
  PRIMARY KEY (categoria),
  FOREIGN KEY (categoria) REFERENCES Categoria(nome),
  FOREIGN KEY (super_categoria) REFERENCES Super_categoria(nome)
);

CREATE TABLE Produto(
    ean CHAR(13) NOT NULL,
    cat VARCHAR(255) NOT NULL,
    descr VARCHAR(255) NOT NULL,
    PRIMARY KEY (ean),
    FOREIGN KEY (cat) REFERENCES Categoria(nome)
);

CREATE TABLE Tem_categoria(
  ean CHAR(13) NOT NULL,
  nome VARCHAR(255) NOT NULL,
  PRIMARY KEY (ean, nome),
  FOREIGN KEY (ean) REFERENCES Produto(ean),
  FOREIGN KEY (nome) REFERENCES Categoria(nome)
);

CREATE TABLE Ivm(
  num_serie NUMERIC(8,0) NOT NULL,
  fabricante VARCHAR(255) NOT NULL,
  PRIMARY KEY (num_serie, fabricante)
);

CREATE TABLE Ponto_de_retalho(
  nome VARCHAR(255) NOT NULL,
  distrito VARCHAR(255) NOT NULL,
  concelho VARCHAR(255) NOT NULL,
  PRIMARY KEY (nome)
);

CREATE TABLE Instalada_em(
  num_serie NUMERIC(8,0) NOT NULL,
  fabricante VARCHAR(255) NOT NULL,
  local VARCHAR(255) NOT NULL,
  PRIMARY KEY (num_serie, fabricante),
  FOREIGN KEY (num_serie, fabricante) REFERENCES Ivm(num_serie, fabricante),
  FOREIGN KEY (local) REFERENCES Ponto_de_retalho(nome)
);

CREATE TABLE Prateleira(
  nro INTEGER NOT NULL,
  num_serie NUMERIC(8,0) NOT NULL,
  fabricante VARCHAR(255) NOT NULL,
  altura NUMERIC(20,4) NOT NULL,
  nome VARCHAR(255) NOT NULL,
  PRIMARY KEY (nro, num_serie, fabricante),
  FOREIGN KEY (num_serie, fabricante) REFERENCES Ivm(num_serie, fabricante),
  FOREIGN KEY (nome) REFERENCES Categoria(nome)
);

CREATE  TABLE Planograma(
  ean CHAR(13) NOT NULL,
  nro INTEGER NOT NULL,
  num_serie NUMERIC(8,0) NOT NULL,
  fabricante VARCHAR(255) NOT NULL,
  faces INTEGER NOT NULL,
  unidades INTEGER NOT NULL,
  loc INTEGER NOT NULL,
  PRIMARY KEY (ean, nro, num_serie, fabricante),
  FOREIGN KEY (ean) REFERENCES Produto(ean),
  FOREIGN KEY (nro, num_serie, fabricante) REFERENCES Prateleira(nro, num_serie, fabricante)
);

CREATE TABLE Retalhista(
  tin NUMERIC(9,0) NOT NULL,
  nome VARCHAR(255) NOT NULL,
  PRIMARY KEY (tin),
  UNIQUE(nome)
);

CREATE TABLE Responsavel_por(
  nome_cat VARCHAR(255) NOT NULL,
  tin NUMERIC(9,0) NOT NULL,
  num_serie NUMERIC(8,0) NOT NULL,
  fabricante VARCHAR(255) NOT NULL,
  PRIMARY KEY (num_serie, fabricante),
  FOREIGN KEY (num_serie, fabricante) REFERENCES Ivm(num_serie, fabricante),
  FOREIGN KEY (tin) REFERENCES Retalhista(tin),
  FOREIGN KEY (nome_cat) REFERENCES Categoria(nome)
);

CREATE TABLE Evento_reposicao(
  ean CHAR(13) NOT NULL,
  nro INTEGER NOT NULL,
  num_serie NUMERIC(8,0) NOT NULL,
  fabricante VARCHAR(255) NOT NULL,
  instante timestamp NOT NULL,
  unidades INTEGER NOT NULL,
  tin NUMERIC(9,0) NOT NULL,
  PRIMARY KEY (ean, nro, num_serie, fabricante, instante),
  FOREIGN KEY (ean, nro, num_serie, fabricante) REFERENCES Planograma(ean, nro, num_serie, fabricante),
  FOREIGN KEY (tin) REFERENCES Retalhista(tin)
);

/*Triggers*/

CREATE TRIGGER exists_super_categoria
BEFORE INSERT ON Tem_outra
FOR EACH ROW EXECUTE FUNCTION insert_super_categoria();

CREATE TRIGGER insert_into_categoria
BEFORE INSERT ON Categoria_simples
FOR EACH ROW EXECUTE FUNCTION insert_categoria();

CREATE TRIGGER erase_categoria
BEFORE DELETE ON Categoria
FOR EACH ROW EXECUTE FUNCTION delete_categoria();

CREATE TRIGGER erase_retalhista
BEFORE DELETE ON Retalhista
FOR EACH ROW EXECUTE FUNCTION delete_Retalhista();

/*Categoria*/

INSERT INTO Categoria VALUES ('Cereais e Barras');
INSERT INTO Categoria VALUES ('Congelados');
INSERT INTO Categoria VALUES ('Laticinios e Ovos');


/*Categoria simples*/

INSERT INTO Categoria_simples VALUES ('Gelados');
INSERT INTO Categoria_simples VALUES ('Barras de Cereais');
INSERT INTO Categoria_simples VALUES ('Ovos');
INSERT INTO Categoria_simples VALUES ('Flocos e Papas de Aveia');
INSERT INTO Categoria_simples VALUES ('Queijos');
INSERT INTO Categoria_simples VALUES ('Leite');
INSERT INTO Categoria_simples VALUES ('Corn Flakes');
INSERT INTO Categoria_simples VALUES ('Pizzas');
INSERT INTO Categoria_simples VALUES ('Carne Congelada');

INSERT INTO Categoria_simples VALUES ('Cornetos');
INSERT INTO Categoria_simples VALUES ('Cornetos Fruta');
INSERT INTO Categoria_simples VALUES ('Magnuns');

INSERT INTO Categoria_simples VALUES ('Pizzas Pingo Doce');
INSERT INTO Categoria_simples VALUES ('Pizzas Ristorante');

/* Tem outra*/

INSERT INTO Tem_outra VALUES ('Cereais e Barras','Flocos e Papas de Aveia');
INSERT INTO Tem_outra VALUES ('Laticinios e Ovos','Leite');
INSERT INTO Tem_outra VALUES ('Cereais e Barras','Corn Flakes');
INSERT INTO Tem_outra VALUES ('Cereais e Barras','Barras de Cereais');
INSERT INTO Tem_outra VALUES ('Laticinios e Ovos','Queijos');
INSERT INTO Tem_outra VALUES ('Laticinios e Ovos','Ovos');

INSERT INTO Tem_outra VALUES ('Congelados','Carne Congelada');
INSERT INTO Tem_outra VALUES ('Congelados','Pizzas');
INSERT INTO Tem_outra VALUES ('Congelados','Gelados');

INSERT INTO Tem_outra VALUES ('Pizzas', 'Pizzas Pingo Doce');
INSERT INTO Tem_outra VALUES ('Pizzas', 'Pizzas Ristorante');
INSERT INTO Tem_outra VALUES ('Gelados','Cornetos');
INSERT INTO Tem_outra VALUES ('Cornetos', 'Cornetos Fruta');
INSERT INTO Tem_outra VALUES ('Cornetos', 'Magnuns');

/*Produto*/

INSERT INTO Produto VALUES ('0913688747902','Barras de Cereais','Barras de Cereais Chocolate Negro e Amendoim');
INSERT INTO Produto VALUES ('4861059308280','Barras de Cereais','Barras de Cereais Chocolate Fitness');
INSERT INTO Produto VALUES ('6504772148317','Barras de Cereais','Barras de Cereais de Chocolate Negro Sarialis');
INSERT INTO Produto VALUES ('6645848962217','Barras de Cereais','Barras de Cereais Proteína Coco Cacau e Caju Special K');
INSERT INTO Produto VALUES ('1953073004951','Barras de Cereais','Barras de Cereais Nesquik');

INSERT INTO Produto VALUES ('3866277547041','Barras de Cereais','Barras de Cereais Morango Fitness');
INSERT INTO Produto VALUES ('4184202186836','Barras de Cereais','Barras de Cereais Chocolate de Leite e Banana');
INSERT INTO Produto VALUES ('3856323671349','Barras de Cereais','Barras de Cereais Morango e Chocolate Branco');
INSERT INTO Produto VALUES ('1257077368596','Barras de Cereais','Barras de Cereais Golden Grahams');
INSERT INTO Produto VALUES ('5208190526525','Barras de Cereais','Barras de Cereais Proteína Amendoim e Chocolate sem Glúten');
INSERT INTO Produto VALUES ('8882641196104','Barras de Cereais','Barras de Cereais Chocolate All Bran');

INSERT INTO Produto VALUES ('1234567891011', 'Congelados', 'Legumes congelados');

INSERT INTO Produto VALUES ('1234567891012', 'Gelados', 'Corneto morango');
INSERT INTO Produto VALUES ('1234567891013', 'Gelados', 'Corneto chocolate');
INSERT INTO Produto VALUES ('1234567891014', 'Gelados', 'Corneto limao');

INSERT INTO Produto VALUES ('1234567891015', 'Leite', 'Leite Magro');
INSERT INTO Produto VALUES ('1234567891016', 'Leite', 'Leite Meio-Gordo');
INSERT INTO Produto VALUES ('1234567891017', 'Leite', 'Leite Gordo');


/*Tem categoria*/

INSERT INTO Tem_categoria VALUES ('0913688747902','Barras de Cereais');
INSERT INTO Tem_categoria VALUES ('4861059308280','Barras de Cereais');
INSERT INTO Tem_categoria VALUES ('6504772148317','Barras de Cereais');
INSERT INTO Tem_categoria VALUES ('6645848962217','Barras de Cereais');
INSERT INTO Tem_categoria VALUES ('1953073004951','Barras de Cereais');

INSERT INTO Tem_categoria VALUES ('3866277547041','Barras de Cereais');
INSERT INTO Tem_categoria VALUES ('4184202186836','Barras de Cereais');
INSERT INTO Tem_categoria VALUES ('3856323671349','Barras de Cereais');
INSERT INTO Tem_categoria VALUES ('1257077368596','Barras de Cereais');
INSERT INTO Tem_categoria VALUES ('5208190526525','Barras de Cereais');
INSERT INTO Tem_categoria VALUES ('8882641196104','Barras de Cereais');

INSERT INTO Tem_categoria VALUES ('1234567891012', 'Gelados');
INSERT INTO Tem_categoria VALUES ('1234567891013', 'Gelados');
INSERT INTO Tem_categoria VALUES ('1234567891014', 'Gelados');

INSERT INTO Tem_categoria VALUES ('1234567891015', 'Leite');
INSERT INTO Tem_categoria VALUES ('1234567891016', 'Leite');
INSERT INTO Tem_categoria VALUES ('1234567891017', 'Leite');

INSERT INTO Tem_categoria VALUES ('1234567891011', 'Congelados');

/*Ivm*/

INSERT INTO Ivm VALUES (09619919,'Samsung');
INSERT INTO Ivm VALUES (02567464,'Samsung');
INSERT INTO Ivm VALUES (11688768,'Apple');
INSERT INTO Ivm VALUES (70035900,'Apple');
INSERT INTO Ivm VALUES (84939152,'Samsung');

/*Ponto de retalho*/

INSERT INTO Ponto_de_retalho VALUES ('Ivm_CV','Beja','Castro Verde');
INSERT INTO Ponto_de_retalho VALUES ('Ivm_C','Lisboa','Cascais');
INSERT INTO Ponto_de_retalho VALUES ('Ivm_M','Porto','Matosinhos');
INSERT INTO Ponto_de_retalho VALUES ('Ivm_CM','Faro','Castro Marim');
INSERT INTO Ponto_de_retalho VALUES ('Ivm_G','Guarda','Gouveia');

/*Instalada em*/

INSERT INTO Instalada_em VALUES (09619919,'Samsung','Ivm_CV');
INSERT INTO Instalada_em VALUES (02567464,'Samsung','Ivm_C');
INSERT INTO Instalada_em VALUES (11688768,'Apple','Ivm_M');
INSERT INTO Instalada_em VALUES (70035900,'Apple','Ivm_CM');
INSERT INTO Instalada_em VALUES (84939152,'Samsung','Ivm_G');

/*Prateleira*/

INSERT INTO Prateleira VALUES (1,09619919,'Samsung','47','Barras de Cereais');
INSERT INTO Prateleira VALUES (2,09619919,'Samsung','34','Barras de Cereais');
INSERT INTO Prateleira VALUES (3,09619919,'Samsung','44','Barras de Cereais');
INSERT INTO Prateleira VALUES (4,09619919,'Samsung','40','Barras de Cereais');
INSERT INTO Prateleira VALUES (5,09619919,'Samsung','42','Barras de Cereais');
INSERT INTO Prateleira VALUES (6,09619919,'Samsung','53','Congelados');
INSERT INTO Prateleira VALUES (7,09619919,'Samsung','42','Gelados');
INSERT INTO Prateleira VALUES (8,09619919,'Samsung','85','Gelados');
INSERT INTO Prateleira VALUES (1,02567464,'Samsung','32','Barras de Cereais');
INSERT INTO Prateleira VALUES (2,02567464,'Samsung','31','Barras de Cereais');
INSERT INTO Prateleira VALUES (3,02567464,'Samsung','50','Barras de Cereais');
INSERT INTO Prateleira VALUES (4,02567464,'Samsung','40','Barras de Cereais');
INSERT INTO Prateleira VALUES (5,02567464,'Samsung','31','Barras de Cereais');
INSERT INTO Prateleira VALUES (1,11688768,'Apple','43','Barras de Cereais');
INSERT INTO Prateleira VALUES (2,11688768,'Apple','21','Barras de Cereais');
INSERT INTO Prateleira VALUES (3,11688768,'Apple','32','Barras de Cereais');
INSERT INTO Prateleira VALUES (4,11688768,'Apple','39','Barras de Cereais');
INSERT INTO Prateleira VALUES (5,11688768,'Apple','49','Barras de Cereais');
INSERT INTO Prateleira VALUES (1,70035900,'Apple','38','Barras de Cereais');
INSERT INTO Prateleira VALUES (2,70035900,'Apple','20','Barras de Cereais');
INSERT INTO Prateleira VALUES (3,70035900,'Apple','34','Barras de Cereais');
INSERT INTO Prateleira VALUES (4,70035900,'Apple','26','Barras de Cereais');
INSERT INTO Prateleira VALUES (5,70035900,'Apple','32','Barras de Cereais');
INSERT INTO Prateleira VALUES (1,84939152,'Samsung','32','Barras de Cereais');
INSERT INTO Prateleira VALUES (2,84939152,'Samsung','36','Congelados');
INSERT INTO Prateleira VALUES (3,84939152,'Samsung','25','Gelados');
INSERT INTO Prateleira VALUES (4,84939152,'Samsung','34','Gelados');
INSERT INTO Prateleira VALUES (5,84939152,'Samsung','35','Barras de Cereais');

/*Planograma*/

INSERT INTO Planograma VALUES ('1234567891011',6,09619919,'Samsung',8,9,0);
INSERT INTO Planograma VALUES ('1234567891012',7,09619919,'Samsung',10,11,0);
INSERT INTO Planograma VALUES ('1234567891013',8,09619919,'Samsung',12,13,0);

INSERT INTO Planograma VALUES ('1234567891011',2,84939152,'Samsung',8,9,0);
INSERT INTO Planograma VALUES ('1234567891012',3,84939152,'Samsung',10,11,0);
INSERT INTO Planograma VALUES ('1234567891013',4,84939152,'Samsung',12,13,0);

INSERT INTO Planograma VALUES ('0913688747902',1,09619919,'Samsung',8,9,0);
INSERT INTO Planograma VALUES ('4861059308280',2,09619919,'Samsung',9,15,0);
INSERT INTO Planograma VALUES ('6504772148317',3,09619919,'Samsung',2,13,0);
INSERT INTO Planograma VALUES ('6645848962217',4,09619919,'Samsung',6,14,0);
INSERT INTO Planograma VALUES ('1953073004951',5,09619919,'Samsung',3,7,0);

INSERT INTO Planograma VALUES ('0913688747902',1,02567464,'Samsung',6,11,0);
INSERT INTO Planograma VALUES ('4861059308280',2,02567464,'Samsung',2,12,0);
INSERT INTO Planograma VALUES ('6504772148317',3,02567464,'Samsung',6,5,0);
INSERT INTO Planograma VALUES ('6645848962217',4,02567464,'Samsung',10,9,0);
INSERT INTO Planograma VALUES ('1953073004951',5,02567464,'Samsung',6,5,0);

INSERT INTO Planograma VALUES ('3866277547041',1,11688768,'Apple',8,15,0);
INSERT INTO Planograma VALUES ('4184202186836',2,11688768,'Apple',9,8,0);
INSERT INTO Planograma VALUES ('3856323671349',3,11688768,'Apple',8,9,0);
INSERT INTO Planograma VALUES ('1257077368596',4,11688768,'Apple',3,6,0);
INSERT INTO Planograma VALUES ('5208190526525',5,11688768,'Apple',9,6,0);

INSERT INTO Planograma VALUES ('8882641196104',1,70035900,'Apple',6,13,0);
INSERT INTO Planograma VALUES ('0913688747902',2,70035900,'Apple',2,11,0);
INSERT INTO Planograma VALUES ('4861059308280',3,70035900,'Apple',3,15,0);
INSERT INTO Planograma VALUES ('6645848962217',4,70035900,'Apple',7,14,0);
INSERT INTO Planograma VALUES ('3856323671349',5,70035900,'Apple',6,7,0);

INSERT INTO Planograma VALUES ('8882641196104',1,84939152,'Samsung',9,14,0);
INSERT INTO Planograma VALUES ('1953073004951',2,84939152,'Samsung',10,11,0);
INSERT INTO Planograma VALUES ('0913688747902',3,84939152,'Samsung',6,14,0);
INSERT INTO Planograma VALUES ('6645848962217',4,84939152,'Samsung',4,8,0);
INSERT INTO Planograma VALUES ('4861059308280',5,84939152,'Samsung',8,10,0);


/*Retalhista*/

INSERT INTO Retalhista VALUES (171324750,'Continente');
INSERT INTO Retalhista VALUES (421549475,'Carrefour');
INSERT INTO Retalhista VALUES (146870761,'Lidl');
INSERT INTO Retalhista VALUES (408315885,'Pingo-Doce');
INSERT INTO Retalhista VALUES (710684990,'Jumbo');
INSERT INTO Retalhista VALUES (256637255,'Mini-Market');
INSERT INTO Retalhista VALUES (619016731,'Mini-Preço');
INSERT INTO Retalhista VALUES (010809520,'Walmart');
INSERT INTO Retalhista VALUES (084873916,'Target');
INSERT INTO Retalhista VALUES (596991055,'Modelo');

/*Responsavel por*/

INSERT INTO Responsavel_por VALUES ('Barras de Cereais', 171324750, 84939152,'Samsung');
INSERT INTO Responsavel_por VALUES ('Gelados',084873916,09619919,'Samsung');
INSERT INTO Responsavel_por VALUES ('Pizzas',596991055,02567464,'Samsung');
INSERT INTO Responsavel_por VALUES ('Pizzas',421549475,11688768,'Apple');
INSERT INTO Responsavel_por VALUES ('Gelados',084873916,70035900,'Apple');


/*evento_reposicao*/

INSERT INTO Evento_reposicao VALUES ('8882641196104',1,84939152,'Samsung', '2007-06-01 00:00:01',3,084873916);
INSERT INTO Evento_reposicao VALUES ('8882641196104',1,84939152,'Samsung', '2008-06-01 00:00:01',3,084873916);
INSERT INTO Evento_reposicao VALUES ('8882641196104',1,84939152,'Samsung', '2008-03-01 00:00:01',3,084873916);

INSERT INTO Evento_reposicao VALUES ('1234567891011',2,84939152,'Samsung', '2007-06-01 00:00:01',3,084873916);
INSERT INTO Evento_reposicao VALUES ('1234567891012',3,84939152,'Samsung', '2008-06-01 00:00:01',3,084873916);
INSERT INTO Evento_reposicao VALUES ('1234567891013',4,84939152,'Samsung', '2008-03-01 00:00:01',3,084873916);

INSERT INTO Evento_reposicao VALUES ('1234567891011',6,09619919,'Samsung','2008-03-01 00:00:01',7,084873916);
INSERT INTO Evento_reposicao VALUES ('1234567891012',7,09619919,'Samsung','2008-06-01 00:00:01',9, 084873916);
INSERT INTO Evento_reposicao VALUES ('1234567891013',8,09619919,'Samsung','2007-03-01 00:00:01',10, 084873916);
