<%inherit file="site_gallery_base.mako" />

<script type="text/javascript" src="${request.static_url('kimochi:static/dropzone.js')}"></script>

<h3 class="top" style="border-bottom: 1px solid #ccc; padding-bottom: 16px;">
    Gallery: ${gallery.name}
</h3>

% if gallery.images:
    <ol>
        % for image in gallery.images:
            <li style="margin-bottom: 1.0em; min-height: 100px; overflow: hidden; list-style-type: none;">
                <img src="${request.imbo.image_url(image.imbo_id).max_size(250, 150)}" alt="" style="float: left;" />

                <div style="margin-left: 275px;">
                    <h4 style="margin-top: 0;">
                        No title provided
                    </h4>
                    <p>
                        No description
                    </p>
                </div>
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