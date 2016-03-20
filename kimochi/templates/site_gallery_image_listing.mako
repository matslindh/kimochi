<%page args="images" />

<ol id="gallery-images" class="listed">
    % for image in images:
        <li data-image-id="${image.id}">
            <div class="sort-handle">☰</div>

            <a href="${request.current_route_url(_route_name='site_gallery_image', image_id=image.id)}"><img src="${request.imbo.image_url(image.imbo_id).max_size(150, 100)}" alt="" style="float: left;" /></a>

            <div class="action-row">
                <a href="${request.current_route_url(_route_name='site_gallery_image', image_id=image.id)}"><span class="glyphicon glyphicon-pencil"></span></a>
            </div>

            <div class="image-description">
                <h4 class="${'content-not-provided' if not image.title else ''}">
                    ${image.title if image.title else 'Untitled'}
                </h4>
                <p class="${'content-not-provided' if not image.description else ''}">
                    ${image.description if image.description else 'No description'}
                </p>
            </div>
        </li>
    % endfor
</ol>

<script type="text/javascript">
    var sortable = new Sortable(document.getElementById('gallery-images'), {
        handle: '.sort-handle',
        ghostClass: 'sort-ghost',
        animation: 100,
        onEnd: function (evt) {
            if (evt.oldIndex != evt.newIndex)
            {
                $("#gallery-save-button").addClass("btn-primary");
            };
        }
    });
</script>