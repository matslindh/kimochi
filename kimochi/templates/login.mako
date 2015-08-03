<%inherit file="base.mako" />

<form class="form-signin" method="post">
    <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />
    <h2 class="form-signin-heading">Please sign in</h2>

    % if request.session.peek_flash():
        <ul>
            % for message in request.session.pop_flash():
                <li class="alert alert-danger">${message}</li>
            % endfor
        </ul>
    % endif

    <label for="email-field" class="sr-only">Email address</label>
    <input name="email" type="email" id="email-field" class="form-control" placeholder="Email address" value="${email if email else '' }" required autofocus>
    <label for="password-field" class="sr-only">Password</label>
    <input name="password" type="password" id="password-field" class="form-control" placeholder="Password" required>
    <div class="checkbox">
        <label>
            <input type="checkbox" value="remember-me"> Remember me
        </label>
    </div>
    <button class="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>
</form>