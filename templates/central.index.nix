{ lib, machines, subpath ? "/" }:

''
<!doctype html>
<html>
    <head>
        <meta name="viewport" content="width=device-width" />
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>Server Landing Page</title>
        <!-- <script type="text/javascript" src="http://livejs.com/live.js"></script>--!>
        <style>
            body {
                font-family: Arial, Helvetica, sans-serif;
                background-color: silver;
                color: #eaeaea;
                background-color: #222222;
                /* Text alignment */
                text-align: center;
                vertical-align: middle;
            }
            a {
                text-size: 3em;
                color: #eaeaea;
                text-decoration: none;
            }
            .hostname {
                font-family: monospace;
            }
            .main {
                display: grid;
                grid-template-columns: 100%;
                grid-template-rows: repeat(6, 1fr);
                grid-auto-flow: column;
                height: 100%;
                width: 100%;
            }
            iframe.machine {
                display: block;
                margin: 0px;
                padding: 0px;
                width: 100%;
                height: 600px;
                border: none;
                overflow: scroll;
            }
        </style>
    </head>
    <body>
        <div class="main">
${lib.concatStringsSep "\n" (builtins.map (machine: ''
            <iframe class="machine" src="http://${toString machine}${subpath}" scrolling="no" onload="resizeIframe(this)"></iframe>
'') machines)}
        </div>
    </body>
</html>
''
