---
title: Build a data source plugin
summary: Create a plugin to add support for your own data sources.
id: build-a-data-source-plugin
categories: ["plugins"]
tags: beginner
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/tutorials/issues/new
weight: 70
---

{{< tutorials/step title="Introduction" >}}

> **IMPORTANT**: This tutorial is currently in **beta** and requires Grafana 7.0, which is scheduled for release in May. Some of the features mentioned may not work for earlier versions.

Grafana supports a wide range of data sources, including Prometheus, MySQL, and even Datadog. There's a good chance you can already visualize metrics from the systems you have set up. In some cases, though, you already have an in-house metrics solution that you’d like to add to your Grafana dashboards. This tutorial teaches you to build a support for your data source.

In this tutorial, you'll:

- Build a data source
- Construct queries using the query editor
- Configure your data source using the config editor

### Prerequisites

- Grafana version 7.0+
- NodeJS
- yarn

{{< /tutorials/step >}}
{{< tutorials/step title="Set up your environment" >}}

{{< tutorials/shared "set-up-environment" >}}

{{< /tutorials/step >}}
{{< tutorials/step title="Create a new plugin" >}}

{{< tutorials/shared "create-plugin" >}}

{{< /tutorials/step >}}
{{< tutorials/step title="Anatomy of a plugin" >}}

{{< tutorials/shared "plugin-anatomy" >}}

{{< /tutorials/step >}}
{{< tutorials/step title="Data source plugins" >}}

A data source in Grafana must extend the `DataSourceApi` interface, which requires you to defines two methods: `query` and `testDatasource`.

### Query data

The `query` method accepts a query from the user, and returns the data in a format that Grafana recognizes. This is where most of the work happens.

```
async query(options: DataQueryRequest<MyQuery>): Promise<DataQueryResponse>
```

The `DataQueryRequest` object contains the queries, or _targets_, that the user made, along with context information, like the current time interval. Use this information to query an external database.

After you receive the results from your database query, you need to return it as a _data frame_—the data format that Grafana uses internally.

Positive
: The term _target_ originates from Graphite, and the earlier days of Grafana when Graphite was the only supported data source. As Grafana gained support for more data sources, the term "target" became synonymous with any type of query.

### Test your data source

`testDatasource` implements a health check for your data source. For example, Grafana calls this method whenever the user clicks the **Save & Test** button, after changing the connection settings.

```
async testDatasource()
```

{{< /tutorials/step >}}
{{< tutorials/step title="Support custom queries" >}}

Most data sources offer a way to query specific data. MySQL and PostgreSQL use SQL, while Prometheus has its own query language, called _PromQL_. No matter what query language your databases are using, Grafana lets you build support for it.

Add support for custom queries to your data source, by implementing a your own _query editor_, a React component that enables users to build their own queries, through a user-friendly graphical interface.

A query editor can be as simple a text field where the user edits the raw query text, or it can provide a more user-friendly form with drop-down menus and switches, that later gets converted into the raw query text before it gets sent off to the database.

The first step in designing your query editor is to define its _query model_. The query model defines the user input to your data source. The query model in the starter plugin you created, defines two values: the query text, and a constant.

**types.ts**

```ts
export interface MyQuery extends DataQuery {
  queryText?: string;
  constant: number;
}
```

Now that you've defined the query model you wish to support, the next step is to bind the model to a form. The `FormField` is a text field component from `grafana/ui` that lets you register a listener, which will be invoked whenever the form field value changes.

**QueryEditor.tsx**

```js
<FormField value={queryText || ''} onChange={this.onQueryTextChange} label="Query Text"></FormField>
```

The registered listener, `onQueryTextChange`, calls `onChange` to update the current query:

```js
onQueryTextChange = (event: ChangeEvent<HTMLInputElement>) => {
    const { onChange, query } = this.props;
    onChange({ ...query, queryText: event.target.value });
  };
```

If you want the query to run automatically after updating the query, you can add a call to `onRunQuery`:

```
onRunQuery();
```

{{< /tutorials/step >}}
{{< tutorials/step title="Configure your data source" >}}

To access a specific data source, you often need to configure things like hostname, credentials, or authentication method. A _config editor_ lets you users configure your data source plugin to fit their needs.

The config editor looks similar to the query editor, in that it defines a model and binds it to a form.

**types.ts**

```js
export interface MyDataSourceOptions extends DataSourceJsonData {
  path?: string;
}
```

Just like query editor, the form field in the config editor calls the registered listener whenever the value changes.

**ConfigEditor.tsx**

```js
<FormField
  label="Path"
  onChange={this.onPathChange}
  value={jsonData.path || ''}
  placeholder="json field returned to frontend"
/>
```

To update the options for the data source, call the `onOptionsChange` method:

```
onPathChange = (event: ChangeEvent<HTMLInputElement>) => {
    const { onOptionsChange, options } = this.props;
    const jsonData = {
      ...options.jsonData,
      path: event.target.value,
    };
    onOptionsChange({ ...options, jsonData });
  };
```

{{< /tutorials/step >}}
{{< tutorials/step title="Publish your plugin" >}}

{{< tutorials/shared "publish-your-plugin" >}}

{{< /tutorials/step >}}
{{< tutorials/step title="Congratulations" >}}

Congratulations, you made it to the end of this tutorial!

{{< /tutorials/step >}}
