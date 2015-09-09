from pyramid.view import (
    view_config,
    view_defaults,
    forbidden_view_config,
)

from .models import (
    Site,
)

@view_defaults(renderer='json', permission='api')
class Site:
    def __init__(self, request):
        self.request = request
        self.site = Site.get_from_key(request.matchdict['site_key'])
        print("- --- - - - - - - - -- - - - - - WE ARE INIT")

    @view_config(route_name='api_site_page')
    def page(self):
        return {'page': 'beep boop'}

    @view_config(route_name='api_site_gallery')
    def gallery(self):
        return {'gallery': 'beep boop'}

    def image(self):
        return {'image': 'beepel boopel'}