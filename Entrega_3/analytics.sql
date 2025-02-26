CREATE FUNCTION dentro_do_intervalo_selecionado(ano double precision, mes double precision,
  dia_mes double precision, ano_inferior double precision ,mes_inferior double precision,
  dia_inferior double precision, ano_superior double precision, mes_superior double precision,
    dia_superior double precision)
  RETURNS INTEGER
  AS
  $$
  DECLARE
  BEGIN
    IF ano = ano_inferior THEN
      IF mes = mes_inferior THEN
        IF dia_mes < dia_inferior THEN
          RETURN 1;
        END IF;
      ELSEIF mes < mes_inferior THEN
        RETURN 1;
      END IF;
    ELSEIF ano < ano_inferior THEN
      RETURN 1;
    END IF;

    IF ano = ano_superior THEN
      IF mes = mes_superior THEN
        IF dia_mes > dia_superior THEN
          RETURN 1;
        END IF;
      ELSEIF mes > mes_superior THEN
        RETURN 1;
      END IF;
    ELSEIF ano > ano_superior THEN
      RETURN 1;
    END IF;

    RETURN 0;
  END
  $$ LANGUAGE plpgsql;


SELECT Vendas.dia_semana, Vendas.concelho, SUM(Vendas.unidades)
    FROM Vendas
    WHERE dentro_do_intervalo_selecionado(Vendas.ano, Vendas.mes, Vendas.dia_mes,
      2007,6,1,2008,6,1) = 0
    GROUP BY
      ROLLUP(Vendas.dia_semana, Vendas.concelho);

SELECT Vendas.concelho, Vendas.cat, Vendas.dia_semana, SUM(Vendas.unidades)
  FROM Vendas
  WHERE Vendas.distrito = 'Beja'
  GROUP BY
    ROLLUP(Vendas.concelho, Vendas.cat, Vendas.dia_semana);
