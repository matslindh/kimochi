<!DOCTYPE html>
<html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <script src="https://code.jquery.com/jquery-2.1.4.min.js"></script>
        <link href='http://fonts.googleapis.com/css?family=Shadows+Into+Light' rel='stylesheet' type='text/css'>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
        <style type="text/css">
            body {
                background: white;
                margin: 0;
                padding: 0;
            }

            header div h1 {
                color: #4AD9D9;
                text-shadow: 1px 1px 3px #888;
                font-family: 'Shadows Into Light', cursive;
                font-size: 3.0em;
                margin: 0;
                display: inline-block;
            }

            header div h1>a {
                text-decoration: none;
                color: inherit;
            }

            header div h1>a:hover {
                text-decoration: none;
                color: inherit;
            }

            header>div>div
            {
                position: absolute;
                right: 0;
                bottom: 6px;
                display: inline-block;
            }

            header>div {
                width: 1000px;
                margin: auto;
                overflow: hidden;
                position: relative;
            }



            #container {
                width: 1000px;
                margin: auto;
                font-size:  14pt;
            }

            header {
                background: #E9F1DF;
            }

            footer {
                margin-top: 2.0em;
                text-align: center;
                font-family: arial;
                font-size: 0.8em;
            }

            form.form-signin {
                width: 400px;
                margin: auto;
            }

            form li {
                list-style-type: none;
            }

            form ul {
                padding-left: 0;
            }

            h3.top
            {
                margin-top: 0;
            }

            nav ol
            {
                list-style-type: none;
                margin: 0;
                padding: 0;
            }

            nav li>ol
            {
                margin-top: 0.4em;
                margin-left: 3.0em;
            }

            nav>ol
            {
                margin-top: 2.0em;
                font-size: 0.8em;
            }

            nav>ol>li
            {
                line-height: 1.6em;
            }

            .collapsed, .hidden
            {
                display: none;
            }

            .section-type-container
            {
                display: none;
            }

        </style>
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