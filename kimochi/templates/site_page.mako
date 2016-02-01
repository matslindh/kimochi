<%inherit file="site_page_base.mako" />

<script src="//tinymce.cachefly.net/4.2/tinymce.min.js"></script>

<form method="post">
    <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />
    <input type="hidden" name="command" value="toggle_published" />

    <h3 class="top">
        <input type="submit" value="Save" class="btn btn-default" style="margin-left: 2.0em; float: right;"/>
        <input type="submit" value="${'Published and live' if page.published else 'Not published'}" class="btn ${'btn-primary' if page.published else 'btn-default active'} btn-lg" style="float: right; margin-left: 2.0em;" />
        Editing Page: ${page.name}
    </h3>

    <ol class="page-section-list" id="page-section-list">
        % for section in page.get_sections_active():
            <li>
                <div style="overflow: hidden; margin-bottom: 1.0em;">
                    <div class="sort-handle">☰</div>

                    <div class="btn-group btn-group-sm" data-toggle="buttons" role="group" style="float: left;">
                        ${section.type}
                    </div>
                </div>

                <%include file="sections/${section.type}.mako" args="section=section" />
            </li>
        % endfor
    </ol>
</form>

<div class="page-section-footer">
    <%include file="sections/helpers/section_type_dropdown.mako" />

    <form method="post">
        <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />
        <input type="hidden" name="command" value="page_section_create" />

    </form>
</div>

<script type="text/javascript">
    var sortable = new Sortable(document.getElementById('page-section-list'), {
        handle: '.sort-handle',
        ghostClass: 'sort-ghost',
        animation: 100,
        onEnd: function (evt) {
            if (evt.oldIndex != evt.newIndex)
            {
                // $("#gallery-save-button").addClass("btn-primary");
            };
        }
    });

    $(document).ready(function () {
        if (window.location.hash && (window.location.hash.substring(0, 14) == '#page-section-'))
        {
            var section_id = window.location.hash.substring(14)
            //activate_section(section_id);
        }
        else
        {
            var section_id = $(".page-section:eq(0)").data('section-id');

            if (section_id)
            {
                //activate_section(section_id);
            }
        }
    });

    $(".page-section-list").not(":has(li)").addClass('page-section-list-empty');
</script>