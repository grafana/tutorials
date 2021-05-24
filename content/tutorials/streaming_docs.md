# Grafana Live docs

Grafana Live is a real-time messaging engine introduced in Grafana v8.

With Grafana Live it's possible to push event data to a frontend as soon as some event happened. This could be notifications about dashboard changes, new frames for rendered data etc. This can help eliminating page reloads and polling in many places.  

Grafana Live is a PUB/SUB server - clients subscribe to channels to receive real-time updates published to those channels.

## Channel

Channel – is just a string identifier. In Grafana channel consists of 3 parts delimited by `/`:

* Scope
* Namespace
* Path

For example, the channel `grafana/dashboard/xyz` has the scope `grafana`, namespace `dashboard`, and path `xyz`.

Scope, namespace and path can only have ASCII alphanumeric symbols (A-Z, a-z, 0-9), `_` (underscore) and `-` (dash) at the moment. The path part can additionally have `/`, `.` and `=` symbols. The meaning of scope, namespace and path is context-specific.

The maximum length of a channel is **160** symbols.

Scope determines the purpose of a channel in Grafana. For example, for datasource plugin channels Grafana uses `ds` scope. For built-in features like dashboard edit notifications Grafana uses `grafana` scope.

Namespace has a different meaning depending on scope. For example, for `grafana` scope this could be a name of built-in real-time feature like `dashboard` (i.e. dashboards events).

The path is a final part of channel which is usually has an identifier of some concrete resource. For example ID of a dashboard user currently looking at. But path can be anything actually.

Channels are lightweight and ephemeral - they are created automatically on user subscription and removed as soon as last user left a channel.

## Data format

All data travelling over Live channels should be JSON-encoded.

## Built-in real-time features

Grafana v8 will update dashboad as soon as someone changed it.

## Data streaming from plugins

With Grafana Live datasource plugins can stream data updates if form of Grafana dataframes to a frontend.

For datasource plugin channels Grafana uses `ds` scope. Namespace in the case of datasource channels is a datasource unique ID (UID) which is issued by Grafana at the moment of datasource creation. The path is a custom string that plugin authors free to choose themselves (just make sure it consists of allowed symbols).

I.e. datasource channel looks like `ds/<DATASOURCE_UID>/<CUSTOM_PATH>`.

See a tutorial about building a streaming datasource backend plugin for more details.

## Data streaming from Telegraf

A new API endpoint `/api/live/push/:streamId` allows accepting metrics data in Influx format from Telegraf. These metrics will be transformed into Grafana dataframes and published to channels.

See a tutorial about streaming data from Telegraf for more details.

## WebSocket connection

Grafana Live uses WebSocket protocol to deliver real-time updates to a frontend application. WebSocket is a persistent connection which starts with HTTP Upgrade request and then switches to a TCP mode where WebSocket frames can travel in both directions between a client and a server.

Each logged-in user opens a WebSocket connection – one per browser tab.

Introducing a persistent connection leads to some things Grafana users should be aware of.

### Resource usage

Each persistent connection will cost some memory on a server. Typically this should be about 50KB per connection at this moment. Thus a server with 1GB RAM is expected to handle about 20k connections max. Each active connection will consume additional CPU resources since client and server send PING/PONG frames to each other to maintain a connection.

And of course it will cost additional CPU as soon as you are using streaming functionality. The exact resource usage is hard to estimate since it heavily depends on Grafana usage pattern.

### Open file limit

Each WebSocket connection will cost a file descriptor on a server machine where Grafana runs. Most operating systems has a quite low default limit for the maximum number of descriptors that process can open.

To look current limit on Unix:

```
ulimit -n
```

The result shows approximately how many user connections your server can currently handle.

This limit can be increased – see for example [these instructions](https://docs.riak.com/riak/kv/2.2.3/using/performance/open-files-limit.1.html).

### Ephemeral port exhaustion

Ephemeral ports exhaustion problem can happen between your load balancer and your Grafana server. I.e. only if you load balance connections between different Grafana instances. If users connect directly to a single Grafana server instance you likely come across this issue.

The problem arises due to the fact that each TCP connection uniquely identified in the OS by the 4-part-tuple:

```
source ip | source port | destination ip | destination port
```

On load balancer/server boundary you are limited in 65536 possible variants by default. But actually due to some OS limits and sockets in TIME_WAIT state the number is even less.

In order to eliminate a problem you can:

* Increase the ephemeral port range by tuning `ip_local_port_range` kernel option
* Deploy more Grafana server instances to load balance across
* Deploy more load balancer instances
* Use virtual network interfaces

### WebSocket and proxies

Not all proxies can transparently proxy WebSocket connections by default. For example, if you are using Nginx before Grafana you need to configure WebSocket proxy like this:

```
http {
    map $http_upgrade $connection_upgrade {
        default upgrade;
        '' close;
    }
 
    upstream grafana {
        server 127.0.0.1:3000;
    }
 
    server {
        listen 8000;

        location / {
            proxy_pass http://grafana;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
            proxy_set_header Host $host;
        }
    }
}
```

See [more information on Nginx web site](https://www.nginx.com/blog/websocket-nginx/). Refer to your load balancer/reverse proxy documentation to find out more information on dealing with WebSocket connections.

Some corporative proxies can remove headers required to properly establish WebSocket connection. In this case you should tune intermediate proxies to not remove required headers. But the better way may me using Grafana with TLS. In this case WebSocket connection will also inherit TLS and thus must fully resolve proxy problem.

Proxies like Nginx and Envoy have default limits on maximum number of connections which can be established. Make sure you have a reasonable limit for max number of incoming and outgoing connections in your proxy configuration.

## Grafana Live in HA setup

Live features in Grafana v8 designed to work with a single Grafana server instance. We aim to introduce an option for HA setup in future Grafana releases to eliminate current limitations described below.

For Grafana v8, if you have several Grafana server instances behind a load balancer, you may come across the following limitations:

* Built-in features like dashboard change notifications will only be broadcasted to users connected to the same Grafana server process instance
* Streaming from Telegraf will deliver data only to clients connected to the same instance which receved Telegraf data
* A separate unidirectional streams between Grafana and backend datasource may be opened on different Grafana servers for the same channel
