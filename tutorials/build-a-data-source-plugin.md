summary: See how to add support for your own data sources.
id: build-a-data-source-plugin
categories: Plugins
tags: beginner
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/grafana

# Build a data source plugin

## Introduction

Duration: 1

Grafana has support for a wide range of data sources, like Prometheus, MySQL, or even Datadog. There's a good chance you already can visualize metrics from the systems you've already set up. In some cases though, you already have an in-house metrics solution that you’d like to add to your Grafana dashboards.

### What you'll build

In this tutorial, you'll build a simple but complete data source plugin.

### What you'll learn

- How to configure a data source
- How to construct data source queries

### What you'll need

- Grafana version 6.4+
- NodeJS
- yarn

## Create a new plugin

Duration: 1

[[**import** [create-plugin](shared/create-plugin.md)]]

## Add a config editor

Duration: 2

To access a specific data source, you often need to configure things like hostname, credentials, or authentication method. By adding a _config editor_ users can configure your data source plugin to fit their needs.

1\. In `types.ts`, update `MyDataSourceOptions` to contain a optional field named `path`:

**type.ts**

```ts
export interface MyDataSourceOptions extends DataSourceJsonData {
  path?: string;
}
```

2\. In `ConfigEditor.tsx`, update the `render` function to return a `FormField` for the `path` option:

**ConfigEditor.tsx**

```ts
return (
  <div className="gf-form-group">
    <div className="gf-form">
      <FormField
        label="Path"
        labelWidth={6}
        onChange={this.onPathChange}
        value={jsonData.path || ""}
        placeholder="sample.csv"
      />
    </div>
  </div>
);
```

3\. Change the `onChange` function to update the path option with the value from the `FormField`.

```ts
onPathChange = (event: ChangeEvent<HTMLInputElement>) => {
  const { onOptionsChange, options } = this.props;
  const jsonData = {
    ...options.jsonData,
    path: event.target.value
  };
  onOptionsChange({ ...options, jsonData });
};
```

Positive
: Did you notice the `jsonData` object? This object is automatically persisted for you, and will be available to your data source implementation as well.

4\. Build your assets:

```
yarn dev
```

5\. In Grafana, navigate to **Configuration** -> **Data Sources**, and select your data source. The settings should now allow you to configure the path.

## Add a query editor

Duration: 3

Most data sources offer a way to query specific data. For MySQL and PostgreSQL this would be SQL queries, while Prometheus has its own query language, called _PromQL_. Let's add query support for our plugin, using a custom _query editor_.

1\. In `types.ts`, update `MyQuery` to contain a optional field named `values`:

**types.ts**

```ts
export interface MyQuery extends DataQuery {
  values?: string;
}
```

```ts
export const defaultQuery: Partial<MyQuery> = {
  values: "value"
};
```

2\. In `QueryEditor.tsx`, update the `render` function to return a `FormField` for the query string:

**QueryEditor.tsx**

```ts
render() {
  const query = defaults(this.props.query, defaultQuery);
  const { values } = query;

  return (
    <div className="gf-form">
      <FormField label="Values" value={values || ''} onChange={this.onValuesChange} />
    </div>
  );
}
```

3\. Update `DataSource.ts` to return a data frame with the values from the query editor.

**DataSource.ts**

```ts
query(options: DataQueryRequest<MyQuery>): Promise<DataQueryResponse> {
  const { range } = options;
  const from = range.from.valueOf();
  const to = range.to.valueOf();

  const data = options.targets.map(target => {
    const query = defaults(target, defaultQuery);

    const values = query.values.split(',').map(value => parseFloat(value));

    // Generate timestamps for every value.
    const timestamps = values.map((value, index) => {
      return from + (index / (values.length - 1)) * (to - from);
    });

    return new MutableDataFrame({
      refId: query.refId,
      fields: [
        { name: 'Time', values: timestamps, type: FieldType.time },
        { name: 'Value', values: values, type: FieldType.number },
      ],
    });
  });

  return Promise.resolve({ data });
}
```

4\. Build your assets:

```
yarn dev
```

5\. In Grafana, create a new dashboard.

6\. Add a graph panel.

7\. In the query editor, try adding a sequence of numbers, separated by commas.
