from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyQt4.QtSql import *
from settings import *

def sql_from_file(filename):
    import os.path
    if os.path.isfile(filename):
        """ load entire file into memory, dont do this if file is large """
        sql = open(filename,"r").read()
    else:
         sys.exit(0)
    return sql


class AppForm(QMainWindow):
    def __init__(self, parent=None):
        QMainWindow.__init__(self, parent)
        self.create_main_frame()       
        self.table       = QTableWidget()

    def create_main_frame(self):        
        page = QWidget()        

        self.button = QPushButton('OK', page)
        self.databases = groups
        self.database = QComboBox(self)
        self.database.addItems(self.databases)

        vbox1 = QVBoxLayout()
        vbox1.addWidget(self.database)
        vbox1.addWidget(self.button)
        page.setLayout(vbox1)
        self.setCentralWidget(page)

        #self.connect(self.button, SIGNAL("clicked()"), self.clicked)
        self.button.clicked.connect(self.clicked)

    def clicked(self):
        setGroup(self.databases[self.database.currentIndex()])
        conf = getProperties()
        db = QSqlDatabase.addDatabase("QMYSQL")
        db.setUserName(conf['username'])
        db.setPassword(conf['password'])
        db.setHostName(conf['host'])
        db.setDatabaseName(conf['database'])
        if (db.open() == False):
            QMessageBox.critical(self,db.lastError().text(),db.lastError().text())

        result = QSqlQuery(sql_from_file('report_age_analysis.sql'))
        result_text_err = str(result.lastError().text())
        
        if len(result_text_err) > 1:
            QMessageBox.critical(self,result.lastError().text(),result.lastError().text())
            db.close()
        else:
            columns = []
            for i in range(0,result.record().count()):
                columns.append(str(result.record().fieldName(i)))

            self.table.setColumnCount(result.record().count())
            self.table.setRowCount(result.size())
            """ Column headers for UI table """
            self.table.setHorizontalHeaderLabels(columns)
            self.table.setMinimumSize(800,600)
            self.table.setSelectionBehavior(self.table.SelectRows)
            self.table.setSelectionMode(self.table.NoSelection)
            self.table.setFocusPolicy(Qt.NoFocus)
            self.table.setAlternatingRowColors(True)
            self.table.verticalHeader().hide()
            self.table.setShowGrid(False)
            self.table.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
            index=0
            while (result.next()):
                for i in range(0,len(columns)):
                    self.table.setItem(index,i,QTableWidgetItem(result.value(i).toString()))
                index = index+1
            self.table.show()
            db.close()
        



if __name__ == "__main__":
    import sys
    app = QApplication(sys.argv)
    form = AppForm()
    form.show()
    app.exec_()
