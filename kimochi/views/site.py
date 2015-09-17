from pyramid.view import (
    view_config,
)

from pyramid.httpexceptions import (
    HTTPBadRequest,
    HTTPSeeOther,
)

from ..models import (
    User,
    Site,
    DBSession,
    )

from pyramid.security import (
    authenticated_userid,
)


@view_config(route_name='index', renderer='kimochi:templates/index.mako')
def index(request):
    return {}

@view_config(route_name='sites', request_method='POST', renderer='kimochi:templates/index.mako')
def site_add(request):
    if 'site_name' not in request.POST or len(request.POST['site_name'].strip()) < 1:
        raise HTTPBadRequest

    site = Site(name=request.POST['site_name'].strip())
    user = User.get_from_id(authenticated_userid(request))

    site.users.append(user)
    DBSession.add(site)
    DBSession.flush()

    return HTTPSeeOther(location=request.route_url('site', site_key=site.key))

@view_config(route_name='site', request_method='POST', renderer='kimochi:templates/site.mako')
def site_update(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))

    if 'command' in request.POST:
        if request.POST['command'] == 'generate_api_key' and len(site.api_keys) < 20:
            key = site.api_key_generate()
            request.session.flash("A new API key has been generated!")
            DBSession.flush()

            return HTTPSeeOther(
                location=request.current_route_url() + '#key_' + str(key.id)
            )

    if 'footer' in request.POST:
        site.footer = request.POST['footer'].strip()

        request.session.flash("Footer text has been updated!")

    if 'select_index_page' in request.POST and site.get_active_page(request.POST['select_index_page']):
        site.set_default_index_page(site.get_active_page(request.POST['select_index_page']))

        request.session.flash("The default index page has been updated.")

    return HTTPSeeOther(
        location=request.current_route_url()
    )

@view_config(route_name='site', renderer='kimochi:templates/site.mako')
def site(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))

    return {
        'site': site,
    }