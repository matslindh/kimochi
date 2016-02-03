from pyramid.view import (
    view_config,
)

from pyramid.httpexceptions import (
    HTTPBadRequest,
    HTTPFound,
    HTTPSeeOther,
    HTTPNotFound,
)

from ..models import (
    Site,
    Page,
    PageSection,
    Gallery,
    DBSession,
    )

from pyramid.security import (
    authenticated_userid,
)

from pyramid.renderers import JSON

@view_config(route_name='site_pages', request_method='POST', check_csrf=True)
def site_pages(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))

    if 'page_name' in request.POST and len(request.POST['page_name'].strip()) > 0:
        first_page = not site.pages
        page = Page(name=request.POST['page_name'].strip(), site=site, published=first_page)
        DBSession.add(page)

        page_section = PageSection(type='text', page=page, content='')
        DBSession.add(page_section)

        if first_page:
            site.set_default_index_page(page)

        DBSession.flush()

        return HTTPSeeOther(location=request.route_url('site_page', site_key=site.key, page_id=page.id))

    return HTTPFound(location=request.route_url('site', site_key=site.key))

@view_config(route_name='site_pages', request_method='GET', renderer='kimochi:templates/site_pages.mako')
def site_pages_list(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))

    if site.pages:
        return HTTPFound(location=request.route_url('site_page', site_key=site.key, page_id=site.pages[0].id))

    return {
        'site': site,
    }


@view_config(route_name='site_page', request_method='POST', renderer='kimochi:templates/site_page.mako', check_csrf=True, xhr=False)
@view_config(route_name='site_page', request_method='POST', renderer='json', check_csrf=True, xhr=True)
def site_page_update(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))
    page = Page.get_for_site_id_and_page_id(site.id, request.matchdict['page_id'])

    if not page:
        return HTTPFound(location=request.route_url('site', site_key=site.key))

    if 'page_section_id' in request.POST:
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

        return HTTPSeeOther(
            location=request.route_url('site_page', site_key=site.key, page_id=page.id) + '#page-section-' + str(page_section.id)
        )

    if request.method == 'POST':
        if request.headers['Content-Type'].startswith('application/json'):
            # We need to actually save stuff here and return False if things are fubar
            return {
                'success': True,
            }

        if 'toggle_published' in request.POST:
            page.published = not page.published

            return HTTPSeeOther(
                location=request.current_route_url()
            )
        elif request.POST['command'] == 'page_section_create':
            section_type = 'text'
            valid = ['text', 'gallery', 'two_columns']

            for v in valid:
                if v in request.POST:
                    section_type = v
                    break

            if section_type == 'two_columns':
                page_section = PageSection.create_two_columns(page=page)
            else:
                page_section = PageSection(page=page, type=section_type)

            DBSession.add(page_section)
            DBSession.flush()

            return HTTPSeeOther(
                location=request.route_url('site_page', site_key=site.key, page_id=page.id) + '#page-section-' + str(page_section.id)
            )

    return {
        'site': site,
        'page': page,
    }


@view_config(route_name='site_page', renderer='kimochi:templates/site_page.mako')
def site_page(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))
    page = Page.get_for_site_id_and_page_id(site.id, request.matchdict['page_id'])

    return {
        'site': site,
        'page': page,
    }