<%inherit file="site_page_base.mako" />

<script src="//tinymce.cachefly.net/4.2/tinymce.min.js"></script>

<h3 class="top" style="border-bottom: 1px solid #ccc; padding-bottom: 16px;">
    Editing Page: ${page.name}
</h3>

% for section in page.sections:
    <form method="post" id="page-section-${section.id}" class="page-section collapsed" data-section-id="${section.id}" style="overflow: hidden;">
        <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />
        <input type="hidden" name="page_section_id" value="${section.id}" />
        <div style="overflow: hidden; margin-bottom: 1.0em;">
            <input type="submit" value="Save" class="btn btn-default" style="float: right; margin-left: 2.0em;" />

            <div class="btn-group btn-group-sm" data-toggle="buttons" role="group" style="float: left;">
                <label class="btn btn-default ${'active' if section.type == 'text' else '' | n}"><input type="radio" name="section_type" ${'checked="checked"' if section.type == 'text' else '' | n} value="text">Text</label>
                <label class="btn btn-default ${'active' if section.type == 'gallery' else '' | n}"><input type="radio" name="section_type" ${'checked="checked"' if section.type == 'gallery' else '' | n} value="gallery">Gallery</label>
            </div>
        </div>

        <div class="section-type-container section-type-text">
            <textarea style="clear: both; height: 300px; margin-top: 2.0em;" name="section_content">${section.content if section.content else ''}</textarea>
        </div>

        <div class="section-type-container section-type-gallery container-fluid">
            % if section.gallery:
                <h4>${section.gallery.name}</h4>

                % if section.gallery.images:
                    % for image in section.gallery.images:
                        <div class="col-md-4" style="margin-top: 1.0em;">
                            <a href="${request.route_url('site_gallery_image', site_key=site.key, gallery_id=section.gallery.id, image_id=image.id)}?return_page_section_id=${section.id}">
                                <h5>${image.title if image.title else 'No title'}</h5>

                                <div>
                                    <img src="${request.imbo.image_url(image.imbo_id).max_size(150, 150)}" alt="${image.title}" />
                                </div>
                            </a>
                        </div>
                    % endfor
                % else:
                    <div class="placeholder">
                        Empty gallery
                    </div>
                % endif
            % else:
                <h4>Select a gallery</h4>

                % for gallery in site.galleries:
                    <div class="col-md-4">
                        <a href="#" class="gallery-picker" data-gallery-id="${gallery.id}">
                            <h5>${gallery.name}</h5>

                            % if gallery.images:
                                <div>
                                    <img src="${request.imbo.image_url(gallery.images[0].imbo_id).max_size(150, 150)}" alt="${gallery.images[0].title if gallery.images[0].title else ''}" />
                                </div>
                            % else:
                                <div class="placeholder">
                                    Empty gallery
                                </div>
                            % endif
                        </a>
                    </div>
                % endfor
            % endif
        </div>

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
    };

    $(document).ready(function () {
        if (window.location.hash && (window.location.hash.substring(0, 14) == '#page-section-'))
        {
            var section_id = window.location.hash.substring(14)
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

    $("input[name=section_type]").change(function () {
        update_section_type(get_section_id_from_element($(this)));
    });

    $(".gallery-picker").click(function () {
        $.post("${request.current_route_url()}", {"section_gallery_id": $(this).data('gallery-id'), "page_section_id": get_section_id_from_element($(this))}, function (data) {
            console.log(data);
        });
    });
</script>