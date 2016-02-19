<%page args="section" />

% if section.images:
    <div id="carousel-section-${section.id}" class="carousel slide" data-ride="carousel" data-interval="false">
        <div class="carousel-inner">
            % for i, psi in enumerate(section.images):
                <div class="item ${'active' if i == 0 else ''}">
                    <img src="${request.imbo.image_url(psi.image.imbo_id).max_size(1280, 1000)}" alt="" />
                </div>
            % endfor
        </div>

        <a class="left carousel-control" href="#carousel-section-${section.id}" role="button" data-slide="prev" ${'style="display: none;"' if len(section.images) < 2 else '' | n}>
            <span class="glyphicon glyphicon-chevron-left"></span>
        </a>
        <a class="right carousel-control" href="#carousel-section-${section.id}" role="button" data-slide="next" ${'style="display: none;"' if len(section.images) < 2 else '' | n}>
            <span class="glyphicon glyphicon-chevron-right"></span>
        </a>
    </div>

    <div style="margin-top: 1.0em; text-align: right;">
        <button class="image-action-button btn btn-default" role="button" data-show-id="image-file-uploader-${section.id}-add">Add image to carousel</button>

        <button class="image-action-button btn" role="button" data-show-id="image-file-uploader-${section.id}-replace">Replace ${'image' if len(section.images) < 2 else 'carousel'}</button>
    </div>

    <div class="dropzone drag-and-drop-upload-destination" id="image-file-uploader-${section.id}-add" style="display: none;">
        <div class="dz-message">
            <span class="glyphicon glyphicon-upload"></span> Drag and drop additional images here to ${'add them to the carousel' if len(section.images) > 1 else 'create an image carousel'}
        </div>
    </div>

    <div class="dropzone drag-and-drop-upload-destination" id="image-file-uploader-${section.id}-replace" style="display: none;">
        <div class="dz-message">
            <span class="glyphicon glyphicon-refresh"></span> Drag and drop images here to replace the current ${'carousel' if len(section.images) > 1 else 'image'}
        </div>
    </div>

    <script type="text/javascript">
        $("#image-file-uploader-${section.id}-add").dropzone({
            "url": "${request.current_route_url(_route_name='site_page')}?page_section_id=${section.id}&command=add_image",
            "headers": { "X-CSRF-Token": "${request.session.get_csrf_token()}" }
        });

        var first = true;

        $("#image-file-uploader-${section.id}-replace").dropzone({
            "url": "${request.current_route_url(_route_name='site_page')}?page_section_id=${section.id}&command=replace_images",
            "headers": { "X-CSRF-Token": "${request.session.get_csrf_token()}" },
            "sending": function(file, xhr, formData) {
                formData.append("is_first", first ? 1 : 0);
                first = false;
            }
        });
    </script>
% endif

% if not section.images:
    <div class="dropzone drag-and-drop-upload-destination" id="image-file-uploader-${section.id}">
        <div class="dz-message">
            Drag and drop an image here to add it to the layout!
        </div>
    </div>

    <script type="text/javascript">
        $("#image-file-uploader-${section.id}").dropzone({
            "url": "${request.current_route_url(_route_name='site_page')}?page_section_id=${section.id}",
            "headers": { "X-CSRF-Token": "${request.session.get_csrf_token()}" }
        });
    </script>
% endif