<%page args="section" />

<div class="section-type-container section-type-two-columns">
    <div class="rows">
        <div class="col-sm-6">
            % for _section in section.sections[0].sections:
                <%include file="${_section.type}.mako" args="section=_section" />
            % endfor
        </div>
        <div class="col-sm-6">
            % for _section in section.sections[1].sections:
                <%include file="${_section.type}.mako" args="section=_section" />
            % endfor
        </div>
    </div>
</div>