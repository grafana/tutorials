# Use the backend plugin from the client

Let's make the `testDatasource` call our backend to make sure it's responding correctly.

1. Install `@grafana/runtime`, by running `yarn add --dev @grafana/runtime`.

`getBackendSrv` is a function that returns runtime information about the Grafana backend.

2. In `DataSource.ts`, import the `getBackendSrv`.

```
import { getBackendSrv } from '@grafana/runtime';
```

3. Define the backend request:

```
interface Request {
  queries: any[];
  from?: string;
  to?: string;
}
```

4. In `DataSource.ts`, add the following code:

```ts
testDatasource() {
  const requestData: Request = {
    from: '5m',
    to: 'now',
    queries: [
      {
        datasourceId: this.id,
      },
    ],
  };

  return getBackendSrv()
    .post('/api/tsdb/query', requestData)
    .then((response: any) => {
      if (response.status === 200) {
        return { status: 'success', message: 'Data source is working', title: 'Success' };
      } else {
        return { status: 'failed', message: 'Data source is not working', title: 'Error' };
      }
    })
    .catch((error: any) => {
      return { status: 'failed', message: 'Data source is not working', title: 'Error' };
    });
}
```

5. Confirm that the client is able to call our backend plugin by hitting **Save & Test** on your data source. It should give you a green message saying _Data source is working_.
