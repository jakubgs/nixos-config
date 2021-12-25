{ pkgs, lib, config, proxyServices }:

let
  sortedServices = lib.sort ((a: b: a.title < b.title)) proxyServices;
  hostname = config.networking.hostName;
  grafanaUrl = "http://bardiel.magi.vpn/grafana/d-solo/YFtG6HViz/multiple-hosts";
in ''
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
        :root {
            --font-color: #eaeaea;
            --bg-color: #222222;
            --fg-color: #393939;
            --border-color: #404040;
        }
        body {
            font-family: Arial, Helvetica, sans-serif;
            background-color: silver;
            margin-left: 10%;
            margin-right: 10%;
            color: var(--font-color);
            background-color: var(--bg-color);
            /* Text alignment */
            text-align: center;
            vertical-align: middle;
        }
        a {
            text-size: 3em;
            color: var(--font-color);
            text-decoration: none;
        }
        .hostname {
            font-family: monospace;
        }
        .main {
            display: grid;
            grid-template-columns: repeat(4, minmax(20em, 1fr));
        }
        .service {
            font-size: 3em;
            line-height: 160px;
            display: block;
            border-radius: 0.3ex;
            margin: 0.1em;
            padding: 0.5em;
            border: 1px solid var(--border-color);
            background-color: var(--fg-color);
        }
        .service:hover {
            border: 1px solid var(--fg-color);
            background-color: var(--border-color);
        }
        .graph {
            padding: 0;
        }
    </style>
    <body>
        <header class="row center-text">
            <h1 class="hostname">⛁ ${hostname}</h1>
        </header>
        <iframe class="service graph" src="${grafanaUrl}?var-hostname=${pkgs.lib.fqdn}&amp;panelId=4" width="100%" height="200" frameborder="0"></iframe>
        <iframe class="service graph" src="${grafanaUrl}?var-hostname=${pkgs.lib.fqdn}&amp;panelId=2" width="100%" height="200" frameborder="0"></iframe>
        <div class="main">
${lib.concatStringsSep "\n" (builtins.map (service: ''
            <a class="service" href="${service.name}">${service.title}</a>
'') sortedServices)}
        </div>
    </body>
</html>
''
