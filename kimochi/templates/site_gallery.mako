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

<form action="${request.current_route_url(_route_name='site_gallery_images')}" class="dropzone" id="gallery-file-uploader">
    <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

    <div class="dz-message">
        Drop images here to add them to the gallery
    </div>
</form>

% if gallery.images:
    <%include file="site_gallery_image_listing.mako" args="images=gallery.images" />
% else:
    Gallery is empty. Add some images!
% endif

<script type="text/javascript">
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

    var error_occured = false;

    var dz = $(".dropzone").dropzone({
        "url": "${request.current_route_url(_route_name='site_gallery_images')}",
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
