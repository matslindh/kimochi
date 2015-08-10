<%inherit file="site_base.mako" />

<script src="//tinymce.cachefly.net/4.2/tinymce.min.js"></script>

<h3 class="top" style="border-bottom: 1px solid #ccc; padding-bottom: 16px;">
    Editing Page: ${page.name}
</h3>

% for section in page.sections:
    <form method="post" id="page-section-${section.id}" class="page-section collapsed" data-section-id="${section.id}">
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
        <input type="submit" value="Save" class="btn btn-default" style="margin-top: 0.5em; margin-bottom: 3.0em; float: right;"/>
    </form>

    <a href="#" class="activate-section btn btn-default btn-lg btn-block" id="activate-section-${section.id}" role="button" style="margin-bottom: 1.0em; overflow: hidden; color: #aaa;" data-section-id="${section.id}">
        ${section.type}

        <span class="glyphicon glyphicon-chevron-down" style="float: right;"></span>
    </a>
% endfor

<div style="text-align: center; border-top: 1px solid #ccc; color: #888; margin-top: 1.5em;">
    <form method="post">
        <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />
        <input type="hidden" name="command" value="page_section_create" />

        <button class="btn" style="background: none;">
            <p>
                Add a new page section
            </p>

            <span class="glyphicon glyphicon-chevron-down"></span>
        </button>
    </form>
</div>

<script type="text/javascript">
    tinymce.init({
        selector: 'textarea'
        // plugins: "autoresize"
    });

    var activate_section = function (section_id) {
        $(".page-section").hide(200);
        $(".activate-section, #page-section-" + section_id).show();
        $("#activate-section-" + section_id).hide();

        $(".menu-section-link").removeClass('active');
        $("#menu-page-section-id-" + section_id).addClass('active');
    }

    $(document).ready(function () {
        if (window.location.hash && (window.location.hash.substring(0, 14) == '#page-section-'))
        {
            var section_id = window.location.hash.substring(14)
            console.log(section_id);
            activate_section(section_id);
        }
        else
        {
            var section_id = $(".page-section:eq(0)").data('section-id');

            if (section_id)
            {
                activate_section(section_id);
            }
        }
    });

    $(".activate-section").click(function () {
        activate_section($(this).data('section-id'));

        return false;
    });
</script>