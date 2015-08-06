<%inherit file="base.mako" />

<h2>
    ${site.name}
</h2>

<ol>
    % for page in site.pages:
        <li>
            <a href="${request.route_url('site_page', site_key=site.key, page_id=page.id)}">${page.name}</a>
        </li>
    % endfor
    <li>
        <a href="#" id="add-new-page-link">+ Add new page</a>

        <form method="post" action="${request.route_url('site_pages', site_key=site.key)}">
            <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

            <input type="text" name="page_name" placeholder="Page name" />
            <input type="submit" value="Add" />
        </form>
    </li>
</ol>

${next.body()}

<script type="text/javascript">
    $("#add-new-page-link").click(function () {
        $(this).hide();
        $("#add-page-form").show();
    });
</script>