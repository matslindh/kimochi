<%page args="section" />

<div class="section-type-container section-type-text">
    <textarea id="text_${section.id}" style="clear: both; height: 300px; margin-top: 2.0em;" class="section-form-element" data-section-id="${section.id}" data-section-type="text" name="content">${section.content if section.content else ''}</textarea>
</div>

<script type="text/javascript">
    tinymce.init({
        menubar: false,
        statusbar: false,
        selector: '#text_${section.id}',
        valid_styles: { '*' : 'color,background-color,font-weight,font-style,text-decoration,text-align,font-size' },
        content_css: "${request.static_url('kimochi:static/tinymce.css')}",
        toolbar: "undo redo | styleselect hr | bold italic fontsizeselect | forecolor backcolor removeformat | alignleft aligncenter alignright |  link unlink | ",
        plugins: "hr link textcolor"
    });
</script>