<!DOCTYPE html>
<html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <script src="https://code.jquery.com/jquery-2.1.4.min.js"></script>
        <link href="http://fonts.googleapis.com/css?family=Shadows+Into+Light" rel="stylesheet" type="text/css">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
        <script src="//cdnjs.cloudflare.com/ajax/libs/Sortable/1.2.1/Sortable.min.js"></script>
        <script src="${request.static_url('kimochi:static/jquery.color-2.1.2.min.js')}"></script>
        <script type="text/javascript" src="${request.static_url('kimochi:static/dropzone.js')}"></script>
        <script type="text/javascript" src="${request.static_url('kimochi:static/utilities.js')}"></script>

        <link rel="stylesheet" href="${request.static_url('kimochi:static/kimochi.css')}">
        <title>Kimochi</title>
    </head>
    <body>
        <header>
            <div>
                <h1>
                    <a href="/">Kimochi</a>
                </h1>

                <div>
                    % if user:
                        <a href="${request.route_url('profile')}">
                            ${user.email}

                            % if False:
                                <span class="badge">13 messages</span>
                            % endif
                        </a>
                    % endif
                </div>
            </div>
        </header>

        <div id="container">
            ${next.body()}
        </div>

        <footer>
            Kimochi Portfolio Content Provider, Licensed under The MIT License.
        </footer>
    </body>
</html>