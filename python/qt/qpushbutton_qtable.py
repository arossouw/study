from PyQt4.QtCore import *
from PyQt4.QtGui import *


lista = ['aa', 'ab', 'ac']
listb = ['ba', 'bb', 'bc']
listc = ['ca', 'cb', 'cc']
mystruct = {'A':lista, 'B':listb, 'C':listc}

def resizeEvent(hedprops, event):
     selfsz = event.size().width()
     totalprops = sum(hedprops)
     newszs = [sz * selfsz / totalprops for sz in hedprops]
     for i, sz in enumerate(newszs):
            self.horizontalHeader().resizeSection(i, sz)


class MyTable(QTableWidget):
	def __init__(self, thestruct,*args):
		QTableWidget.__init__(self, *args)
		self.data = thestruct
		self.verticalHeader().hide()
		self.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
		hedprops = (330,330,330,330,330,330,330)
		selfsz = self.size().width()
		totalprops = sum(hedprops)
		newszs = [sz * selfsz / totalprops for sz in hedprops]
		for i, sz in enumerate(newszs):
			self.horizontalHeader().resizeSection(i, sz)
		self.setHorizontalHeaderLabels(thestruct.keys())
		self.setmydata()

	def setResolution(self,width,height):
		self.setMinimumSize(height,width)

        
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

        self.button = QPushButton('joy', page)

        vbox1 = QVBoxLayout()
        vbox1.addWidget(self.button)
        page.setLayout(vbox1)
        self.setCentralWidget(page)

        self.connect(self.button, SIGNAL("clicked()"), self.clicked)

    def clicked(self):
		self.table = MyTable(mystruct,5,3)
		self.table.setResolution(300,200)
		self.table.show()
        #QMessageBox.about(self, "My message box", "Text1 = %s, Text2 = %s" % (
        #    self.edit1.text(), self.edit2.text()))



if __name__ == "__main__":
    import sys
    app = QApplication(sys.argv)
    form = AppForm()
    form.show()
    app.exec_()
