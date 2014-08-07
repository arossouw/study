from pyramid.security import authenticated_userid
from pyramid.security import forget
from pyramid.security import remember
from pyramid.authentication import AuthTktAuthenticationPolicy
from pyramid.authorization import ACLAuthorizationPolicy
from pyramid.security import Deny
from pyramid.security import Everyone
from hashlib import sha1
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.exc import IntegrityError
import transaction

import os

from sqlalchemy import Integer
from sqlalchemy import Unicode
from sqlalchemy import ForeignKey
from sqlalchemy import Table
from sqlalchemy import Column
from sqlalchemy import String
from sqlalchemy import types
from sqlalchemy import Sequence
from sqlalchemy import orm
from sqlalchemy import create_engine
from sqlalchemy.orm import scoped_session
from sqlalchemy.orm import sessionmaker
from pyramid.security import Authenticated
from zope.sqlalchemy import ZopeTransactionExtension



DBSession = scoped_session(sessionmaker(extension=ZopeTransactionExtension()))
Base = declarative_base()


def groupfinder(userid, request):
    user = Users.by_id(userid)
    return [g.groupname for g in user.mygroups]



class Groups(Base):
    __tablename__ = 'groups'
    __table_args__ = {'mysql_engine':'InnoDB'}
    id = Column(Integer,
                Sequence('groups_seq_id', optional=True),
                primary_key=True)
    groupname = Column(String(30),nullable=False, unique=True)

    def __init__(self, groupname):
        self.groupname = groupname

class Users(Base):
    __tablename__ = 'users'
    __table_args__ = {'mysql_engine':'InnoDB'}
    id = Column(Integer,
                   Sequence('users_seq_id', optional=True),
                   primary_key=True)
    firstname = Column(String(25),nullable=False)
    surname = Column(String(25),nullable=False)
    username = Column(String(15), nullable=False, unique=True)
    password = Column(String(80), nullable=False)
    mygroups = orm.relationship(Groups, secondary='user_group')

    def __init__(self, firstname, surname, user, password):
        self.username = user
        self.firstname = firstname
	self.surname = surname
        self._set_password(password)

    @classmethod
    def by_id(cls, userid):
        Session = DBSession()
        return Session.query(Users).filter(Users.id==userid).first()

    @classmethod
    def by_username(cls, username):
        Session = DBSession()    
        return Session.query(Users).filter(Users.username==username).first()

    def _set_password(self, password):
        hashed_password = password

        if isinstance(password, unicode):
            password_8bit = password.encode('UTF-8')
        else:
            password_8bit = password

        salt = sha1()
        salt.update(os.urandom(60))
        hash = sha1()
        hash.update(password_8bit + salt.hexdigest())
        hashed_password = salt.hexdigest() + hash.hexdigest()

        if not isinstance(hashed_password, unicode):
            hashed_password = hashed_password.decode('UTF-8')

        self.password = hashed_password

    def validate_password(self, password):
        hashed_pass = sha1()
        hashed_pass.update(password + self.password[:40])
        return self.password[40:] == hashed_pass.hexdigest()


user_group_table = Table('user_group', Base.metadata,
    Column('user_id', Integer, ForeignKey(Users.id),nullable=False),
    Column('group_id',Integer, ForeignKey(Groups.id),nullable=False),
    mysql_engine='InnoDB'
)

class Departments(Base):
     __tablename__ = 'departments'
     id = Column(Integer,primary_key=True)
     department_name = Column(String(35),nullable=False, unique=True)
     mydepartment = orm.relationship(Users,secondary='user_department')    
     def __init__(self,department):
	self.department_name = department

user_department_table = Table('user_department',Base.metadata,
      Column('user_id',Integer,ForeignKey(Users.id),nullable=False, unique=True),
      Column('department_id',Integer,ForeignKey(Departments.id) , nullable=False),
)

def get_groups():
      session = DBSession()
      group_q = session.query(Groups).order_by(Groups.groupname)
      groups = [(group.id,group.groupname) for group in group_q.all()]
      return groups

def get_departments():
	session = DBSession()
	departments_q = session.query(Departments).order_by(Departments.department_name)
        departments  = [(department.id,department.department_name) for department in departments_q.all()]

	return departments


def populate():
    try:
       transaction.begin()
       session = DBSession()
#      session.add_all([Departments("IT"),
#			Departments("Accounts"),
#			Departments("Sales")
#			])
       user1 = Users("Arno","Rossouw","arossouw","plonki")
       user2 = Users("Leon","Coertzen","leonc","smilex12")
       group1 = Groups("employee")
       group2 = Groups("manager")
  
       session.add(user1)
       session.flush()
       session.add(user2)
       session.flush()
       session.add(group1)
       session.flush()
       session.add(group2)
       session.flush()
       user1.mygroups.append(group1)
       user2.mygroups.append(group2)

       dep = Departments("IT")
       session.add(dep)
       dep.mydepartment.append(user1)
       dep.mydepartment.append(user2)

       transaction.commit()
    except IntegrityError:
       transaction.abort()


def load_database(db_string):
    #DBSession.configure(bind=db_string)
    Base.metadata.bind = db_string
    Base.metadata.create_all(db_string)
    populate()


def initialize_sql(engine):
    #DBSession.configure(bind=engine)
    Base.metadata.bind = engine
    Base.metadata.create_all(engine)
    populate()
    return DBSession
