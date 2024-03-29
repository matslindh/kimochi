from pyramid.config import Configurator
from pyramid.authentication import SessionAuthenticationPolicy
from pyramid.authorization import ACLAuthorizationPolicy
from pyramid.security import (
    Authenticated,
    NO_PERMISSION_REQUIRED,
)
from pyramid.authentication import (
    SessionAuthenticationHelper,
)

from sqlalchemy import engine_from_config

from .models import (
    DBSession,
    Base,
    User,
    RootFactory,
    APIRootFactory,
    )

from pyramid.events import subscriber
from pyramid.events import BeforeRender

import imboclient.client as imboclient
session_helper = SessionAuthenticationHelper()


@subscriber(BeforeRender)
def add_user(event):
    event['user'] = None

    if session_helper.authenticated_userid(event['request']):
        event['user'] = User.get_from_id(session_helper.authenticated_userid(event['request']))


def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    engine = engine_from_config(settings, 'sqlalchemy.')
    DBSession.configure(bind=engine)
    Base.metadata.bind = engine

    authentication_policy = SessionAuthenticationPolicy()
    authorization_policy = ACLAuthorizationPolicy()

    def get_imbo(request):
        return imboclient.Client((settings['imbo.host'], ), settings['imbo.public_key'], settings['imbo.private_key'])

    config = Configurator(
        settings=settings,
        root_factory=RootFactory,
        authentication_policy=authentication_policy,
        authorization_policy=authorization_policy,
        default_permission=Authenticated
    )

    def api_configuration(config):
        config.add_route('api_site_gallery', '/sites/{site_key}/galleries/{gallery_id}', factory=APIRootFactory)
        config.add_view('kimochi.api.SiteAPI', attr='gallery', route_name='api_site_gallery', permission=NO_PERMISSION_REQUIRED)
        config.add_route('api_site_gallery_image', '/sites/{site_key}/galleries/{gallery_id}/image/{image_id}', factory=APIRootFactory)
        config.add_view('kimochi.api.SiteAPI', attr='gallery_image', route_name='api_site_gallery_image', permission=NO_PERMISSION_REQUIRED)
        config.add_route('api_site_page', '/sites/{site_key}/pages/{page_id}', factory=APIRootFactory)
        config.add_view('kimochi.api.SiteAPI', attr='page', route_name='api_site_page', permission=NO_PERMISSION_REQUIRED)

    config.include('pyramid_beaker')
    config.include('pyramid_mako')
    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_route('index', '/')
    config.add_route('profile', '/profile')
    config.add_route('sites', '/sites')
    config.add_route('site', '/sites/{site_key}')

    config.add_route('site_gallery', '/sites/{site_key}/gallery/{gallery_id}')
    config.add_route('site_gallery_image', '/sites/{site_key}/gallery/{gallery_id}/images/{image_id}')
    config.add_route('site_gallery_image_variation',
                     '/sites/{site_key}/gallery/{gallery_id}/images/{image_id}/variation/{width}/{height}'
                     )
    config.add_route('site_gallery_images', '/sites/{site_key}/gallery/{gallery_id}/images')
    config.add_route('site_galleries', '/sites/{site_key}/galleries')

    config.add_route('site_page', '/sites/{site_key}/pages/{page_id}')
    config.add_route('site_pages', '/sites/{site_key}/pages')
    config.add_route('site_pages_archived', '/sites/{site_key}/pages/archived')

    config.add_route('site_setting_details', '/sites/{site_key}/settings/details')
    config.add_route('site_setting_header_footer', '/sites/{site_key}/settings/headerfooter')
    config.add_route('site_setting_aspect_ratios', '/sites/{site_key}/settings/aspectratios')
    config.add_route('site_setting_api_keys', '/sites/{site_key}/settings/apikeys')
    config.add_route('site_setting_social_media', '/sites/{site_key}/settings/socialmedia')

    config.add_route('login', '/login')
    config.add_route('logout', '/logout')

    # include API configuration under /api
    config.include(api_configuration, route_prefix='/api')

    config.add_request_method(get_imbo, 'imbo', reify=True)
    config.scan()
    return config.make_wsgi_app()
