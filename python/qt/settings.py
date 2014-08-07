from PyQt4.QtCore import QSettings,QStringList
from PyQt4.QtSql import *

config = QSettings("__settings.ini",QSettings.IniFormat)
groups = [str(k) for k in QStringList(config.childGroups())]


def setGroup(text):
    config.beginGroup(text)

def getProperties():
    #fields = [{str(field),config.value(field).toString()} for field in QStringList(config.allKeys())]
    fields = {}
    for name in config.allKeys():
         value = str(config.value(name).toString())
         fields[str(name)] = value

    config.endGroup()
    return fields



