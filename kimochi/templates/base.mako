<!DOCTYPE html>
<html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href='http://fonts.googleapis.com/css?family=Shadows+Into+Light' rel='stylesheet' type='text/css'>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
        <style type="text/css">
            body {
                background: #E9F1DF;
            }

            h1 {
                color: #4AD9D9;
                text-shadow: 1px 1px 3px #888;
                font-family: 'Shadows Into Light', cursive;
                font-size: 3.0em;
            }


            #container {
                width: 1000px;
                margin: auto;
                font-size:  14pt;
            }

            header {
                padding: 2.0em 4.0em;
                text-align: center;
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
        </style>
        <title>Kimochi</title>
    </head>
    <body>
        <div id="container">
            <header>
                <h1>Kimochi</h1>
            </header>

            <div id="content">
                ${self.body()}
            </div>

            <footer>
                Kimochi Portfolio Content Provider, Licensed under The MIT License.
            </footer>
        </div>
    </body>
</html>