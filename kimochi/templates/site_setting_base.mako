<%inherit file="site_base.mako" />

<h3>
    Site Settings

    <a href="${request.route_url('site_setting_details', site_key=site.key)}" class="${'btn-primary' if 'details' in request.matched_route.name else ''} btn">Details</a>
    <a href="${request.route_url('site_setting_header_footer', site_key=site.key)}" class="${'btn-primary' if 'header_footer' in request.matched_route.name else ''} btn">Header and Footer</a>
    <a href="${request.route_url('site_setting_social_media', site_key=site.key)}" class="${'btn-primary' if 'social_media' in request.matched_route.name else ''} btn">Social Media</a>
    <a href="${request.route_url('site_setting_aspect_ratios', site_key=site.key)}" class="${'btn-primary' if 'aspect_ratios' in request.matched_route.name else ''} btn">Image Aspect Ratios</a>
    <a href="${request.route_url('site_setting_api_keys', site_key=site.key)}" class="${'btn-primary' if 'api_keys' in request.matched_route.name else ''} btn">API Keys</a>
</h3>

% if request.session.peek_flash():
    % for message in request.session.pop_flash():
        <div class="alert alert-success" role="alert">${message}</div>
    % endfor
% endif

${next.body()}