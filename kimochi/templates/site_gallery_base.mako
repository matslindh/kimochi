<%inherit file="site_base.mako" />

<nav class="col-md-4">
    <ol class="nav nav-pills nav-stacked">
        % for gallery in site.galleries:
            % if 'gallery_id' in request.matchdict and int(request.matchdict['gallery_id']) == gallery.id:
                <li class="active">
                    <a href="${request.route_url('site_gallery', site_key=site.key, gallery_id=gallery.id)}">${gallery.name}</a>
                </li>
            % else:
                <li>
                    <a href="${request.route_url('site_gallery', site_key=site.key, gallery_id=gallery.id)}">${gallery.name}</a>
                </li>
            % endif
        % endfor
        <li style="padding-top: 1.4em;">
            <a href="#" id="add-new-gallery-link">+ Add new gallery</a>

            <form method="post" action="${request.route_url('site_galleries', site_key=site.key)}">
                <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

                <input type="text" name="gallery_name" placeholder="Gallery name" />
                <input type="submit" value="Add" />
            </form>
        </li>
    </ol>
</nav>

<div class="col-md-8">
    ${next.body()}
</div>