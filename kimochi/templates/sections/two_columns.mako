<%page args="section" />

<div class="section-type-container section-type-two-columns">
    <div class="rows">
        <div class="col-sm-6">
            <ol class="page-section-list" id="two-columns-left-${section.id}">
                % for _section in section.sections[0].sections:
                    <li>
                        <div style="overflow: hidden; margin-bottom: 1.0em;">
                            <div class="sort-handle">☰</div>
                        </div>

                        <%include file="${_section.type}.mako" args="section=_section" />
                    </li>
                % endfor
            </ol>
        </div>
        <div class="col-sm-6">
            <ol class="page-section-list" id="two-columns-right-${section.id}">
                % for _section in section.sections[1].sections:
                    <li>
                        <div style="overflow: hidden; margin-bottom: 1.0em;">
                            <div class="sort-handle">☰</div>
                        </div>

                        <%include file="${_section.type}.mako" args="section=_section" />
                    </li>
                % endfor
            </ol>
        </div>
    </div>
</div>

<script type="text/javascript">
    for (el of ['two-columns-left-${section.id}', 'two-columns-right-${section.id}']) {
        var sortable_two = new Sortable(document.getElementById(el), {
            handle: '.sort-handle',
            ghostClass: 'sort-ghost',
            group: {
                name: 'two-columns-${section.id}',
                put: true,
                pull: true
            },
            animation: 100,
            onEnd: function (evt) {
                if (evt.oldIndex != evt.newIndex)
                {
                    // $("#gallery-save-button").addClass("btn-primary");
                };

                $(".page-section-list").removeClass('page-section-list-empty');
                $(".page-section-list").not(":has(li)").addClass('page-section-list-empty');
            }
        });
    }
</script>