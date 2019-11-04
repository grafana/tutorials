# Error handling

Use `throw` to display a friendly error message in the top-left corner of the panel whenever a data source error occurred:

```ts
async query(options: DataQueryRequest<MyQuery>): Promise<DataQueryResponse> {
  throw { message: 'Malformed query' };
}
```
