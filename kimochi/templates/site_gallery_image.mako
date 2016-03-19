<%inherit file="site_gallery_base.mako" />

<h3 class="top">
    <a href="${request.current_route_url(_route_name='site_gallery')}">${gallery.name}</a> / ${image.title if image.title else 'Untitled image'}

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

    <div>
        Variations:

        % for variation in image.variations_and_site_aspect_ratios(site.aspect_ratios):
            <a href="${request.current_route_url(_route_name='site_gallery_image_variation', width=variation['width'], height=variation['height'])}">
                ${variation['width']}:${variation['height']}
                ${'<span class="glyphicon glyphicon-ok"></span>' if variation['has_variation'] else '<span class="glyphicon glyphicon-remove"></span>' | n}
            </a>
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
</script>