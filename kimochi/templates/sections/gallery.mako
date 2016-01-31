<%page args="section" />

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

        % if site.galleries:
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
        % else:
            <div class="placeholder lg">
                You haven't added any galleries for this site yet. <a href="${request.route_url('site_galleries', site_key=site.key)}">Add galleries</a>
            </div>
        % endif
    % endif
</div>

<script type="text/javascript">
    $(".gallery-picker").click(function () {
        $.post("${request.current_route_url()}", {
                "section_gallery_id": $(this).data('gallery-id'),
                "page_section_id": get_section_id_from_element($(this)),
                "csrf_token": "${request.session.get_csrf_token()}",
            }, function (el) {
                return function (data) {
                    $(el).addClass("selected");
                };
            }(this)
        );

        return false;
    });
</script>