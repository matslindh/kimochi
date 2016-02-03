<%page args="section" />

<div class="section-type-container section-type-text">
    <textarea id="text_${section.id}" style="clear: both; height: 300px; margin-top: 2.0em;" class="section-form-element" data-section-id="${section.id}" data-section-type="text" name="content">${section.content if section.content else ''}</textarea>
</div>

<script type="text/javascript">
    tinymce.init({
        menubar: false,
        statusbar: false,
        selector: '#text_${section.id}',
        valid_styles : { '*' : 'color,font-weight,font-style,text-decoration' }
        // plugins: "autoresize"
    });
</script>