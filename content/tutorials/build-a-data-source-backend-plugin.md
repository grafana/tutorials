---
title: Build a backend for a data source plugin
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

In this tutorial, you'll:

- Build a backend for your data source
- Implement a health check for your data source
- Enable alerting for your data source

### Prerequisites

- Knowledge about how data sources are implemented in the frontend.
- Grafana version 7.0+
- Go 1.14+
- [Mage](https://magefile.org/)

{{< /tutorials/step >}}
{{< tutorials/step title="Set up your environment" >}}

{{< tutorials/shared "set-up-environment" >}}

{{< /tutorials/step >}}
{{< tutorials/step title="Create a new plugin" >}}

To build a backend for your data source plugin, Grafana requires a binary that it can execute when it loads the plugin during start-up. In this guide, we will build a binary using our backend plugin SDK in Go.

The easiest way to get started is to clone one of our test data datasources. Navigate to the plugin folder that you configured in step 1 and type:

```
npx @grafana/toolkit plugin:create my-plugin
```

Select `Backend Datasource Plugin` and follow the rest of the steps in the plugin scaffolding command.

```
cd my-plugin
```

To build the plugin:

```
yarn install --pure-lockfile
 yarn build
 mage -v buildAll
```

{{< /tutorials/step >}}
{{< tutorials/step title="Anatomy of a backend plugin" >}}

The folders and files used to build the backend for the data source are

| file/folder         | description                                                                                                                                        |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Magefile.go`       | It’s not a requirement to use mage build files, but we strongly recommend using it so that you can use the build steps provided in the plugin SDK. |
| `/src/plugins.json` | A JSON file describing the backend plugin                                                                                                          |
| `/pkg/main.go`      | Starting point of the plugin binary.                                                                                                               |

#### plugin.json

When building a backend plugin these fields are important:

| field      | description                                                                                                            |
| ---------- | ---------------------------------------------------------------------------------------------------------------------- |
| backend    | Should be set to `true` for backend plugins. This tells Grafana that it should start a binary when loading the plugin. |
| executable | This is the name of the executable that Grafana expects to start.                                                      |
| alerting   | Should be set to true if your backend datasource supports alerting.                                                    |

In the next step we will look at the query endpoint!

{{< /tutorials/step >}}
{{< tutorials/step title="Implement data queries" >}}

We begin by opening the file `/pkg/datasource/sample-datasource.go`. In this file you will see the `DatasourceInstance` struct which implements the `backend.QueryDataHandler` interface.
The `QueryData` method on this struct is where the data fetching happens for a data source plugin.

Each request contains multiple queries to reduce traffic between Grafana and plugins.
So you need to loop over the slice of queries, process each query, and then return the results of all queries.

In the tutorial we have extracted a function named `query` to take care of each query model.
Since each plugin has their own unique query model, Grafana sends it to the backend plugin as JSON. Therefore the plugin needs
to `Unmarshal` the query model into something easier to work with.

As you can see the sample only returns static numbers. Try to extend the plugin to return other types of data.
You can read more about how to [build data frames in our docs](https://grafana.com/docs/grafana/latest/plugins/developing/dataframes).

{{< /tutorials/step >}}
{{< tutorials/step title="Add support for health checks" >}}

Implementing the health check handler allows Grafana to verify that a data source has been configured correctly.
After a user has created a new datasource in Grafana's UI, she can click the **Test** to verify that it works as expected.

In this sample data source, there is a 50% chance that the health check will be successful. Make sure to return appropriate error messages to
the users, informing them about what is misconfigured in the data source.

Open `/pkg/datasource/sample-datasource.go` and navigate to the `CheckHealth` function to see how the health check for this sample plugin is implemented.

{{< /tutorials/step >}}
{{< tutorials/step title="Congratulations" >}}

Congratulations, you made it to the end of this tutorial!

{{< /tutorials/step >}}
