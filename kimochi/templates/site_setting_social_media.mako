<%inherit file="site_setting_base.mako" />

<h4 class="option-header">
    Social Media
</h4>

<p class="option-description">
    Configure social media settings for your site - these will be used to provide links to your social media presence.
</p>

<form method="post" class="form-horizontal">
    <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

    <div class="form-group">
        <label for="social-media-facebook" class="col-sm-2 control-label">Facebook</label>
        <div class="col-sm-10">
            <input type="url" name="social_media_facebook" class="form-control" id="social-media-facebook" placeholder="Address to your Facebook page / profile / group" value="${site.setting('social_media_facebook') if site.has_setting('social_media_facebook') else ''}">
        </div>
    </div>

    <div class="form-group">
        <label for="social-media-instagram" class="col-sm-2 control-label">Instagram</label>
        <div class="col-sm-10">
            <input type="url" name="social_media_instagram" class="form-control" id="social-media-instagram" placeholder="Address to your Instagram profile" value="${site.setting('social_media_instagram') if site.has_setting('social_media_instagram') else ''}">
        </div>
    </div>

    <button class="btn">
        Save Social Media Settings
    </button>
</form>