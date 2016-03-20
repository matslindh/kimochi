<%inherit file="site_setting_base.mako" />

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
