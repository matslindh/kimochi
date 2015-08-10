from pyramid.view import (
    view_config,
    forbidden_view_config,
)

from pyramid.httpexceptions import (
    HTTPBadRequest,
    HTTPFound,
    HTTPSeeOther,
    HTTPNotFound,
)

from .models import (
    User,
    Site,
    Page,
    PageSection,
    Gallery,
    DBSession,
    )

from pyramid.security import (
    remember,
    forget,
    authenticated_userid,
)


@view_config(route_name='login', renderer='templates/login.mako')
@forbidden_view_config(renderer='templates/login.mako')
def login(request):
    if 'user_id' in request.session:
        return HTTPFound(location=request.route_url('index'))

    if request.POST:
        if 'password' not in request.POST or 'email' not in request.POST:
            return HTTPBadRequest

        user = User.sign_in(request.POST.getone('email'), request.POST.getone('password'))

        if user:
            headers = remember(request, user.id)

            return HTTPFound(
                location=request.route_url('index'),
                headers=headers
            )

        request.session.flash('Invalid user or password.')

        return {
            'email': request.POST.getone('email'),
        }

    return {}


@view_config(route_name='logout')
def logout(request):
    headers = forget(request)

    return HTTPFound(
        location=request.route_url('index'),
        headers=headers
    )


@view_config(route_name='index', renderer='templates/index.mako')
def index(request):
    return {}

@view_config(route_name='sites', request_method='POST', renderer='templates/index.mako')
def site_add(request):
    if 'site_name' not in request.POST or len(request.POST['site_name'].strip()) < 1:
        raise HTTPBadRequest

    site = Site(name=request.POST['site_name'].strip())
    user = User.get_from_id(authenticated_userid(request))

    site.users.append(user)
    DBSession.add(site)
    DBSession.flush()

    return HTTPSeeOther(location=request.route_url('site', site_key=site.key))

@view_config(route_name='site', renderer='templates/site.mako')
def site(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))

    return {
        'site': site,
    }

@view_config(route_name='site_pages', request_method='POST')
def site_pages(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))

    if 'page_name' in request.POST and len(request.POST['page_name'].strip()) > 0:
        page = Page(name=request.POST['page_name'].strip(), site=site)
        DBSession.add(page)

        page_section = PageSection(type='undecided', page=page)
        DBSession.add(page_section)
        DBSession.flush()

        return HTTPSeeOther(location=request.route_url('site_page', site_key=site.key, page_id=page.id))

    return HTTPFound(location=request.route_url('site', site_key=site.key))

@view_config(route_name='site_page', renderer='templates/site_page.mako')
def site_page(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))
    page = Page.get_for_site_id_and_page_id(site.id, request.matchdict['page_id'])

    if not page:
        return HTTPFound(location=request.route_url('site', site_key=site.key))

    if request.POST and 'page_section_id' in request.POST:
        page_section = page.get_page_section(request.POST['page_section_id'])

        if not page_section:
            return HTTPNotFound()

        if 'section_type' in request.POST and PageSection.is_valid_type(request.POST['section_type']):
            page_section.type = request.POST['section_type']

        if 'section_content' in request.POST:
            page_section.content = request.POST['section_content']

        if 'section_gallery_id' in request.POST:
            gallery = Gallery.get_from_site_id_and_gallery_id(site.id, request.POST['section_gallery_id'])

            if not gallery:
                return HTTPBadRequest()

            page_section.gallery = gallery

    if request.POST and 'command' in request.POST:
        if request.POST['command'] == 'page_section_create':
            page_section = PageSection(page=page, type='gallery')

            DBSession.add(page_section)
            DBSession.flush()

            return HTTPSeeOther(
                location=request.route_url('site_page', site_key=site.key, page_id=page.id) + '#page-section-' + str(page_section.id)
            )

    return {
        'site': site,
        'page': page,
    }