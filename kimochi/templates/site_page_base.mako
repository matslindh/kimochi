<%inherit file="site_base.mako" />

<div class="col-md-9 site-page-editor">
    ${next.body()}
</div>

<div class="col-md-3 site-page-tools">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h3 class="panel-title">Publish</h3>
        </div>
        <div class="panel-body">
            <form method="post">
                Status:
                <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />
                <input type="submit" value="${'Published' if page.published else 'Not published'}" class="btn btn-link" name="toggle_published" />
            </form>
        </div>
        <div class="panel-body">
            <form method="post">
                <input type="submit" value="Update layout and text" class="btn btn-default save-layout-button" name="save" style="float: right;"/>
            </form>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h3 class="panel-title">Operations</h3>
        </div>
        <div class="panel-body">
            <form method="post">
                <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />
                <button class="btn btn-sm"><span class="glyphicon glyphicon-trash"></span> Archive this page</button>
            </form>
        </div>
    </div>
</div>

<script type="text/javascript">
    $(".save-layout-button").click(function () {
        $("#save-layout-form").submit();
        return false;
    });
</script>