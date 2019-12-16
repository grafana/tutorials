summary: See how to add support for your own data sources.
id: build-a-data-source-plugin
categories: Plugins
tags: beginner
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/grafana

# Build a data source plugin

## Overview

Duration: 1

Grafana has support for a wide range of data sources, like Prometheus, MySQL, or even Datadog. This means that it’s likely that you can already visualize metrics from the systems you've already set up. In some cases though, you might already have an in-house metrics solution that you’d like to add to your Grafana dashboards. Luckily, Grafana supports data source plugins, which lets you build a custom integration for your specific source of data.

### What you'll learn

- Build a plugin to integrate with a custom data source.

### What you'll need

- Grafana version 6.4+
- NodeJS
- yarn

## Create a new plugin

Duration: 1

[[**import** [create-plugin](shared/create-plugin.md)]]

## Add a config editor

Duration: 2

For most data sources, you probably want to give your users the ability to configure things like hostname or authentication method. You can accomplish this by adding an _config editor_.

- In `types.ts`, update `MyDataSourceOptions` to contain a optional field named `path`:

**type.ts**

```ts
export interface MyDataSourceOptions extends DataSourceJsonData {
  path?: string;
}
```

- In `ConfigEditor.tsx`, update the `render` function to return a `FormField` for our path option:

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

- Change the `onChange` function to update the path option with the value from the `FormField`.

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
: Note: You might have noticed that we added the path to an object called `jsonData`. This object is automatically persisted for you, and will be made available to your data source implementation as well.

- Build your assets with `yarn dev`.

- Navigate to Configuration -> Data Sources, and select your data source. The settings should now allow you to configure the path.

## Add a query editor

Duration: 3

Most likely you want your users to be able to select the data they're interested in. For MySQL and PostgreSQL this would be SQL queries, while Prometheus has its own query language, called PromQL. Let's add query support for our plugin, using a custom _query editor_.

- In `types.ts`, update `MyQuery` to contain a optional field named `values`:

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

- In `QueryEditor.tsx`, update the `render` function to return a `FormField` for our query string:

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

- Update `DataSource.ts` to return a data frame with the values from the query editor.

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

- Build your assets with `yarn dev`.

- Create a new dashboard.

- Add a graph panel.

- In the query editor, try adding a sequence of numbers, separated by commas.

## Error handling

Duration: 4

Use `throw` to display a friendly error message in the top-left corner of the panel whenever a data source error occurred:

**DataSource.ts**

```ts
async query(options: DataQueryRequest<MyQuery>): Promise<DataQueryResponse> {
  throw { message: 'Malformed query' };
}
```
