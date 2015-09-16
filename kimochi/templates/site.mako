<%inherit file="site_base.mako" />

<h3>
    Your site yes yes
</h3>

% if request.session.peek_flash():
    % for message in request.session.pop_flash():
        <div class="alert alert-success" role="alert">${message}</div>
    % endfor
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