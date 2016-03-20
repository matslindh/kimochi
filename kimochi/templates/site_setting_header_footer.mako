<%inherit file="site_setting_base.mako" />

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

