<%inherit file="base.mako" />

<h2>
    ${site.name}
</h2>

<div class="row">
    <nav class="col-md-4">
        <ol class="nav nav-pills nav-stacked">
            % for page in site.pages:
                <li ${'class="active"' if 'page_id' in request.matchdict and int(request.matchdict['page_id']) == page.id else 'foo' | n}>
                    <a href="${request.route_url('site_page', site_key=site.key, page_id=page.id)}">${page.name}</a>
                </li>
            % endfor
            <li style="padding-top: 1.4em;">
                <a href="#" id="add-new-page-link">+ Add new page</a>

                <form method="post" action="${request.route_url('site_pages', site_key=site.key)}">
                    <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

                    <input type="text" name="page_name" placeholder="Page name" />
                    <input type="submit" value="Add" />
                </form>
            </li>
        </ol>
    </nav>

    <div class="col-md-8">
        ${next.body()}
    </div>
</nav>

<script type="text/javascript">
    $("#add-new-page-link").click(function () {
        $(this).hide();
        $("#add-page-form").show();
    });
</script>