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
      ${lib.fileContents ./landing.css}
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
