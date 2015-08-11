from pyramid.config import Configurator
from pyramid.authentication import SessionAuthenticationPolicy
from pyramid.authorization import ACLAuthorizationPolicy
from pyramid.security import (
    Authenticated,
    authenticated_userid,
)

from sqlalchemy import engine_from_config

from .models import (
    DBSession,
    Base,
    User,
    RootFactory,
    )

from pyramid.events import subscriber
from pyramid.events import BeforeRender

@subscriber(BeforeRender)
def add_user(event):
    event['user'] = None

    if authenticated_userid(event['request']):
        event['user'] = User.get_from_id(authenticated_userid(event['request']))

def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    engine = engine_from_config(settings, 'sqlalchemy.')
    DBSession.configure(bind=engine)
    Base.metadata.bind = engine

    authentication_policy = SessionAuthenticationPolicy()
    authorization_policy = ACLAuthorizationPolicy()

    config = Configurator(
        settings=settings,
        root_factory=RootFactory,
        authentication_policy=authentication_policy,
        authorization_policy=authorization_policy,
        default_permission=Authenticated
    )

    config.include('pyramid_beaker')
    config.include('pyramid_mako')
    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_route('index', '/')
    config.add_route('profile', '/profile')
    config.add_route('sites', '/sites')
    config.add_route('site', '/sites/{site_key}')
    config.add_route('site_gallery', '/sites/{site_key}/gallery/{gallery_id}')
    config.add_route('site_galleries', '/sites/{site_key}/galleries')
    config.add_route('site_page', '/sites/{site_key}/pages/{page_id}')
    config.add_route('site_pages', '/sites/{site_key}/pages')
    config.add_route('login', '/login')
    config.add_route('logout', '/logout')
    config.scan()
    return config.make_wsgi_app()
