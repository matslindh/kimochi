<%inherit file="site_base.mako" />

<script src="//tinymce.cachefly.net/4.2/tinymce.min.js"></script>

<form method="post">
    <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />
    <h3 class="top" style="border-bottom: 1px solid #ccc; padding-bottom: 16px;">
        Editing Page: ${page.name}

        <input type="submit" value="Save" class="btn btn-default" style="float: right;" />
    </h3>

    <div style="overflow: hidden; margin-bottom: 1.0em;">
        <div class="btn-group btn-group-sm" data-toggle="buttons" role="group" style="float: right;">
            <label class="btn btn-default active"><input type="radio" name="page_type" checked="checked" value="text">Text</label>
            <label class="btn btn-default"><input type="radio" name="page_type" value="gallery">Gallery</label>
        </div>
    </div>

    <textarea style="clear: both; height: 300px; margin-top: 2.0em;"></textarea>
    <input type="text" name="page_name" placeholder="Page name" />
    <input type="submit" value="Save" class="btn btn-default" />

    <script type="text/javascript">
        tinymce.init({
            selector: 'textarea',
            plugins: "autoresize"
        });
    </script>
</form>