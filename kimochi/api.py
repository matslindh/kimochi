from pyramid.view import (
    view_config,
    view_defaults,
    forbidden_view_config,
)

from pyramid.httpexceptions import (
    HTTPUnauthorized,
    HTTPNotFound,
)

from .models import (
    Site,
    Page,
    Gallery,
    Image,
    NotFoundException,
    NoAccessException,
)

@view_defaults(renderer='json', permission='api')
class SiteAPI:
    def __init__(self, request):
        self.request = request

        if 'api_key' not in request.GET:
            raise HTTPUnauthorized

        try:
            site = Site.get_from_key_and_api_key(request.matchdict['site_key'], request.GET.getone('api_key'))
        except NotFoundException:
            raise HTTPNotFound
        except NoAccessException:
            raise HTTPUnauthorized

        self.site = site

    @view_config(route_name='api_site_page')
    def page(self):
        page = Page.get_for_site_id_and_page_id_or_alias(self.site.id, self.request.matchdict['page_id'])

        if not page or not page.published:
            raise HTTPNotFound

        return {
            'site': self.site,
            'page': page,
        }

    @view_config(route_name='api_site_gallery')
    def gallery(self):
        gallery = self._current_gallery()

        return {
            'site': self.site,
            'gallery': gallery,
        }

    @view_config(route_name='api_site_gallery_image')
    def gallery_image(self):
        gallery = self._current_gallery()
        image = Image.get_from_gallery_id_and_image_id(self.request.matchdict['gallery_id'], self.request.matchdict['image_id'])

        if not image:
            raise HTTPNotFound

        return {
            'site': self.site,
            'gallery': gallery,
            'image': image,
        }

    def _current_gallery(self):
        gallery = Gallery.get_from_site_id_and_gallery_id(self.site.id, self.request.matchdict['gallery_id'])

        if not gallery:
            raise HTTPNotFound

        return gallery