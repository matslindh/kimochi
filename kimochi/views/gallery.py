from pyramid.view import (
    view_config,
)

from pyramid.httpexceptions import (
    HTTPFound,
    HTTPNotFound,
    HTTPSeeOther,
    HTTPBadRequest,
    HTTPNoContent,
)

from ..models import (
    Site,
    Gallery,
    Image,
    ImageVariation,
    PageSection,
    DBSession,
    )

from pyramid.security import (
    authenticated_userid,
)

from pyramid.session import check_csrf_token

@view_config(route_name='site_galleries', renderer='kimochi:templates/site_galleries.mako')
def site_galleries(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))

    if request.POST and 'gallery_name' in request.POST and len(request.POST['gallery_name'].strip()) > 0:
        gallery = Gallery(name=request.POST['gallery_name'].strip(), site=site)
        DBSession.add(gallery)
        DBSession.flush()

        return HTTPSeeOther(location=request.route_url('site_gallery', site_key=site.key, gallery_id=gallery.id))

    if site.galleries:
        return HTTPFound(location=request.route_url('site_gallery', site_key=site.key, gallery_id=site.galleries[0].id))

    return {
        'site': site,
    }

@view_config(route_name='site_gallery', renderer='kimochi:templates/site_gallery.mako')
def site_gallery(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))
    gallery = Gallery.get_from_site_id_and_gallery_id(site.id, request.matchdict['gallery_id'])

    if not gallery:
        return HTTPNotFound()

    return {
        'site': site,
        'gallery': gallery,
    }

@view_config(route_name='site_gallery_images', request_method='POST', renderer='json')
def site_gallery_images(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))
    gallery = Gallery.get_from_site_id_and_gallery_id(site.id, request.matchdict['gallery_id'])

    if not gallery:
        return HTTPNotFound()

    if 's[]' in request.POST:
        sequence = [int(id) for id in request.POST.getall('s[]')]
        image_ids = {image.id: image for image in gallery.images}

        for id in sequence:
            if id not in image_ids:
                return HTTPBadRequest()

        for idx, id in enumerate(sequence):
            image_ids[id].order = idx + 1

        return HTTPNoContent()

    if 'file' in request.POST and getattr(request.POST['file'], 'file'):
        result = request.imbo.add_image_from_string(request.POST['file'].file)

        if not result or 'imageIdentifier' not in result:
            return HTTPBadRequest()

        image = Image(gallery=gallery, imbo_id=result['imageIdentifier'], width=result['width'], height=result['height'])
        DBSession.add(image)
        DBSession.flush()

        return image

    return HTTPBadRequest()

@view_config(route_name='site_gallery_image', renderer='kimochi:templates/site_gallery_image.mako')
def site_gallery_image(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))
    gallery = Gallery.get_from_site_id_and_gallery_id(site.id, request.matchdict['gallery_id'])

    if not gallery:
        return HTTPNotFound()

    image = Image.get_from_gallery_id_and_image_id(gallery.id, request.matchdict['image_id'])

    if not image:
        return HTTPNotFound()

    if 'title' in request.POST:
        image.title = request.POST['title']

        if 'description' in request.POST:
            image.description = request.POST['description']

        request.session.flash("Image title and description was updated!")

        if 'return_page_section_id' in request.GET:
            section = PageSection.get_from_id(request.GET['return_page_section_id'])

            if section and section.page.site_id == gallery.site_id:
                url = request.current_route_url(_route_name='site_page', page_id=section.page_id)+ '#page-section-' + str(section.id)
                return HTTPFound(location=url)

        return HTTPFound(location=request.current_route_url(_route_name='site_gallery'))

    return {
        'site': site,
        'gallery': gallery,
        'image': image,
    }

@view_config(route_name='site_gallery_image_variation', renderer='kimochi:templates/site_gallery_image_variation.mako')
def site_gallery_image_variation(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))
    gallery = Gallery.get_from_site_id_and_gallery_id(site.id, request.matchdict['gallery_id'])

    if not gallery:
        return HTTPNotFound()

    image = Image.get_from_gallery_id_and_image_id(gallery.id, request.matchdict['image_id'])

    if not image:
        return HTTPNotFound()

    try:
        if int(request.matchdict['width']) < 1 or int(request.matchdict['height']) < 1:
            return HTTPBadRequest()
    except ValueError:
        return HTTPBadRequest()

    if all(k in request.POST for k in ('crop_width', 'crop_height', 'crop_offset_width', 'crop_offset_height')):
        check_csrf_token(request)

        try:
            variation = ImageVariation(image=image)
            variation.width = int(round(float(request.POST['crop_width'])))
            variation.height = int(round(float(request.POST['crop_height'])))
            variation.offset_width = int(round(float(request.POST['crop_offset_width'])))
            variation.offset_height = int(round(float(request.POST['crop_offset_height'])))
            variation.aspect_width = int(request.matchdict['width'])
            variation.aspect_height = int(request.matchdict['height'])

            DBSession.add(variation)
        except ValueError as e:
            raise HTTPBadRequest()

        return HTTPFound(location=request.current_route_url(_route_name='site_gallery_image'))

    return {
        'site': site,
        'gallery': gallery,
        'image': image,
        'aspect_ratio': float(request.matchdict['width']) / float(request.matchdict['height']),
    }