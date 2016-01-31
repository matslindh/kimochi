<%inherit file="site_page_base.mako" />

<script src="//tinymce.cachefly.net/4.2/tinymce.min.js"></script>

<form method="post">
    <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />
    <input type="hidden" name="command" value="toggle_published" />

    <h3 class="top" style="border-bottom: 1px solid #ccc; padding-bottom: 16px;">
        <input type="submit" value="Save" class="btn btn-default" style="margin-left: 2.0em; float: right;"/>
        <input type="submit" value="${'Published and live' if page.published else 'Not published'}" class="btn ${'btn-primary' if page.published else 'btn-default active'} btn-lg" style="float: right; margin-left: 2.0em;" />
        Editing Page: ${page.name}
    </h3>

    % for section in page.get_sections_active():
        <div style="overflow: hidden; margin-bottom: 1.0em;">
            <div class="btn-group btn-group-sm" data-toggle="buttons" role="group" style="float: left;">
                ${section.type}
            </div>
        </div>

        <%include file="sections/${section.type}.mako" args="section=section" />

        <hr />
    % endfor
</form>

<div style="text-align: center; color: #888; margin-top: 1.5em;">
    <form method="post">
        <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />
        <input type="hidden" name="command" value="page_section_create" />

            <p>
                Add a new page section
            </p>

            <button class="btn" style="background: none;" name="text">
                <span class="glyphicon glyphicon-align-justify" title="Text"></span>
            </button>
            <button class="btn" style="background: none;" name="gallery" title="Gallery">
                <span class="glyphicon glyphicon-picture"></span>
            </button>
            <button class="btn" style="background: none;" name="two_columns" title="Column Layout">
                <span class="glyphicon glyphicon-object-align-top"></span>
            </button>
        </button>
    </form>
</div>

<!--
    var activate_section = function (section_id) {
        // return early if the section already is the active section
        if ($("#page-section-" + section_id).is(':visible'))
        {
            return;
        }

        $(".page-section").slideUp(200);
        $(".activate-section, #page-section-" + section_id).show();
        update_section_type(section_id);
        $("#activate-section-" + section_id).hide();

        $(".menu-section-link").removeClass('active');
        $("#menu-page-section-id-" + section_id).addClass('active');

        history.replaceState(null, "", "#page-section-" + section_id);
    }

    var get_section_id_from_element = function (el) {
        return el.closest("form").data("section-id");
    }

    var update_section_type = function (section_id) {
        var root = $("#page-section-" + section_id);
        var type = root.find("input[name=section_type]:checked").val();

        root.find(".section-type-container").hide();
        root.find(".section-type-" + type).slideDown(200);
    }; -->

<script type="text/javascript">
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
</script>