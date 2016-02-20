<%page args="section" />
<li data-section-id="${section.id}" data-parent-section-id="${section.parent_section_id if section.parent_section_id else ''}" data-section-type="${section.type}" class="page-section-element">
    <div style="overflow: hidden; margin-bottom: 1.0em;">
        <div class="sort-handle">☰</div>

        <div class="btn-group btn-group-sm" data-toggle="buttons" role="group" style="float: left;">
            ${section.type}
        </div>
    </div>

    <%include file="${section.type}.mako" args="section=section" />
</li>