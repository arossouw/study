#include <QtSql>
#include <iostream>
#include <QDebug>
using namespace std;

int main()
{

    QSqlDatabase db = QSqlDatabase::addDatabase("QMYSQL");
    for (int i = 100900;i < 101100;i++){

    db.setHostName("10.2.13.2");
    db.setDatabaseName("albrecht");
    db.setUserName("mysqluser");
    db.setPassword("mysqluser");
    if (!db.open())
    {
	cout << "Couldn't open database";
    }
    QSqlQuery q;
    QString invoice = QString::number(i);

    q.prepare("SET SESSION query_cache_type = OFF;");
    q.prepare("SELECT * from pay_Invoices where InvoiceNo = :invoice;");
    q.bindValue(":invoice",invoice);
    q.exec();
    qDebug() << invoice;
	
    db.close();
   }
}
