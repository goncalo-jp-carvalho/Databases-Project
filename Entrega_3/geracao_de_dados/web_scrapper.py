from bs4 import BeautifulSoup
import requests
import random
import string

categorias={
    "Cereais e Barras":{
        "Barras de Cereais":"https://www.continente.pt/mercearia/cereais-e-barras/barras-de-cereais/?start=0",
        "Flocos e Papas de Aveia":"https://www.continente.pt/mercearia/cereais-e-barras/flocos-e-papas-de-aveia/?start=0",
        "Corn Flakes":"https://www.continente.pt/mercearia/cereais-e-barras/corn-flakes/?start=0"
    },
    "Laticinios e Ovos":{
        "Ovos":"https://www.continente.pt/laticinios-e-ovos/ovos/?start=0",
        "Leite":"https://www.continente.pt/laticinios-e-ovos/leite/?start=0",
        "Queijos":"https://www.continente.pt/charcutaria-e-queijos/queijos/?start=0"
    },
    "Congelados":{
        "Gelados":"https://www.continente.pt/congelados/gelados/?start=0",
        "Pizzas":"https://www.continente.pt/congelados/pizzas/?start=0",
        "Carne Congelada":"https://www.continente.pt/peixaria-e-talho/talho/carne-congelada/?start=0"
    }
}

eans = []

#gera os eans
while len(eans)<288:
    ean = ''.join(random.choice( string.digits) for _ in range(13))
    if (ean not in eans):
        eans.append(ean)

i =0
with open("/home/gc/web_scrapping/prods.csv",'w',encoding='utf-8') as f:
    f.write("supercategoria,categoria,produto,ean\n")
    for supercategoria in categorias:
        for categoria in categorias[supercategoria]:
            print(f'{supercategoria},{categoria}\n')
            html_text = requests.get(categorias[supercategoria][categoria])
            print(html_text)
            soup = BeautifulSoup(html_text.text,'lxml')
            produtos = soup.find_all('div',class_='col-12 col-sm-3 col-lg-2 productTile')
            for prod in produtos:
                prod_name = prod.find('a',class_='ct-tile--description').text
                prod_name=prod_name.replace(',','')
                ean = eans[i]
                f.write(f'{supercategoria},{categoria},{prod_name},{ean}\n')
                i+=1



#"https://www.continente.pt/mercearia/cereais-e-barras/?start=0"
#"https://www.continente.pt/laticinios-e-ovos/?start=0"
#"https://www.continente.pt/congelados/"