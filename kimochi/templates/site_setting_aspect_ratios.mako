<%inherit file="site_setting_base.mako" />

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
