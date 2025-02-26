#!/usr/bin/python3
from crypt import methods
from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template, request
import psycopg2
import psycopg2.extras

## SGBD configs
DB_HOST = "db.tecnico.ulisboa.pt"
DB_USER = "ist199227"
DB_DATABASE = DB_USER
DB_PASSWORD = ""
DB_CONNECTION_STRING = "host=%s dbname=%s user=%s password=%s" % (
    DB_HOST,
    DB_DATABASE,
    DB_USER,
    DB_PASSWORD,
)

app = Flask(__name__)

@app.route("/")
def home():
    
    return render_template("home.html")
    

@app.route("/categorias")
def list_categorias():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM categoria;"
        cursor.execute(query)
        return render_template("categorias.html", cursor=cursor)
    except Exception as e:
        return str(e)  # Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route("/remove_category")
def list_categorias_edit():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT nome FROM categoria;"
        cursor.execute(query)
        return render_template("remove_category.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()


@app.route("/add_subcategory")
def add_subcategory():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT nome FROM categoria;"
        cursor.execute(query)
        return render_template("add_subcategory.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()
@app.route("/choose_subcategory")

def choose_subcategory():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT nome FROM categoria;"
        cursor.execute(query)
        return render_template("choose_subcategory.html", cursor=cursor,params=request.args)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

@app.route("/add_category")
def add_category():
    try:
        return render_template("add_category.html", params=request.args)
    except Exception as e:
        return str(e)

@app.route("/remove_subcategory")
def remove_subcategory():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT nome FROM super_categoria;"
        cursor.execute(query)
        return render_template("remove_subcategory.html", cursor=cursor,params=request.args)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

@app.route("/choose_subcategory_to_remove")
def choose_subcategory_to_remove():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        supercat = request.args.get("super",type=str)
        query = "SELECT tem_outra.categoria FROM tem_outra WHERE tem_outra.super_categoria=%s"
        cursor.execute(query,[supercat])
        return render_template("choose_subcategory_to_remove.html", cursor=cursor,params=request.args)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

@app.route("/add_retalhista")
def add_retalhista():
    try:
        return render_template("add_retalhista.html", params=request.args)
    except Exception as e:
        return str(e)

@app.route("/remove_retalhista")
def remove_retalhista():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT tin,nome FROM retalhista;"
        cursor.execute(query)
        return render_template("remove_retalhista.html", cursor=cursor,params=request.args)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

@app.route("/choose_ivm")
def choose_ivm():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT num_serie,fabricante FROM Ivm;"
        cursor.execute(query)
        return render_template("choose_ivm.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

@app.route("/get_subcategories")
def cget_subcategories():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT nome FROM super_categoria;"
        cursor.execute(query)
        return render_template("get_subcategories.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

@app.route("/update_remove_category")
def update_remove_category():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        data = request.args.get("category_to_remove")
        query = "DELETE FROM Categoria WHERE Categoria.nome = %s;"
        cursor.execute(query,[data])
        return render_template("update_remove_category.html", cursor=cursor,params=request.args)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route("/update_add_category",methods=["POST"])
def update_add_category():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        data = request.form["category_name"]
        query = "INSERT INTO Categoria_simples VALUES(%s);"
        cursor.execute(query,[data])
        return query
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route("/update_add_subcategory")
def update_add_subcategory():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        super_categoria =request.args.get("super").lstrip()
        categoria = request.args.get("category").lstrip()
        data = (super_categoria,categoria)
        query = "INSERT INTO Tem_outra VALUES(%s,%s);"
        cursor.execute(query,data)
        return render_template("update_add_subcategory.html", cursor=cursor,params=request.args)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route("/update_remove_subcategory")
def update_remove_subcategory():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        data = request.args.get("category")
        query = "DELETE FROM Tem_outra WHERE Tem_outra.categoria = %s;"
        cursor.execute(query,[data])
        return render_template("update_remove_subcategory.html", cursor=cursor,params=request.args)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route("/update_add_retalhista",methods=["POST"])
def update_add_retalhista():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        name = request.form["name"]
        tin = request.form["tin"]
        data = (tin,name)
        query = "INSERT INTO retalhista VALUES(%s,%s);"
        cursor.execute(query,data)
        return query
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route("/update_remove_retalhista")
def update_remove_retalhista():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        data = int(request.args.get("tin"))
        query = "DELETE FROM Retalhista WHERE Retalhista.tin = %s;"
        cursor.execute(query,[data])
        return render_template("update_remove_retalhista.html", cursor=cursor,params=request.args)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route("/update_choose_ivm")
def update_choose_ivm():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        num_serie = int(request.args.get("num_serie"))
        fabricante=request.args.get("fabricante").lstrip()
        query = "SELECT info.nome categoria, SUM(info.unidades) total_unidades\
                    FROM(SELECT *\
                        FROM Evento_reposicao\
                        NATURAL JOIN Prateleira) AS info\
                        WHERE info.num_serie = %s AND info.fabricante=%s\
                        GROUP BY categoria;"
        data = (num_serie,fabricante)
        cursor.execute(query,data)
        return render_template("update_choose_ivm.html", cursor=cursor,params=request.args)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route("/update_get_subcategories")
def update_get_subcategories():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        data=request.args.get("super")
        query = "WITH RECURSIVE sub_categorias AS (\
        SELECT T1.categoria\
            FROM Tem_outra T1\
            WHERE T1.super_categoria = %s\
        UNION ALL\
        SELECT T2.categoria\
            FROM Tem_outra T2\
        JOIN sub_categorias sb ON sb.categoria = T2.super_categoria\
        ) SELECT * FROM sub_categorias;"
        cursor.execute(query,[data])
        return render_template("update_get_subcategories.html", cursor=cursor,params=request.args)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

CGIHandler().run(app)
