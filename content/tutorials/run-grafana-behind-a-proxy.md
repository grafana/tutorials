---
title: Run Grafana behind a reverse proxy
summary: Learn how to run Grafana behind a reverse proxy
id: run-grafana-behind-a-proxy
categories: ["administration"]
tags: advanced
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/tutorials/issues/new
aliases: ["/docs/grafana/latest/installation/behind_proxy/"]
---

{{< tutorials/step title="Introduction" >}}

In this tutorial, you'll configure Grafana to run behind a reverse proxy.

When running Grafana behind a proxy, you need to configure the domain name to let Grafana know how to render links and redirects correctly.

- In the Grafana configuration file, change `server.domain` to the domain name you'll be using:

```bash
[server]
domain = example.com
```

- Restart Grafana for the new changes to take effect.

You can also serve Grafana behind a _sub path_, such as `http://example.com/grafana`.

To serve Grafana behind a sub path:

- Include the sub path at the end of the `root_url`.
- Set `serve_from_sub_path` to `true`.

```bash
[server]
domain = example.com
root_url = %(protocol)s://%(domain)s:%(http_port)s/grafana/
serve_from_sub_path = true
```

Next, you need to configure your reverse proxy.

{{< /tutorials/step >}}
{{< tutorials/step title="Configure NGINX" >}}

[NGINX](https://www.nginx.com) is a high performance load balancer, web server, and reverse proxy.

- In your NGINX configuration file, add a new `server` block:

```nginx
server {
  listen 80;
  root /usr/share/nginx/html;
  index index.html index.htm;

  location / {
   proxy_pass http://localhost:3000/;
  }
}
```

- Reload the NGINX configuration.
- Navigate to port 80 on the machine NGINX is running on. You're greeted by the Grafana login page.

To configure NGINX to serve Grafana under a _sub path_, update the `location` block, make sure this block is the first `location` block:

```nginx
server {
  listen 80;
  root /usr/share/nginx/www;
  index index.html index.htm;

  location ~/grafana/ {
   proxy_pass http://localhost:3000/;
  }
}
```

{{< /tutorials/step >}}
{{< tutorials/step title="Configure HAProxy" >}}

To configure HAProxy to serve Grafana under a _sub path_:

```bash
frontend http-in
  bind *:80
  use_backend grafana_backend if { path /grafana } or { path_beg /grafana/ }

backend grafana_backend
  # Requires haproxy >= 1.6
  http-request set-path %[path,regsub(^/grafana/?,/)]

  # Works for haproxy < 1.6
  # reqrep ^([^\ ]*\ /)grafana[/]?(.*) \1\2

  server grafana localhost:3000
```

{{< /tutorials/step >}}
{{< tutorials/step title="Configure IIS" >}}

> IIS requires that the URL Rewrite module is installed.

To configure IIS to serve Grafana under a _sub path_, create an Inbound Rule for the parent website in IIS Manager with the following settings:

- pattern: `grafana(/)?(.*)`
- check the `Ignore case` checkbox
- rewrite URL set to `http://localhost:3000/{R:2}`
- check the `Append query string` checkbox
- check the `Stop processing of subsequent rules` checkbox

This is the rewrite rule that is generated in the `web.config`:

```xml
  <rewrite>
      <rules>
          <rule name="Grafana" enabled="true" stopProcessing="true">
              <match url="grafana(/)?(.*)" />
              <action type="Rewrite" url="http://localhost:3000/{R:2}" logRewrittenUrl="false" />
          </rule>
      </rules>
  </rewrite>
```

See the [tutorial on IIS URL Rewrites](/tutorials/iis/) for more in-depth instructions.

{{< /tutorials/step >}}
