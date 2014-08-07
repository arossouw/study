from pyramid.config import Configurator
from sqlalchemy import engine_from_config
from pyramid.session import UnencryptedCookieSessionFactoryConfig
from .models import (
    DBSession,
    Base,
    load_database,
    initialize_sql,
)
from pyramid.authentication import AuthTktAuthenticationPolicy
from pyramid.authorization import ACLAuthorizationPolicy
from forms.models import groupfinder

def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    engine = engine_from_config(settings, 'sqlalchemy.')
    load_database(engine)
    initialize_sql(engine)
    session_factory = UnencryptedCookieSessionFactoryConfig('#lkj2991]][`\;')

    authn_policy = AuthTktAuthenticationPolicy('342334#434lakjd',hashalg='sha512',callback=groupfinder)
    authz_policy = ACLAuthorizationPolicy()

    Base.metadata.bind = engine
    config = Configurator(settings=settings, session_factory=session_factory,root_factory='forms.security.ViewACL')
    config.set_authentication_policy(authn_policy)
    config.set_authorization_policy(authz_policy)
    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_route('login', '/')
    config.add_route('manager','/manager')
    config.add_route('test','/test')
    config.add_route('logout','/logout')
   
    config.scan()
    return config.make_wsgi_app()
