<%inherit file="site_gallery_base.mako" />

<h3 class="top">
    <a href="${request.current_route_url(_route_name='site_gallery')}">${gallery.name}</a>
    % if image.parent_image_id and image.parent_image:
        / <a href="${request.current_route_url(image_id=image.parent_image_id)}">${image.parent_image.title if image.parent_image.title else 'Untitled image'}</a>
    % endif

    / ${image.title if image.title else 'Untitled image'}

    <form method="post" class="gallery-delete-image-form">
        <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />
        <input type="hidden" name="delete_image" value="true" />
        <button class="btn btn-sm"><span class="glyphicon glyphicon-trash"></span> Delete this image permanently</button>
    </form>
</h3>

<section class="image-details">
    <div>
        <img src="${request.imbo.image_url(image.imbo_id).max_size(656, 656)}" alt="Image preview" />
    </div>

    <div class="cropped-versions-list">
        Cropped versions:

        % for variation in image.variations_and_site_aspect_ratios(site.aspect_ratios):
            <a href="${request.current_route_url(_route_name='site_gallery_image_variation', width=variation['width'], height=variation['height'])}">
                ${variation['width']}:${variation['height']}
                ${'<span class="glyphicon glyphicon-ok"></span>' if variation['has_variation'] else '<span class="glyphicon glyphicon-remove"></span>' | n}</a>
        % endfor
    </div>

    <form method="post">
        <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

        <div class="form-group">
            <label for="image-title-field">Title</label>
            <input type="text" name="title" class="form-control" id="image-title-field" placeholder="Untitled image" value="${image.title if image.title else ''}" />
        </div>
        <div class="form-group">
            <label for="image-description-field">Description</label>
            <textarea class="form-control" name="description" id="image-description-field" placeholder="Extended image description, if needed." rows="5">${image.description if image.description else ''}</textarea>
        </div>

        <input type="submit" id="gallery-save-button" value="Save" class="btn btn-primary" />
    </form>
</section>

% if not image.parent_image_id:
    <h4 class="option-header">
        Related / Alternative Images
    </h4>

    <p class="option-description">
        These are images that will be included as "related images" or "alternative images" of the existing image, for example to showcase a different view of the same image (i.e. a pattern on a product, a photo in a gallery, etc.).
    </p>

    <form action="${request.current_route_url(_route_name='site_gallery_images')}" class="dropzone" id="gallery-file-uploader">
        <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

        <div class="dz-message">
            Drop images here to add them as relevant images
        </div>
    </form>

    <h5>
        Added images
    </h5>

    % if image.children:
        <%include file="site_gallery_image_listing.mako" args="images=image.children" />
    % else:
        <p>
            No images has been added as related or alternative images.
        </p>
    % endif
% endif

<script type="text/javascript">
    $(".gallery-delete-image-form button").click(function () {
        if ($(this).data("already-clicked")) {
            return true;
        }

        $(this).data("already-clicked", true);
        $(this).addClass("btn-danger");
        $(this).html("<span class='glyphicon glyphicon-ok'></span> Yes. Delete this image permanently.");

        return false;
    });

    var dz = $(".dropzone").dropzone({
        "url": "${request.current_route_url()}",
        "headers": { "X-CSRF-Token": "${request.session.get_csrf_token()}" },
        "queuecomplete": function () {
            if (!error_occured) {
                location.href = location.href;
            }
        },
        "error": function (file, message, xhr) {
            error_occured = true;
            var el = $(file.previewElement);
            el.addClass('dz-error');
            el.html(message);
        }
    });
</script>