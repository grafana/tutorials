# Add a query editor

Most likely you want your users to be able to select the data they're interested in. For MySQL and PostgreSQL this would be SQL queries, while Prometheus has its own query language, called PromQL. Let's add query support for our plugin, using a custom _query editor_.

1. In `types.ts`, update `MyQuery` to contain a optional field named `values`:

```ts
export interface MyQuery extends DataQuery {
  values?: string;
}
```

```ts
export const defaultQuery: Partial<MyQuery> = {
  values: 'value',
};
```

2. In `QueryEditor.tsx`, update the `render` function to return a `FormField` for our query string:

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

3. Update `DataSource.ts` to return a data frame with the values from the query editor.

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

3. Build your assets with `yarn dev`.

4. Create a new dashboard.

5. Add a graph panel.

6. In the query editor, try adding a sequence of numbers, separated by commas.

