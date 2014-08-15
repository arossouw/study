from PyQt4.QtCore import *
from PyQt4.QtGui import *
from qtsqldict import data

class MyTable(QTableWidget):
    def __init__(self, thestruct, *args):
        QTableWidget.__init__(self, *args)
        self.data = thestruct
	self.setHorizontalHeaderLabels(self.data.keys())
        self.setmydata()
    def setWindowSize(self,x,y):
	self.setMinimumSize(x,y)
        
    def setmydata(self):
        n = 0
        for key in self.data:
            m = 0
            for item in self.data[key]:
                newitem = QTableWidgetItem(item)
                self.setItem(m, n, newitem)
                m += 1
            n += 1

class AppForm(QMainWindow):
    def __init__(self, parent=None):
        QMainWindow.__init__(self, parent)
        self.create_main_frame()       

    def create_main_frame(self):        
        page = QWidget()        

        self.button = QPushButton('Go', page)

        vbox1 = QVBoxLayout()
        vbox1.addWidget(self.button)
        page.setLayout(vbox1)
        self.setCentralWidget(page)

        self.connect(self.button, SIGNAL("clicked()"), self.clicked)

    def clicked(self):
        self.table = MyTable(data,len(data.values()),len(data.keys()))
	#self.table.setWindowSize(800,600)
        self.table.show()



if __name__ == "__main__":
    import sys
    app = QApplication(sys.argv)
    form = AppForm()
    form.show()
    app.exec_()
