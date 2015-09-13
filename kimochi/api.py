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
        page = Page.get_for_site_id_and_page_id(self.site.id, self.request.matchdict['page_id'])

        if not page or not page.published:
            raise HTTPNotFound

        return {
            'site': self.site,
            'page': page,
        }

    @view_config(route_name='api_site_gallery')
    def gallery(self):
        return {'gallery': 'beep boop'}

    def image(self):
        return {'image': 'beepel boopel'}