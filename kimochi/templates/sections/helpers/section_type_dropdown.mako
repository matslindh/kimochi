<%page args="button_text='Add a new page section', hide_columns=False" />

<div class="btn-group dropup">
    <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
         ${button_text} <span class="caret"></span>
    </button>

    <ul class="dropdown-menu">
        <li>
            <button class="btn" style="background: none; width: 100%; text-align: left; " name="text">
                <span class="glyphicon glyphicon-align-justify" title="Text"></span> Text
            </button>
        </li>
        <li>
            <button class="btn" style="background: none; width: 100%; text-align: left; " name="gallery" title="Gallery">
                <span class="glyphicon glyphicon-picture"></span> Gallery
            </button>
        </li>
        % if not hide_columns:
            <li>
                <button class="btn" style="background: none; width: 100%; text-align: left; " name="two_columns" title="Column Layout">
                    <span class="glyphicon glyphicon-object-align-top"></span> Two Column Layout
                </button>
            </li>
        % endif
    </ul>
</div>
