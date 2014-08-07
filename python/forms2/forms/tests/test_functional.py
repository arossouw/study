import unittest

from pyramid import testing
from paste.deploy.loadwsgi import appconfig
from webtest import TestApp
from sqlalchemy import engine_from_config
from sqlalchemy.orm import sessionmaker
import os
here = os.path.dirname(__file__)
settings = appconfig('config:' + os.path.join(here, '../../', 'development.ini'))


class BaseTestCase(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.engine = engine_from_config(settings, prefix='sqlalchemy.')
        cls.Session = sessionmaker()

    def setUp(self):
        connection = self.engine.connect()

        # begin a non-ORM transaction
        self.trans = connection.begin()
	from forms.models import DBSession
	self.session = DBSession
    
  
    def tearDown(self):
        # rollback - everything that happened with the
        # Session above (including calls to commit())
        # is rolled back.
        testing.tearDown()
        self.trans.rollback()
        self.session.close()

class FunctionalTestBase(BaseTestCase):
    @classmethod
    def setUpClass(cls):
	from forms import main
        cls.app = main({}, **settings)
        super(FunctionalTestBase, cls).setUpClass()

    def setUp(self):
        self.app = TestApp(self.app)
        self.config = testing.setUp()
        super(FunctionalTestBase, self).setUp()

    def test_view_home_page(self):
	result = self.app.get('/',status=200)
	body = result.body
	self.assertTrue('Copyright no' in body)


    def test_form_blank_input_field_firstname_throws_error(self):
	result = self.app.get('/',status=200)
	form = result.forms[0]
	form['Firstname'] = ''
        submit = form.submit('submit')
	self.assertTrue('<small>Required</small>' in submit)

    def test_form_blank_input_field_surname_throws_error(self):
	result = self.app.get('/',status=200)
	form = result.forms[0]
	form['Surname'] = ''
        submit = form.submit('submit')
	self.assertTrue('<small>Required</small>' in submit)

    def test_form_blank_input_field_username_throws_error(self):
	result = self.app.get('/',status=200)
	form = result.forms[0]
	form['Username'] = ''
        submit = form.submit('submit')
	self.assertTrue('<small>Required</small>' in submit)

    def test_form_blank_input_field_password_throws_error(self):
	result = self.app.get('/',status=200)
	form = result.forms[0]
	form['Password'] = ''
        submit = form.submit('submit')
	self.assertTrue('<small>Required</small>' in submit)


    def test_form_submit_does_redirect(self):
        res = self.app.post('/', 
                   dict(Firstname='admin',
		   Surname='admin',
		   Username='admin',
                   department=1,
		   employee_type=1,
	           Password='plonki234',
                   submit='submit'))

        assert res.status == '302 Found'
        res = res.follow()
        assert res.status == '200 OK'



