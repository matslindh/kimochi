<%page args="section" />
<li data-section-id="${section.id}" data-parent-section-id="${section.parent_section_id if section.parent_section_id else ''}" data-section-type="${section.type}" class="page-section-element">
    <div style="overflow: hidden; margin-bottom: 1.0em;">
        <div class="sort-handle">☰</div>

        <div class="btn-group btn-group-sm" data-toggle="buttons" role="group" style="float: left;">
            ${section.type}
        </div>


        <div class="btn btn-group section-options-expander" style="float: right;">
            Options <span class="glyphicon glyphicon-triangle-bottom"></span>
        </div>
    </div>

    <div class="panel panel-default section-options">
        <div class="panel-heading">
            <h4 class="panel-title">Section Options</h4>
        </div>
        <div class="panel-body">

        </div>
    </div>

    <%include file="${section.type}.mako" args="section=section" />
</li>