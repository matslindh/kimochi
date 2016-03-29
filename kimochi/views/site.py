from pyramid.view import (
    view_config,
)

from pyramid.httpexceptions import (
    HTTPBadRequest,
    HTTPSeeOther,
    HTTPServerError,
)

from ..models import (
    User,
    Site,
    SiteAspectRatio,
    DBSession,
    )

from pyramid.security import (
    authenticated_userid,
)


@view_config(route_name='index', renderer='kimochi:templates/index.mako')
def index(request):
    return {}


@view_config(route_name='sites', request_method='POST', renderer='kimochi:templates/index.mako', check_csrf=True)
def site_add(request):
    if 'site_name' not in request.POST or len(request.POST['site_name'].strip()) < 1:
        raise HTTPBadRequest

    site = Site(name=request.POST['site_name'].strip())
    user = User.get_from_id(authenticated_userid(request))

    site.users.append(user)
    DBSession.add(site)
    DBSession.flush()

    return HTTPSeeOther(location=request.route_url('site', site_key=site.key))


@view_config(route_name='site_setting_details', request_method='POST', check_csrf=True)
def site_setting_details(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))

    if 'select_index_page' in request.POST and site.get_active_page(request.POST['select_index_page']):
        site.set_default_index_page(site.get_active_page(request.POST['select_index_page']))
        request.session.flash("The default index page has been updated.")

    updated_details = False

    if 'site_name' in request.POST and len(request.POST.getone('site_name')) > 0:
        site.name = request.POST.getone('site_name')
        updated_details = True

    if 'site_meta_description' in request.POST:
        site.meta_description = request.POST.getone('site_meta_description')
        updated_details = True

    if 'site_tagline' in request.POST:
        site.tagline = request.POST.getone('site_tagline')
        updated_details = True

    if updated_details:
        request.session.flash("Site settings has been saved.")

    return HTTPSeeOther(
        location=request.current_route_url()
    )


@view_config(route_name='site_setting_header_footer', request_method='POST', check_csrf=True)
def site_setting_header_footer(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))

    if 'footer' in request.POST:
        site.footer = request.POST['footer'].strip()
        request.session.flash("Footer text has been updated!")

    if 'file' in request.POST and getattr(request.POST['file'], 'file'):
        result = request.imbo.add_image_from_string(request.POST['file'].file)

        if not result or 'imageIdentifier' not in result:
            return HTTPServerError()

        site.header_imbo_id = result['imageIdentifier']
        request.session.flash("Header image has been updated")

    return HTTPSeeOther(
        location=request.current_route_url()
    )


@view_config(route_name='site_setting_social_media', request_method='POST', check_csrf=True)
def site_setting_social_media(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))
    updated_details = False

    if 'social_media_facebook' in request.POST:
        site.set_setting('social_media_facebook', request.POST.getone('social_media_facebook'))
        updated_details = True

    if 'social_media_instagram' in request.POST:
        site.set_setting('social_media_instagram', request.POST.getone('social_media_instagram'))
        updated_details = True

    if updated_details:
        request.session.flash("Social media addresses has been updated!")

    return HTTPSeeOther(
        location=request.current_route_url()
    )


@view_config(route_name='site_setting_aspect_ratios', request_method='POST', check_csrf=True)
def site_setting_aspect_ratios(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))

    if 'aspect_ratio_width' in request.POST and 'aspect_ratio_height' in request.POST:
        try:
            width = int(request.POST['aspect_ratio_width'])
            height = int(request.POST['aspect_ratio_height'])

            if width < 1 or height < 1:
                request.session.flash("Invalid dimensions for new aspect ratio.")
            else:
                aspect = SiteAspectRatio(width=width, height=height)
                site.aspect_ratios.append(aspect)
                request.session.flash("New aspect ratio has been added!")
        except ValueError:
            request.session.flash("The provided aspect ratios was unparsable.")

    return HTTPSeeOther(
        location=request.current_route_url()
    )


@view_config(route_name='site_setting_api_keys', request_method='POST', check_csrf=True)
def site_setting_api_keys(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))

    if 'command' in request.POST:
        if request.POST['command'] == 'generate_api_key' and len(site.api_keys) < 20:
            key = site.api_key_generate()
            request.session.flash("A new API key has been generated: " + key.key)
            DBSession.flush()

            return HTTPSeeOther(
                location=request.current_route_url() + '#key_' + str(key.id)
            )

    return HTTPSeeOther(
        location=request.current_route_url()
    )


@view_config(route_name='site', renderer='kimochi:templates/site_setting_details.mako')
@view_config(route_name='site_setting_details', renderer='kimochi:templates/site_setting_details.mako')
@view_config(route_name='site_setting_header_footer', renderer='kimochi:templates/site_setting_header_footer.mako')
@view_config(route_name='site_setting_social_media', renderer='kimochi:templates/site_setting_social_media.mako')
@view_config(route_name='site_setting_api_keys', renderer='kimochi:templates/site_setting_api_keys.mako')
@view_config(route_name='site_setting_aspect_ratios', renderer='kimochi:templates/site_setting_aspect_ratios.mako')
def site_details(request):
    site = Site.get_from_key_and_user_id(request.matchdict['site_key'], authenticated_userid(request))

    return {
        'site': site,
        'index_page': site.get_index_page(),
    }