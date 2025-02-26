import csv
from math import factorial
import random
import string


files =[
    '/home/piterriosag2/Documents/BD/projeto_BD/Entrega_3/geracao_de_dados/produto.sql',
    '/home/piterriosag2/Documents/BD/projeto_BD/Entrega_3/geracao_de_dados/categoria_simples.sql',
    '/home/piterriosag2/Documents/BD/projeto_BD/Entrega_3/geracao_de_dados/super_categoria.sql',
    '/home/piterriosag2/Documents/BD/projeto_BD/Entrega_3/geracao_de_dados/tem_outra.sql',
    '/home/piterriosag2/Documents/BD/projeto_BD/Entrega_3/geracao_de_dados/tem_categoria.sql',
    '/home/piterriosag2/Documents/BD/projeto_BD/Entrega_3/geracao_de_dados/Ivm.sql',
    '/home/piterriosag2/Documents/BD/projeto_BD/Entrega_3/geracao_de_dados/retalhista.sql',
    '/home/piterriosag2/Documents/BD/projeto_BD/Entrega_3/geracao_de_dados/ponto_de_retalho.sql',
    '/home/piterriosag2/Documents/BD/projeto_BD/Entrega_3/geracao_de_dados/instalada_em.sql',
    '/home/piterriosag2/Documents/BD/projeto_BD/Entrega_3/geracao_de_dados/prateleira.sql',
    '/home/piterriosag2/Documents/BD/projeto_BD/Entrega_3/geracao_de_dados/planograma.sql',
    '/home/piterriosag2/Documents/BD/projeto_BD/Entrega_3/geracao_de_dados/responsavel_por.sql',
    '/home/piterriosag2/Documents/BD/projeto_BD/Entrega_3/geracao_de_dados/categoria.sql'
]

path_to_csv='/home/piterriosag2/Documents/BD/projeto_BD/Entrega_3/geracao_de_dados/prods.csv'

with open(path_to_csv,'r') as f:
    csvreader = csv.reader(f)
    header=[]
    header = next(csvreader)
    rows = []
    for row in csvreader:
        rows.append(row)
#produtos e categorias
super_categorias =[]
categorias =[]
produtos = []
eans = []
#ivm
ivms_serial_numbers =[]
ivms_manufacturers = ['Apple','Samsung']
#retalhista
tins = []
nomes_ret =['Continente','Carrefour','Lidl','Pingo-Doce','Jumbo','Mini-Market','Mini-Preço','Walmart','Target','Modelo']

#ponto de retalho
locations ={
    'Beja':'Castro Verde',
    'Lisboa':'Cascais',
    'Porto':'Matosinhos',
    'Faro':'Castro Marim',
    'Guarda':'Gouveia'
}
nomes_pr = ['Ivm_CV','Ivm_C','Ivm_M','Ivm_CM','Ivm_G']

#gerar serial numbers para ivms
while len(ivms_serial_numbers)<5:
    serial_number = ''.join(random.choice(string.digits) for _ in range(8))
    if (serial_number not in ivms_serial_numbers):
        ivms_serial_numbers.append(serial_number)
#gerar tins
while len(tins)<10:
    tin = ''.join(random.choice(string.digits) for _ in range(9))
    if (tin not in tins):
       tins.append(tin)

Ivms = {
    ivms_serial_numbers[0]:ivms_manufacturers[1],
    ivms_serial_numbers[1]:ivms_manufacturers[1],
    ivms_serial_numbers[2]:ivms_manufacturers[0],
    ivms_serial_numbers[3]:ivms_manufacturers[0],
    ivms_serial_numbers[4]:ivms_manufacturers[1],

}

pontos_de_retalho = []
prateleiras = {}
products_by_cat={}

#organizar dados
for row in rows:
    super_categorias.append(row[0])
    categorias.append(row[1])
    produtos.append(row[2])
    eans.append(row[3])

super_categorias_set = set( super_categorias)
categorias_set = set(categorias)


rels = []
for i in range(len(categorias)):
    rels.append((super_categorias[i], categorias[i]))

rels_set = set(rels)
#productsby cat
for i in range(len(eans)):
    if(categorias[i]  in products_by_cat):
        products_by_cat[categorias[i]].append(eans[i])
    else:
        products_by_cat[categorias[i]]=[eans[i]]

