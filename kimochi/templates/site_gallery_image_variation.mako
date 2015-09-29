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
    <div>
        <img src="${request.imbo.image_url(image.imbo_id).max_size(750, 750)}" alt="Full image preview" id="image-full" />
    </div>
</section>


<script language="Javascript">
    $(function($) {
        $('#image-full').Jcrop();
    });
</script>