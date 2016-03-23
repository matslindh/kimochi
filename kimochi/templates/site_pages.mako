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
    <thead>
        <tr>
            <th style="width: 1.0em;"></th>
            <th>Name</th>
        </tr>
    </thead>
    <tbody id="table-page-list">
        % for page in pages:
            <tr data-page-id="${page.id}">
                <td>
                    <div class="sort-handle">☰</div>
                </td>
                <td class="text-muted">
                    <a href="${request.route_url('site_page', site_key=site.key, page_id=page.id)}">${page.name}</a>
                </td>
            </tr>
        % endfor
    </tbody>
</table>

<script type="text/javascript">
    var sortable = new Sortable(document.getElementById('table-page-list'), {
        handle: '.sort-handle',
        draggable: 'tr',
        ghostClass: 'sort-ghost',
        animation: 100,
        onEnd: function (evt) {
            var ids = []
            $("#table-page-list>tr").each(function (idx) {
                ids.push($(this).data('page-id'));
            });

            if (evt.oldIndex != evt.newIndex)
            {
                var el = $(evt.item);

                $.post('', {
                    's': ids,
                    'csrf_token': '${request.session.get_csrf_token()}'
                }, function (data) {
                    if (!data['result']) {
                        $(el).addClass('bg-danger');
                    }
                });
            };
        }
    });
</script>