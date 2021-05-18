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

Grafana supports a wide range of data sources, including Prometheus, MySQL, and even Datadog. There's a good chance you can already visualize metrics from the systems you have set up. In some cases, though, you already have an in-house metrics solution that you’d like to add to your Grafana dashboards. In another tutorial we already showed [how to build a custom backend plugin](https://grafana.com/tutorials/build-a-data-source-backend-plugin/) to access your data source. In this tutorial we make a step further and introduce streaming capabilities for a backend datasource plugin.

For more information about backend plugins, refer to the documentation on [Backend plugins](https://grafana.com/docs/grafana/latest/developers/plugins/backend/).

In this tutorial, you'll:

- Build a backend for your data source
- Implement data querying over plugin
- Add streaming capabilities to a query

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

Implement a `backend.StreamHandler` interface that contains `SubscribeStream`, `RunStream`, and `PublishStream` methods.

{{< /tutorials/step >}}
{{< tutorials/step title="Congratulations" >}}

Congratulations, you made it to the end of this tutorial!

{{< /tutorials/step >}}
