---
title: Build a backend for a data source plugin
summary: Create a backend for your data source plugin.
id: build-a-data-source-backend-plugin
categories: ["plugins"]
tags: beginner
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/tutorials/issues/new
weight: 70
---

{{< tutorials/step duration="1" title="Introduction" >}}

Grafana supports a wide range of data sources, including Prometheus, MySQL, and even Datadog. There's a good chance you can already visualize metrics from the systems you have set up. In some cases, though, you already have an in-house metrics solution that you’d like to add to your Grafana dashboards. This tutorial teaches you to build a support for your data source.

In this tutorial, you'll:

- Build a backend for your data source
- Implement an health check for your data source
- Enable alerting for your data source

### Prerequisites

- Knowledge about how data source are implemented in the frontend.
- Grafana version 7.0+
- Go 1.14+
- [Mage](https://magefile.org/)

{{< /tutorials/step >}}
{{< tutorials/step duration="1" title="Setup Your Environment" >}}

{{< tutorials/shared "set-up-environment" >}}

{{< /tutorials/step >}}
{{< tutorials/step duration="1" title="Create a new plugin" >}}

To build a backend for your data source plugin, Grafana requires a binary that it can execute when it loads the plugin during start-up. In this guide, we will build a binary using our backend plugin SDK in Go.

The easiest way to get started is to clone one of our test data datasources. Navigate to the plugin folder that you configured in step 1 and type:

```
npx @grafana/toolkit plugin:create my-plugin
```

select `Backend Datasource Plugin` and follow the rest of the guide.

```
cd my-plugin
```

To build the plugin

```
yarn install --pure-lockfile
 yarn build
 mage -v buildAll
```

{{< /tutorials/step >}}
{{< tutorials/step duration="1" title="Anatomy of a Backend Plugin" >}}

The folders and files used to build the backend for the data source are

| file/folder         | description                                                                                                                                         |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Magefile.go`       | It’s not a requirement to use mage build files but we strongly recommend using that so that you can use the build steps provided in the plugin SDK. |
| `/src/plugins.json` | A JSON file describing the backend plugin                                                                                                           |
| `/pkg/plugin.go`    | Starting point of the plugin binary. We suggest that you keep this small and have all data source code in another package                           |
| `/pkg/datasource`   | The data source implementation in the plugin.                                                                                                       |

#### plugin.json

When building a backend plugin these fields are important.

| field      | description                                                                                                            |
| ---------- | ---------------------------------------------------------------------------------------------------------------------- |
| backend    | should be set to `true` for backend plugins. This tells Grafana that it should start a binary when loading the plugin. |
| executable | is the name of the executable that grafana expects to start                                                            |
| alerting   | Should be set to true if your backend datasource supports alerting                                                     |

#### /pkg/plugins.go

This is file where you provide the backend SDK with handler functions by calling `backend.Serve({})`. <!-- TODO update serve function with new PR is merged -->
In this tutorial we are building a backend for a datasource so we will provide an implementation of the `backend.QueryDataHandler` interface.

More about that in the next step!

{{< /tutorials/step >}}
{{< tutorials/step duration="1" title="Manage data source configuration" >}}

explain life cycle management for data sources.

{{< /tutorials/step >}}
{{< tutorials/step duration="2" title="Data source backend plugins" >}}

Open the file `/pkg/datasource/sample-datasource.go` and you will see the `DatasourceInstance` struct which implements the `backend.QueryDataHandler` interface.
The `QueryData` function on this struct is where the data fetching happens for data source plugin.

Each request contains multiple queries to reduce traffic between Grafana and plugins.
So you need to loop over the slice of queries, process each query and return the results of all queries.

In the tutorial we have extract a function named `query` to take care of each query model.
Since each plugin have their own unique query model, Grafana sends it to the backend plugin as JSON. Therefore the plugin needs
to Unmarshal the query model into something easier to work with.

As you can see the sample only returns static numbers. Try to extend the plugin to return other types of data.
You can read more about how to (build data frames in our docs)[https://grafana.com/docs/grafana/latest/plugins/developing/dataframes].

{{< /tutorials/step >}}
{{< tutorials/step duration="1" title="Add support for health checks" >}}

Implementing the health check handler allows Grafana to verify that a data source have been configured correctly.
After a user have created a new datasource in Grafanas UI she can click the **Test** to verify that it works as expected.

In this sample datasource there is a 50/50% chance that the health check is successful. Make sure to return good error messages to
the users, informing them about what is miss configured in the data source.

Open `/pkg/datasource/sample-datasource.go` and navigate to the `CheckHealth` function to see how the health check for this sample plugin is implemented.

{{< /tutorials/step >}}
{{< tutorials/step title="Congratulations" >}}

Congratulations, you made it to the end of this tutorial!

{{< /tutorials/step >}}
