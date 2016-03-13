<%inherit file="site_base.mako" />

<h3>
    Add new page
</h3>

<form method="post" action="${request.route_url('site_pages', site_key=site.key)}">
    <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

    <input type="text" name="page_name" placeholder="Page name" />
    <input type="submit" value="Add" />
</form>

<h3>Existing pages</h3>

<table class="table table-striped">
    <tr>
        <th>Name</th>
    </tr>
    % for page in site.pages_available():
        <tr>
            <td class="text-muted">
                <a href="${request.route_url('site_page', site_key=site.key, page_id=page.id)}">${page.name}</a>
            </td>
        </tr>
    % endfor
</table>

Display a 1-2-3 stage tutorial for creating the first page here.