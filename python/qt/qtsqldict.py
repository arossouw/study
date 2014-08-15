from PyQt4.QtSql import *
from PyQt4.QtCore import QString
from collections import defaultdict

db = QSqlDatabase.addDatabase("QMYSQL")
db.setHostName("10.0.0.36")
db.setDatabaseName("JhbGlobal")
db.setUserName("mysqluser")
db.setPassword("mysqluser")

if (db.open()==False):     
    print db.lastError().text()

result = QSqlQuery("SELECT RKey,ChequeNo,Reference,Amount,DepDesc from pay_Refunds limit 5;")

columns = [str(result.record().fieldName(k)) for k in range(result.record().count())]
data = {}
for q in columns:
	data[QString(q)] = []

while (result.next()):
	for column in range(len(columns)):
		data[QString(columns[column])].append(result.value(column).toString())
