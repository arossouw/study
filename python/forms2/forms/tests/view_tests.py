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

	from forms.models import DBSession as Session
	Session.configure(bind=connection)
        self.session = self.Session(bind=connection)
    
  
    def tearDown(self):
        # rollback - everything that happened with the
        # Session above (including calls to commit())
        # is rolled back.
        testing.tearDown()
        self.trans.rollback()
        self.session.close()

class ViewsUnitTests(BaseTestCase):
    def setUp(self):
        self.config = testing.setUp(request=testing.DummyRequest())
        super(ViewsUnitTests, self).setUp()

    def test_site_view(self):
       from forms.views import my_view
       request = testing.DummyRequest()
       result = my_view(request)
       self.assertTrue('form' in result.keys())
