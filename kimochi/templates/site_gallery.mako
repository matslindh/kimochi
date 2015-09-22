<%inherit file="site_gallery_base.mako" />

<h3 class="top">
    Gallery: ${gallery.name}

    <form method="post" id="gallery-save"  style="float: right;">
        <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />
        <input type="submit" id="gallery-save-button" value="Save" class="btn btn-default" />
    </form>
</h3>

% if request.session.peek_flash():
    % for message in request.session.pop_flash():
        <div class="alert alert-success" role="alert">${message}</div>
    % endfor
% endif

% if gallery.images:
    <ol id="gallery-images" class="listed">
        % for image in gallery.images:
            <li data-image-id="${image.id}">
                <div class="sort-handle">☰</div>

                <img src="${request.imbo.image_url(image.imbo_id).max_size(150, 100)}" alt="" style="float: left;" />

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
% else:
    Gallery is empty. Add some images!
% endif

<form action="${request.current_route_url(_route_name='site_gallery_images')}" class="dropzone" id="gallery-file-uploader">
    <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

    <div class="dz-message">
        Drop images here to add them to the gallery
    </div>
</form>

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

    var save = function () {
        var ids = []
        $("#gallery-images>li").each(function (idx) {
            ids.push($(this).data('image-id'));
        });

        console.log(ids);
        $.post("${request.current_route_url(_route_name='site_gallery_images')}", {
                's': ids,
                'csrf_token': '${request.session.get_csrf_token()}'
            }, function () {
            flash_button_ok($("#gallery-save-button"));
        });
        return false;
    };

    $("#gallery-save").submit(save);
</script>