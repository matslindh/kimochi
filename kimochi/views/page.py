from pyramid.view import (
    view_config,
)

from pyramid.httpexceptions import (
    HTTPBadRequest,
    HTTPFound,
    HTTPSeeOther,
    HTTPNotFound,
    HTTPServiceUnavailable,
)

from ..models import (
    Site,
    Page,
    Image,
    PageSection,
    PageSectionImage,
    Gallery,
    DBSession,
    )

from pyramid.renderers import render

import collections


@view_config(route_name='site_pages', request_method='POST', require_csrf=True)
def site_pages(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], request.authenticated_userid)

    if 'page_name' in request.POST and len(request.POST['page_name'].strip()) > 0:
        first_page = not site.pages
        page = Page.create(name=request.POST['page_name'].strip(), site=site, published=first_page)

        DBSession.flush()
        return HTTPSeeOther(location=request.route_url('site_page', site_key=site.key, page_id=page.id))

    return HTTPFound(location=request.route_url('site', site_key=site.key))


@view_config(route_name='site_pages', request_method='GET', renderer='kimochi:templates/site_pages.mako')
def site_pages_list(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], request.authenticated_userid)
    pages = site.pages_available()

    if 'category' in request.GET:
        category = request.GET.getone('category')

        if category == 'archived':
            pages = site.pages_archived()

    return {
        'site': site,
        'pages': pages,
    }


@view_config(route_name='site_pages', request_method='POST', renderer='json', require_csrf=True, xhr=True)
def site_pages_update(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], request.authenticated_userid)

    if 's[]' not in request.POST:
        raise HTTPBadRequest

    for idx, page_id in enumerate(request.POST.getall('s[]')):
        page = Page.get_any_for_site_id_and_page_id(site.id, page_id)

        if not page:
            raise HTTPBadRequest

        page.order = idx + 1

    return {
        'result': True,
    }


@view_config(route_name='site_page', request_method='POST', renderer='kimochi:templates/site_page.mako', require_csrf=True, xhr=False)
@view_config(route_name='site_page', request_method='POST', renderer='json', require_csrf=True, xhr=True)
def site_page_update(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], request.authenticated_userid)
    page = Page.get_for_site_id_and_page_id(site.id, request.matchdict['page_id'])

    if not page:
        return HTTPFound(location=request.route_url('site', site_key=site.key))

    if 'page_section_id' in request.POST:
        page_section = page.get_page_section(request.POST['page_section_id'])

        if not page_section:
            return HTTPNotFound()

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
            try:
                data = request.json_body
            except:
                raise HTTPBadRequest

            # verify that the submitted json is iterable
            if 'sections' not in data or not isinstance(data['sections'], collections.Iterable):
                raise HTTPBadRequest

            if 'page_name' in data and data['page_name'] != page.name:
                page.name = data['page_name']

            def section_parser(sections, depth=1):
                # avoid stack overflow (we currently allow only level of sections within sections)
                if depth > 2:
                    return

                if not len(sections) or not isinstance(sections, collections.Iterable):
                    return

                for position, section_data in enumerate(sections):
                    section = PageSection.get_from_page_id_and_page_section_id(page.id, section_data['section_id'])

                    if not section:
                        raise HTTPBadRequest

                    if 'parent_section_id' in section_data:
                        parent_section_local = PageSection.get_from_page_id_and_page_section_id(page.id, section_data['parent_section_id'])

                        if not parent_section_local or not PageSection.is_valid_parent_type(parent_section_local.type):
                            raise HTTPBadRequest

                        section.parent_section_id = parent_section_local.id

                    section.order = position

                    if section.type == 'text' and 'content' in section_data:
                        # purifier here?
                        section.content = section_data['content']

                    if 'sections' in section_data:
                        section_parser(section_data['sections'], depth + 1)

            # loop through the sections and update content + positions
            # galleries / images usually update live, so we just do text for now..
            section_parser(data['sections'])

            return {
                'success': True,
            }

        if 'toggle_published' in request.POST:
            page.published = not page.published

            return HTTPSeeOther(
                location=request.current_route_url()
            )
        elif 'archive_page' in request.POST:
            page.archive(site)

            return HTTPSeeOther(
                location=request.route_url('site_pages', site_key=site.key)
            )

        elif 'file' in request.POST and getattr(request.POST['file'], 'file') and 'page_section_id' in request.GET:
            page_section = PageSection.get_from_page_id_and_page_section_id(page.id, request.GET.getone('page_section_id'))

            if not page_section:
                return HTTPBadRequest

            result = request.imbo.add_image_from_string(request.POST['file'].file)

            if not result or 'imageIdentifier' not in result:
                return HTTPServiceUnavailable()

            if 'command' in request.GET and request.GET.getone('command') == 'replace_images' and request.POST.getone('is_first') == "1":
                page_section.images = []

            image = Image(imbo_id=result['imageIdentifier'], width=result['width'], height=result['height'], site=site)
            DBSession.add(image)
            DBSession.flush()

            psi = PageSectionImage()
            psi.image = image

            page_section.images.append(psi)
            return image
        elif 'add_section_type' in request.POST and PageSection.is_valid_type(request.POST.getone('add_section_type')):
            section_type = request.POST.getone('add_section_type')

            if section_type == 'two_columns':
                page_section = PageSection.create_two_columns(page=page)
            else:
                page_section = PageSection(page=page, type=section_type)

                if 'parent_section_id' in request.POST and request.POST['parent_section_id']:
                    parent_section_id = request.POST.getone('parent_section_id')
                    parent_section = PageSection.get_from_page_id_and_page_section_id(page.id, parent_section_id)

                    if not parent_section:
                        raise HTTPBadRequest

                    if not PageSection.is_valid_parent_type(parent_section.type):
                        raise HTTPBadRequest

                    if 'parent_sub_section_idx' in request.POST:
                        idx = int(request.POST.getone('parent_sub_section_idx'))

                        if idx >= len(parent_section.sections):
                            raise HTTPBadRequest

                        parent_section.sections[idx].sections.append(page_section)
                    else:
                        parent_section.sections.append(page_section)

            DBSession.add(page_section)
            DBSession.flush()

            content = render('kimochi:templates/sections/wrapper.mako',
                    {'section': page_section, 'site': site, 'page': page, },
                    request=request)

            return {
                'content': content,
            }

    return {
        'site': site,
        'page': page,
    }


@view_config(route_name='site_page', renderer='kimochi:templates/site_page.mako')
def site_page(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], request.authenticated_userid)
    page = Page.get_for_site_id_and_page_id(site.id, request.matchdict['page_id'])

    if not page:
        return HTTPSeeOther(
            location=request.route_url('site_pages', site_key=site.key)
        )

    return {
        'site': site,
        'page': page,
    }
