<%inherit file="site_base.mako" />

<script src="${request.static_url('kimochi:static/Jcrop/jquery.Jcrop.min.js')}"></script>
<link rel="stylesheet" href="${request.static_url('kimochi:static/Jcrop/jquery.Jcrop.min.css')}" type="text/css" />

<h3 class="top" style="margin-top: 1.0em;">
    Selecting ${request.matchdict['width']}:${request.matchdict['height']} Crop of

    <a href="${request.current_route_url(_route_name='site_gallery')}">${gallery.name}</a> /
    <a href="${request.current_route_url(_route_name='site_gallery_image')}">${image.title if image.title else 'Untitled image'}</a>
</h3>

<p>
    <a href="${request.current_route_url(_route_name='site_gallery_image')}">Back to image</a>
</p>

<section class="image-details">
    <div style="float: right; overflow: hidden;">
        <div style="width: 250px; height: 250px; border: 1px dotted #888">
            <div style="overflow:hidden; opacity: 0.1;" id="image-preview-container">
                <img src="${request.imbo.image_url(image.imbo_id).max_size(750,750)}" id="image-preview" style="display: none;" />
            </div>
        </div>

        <form method="post">
            <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />
            <input type="hidden" name="crop_width" value="" id="crop-width" />
            <input type="hidden" name="crop_height" value="" id="crop-height" />
            <input type="hidden" name="crop_offset_width" value="" id="crop-offset-width" />
            <input type="hidden" name="crop_offset_height" value="" id="crop-offset-height" />
            <button class="btn btn-primary">
                Crop &nbsp; <span class="glyphicon glyphicon-scissors"></span>
            </button>
        </form>
    </div>

    <div>
        <img src="${request.imbo.image_url(image.imbo_id)}" style="max-width: 750px; max-height: 750px;" alt="Full image preview" id="image-full" />
    </div>
</section>


<script language="Javascript">
    //  c.x, c.y, c.x2, c.y2, c.w, c.h
    $(window).load(function () {
        var width = ${image.width}, height = ${image.height};

        var update_preview = function (coords) {
            if (parseInt(coords.w) > 0)
            {
                var container = $("#image-preview-container");

                var aspect = coords.w / coords.h;

                if (aspect > 1) {
                    container.css('width', 250);
                    container.css('height', 250 / aspect);
                }
                else
                {
                    container.css('width', 250 * aspect);
                    container.css('height', 250);
                }

                var rx = container.width() / coords.w;
                var ry = container.height() / coords.h;

                $('#image-preview').css({
                    width: Math.round(rx * width) + 'px',
                    height: Math.round(ry * height) + 'px',
                    marginLeft: '-' + Math.round(rx * coords.x) + 'px',
                    marginTop: '-' + Math.round(ry * coords.y) + 'px',
                    display: 'inline'
                });

                container.css('opacity', 1);

                $('#crop-width').val(coords.w);
                $('#crop-height').val(coords.h);
                $('#crop-offset-width').val(coords.x);
                $('#crop-offset-height').val(coords.y);
            }
        }

        $('#image-full').Jcrop({
            onChange: update_preview,
            trueSize: [width, height],
            aspectRatio: ${aspect_ratio}
        });
    });
</script>