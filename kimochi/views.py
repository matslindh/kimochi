from pyramid.response import Response
from pyramid.view import view_config

from .models import (
    DBSession,
    )


@view_config(route_name='login', renderer='templates/login.mako')
def login(request):
    pass

@view_config(route_name='index', renderer='templates/index.mako')
def index(request):
    pass

