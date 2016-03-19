<%inherit file="site_base.mako" />

<h3>
    Site Settings
</h3>

% if request.session.peek_flash():
    % for message in request.session.pop_flash():
        <div class="alert alert-success" role="alert">${message}</div>
    % endfor
% endif

<h4 class="option-header">
    Details
</h4>

<p class="option-description">
    These settings are various metadata about your site, such as the site name, description, meta-information, etc.
</p>

<form method="post">
    <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

    <div class="form-group">
        <label for="site-name-field">Name of site</label>
        <input type="text" name="site_name" class="form-control" value="${site.name if site.name else 'Untitled'}" id="site-name-field" placeholder="Name of the site" />
    </div>

    <div class="form-group">
        <label for="site-tagline-field">Site Tagline</label>
        <p class="option-description">
            Optional. Used as an extension / together with the site title if provided.
        </p>
        <input type="text" name="site_tagline" class="form-control" value="${site.tagline if site.tagline else ''}" id="site-tagline-field" placeholder="Optional Site Tag Line" />
    </div>


    <div class="form-group">
        <label for="site-metadescription-field">Meta-description of the site</label>
        <p class="option-description">
            Used as the default description of the site for search engines etc. Should not exceed 160 characters.
        </p>
        <textarea name="site_meta_description" rows="2" class="form-control" value="" id="site-metadescription-field" placeholder="Optional Description of Site for Search Engines">${site.meta_description if site.meta_description else ''}</textarea>
    </div>

    <button class="btn">
        Save details
    </button>
</form>

<h4 class="option-header">
    Page to use as the site index
</h4>

<p class="option-description">
    Select which page should be used as the default landing page for the site.
</p>

% if site.pages:
    <form method="post">
        <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

        <select name="select_index_page" style="min-width: 14em;">
            % for page in site.pages_active():
                <option value="${page.id}" ${'selected="selected"' if index_page and page.id == index_page.id else '' | n}>${page.name}</option>
            % endfor
        </select>

        <button class="btn">Update</button>
    </form>
% else:
    <p class="option-placeholder">
        There are no pages added for this site yet.
    </p>
% endif

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

<h4 class="option-header">
    Additional Image Aspect Ratios
</h4>

<p class="option-description">
    Any additional ratios configured here will be made available for easy image cropping within the site and gallery properties.
</p>

% if site.aspect_ratios:
    <table class="table table-striped">
        % for aspect_ratio in site.aspect_ratios:
            <tr>
                <td>
                    ${aspect_ratio.width}:${aspect_ratio.height}
                </td>
            </tr>
        % endfor
    </table>
% else:
    No additional aspect ratios has been configured.
% endif

<h5>Add new aspect ratio</h5>

<form method="post">
    <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

    Width x Height:
    <input type="number" value="16" name="aspect_ratio_width" style="width: 40px;" /> :
    <input type="number" value="9" name="aspect_ratio_height" style="width: 40px;" />

    <button class="btn">
        Add new aspect ratio
    </button>
</form>


<h4 class="option-header">
    API Keys
</h4>

<p class="option-description">
    Use these keys to allow an external application (such as your portfolio site) to read your current site configuration and site pages.
</p>

% if site.api_keys:
    <table class="table table-striped">
        % for key in site.api_keys:
            <tr>
                <td>
                    ${key.key}
                </td>
            </tr>
        % endfor
    </table>
% endif

% if len(site.api_keys) < 20:
    <form method="post">
        <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />
        <input type="hidden" name="command" value="generate_api_key" />

        <button class="btn btn-primary">
            Generate a new API key <span class="glyphicon glyphicon-refresh" style="margin-left: 1.0em;"></span>
        </button>
    </form>
% endif