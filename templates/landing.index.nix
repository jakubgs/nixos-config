{ lib, config, proxyServices }:

let
  sortedServices = lib.sort ((a: b: a.title < b.title)) proxyServices;
  hostname = config.networking.hostName;
  fqdn = config.networking.fqdn;
  grafanaUrl = "http://bardiel.magi.vpn/grafana/d-solo/YFtG6HViz/multiple-hosts";
  graphs = [
    "${grafanaUrl}?var-hostname=${fqdn}&amp;panelId=4"
    "${grafanaUrl}?var-hostname=${fqdn}&amp;panelId=2"
    "${grafanaUrl}?var-hostname=${fqdn}&amp;panelId=6"
    "${grafanaUrl}?var-hostname=${fqdn}&amp;panelId=26"
  ];
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
            --bg-color: #111217;
            --fg-color: #181b1f;
            --border-color: #35383e;
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
        .services {
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
        .graphs {
            display: grid;
            grid-template-columns: repeat(2, minmax(20em, 1fr));
        }
        .graph {
            padding: 0;
            border-radius: 0.3ex;
        }
    </style>
    <body>
        <header class="row center-text">
            <h1 class="hostname">⛁ ${hostname}</h1>
        </header>
        <div class="graphs">
${lib.concatStringsSep "\n" (builtins.map (graph: ''
          <div class="service graph">
            <iframe class="graph" src="${graph}" width="100%" height="100%" frameborder="0"></iframe>
          </div>
'') graphs)}
        </div>
        <div class="services">
${lib.concatStringsSep "\n" (builtins.map (service: ''
            <a class="service" href="${service.name}">${service.title}</a>
'') sortedServices)}
        </div>
    </body>
</html>
''
