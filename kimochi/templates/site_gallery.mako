<%inherit file="site_gallery_base.mako" />

<script type="text/javascript" src="${request.static_url('kimochi:static/dropzone.js')}"></script>

<h3 class="top" style="border-bottom: 1px solid #ccc; padding-bottom: 16px;">
    Gallery: ${gallery.name}

    <form method="post" id="gallery-save"  style="float: right;">
        <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />
        <input type="submit" id="gallery-save-button" value="Save" class="btn btn-default" />
    </form>
</h3>

% if gallery.images:
    <ol id="gallery-images" class="listed">
        % for image in gallery.images:
            <li style="margin-bottom: 1.0em; min-height: 100px; overflow: hidden; list-style-type: none;" data-image-id="${image.id}">
                <div class="sort-handle">☰</div>

                <img src="${request.imbo.image_url(image.imbo_id).max_size(150, 100)}" alt="" style="float: left;" />

                <div class="action-row">
                    <span class="glyphicon glyphicon-pencil"></span>
                </div>

                <div class="image-description">
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
        $.post("${request.current_route_url(_route_name='site_gallery_images')}", {s: ids}, function () {
            $("#gallery-save-button").blur();

            $("#gallery-save-button").animate({
                backgroundColor: "#aaffaa",
                borderColor: "#ccc",
                color: "#000000",
            }, 300, function () {
                $(this).delay(1000).animate({
                    backgroundColor: "#ffffff",
                }, 300, function () {
                    $(this).removeClass('btn-primary');
                    $(this).removeAttr('style');
                });
            });
        });
        return false;
    };

    $("#gallery-save").submit(save);
</script>