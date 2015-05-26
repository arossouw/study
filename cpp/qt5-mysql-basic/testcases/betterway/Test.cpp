#include <QtSql>
#include <iostream>
#include <QDebug>
#include <sstream>
//    q.bindValue(":invoice",invoice);

using namespace std;

int main(int argc, char** argv)
{

    QSqlDatabase db = QSqlDatabase::addDatabase("QMYSQL");
    stringstream st;
    st << argv[1];
    int start;
    st >> start;

    stringstream str;
    str << argv[2];
    int end;
    str >> end;


    db.setHostName("10.2.13.2");
    db.setDatabaseName("albrecht");
    db.setUserName("mysqluser");
    db.setPassword("mysqluser");
    if (!db.open())
    {
	cout << "Couldn't open database";
    }
    QSqlQuery q;
    QString invs = QString::number(start);
    QString invend = QString::number(end);

    q.prepare("SET SESSION query_cache_type=OFF;");
    q.prepare("SELECT * from pay_Invoices where InvoiceNo >= :start and InvoiceNo <= :end;");
    q.bindValue(":start",invs);
    q.bindValue(":end",invend);
    q.exec();
    while (q.next())
    {
      QString val = q.value(3).toString();
      qDebug() << val;
    }
    db.close();
}
