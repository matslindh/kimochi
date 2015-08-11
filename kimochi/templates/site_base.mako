<%inherit file="base.mako" />

<h2>
    ${site.name}

    <a href="${request.route_url('site_pages', site_key=site.key)}" class="${'btn-primary' if 'page' in request.matched_route.name else ''} btn-lg">Pages</a>
    <a href="${request.route_url('site_galleries', site_key=site.key)}"  class="${'btn-primary' if 'galler' in request.matched_route.name else ''} btn-lg">Galleries</a>
</h2>

<div class="row">
    ${next.body()}
</div>

<script type="text/javascript">
    $("#add-new-page-link").click(function () {
        $(this).hide();
        $("#add-page-form").show();
    });
</script>