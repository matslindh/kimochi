<%page args="section" />
<li data-section-id="${section.id}">
    <div style="overflow: hidden; margin-bottom: 1.0em;">
        <div class="sort-handle">☰</div>

        <div class="btn-group btn-group-sm" data-toggle="buttons" role="group" style="float: left;">
            ${section.type}
        </div>
    </div>

    <%include file="${section.type}.mako" args="section=section" />
</li>