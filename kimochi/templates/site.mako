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