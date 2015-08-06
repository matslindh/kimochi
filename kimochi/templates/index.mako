<%inherit file="base.mako" />

<h2>
    My sites
</h2>

<p>
    % if user.sites:
        <div class="list-group">
            % for site in user.sites:
                <a href="${request.route_url('site', site_key=site.key)}" class="list-group-item">
                    <h4 class="list-group-item-heading">${site.name}</h4>
                    <p class="list-group-item-text">
                        Stats.
                    </p>
                </a>
            % endfor
        </div>
    % else:
        You have no sites configured.
    % endif

    % if len(user.sites) < user.site_limit:
        <a href="#">Add a new site</a>.

        <form method="post" action="${request.route_url('sites')}">
            <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

            <label for="field-site-name">Site name</label>
            <input type="text" id="field-site-name" name="site_name" placeholder="Brand New Site Name" />
            <input type="submit" value="Add" />
        </form>
    % endif
</p>