for file in files:
    with open(file,'w') as f:
        #produtos
        if(file == files[0]):
            for i in range(len(produtos)):
                ean = eans[i]
                cat  = categorias[i]
                descr = produtos[i]
                f.write(f'INSERT INTO Produto VALUES ('{ean}','{cat}','{descr}');\n')
        #categorias_simples
        if(file == files[1]):
            for cat in categorias_set:
                    f.write(f'INSERT INTO Categoria_simples VALUES ('{cat}');\n')
        #supercategorias
        if(file == files[2]):
            for supercat in super_categorias_set:
                f.write(f'INSERT INTO Super_categoria VALUES ('{supercat}');\n')
        #tem_outra
        if(file == files[3]):
            for rel in rels_set:
                supercat = rel[0]
                cat = rel[1]
                f.write(f'INSERT INTO Tem_outra VALUES ('{supercat}','{cat}');\n')

        #tem_ategoria
        if(file == files[4]):
            for i in range(len(produtos)):
                ean  = eans[i]
                cat  = categorias[i]
                f.write(f'INSERT INTO Tem_categoria VALUES ('{ean}','{cat}');\n')

        #ivm
        if(file == files[5]):
            for serial_number in Ivms:
                manuf  = Ivms[serial_number]
                f.write(f'INSERT INTO Ivm VALUES ({serial_number},'{manuf}');\n')

        #retalhista
        if(file == files[6]):
            for i in range(10):
                tin = tins[i]
                nome = nomes_ret[i]
                f.write(f'INSERT INTO Retalhista VALUES ({tin},'{nome}');\n')
        #ponto_de_retalho
        if(file == files[7]):
            i = 0
            for distrito in locations:
                concelho= locations[distrito]
                nome = nomes_pr[i]
                i+=1
                f.write(f'INSERT INTO Ponto_de_retalho VALUES ('{nome}','{distrito}','{concelho}');\n')
                pontos_de_retalho.append((nome,distrito,concelho))
        #instalada_em
        if(file == files[8]):
            i = 0
            for serial_number in Ivms:
                fabricante= Ivms[serial_number]
                nome = pontos_de_retalho[i][0]
                i+=1
                f.write(f'INSERT INTO Instalada_em VALUES ({serial_number},'{fabricante}','{nome}');\n')
        #prateleira
        if(file == files[9]):
            for serial_number in Ivms:
                fabricante = Ivms[serial_number]
                selected_cats= random.sample(tuple(categorias_set),k=5)
                i =0
                for nro in range(1,6):
                    altura = random.randint(15,50)
                    cat = selected_cats[i]
                    i +=1
                    f.write(f'INSERT INTO Prateleira VALUES ({nro},{serial_number},'{fabricante}','{altura}','{cat}');\n')
                    prateleiras[(nro,serial_number)]=(fabricante,cat)
        #planograma
        if(file == files[10]):
            for nro_serialnumber in prateleiras:
                fabricante = prateleiras[nro_serialnumber][0]
                cat = prateleiras[nro_serialnumber][1]
                nro = nro_serialnumber[0]
                serial_number = nro_serialnumber[1]
                ean_index = random.randint(0,len(products_by_cat[cat])-1)
                ean = products_by_cat[cat][ean_index]
                faces =random.randint(2,10)
                unidades = random.randint(5,15)

                f.write(f'INSERT INTO Planograma VALUES ('{ean}',{nro},{serial_number},'{fabricante}',{faces},{unidades});\n')
        #responsavel_por
        if(file == files[11]):
            for nro_serialnumber in prateleiras:
                fabricante = prateleiras[nro_serialnumber][0]
                nro = nro_serialnumber[0]
                serial_number = nro_serialnumber[1]
                cat = prateleiras[nro_serialnumber][1]
                tin = random.choice(tins)
                f.write(f'INSERT INTO Responsavel_por VALUES ('{cat}',{tin},{serial_number},{fabricante});\n')
        if(file == files[12]):
            for cat in categorias_set:
                    f.write(f'INSERT INTO Categoria VALUES ('{cat}');\n')
            for cat in super_categorias_set:
                    f.write(f'INSERT INTO Categoria VALUES ('{cat}');\n')
