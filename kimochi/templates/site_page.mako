<%inherit file="site_base.mako" />

<script src="//tinymce.cachefly.net/4.2/tinymce.min.js"></script>

<h3 class="top" style="border-bottom: 1px solid #ccc; padding-bottom: 16px;">
    Editing Page: ${page.name}
</h3>

% for section in page.sections:
    <form method="post">
        <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />
        <input type="hidden" name="page_section_id" value="${section.id}" />
        <div style="overflow: hidden; margin-bottom: 1.0em;">
            <input type="submit" value="Save" class="btn btn-default" style="float: right; margin-left: 2.0em;" />

            <div class="btn-group btn-group-sm" data-toggle="buttons" role="group" style="float: left;">
                <label class="btn btn-default ${'active' if section.type == 'text' else '' | n}"><input type="radio" name="section_type" ${'checked="checked"' if section.type == 'text' else '' | n} value="text">Text</label>
                <label class="btn btn-default ${'active' if section.type == 'gallery' else '' | n}"><input type="radio" name="section_type" ${'checked="checked"' if section.type == 'gallery' else '' | n} value="gallery">Gallery</label>
            </div>
        </div>

        <textarea style="clear: both; height: 300px; margin-top: 2.0em;" name="section_content">${section.content}</textarea>
        <input type="submit" value="Save" class="btn btn-default" />
    </form>
% endfor

<script type="text/javascript">
    tinymce.init({
        selector: 'textarea',
        plugins: "autoresize"
    });
</script>