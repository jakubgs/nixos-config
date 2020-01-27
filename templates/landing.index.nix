{ proxiedServices, lib, config }:

''
<!doctype html>
<html>
    <head>
        <meta name="viewport" content="width=device-width" />
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>Server Landing Page</title>
        <!-- <script type="text/javascript" src="http://livejs.com/live.js"></script>--!>
    </head>
    <style>
        body {
            font-family: Arial, Helvetica, sans-serif;
            background-color: silver;
            margin-left: 10%;
            margin-right: 10%;
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
            grid-template-columns: repeat(auto-fit, minmax(20em, 1fr));
        }
        .service {
            font-size: 3em;
            line-height: 160px;
            display: block;
            border-radius: 0.3ex;
            margin: 0.1em;
            padding: 0.5em;
            border: 1px solid #404040;
            background-color: #393939;
        }
        .service:hover {
            border: 1px solid #393939;
            background-color: #404040;
        }
    </style>
    <body>
        <header class="row center-text">
            <h1 class="hostname">⛁ ${config.networking.hostName}</h1>
        </header>
        <div class="main">
${lib.concatStringsSep "\n" (builtins.map (service: ''
<a class="service" href="${service.name}">${service.title}</a>
'') proxiedServices)}
        </div>
    </body>
</html>
''
