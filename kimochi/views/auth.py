from pyramid.view import (
    view_config,
    forbidden_view_config,
)

from pyramid.httpexceptions import (
    HTTPBadRequest,
    HTTPFound,
)

from ..models import (
    User,
    )

from pyramid.security import (
    remember,
    forget,
)


@view_config(route_name='login', renderer='kimochi:templates/login.mako')
@forbidden_view_config(renderer='kimochi:templates/login.mako')
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