---
title: Build a streaming data source backend plugin
summary: Create a backend for your data source plugin with streaming capabilities.
id: build-a-streaming-data-source-backend-plugin
categories: ["plugins"]
tags: ["beginner"]
status: Published
authors: ["grafana_labs"]
Feedback Link: https://github.com/grafana/tutorials/issues/new
weight: 75
---

{{< tutorials/step title="Introduction" >}}

Grafana supports a wide range of data sources, including Prometheus, MySQL, and even Datadog. In previous tutorials we have already shown how to extend Grafana capabilities to query custom data sources by [building a backend datasource plugin](https://grafana.com/tutorials/build-a-data-source-backend-plugin/). In this tutorial we take a step further and add streaming capabilities to the backend datasource plugin. Streaming allows plugins to push data to Grafana panels as soon as data appears (without periodic polling from UI side).

For more information about backend plugins, refer to the documentation on [Backend plugins](https://grafana.com/docs/grafana/latest/developers/plugins/backend/).

In this tutorial, you'll:

- Extend a backend plugin with streaming capabilities

{{% class "prerequisite-section" %}}
#### Prerequisites

- Knowledge about how data sources are implemented in the frontend.
- Knowledge about [backend datasource anatomy](https://grafana.com/tutorials/build-a-data-source-backend-plugin/)
- Grafana 8.0+
- Go 1.16+
- [Mage](https://magefile.org/)
- NodeJS
- yarn
{{% /class %}}

{{< /tutorials/step >}}
{{< tutorials/step title="Set up your environment" >}}

{{< tutorials/shared "set-up-environment" >}}

{{< /tutorials/step >}}
{{< tutorials/step title="Create a new plugin" >}}

To build a backend for your data source plugin, Grafana requires a binary that it can execute when it loads the plugin during start-up. In this guide, we will build a binary using the [Grafana plugin SDK for Go](https://grafana.com/docs/grafana/latest/developers/plugins/backend/grafana-plugin-sdk-for-go/).

The easiest way to get started is to clone one of our test data datasources. Navigate to the plugin folder that you configured in step 1 and type:

```
npx @grafana/toolkit plugin:create my-plugin
```

Select **Backend Datasource Plugin** and follow the rest of the steps in the plugin scaffolding command.

```bash
cd my-plugin
```

Install frontend dependencies and build frontend parts of the plugin to _dist_ directory:

```bash
yarn install
yarn build
```

Run the following to update [Grafana plugin SDK for Go](https://grafana.com/docs/grafana/latest/developers/plugins/backend/grafana-plugin-sdk-for-go/) dependency to the latest minor version:

```bash
go get -u github.com/grafana/grafana-plugin-sdk-go
go mod tidy
```

Build backend plugin binaries for Linux, Windows and Darwin to _dist_ directory:

```bash
mage -v
```

Now, let's verify that the plugin you've built so far can be used in Grafana when creating a new data source:

1. Restart your Grafana instance.
1. Open Grafana in your web browser.
1. Navigate via the side-menu to **Configuration** -> **Data Sources**.
1. Click **Add data source**.
1. Find your newly created plugin and select it.
1. Enter a name and then click **Save & Test** (ignore any errors reported for now).

You now have a new data source instance of your plugin that is ready to use in a dashboard:

1. Navigate via the side-menu to **Create** -> **Dashboard**.
1. Click **Add new panel**.
1. In the query tab, select the data source you just created.
1. A line graph is rendered with one series consisting of two data points.
1. Save the dashboard.

### Troubleshooting

#### Grafana doesn't load my plugin

By default, Grafana requires backend plugins to be signed. To load unsigned backend plugins, you need to
configure Grafana to [allow unsigned plugins](https://grafana.com/docs/grafana/latest/plugins/plugin-signature-verification/#allow-unsigned-plugins).
For more information, refer to [Plugin signature verification](https://grafana.com/docs/grafana/latest/plugins/plugin-signature-verification/#backend-plugins).

{{< /tutorials/step >}}
{{< tutorials/step title="Anatomy of a backend plugin" >}}

As you may notice till this moment we did the same steps described in [build a backend datasource plugin tutorial](https://grafana.com/tutorials/build-a-data-source-backend-plugin/). At this point you should be familiar with its structure and a way how data querying and health check capabilities could be implemented. Let's make the next step and discuss how datasource plugin can handle data streaming.  

{{< /tutorials/step >}}
{{< tutorials/step title="Add streaming capabilities" >}}

What we want to achieve here is issue a query to load initial data from a datasource plugin and then switching to data streaming mode where plugin will push data frames to Grafana time series panel.

In short – implementing a streaming plugin means implementing a `backend.StreamHandler` interface which contains `SubscribeStream`, `RunStream`, and `PublishStream` methods.

`SubscribeStream` is a method where plugin has a chance to authorize user subscription request to a channel. Users on frontend side subscribe to different channels to consume real-time data.

When returning a `data.Frame` with initial data we can return a special field `Channel` to let frontend know that we are going to stream data frames after initial data load. When frontend receives a frame with a `Channel` set it automatically issues a subscription request to that channel.

In Grafana channel consists of 3 parts delimited by `/`:

* Scope
* Namespace
* Path

For example, channel `grafana/dashboard/xyz` has scope `grafana`, namespace `dashboard` and path `xyz`.

Scope, namespace and path can only have ascii alphanumeric symbols (A-Z, a-z, 0-9), `_` (underscore) and `-` (dash) at the moment. The meaning of scope, namespace and path is context specific.

Scope determines a purpose of channel in Grafana. For datasource plugin channels Grafana uses `ds` scope. Namespace in case of datasource channels is a datasource unique ID (UID) which is issued by Grafana at the moment of datasource creation. Path is a custom string which plugin authors free to choose themselves (just make sure it consists of allowed symbols). I.e. datasource channel looks like `ds/<DATASOURCE_UID>/<CUSTOM_PATH>`.

So to let frontend know that we are going to stream data we set a `Channel` field into frame meta data inside `QueryData` implementation. In our tutorial it's a `ds/<DATASOURCE_UID>/stream`. Frontend will issue a subscription request to this channel.

Inside `SubscribeStream` implementation we check whether a user allowed to subscribe on a channel path. If yes – we return an OK status code to tell Grafana user can join a channel:

```go
status := backend.SubscribeStreamStatusPermissionDenied
if req.Path == "stream" {
    // Allow subscribing only on expected path.
    status = backend.SubscribeStreamStatusOK
}
return &backend.SubscribeStreamResponse{
    Status: status,
}, nil
```

As soon as first subscriber joins a channel Grafana opens a unidirectional stream to consume streaming frames from a plugin. To handle this and to push data towards clients we implement a `RunStream` method which provides a way to push JSON data into a channel. So we can push data frame like this (error handling skipped):

```go
frameJSON, _ := json.Marshal(frame)
_ = sender.Send(&backend.StreamPacket{
    Data: frameJSON,
})
```

Open example datasource query editor and make sure `With Streaming` toggle is on. After doing this you should see a data displayed and then periodically updated by streaming frames coming periodically from `RunStream` method.

The important thing to note is that Grafana opens unidirectional stream only once per channel upon the first subscriber joined. Every other subscription requests will be still authorized by `SubscribeStream` method but new `RunStream` won't be issued. I.e. you can have many active subscribers but only one running stream. At this moment this guarantee works for single Grafana instance, we are planning to support this for highly-available Grafana setup (many Grafana instances behind load-balancer) in the future releases.

Stream will be automatically closed as soon as all subscriber users left.

For the tutorial use case we only need to properly implement `SubscribeStream` and `RunStream` - we don't really need to handle publications to a channel from users. But we still need to write `PublishStream` method to fully implement `backend.StreamHandler` interface. Inside `PublishStream` we just do not allow any publications from users since we are pushing data from a backend:

```go
return &backend.PublishStreamResponse{
    Status: backend.PublishStreamStatusPermissionDenied,
}, nil
```

{{< /tutorials/step >}}
{{< tutorials/step title="Congratulations" >}}

Congratulations, you made it to the end of this tutorial! Happy streaming!

{{< /tutorials/step >}}
