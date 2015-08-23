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
    DBSession,
    )

from pyramid.security import (
    authenticated_userid,
)

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

    if 's' in request.POST:
        sequence = request.POST.getall('s')
        image_ids = {image.id: image for image in gallery.images}

        for id in sequence:
            if id not in image_ids:
                return HTTPBadRequest()

        for (idx, id) in sequence:
            image_ids[id].order = idx + 1

        return HTTPNoContent()

    if 'file' in request.POST and getattr(request.POST['file'], 'file'):
        result = request.imbo.add_image_from_string(request.POST['file'].file)

        if not result or 'imageIdentifier' not in result:
            return HTTPBadRequest()

        image = Image(gallery=gallery, imbo_id=result['imageIdentifier'])
        DBSession.add(image)
        DBSession.flush()

        return image

    return HTTPBadRequest()
