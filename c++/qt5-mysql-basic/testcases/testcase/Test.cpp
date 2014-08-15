#include <QtSql>
#include <iostream>
#include <QDebug>
using namespace std;

int main()
{

    QSqlDatabase db = QSqlDatabase::addDatabase("QMYSQL");
    for (int i = 35000;i < 40000;i++){

    db.setHostName("10.0.0.21");
    db.setDatabaseName("JhbGlobal");
    db.setUserName("mysqluser");
    db.setPassword("mysqluser");
    if (!db.open())
    {
	cout << "Couldn't open database";
    }
    QSqlQuery q;
    QString invoice = QString::number(i);

    q.prepare("SELECT * from pay_Invoices where InvoiceNo = :invoice;");
    q.bindValue(":invoice",invoice);
    qDebug() << invoice;
	
    db.close();
   }
}
