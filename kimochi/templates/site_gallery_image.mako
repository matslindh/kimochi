<%inherit file="site_gallery_base.mako" />

<h3 class="top">
    <a href="${request.current_route_url(_route_name='site_gallery')}">${gallery.name}</a> / ${image.title if image.title else 'Untitled image'}
</h3>

<section class="image-details">
    <div>
        <img src="${request.imbo.image_url(image.imbo_id).max_size(656, 656)}" alt="Image preview" />
    </div>

    <form method="post">
        <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

        <div class="form-group">
            <label for="image-title-field">Title</label>
            <input type="text" class="form-control" id="image-title-field" placeholder="Untitled image" value="${image.title if image.title else ''}" />
        </div>
        <div class="form-group">
            <label for="image-description-field">Description</label>
            <textarea class="form-control" id="image-description-field" placeholder="Extended image description, if needed." rows="5">${image.description if image.description else ''}</textarea>
        </div>

        <input type="submit" id="gallery-save-button" value="Save" class="btn btn-primary" />
    </form>
</section>