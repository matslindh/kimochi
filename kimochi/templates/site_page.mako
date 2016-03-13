<%inherit file="site_page_base.mako" />
<script src="//cdn.tinymce.com/4/tinymce.min.js"></script>

<form method="post" id="save-layout-form">
    <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

    <h3 class="top">
        <input type="text" name="page_name" value="${page.name}" placeholder="Name of the page" size="35" class="form-control input-lg" />
    </h3>

    <ol class="page-section-list" id="page-section-list">
        % for section in page.get_sections_active():
            <%include file="sections/wrapper.mako" args="section=section" />
        % endfor
    </ol>
</form>

<div class="page-section-footer" data-page-section-list-id="page-section-list">
    <%include file="sections/helpers/section_type_dropdown.mako" />
</div>

<script type="text/javascript">
    var serialize_section_list = function (sections_in) {
        var sections = []

        sections_in.each(function (idx) {
            var section = {
                'section_id': $(this).data('section-id'),
                'type': $(this).data('section-type'),
                'sections': []
            }

            var parent_section_element = $(this).closest('[data-parent-section-id]');

            if (parent_section_element.data('parent-section-id')) {
                section['parent_section_id'] = parent_section_element.data('parent-section-id');
            }

            $(this).children(".section-type-container").children(".section-form-element").each(function (idx) {
                var el = $(this);
                var name = el.attr('name');
                section[name] = el.val();
            });

            // this will match any selectors further down the tree as well, but we're currently only doing two
            // levels of layouts, so we should be good. for now.
            var subsections = $(this).find("ol.page-section-list>li");

            if (subsections.size() > 0) {
                section['sections'] = serialize_section_list(subsections);
            }

            sections.push(section);
        });

        return sections;
    }

    var serialize_section_contents = function () {
        var sections = serialize_section_list($("#page-section-list>li.page-section-element"));
        return JSON.stringify({
            page_name: $("input[name=page_name]").val(),
            sections: sections
        });
    };

    $("#save-layout-form").submit(function () {
        tinymce.triggerSave();
        var json = serialize_section_contents();

        $.ajax({
            type: 'post',
            url: $(this).attr('action'),
            data: json,
            contentType: "application/json; charset=utf-8",
            headers: { "X-CSRF-Token": "${request.session.get_csrf_token()}" },
            dataType: "json"
        })
        .done(function (data) {
            if (data['success']) {
                location.href = location.href;
            } else {
                alert("success returned false from server. See console log.");
                console.log(data)
            }
        })
        .fail(function (data) {
            alert("failed serializing section data to server");
            console.log(data);
        });

        return false;
    });

    var get_section_id_from_element = function (el) {
        return el.closest("li[data-section-id]").data("section-id");
    };

    $(document).on("click", "button.btn-section-create", function () {
        // collapse the dropup
        $(this).closest(".btn-group-new-section").find(".dropdown-toggle").dropdown('toggle');

        var parent_section_id = get_section_id_from_element($(this));
        var parent_sub_section_idx = $(this).closest("[data-add-sub-section-index]").data("add-sub-section-index");

        if (!parent_section_id) {
            parent_section_id = null;
        }

        // we need === to avoid 0 evaluating as undefined
        if (parent_sub_section_idx === undefined) {
            parent_sub_section_idx = null;
        }

        // create the new section and insert the new content
        $.post("", {
                "csrf_token": "${request.session.get_csrf_token()}",
                "add_section_type": $(this).attr("name"),
                "parent_section_id": parent_section_id,
                "parent_sub_section_idx": parent_sub_section_idx
            }, function (element) {
                return function (data) {
                    var section_list_id = element.closest("[data-page-section-list-id]").data("page-section-list-id");
                    $("#" + section_list_id).append($(data['content']))
                };
            }($(this))
        );

        return false;
    });

    var sortable = new Sortable(document.getElementById('page-section-list'), {
        handle: '.sort-handle',
        ghostClass: 'sort-ghost',
        animation: 100,
        onEnd: function (evt) {
            if (evt.oldIndex != evt.newIndex)
            {
                // $("#gallery-save-button").addClass("btn-primary");
            };

            $(evt.item).find('textarea').each(function () {
                tinymce.execCommand('mceRemoveEditor', false, $(this).attr('id'));
            });

            $(evt.item).find('textarea').each(function () {
                tinymce.execCommand('mceAddEditor', true, $(this).attr('id'));
            });
        },
        onStart: function (evt) {
            console.log($(evt.dragged).find('textarea'));
        },
    });

    $(document).on("click", ".section-options-expander", function () {
        var options_pane = $(this).closest(".page-section-element").find(".section-options");

        options_pane.toggle();

        if (options_pane.is(":visible")) {
            $(this).find("span").removeClass("glyphicon-triangle-bottom").addClass("glyphicon-triangle-top");
        } else {
            $(this).find("span").removeClass("glyphicon-triangle-top").addClass("glyphicon-triangle-bottom");
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

    // image handling
    $(".image-action-button").click(function () {
        var id_to_show = $(this).data('show-id');
        $("#" + id_to_show).toggle();
    });
</script>