<%inherit file="site_gallery_base.mako" />

<h3 class="top" style="border-bottom: 1px solid #ccc; padding-bottom: 16px;">
    <a href="${request.current_route_url(_route_name='site_gallery')}">${gallery.name}</a> / ${image.title if image.title else 'Untitled image'}
</h3>