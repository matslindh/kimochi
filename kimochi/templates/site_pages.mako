<%inherit file="site_base.mako" />

<h3>
    Add new page
</h3>

<form method="post" action="${request.route_url('site_pages', site_key=site.key)}" class="form-inline">
    <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

    <input type="text" name="page_name" placeholder="Page title" class="form-control input-lg " size="40" />
    <input type="submit" value="Add" class="btn btn-default btn-lg" />
</form>

<h2 style="margin-top: 2.0em;">
    Pages
    <small class="header-filter">
        <a href="${request.current_route_url(_query=[])}">All</a>
        <a href="${request.current_route_url(_query=[('category', 'archived')])}">Archived</a>
    </small>
</h2>

<table class="table table-striped">
    <tr>
        <th>Name</th>
    </tr>
    % for page in pages:
        <tr>
            <td class="text-muted">
                <a href="${request.route_url('site_page', site_key=site.key, page_id=page.id)}">${page.name}</a>
            </td>
        </tr>
    % endfor
</table>

Display a 1-2-3 stage tutorial for creating the first page here.