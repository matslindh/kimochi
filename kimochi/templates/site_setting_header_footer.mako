<%inherit file="site_setting_base.mako" />

<h4 class="option-header">
    Header Image
</h4>

<p class="option-description">
    Image used as the header for the page.
</p>

% if site.header_imbo_id:
    <p>
        <img src="${request.imbo.image_url(site.header_imbo_id).max_size(1000,1000)}" alt="Current header image" />
    </p>
% endif

<form action="${request.current_route_url(_route_name='site_setting_header_footer')}" class="dropzone" id="gallery-file-uploader">
    <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

    <div class="dz-message">
        Drop an image here to set it as the page header.
    </div>
</form>

<h4 class="option-header">
    Footer Text
</h4>

<p class="option-description">
    Text made available to a template as a footer, if needed.
</p>

<form method="post">
    <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

    <div>
        <textarea name="footer" rows="5" style="width: 75%;">${site.footer if site.footer else ''}</textarea>
    </div>

    <button class="btn">
        Save footer text
    </button>
</form>

<script type="text/javascript">
    var error_occured = false;

    var dz = $(".dropzone").dropzone({
        "url": "${request.current_route_url()}",
        "headers": { "X-CSRF-Token": "${request.session.get_csrf_token()}" },
        "queuecomplete": function () {
            if (!error_occured) {
                location.href = location.href;
            }
        },
        "error": function (file, message, xhr) {
            error_occured = true;
            var el = $(file.previewElement);
            el.addClass('dz-error');
            el.html(message);
        }
    });
</script>