from pyramid.view import (
    view_config,
)

from pyramid.httpexceptions import (
    HTTPFound,
    HTTPSeeOther,
)

from ..models import (
    Site,
    Gallery,
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
        return HTTPFound(location=request.route_url('site', site_key=site.key))

    return {
        'site': site,
        'gallery': gallery,
    }