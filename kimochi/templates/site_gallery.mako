<%inherit file="site_gallery_base.mako" />

<script type="text/javascript" src="${request.static_url('kimochi:static/dropzone.js')}"></script>

<h3 class="top" style="border-bottom: 1px solid #ccc; padding-bottom: 16px;">
    Gallery: ${gallery.name}
</h3>

% if gallery.images:
    <ol>
        % for image in gallery.images:
            <li>
                <img src="${request.imbo.image_url(image.imbo_id).max_size(200, 200)}" alt="" />
            </li>
        % endfor
    </ol>
% else:
    Gallery is empty. Add some images!
% endif

<form action="${request.route_url('site_gallery_images', site_key=site.key, gallery_id=gallery.id)}" class="dropzone" id="gallery-file-uploader">
    <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

    <div class="dz-message">
        Drop images here to add them to the gallery
    </div>
</form>