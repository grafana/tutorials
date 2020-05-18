---
title: Build a data source backend plugin
summary: Create a backend for your data source plugin.
id: build-a-data-source-backend-plugin
categories: ["plugins"]
tags: beginner
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/tutorials/issues/new
weight: 75
---

{{< tutorials/step title="Introduction" >}}

> **IMPORTANT**: This tutorial is currently in **beta** and requires Grafana 7.0, which is scheduled for release in May.

Grafana supports a wide range of data sources, including Prometheus, MySQL, and even Datadog. There's a good chance you can already visualize metrics from the systems you have set up. In some cases, though, you already have an in-house metrics solution that you’d like to add to your Grafana dashboards. This tutorial teaches you to build a support for your data source.

For more information about backend plugins, refer to the documentation on [Backend plugins](https://grafana.com/docs/grafana/latest/developers/plugins/backend/).

In this tutorial, you'll:

- Build a backend for your data source
- Implement a health check for your data source
- Enable Grafana Alerting for your data source

### Prerequisites

- Knowledge about how data sources are implemented in the frontend.
- Grafana version 7.0+
- Go 1.14+
- [Mage](https://magefile.org/)
- NodeJS
- yarn

{{< /tutorials/step >}}
{{< tutorials/step title="Set up your environment" >}}

{{< tutorials/shared "set-up-environment" >}}

{{< /tutorials/step >}}
{{< tutorials/step title="Create a new plugin" >}}

To build a backend for your data source plugin, Grafana requires a binary that it can execute when it loads the plugin during start-up. In this guide, we will build a binary using the [Grafana plugin SDK for Go](https://grafana.com/docs/grafana/latest/developers/plugins/backend/grafana-plugin-sdk-for-go/).

The easiest way to get started is to clone one of our test data datasources. Navigate to the plugin folder that you configured in step 1 and type:

```
npx @grafana/toolkit@next plugin:create my-plugin
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

{{< /tutorials/step >}}
{{< tutorials/step title="Anatomy of a backend plugin" >}}

The folders and files used to build the backend for the data source are

| file/folder         | description                                                                                                                                          |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Magefile.go`       | It’s not a requirement to use mage build files, but we strongly recommend using it so that you can use the build targets provided by the plugin SDK. |
| `/go.mod     `      | Go modules dependencies, [reference](https://golang.org/cmd/go/#hdr-The_go_mod_file)                                                                 |
| `/src/plugin.json` | A JSON file describing the backend plugin                                                                                                            |
| `/pkg/main.go`      | Starting point of the plugin binary.                                                                                                                 |

#### plugin.json

The [plugin.json](https://grafana.com/docs/grafana/latest/developers/plugins/metadata/) file is required for all plugins. When building a backend plugin these properties are important:

| property   | description                                                                                                            |
| ---------- | ---------------------------------------------------------------------------------------------------------------------- |
| backend    | Should be set to `true` for backend plugins. This tells Grafana that it should start a binary when loading the plugin. |
| executable | This is the name of the executable that Grafana expects to start, see [plugin.json reference](https://grafana.com/docs/grafana/latest/developers/plugins/metadata/) for details. |
| alerting   | Should be set to `true` if your backend datasource supports alerting.                                                  |

In the next step we will look at the query endpoint!

{{< /tutorials/step >}}
{{< tutorials/step title="Implement data queries" >}}

We begin by opening the file `/pkg/sample-plugin.go`. In this file you will see the `SampleDatasource` struct which implements the [backend.QueryDataHandler](https://pkg.go.dev/github.com/grafana/grafana-plugin-sdk-go/backend?tab=doc#QueryDataHandler) interface.
The `QueryData` method on this struct is where the data fetching happens for a data source plugin.

Each request contains multiple queries to reduce traffic between Grafana and plugins.
So you need to loop over the slice of queries, process each query, and then return the results of all queries.

In the tutorial we have extracted a method named `query` to take care of each query model.
Since each plugin has their own unique query model, Grafana sends it to the backend plugin as JSON. Therefore the plugin needs
to `Unmarshal` the query model into something easier to work with.

As you can see the sample only returns static numbers. Try to extend the plugin to return other types of data.
You can read more about how to [build data frames in our docs](https://grafana.com/docs/grafana/latest/plugins/developing/dataframes).

{{< /tutorials/step >}}
{{< tutorials/step title="Add support for health checks" >}}

Implementing the health check handler allows Grafana to verify that a data source has been configured correctly.
When editing a data source in Grafana's UI, you can **Save & Test** to verify that it works as expected.

In this sample data source, there is a 50% chance that the health check will be successful. Make sure to return appropriate error messages to
the users, informing them about what is misconfigured in the data source.

Open `/pkg/sample-plugin.go`. In this file you'll see that the `SampleDatasource` struct also implements the [backend.CheckHealthHandler](https://pkg.go.dev/github.com/grafana/grafana-plugin-sdk-go/backend?tab=doc#CheckHealthHandler) interface. Navigate to the `CheckHealth` method to see how the health check for this sample plugin is implemented.

{{< /tutorials/step >}}
{{< tutorials/step title="Enable Grafana Alerting" >}}

1. Open _src/plugin.json_.
1. Add the top level `backend` property with a value of `true` to specify that your plugin supports Grafana Alerting, e.g.
    ```json
    {
      ...
      "backend": true,
      "executable": "gpx_simple_datasource_backend",
      "alerting": true,
      "info": {
      ...
    }
    ```
1. Rebuild frontend parts of the plugin to _dist_ directory:
  ```bash
  yarn build
  ```
2. Restart your Grafana instance.
1. Open Grafana in your web browser.
1. Open the dashboard you created earlier in the _Create a new plugin_ step.
1. Edit the existing panel.
1. Click on the _Alert_ tab.
1. Click on _Create Alert_ button.
1. Edit condition and specify  _IS ABOVE 10_. Change _Evaluate every_ to _10s_ and clear the _For_ field to make the alert rule evaluate quickly.
1. Save the dashboard.
1. After some time the alert rule should evaluate and transition into _Alerting_ state.

{{< /tutorials/step >}}
{{< tutorials/step title="Congratulations" >}}

Congratulations, you made it to the end of this tutorial!

{{< /tutorials/step >}}
