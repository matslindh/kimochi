<%inherit file="site_base.mako" />

<nav class="col-md-4">
    <ol class="nav nav-pills nav-stacked">
        % for page in site.pages:
            % if 'page_id' in request.matchdict and int(request.matchdict['page_id']) == page.id:
                <li class="active">
                    <a href="${request.route_url('site_page', site_key=site.key, page_id=page.id)}">${page.name}</a>

                    <ol>
                        % for section in page.get_sections_active():
                            <li style="margin-bottom: 4px;">
                                <a href="#page-section-${section.id}" id="menu-page-section-id-${section.id}" class="activate-section menu-section-link btn btn-default btn-block" data-section-id="${section.id}" style="text-align: left;">
                                    ${section.type}
                                </a>
                            </li>
                        % endfor
                    </ol>
                </li>

            % else:
                <li>
                    <a href="${request.route_url('site_page', site_key=site.key, page_id=page.id)}">${page.name}</a>
                </li>
            % endif
        % endfor
        <li style="padding-top: 1.4em;">
            <a href="#" id="add-new-page-link">+ Add new page</a>

            <form method="post" action="${request.route_url('site_pages', site_key=site.key)}">
                <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />

                <input type="text" name="page_name" placeholder="Page name" />
                <input type="submit" value="Add" />
            </form>
        </li>
    </ol>
</nav>

<div class="col-md-8">
    ${next.body()}
</div>