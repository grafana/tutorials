# Add a config editor

For most data sources, you probably want to give your users the ability to configure things like hostname or authentication method. You can accomplish this by adding an _config editor_.

1. In `types.ts`, update `MyDataSourceOptions` to contain a optional field named `path`:

```ts
export interface MyDataSourceOptions extends DataSourceJsonData {
  path?: string;
}
```

2. In `ConfigEditor.tsx`, update the `render` function to return a `FormField` for our path option:

```ts
return (
  <div className="gf-form-group">
    <div className="gf-form">
      <FormField label="Path" labelWidth={6} onChange={this.onPathChange} value={jsonData.path || ''} placeholder="sample.csv" /    >
    </div>
  </div>
);
```

3. Change the `onChange` function to update the path option with the value from the `FormField`.

```ts
onPathChange = (event: ChangeEvent<HTMLInputElement>) => {
  const { onOptionsChange, options } = this.props;
  const jsonData = {
    ...options.jsonData,
    path: event.target.value,
  };
  onOptionsChange({ ...options, jsonData });
};
```

> Note: You might have noticed that we added the path to an object called `jsonData`. This object is automatically persisted for you, and will be made available to your data source implementation as well.

3. Build your assets with `yarn dev`.

4. Navigate to Configuration -> Data Sources, and select your data source. The settings should now allow you to configure the path.
