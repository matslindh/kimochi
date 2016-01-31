<%page args="section" />

<div class="section-type-container section-type-text">
    <textarea id="text_${section.id}" style="clear: both; height: 300px; margin-top: 2.0em;" name="section_content">${section.content if section.content else ''}</textarea>
</div>

<script type="text/javascript">
    tinymce.init({
        selector: '#text_${section.id}',
        valid_styles : { '*' : 'color,font-weight,font-style,text-decoration' }
        // plugins: "autoresize"
    });
</script>