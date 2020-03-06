---
title: Build a Backend Plugin
summary: Discover how you can extend your data source plugin with a backend.
id: build-a-backend-plugin
categories: ["plugins"]
tags: intermediate
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/tutorials/issues/new
---

{{% tutorials/step duration="1" title="Overview" %}}

In this codelab, you'll learn how to build a backend plugin to support your data source plugin.

### Prerequisites

- Completed [Build data source plugins](/build-a-data-source-plugin)

### What you'll need

- Grafana version 7.0+
- NodeJS
- yarn
- Go 1.11+

{{% /tutorials/step %}}
{{% tutorials/step title="Backend Plugins" %}}

In the previous part of this guide, we looked at how to get started with writing data source plugins for Grafana. For many data sources, integrating a custom data source can be done completely in the Grafana browser client. For others, you might want the plugin to be able to continue running even after closing your browser window, such as alerting, or authentication.

Luckily, Grafana has support for _backend plugins_, which lets your data source plugin communicate with a process running on the server.

- Create another directory `backend` in your project root directory, containing a `main.go` file.

**main.go**

```go
package main

import (
    "context"
    "log"
    "os"

    sdk "github.com/grafana/grafana-plugin-sdk-go"
)

const pluginID = "myorg-custom-datasource"

type MyDataSource struct {
    logger *log.Logger
}

func (d *MyDataSource) Query(ctx context.Context, tr sdk.TimeRange, ds sdk.DataSourceInfo, queries []sdk.Query) ([]sdk.QueryResult, error) {
    return []sdk.QueryResult{}, nil
}

func main() {
    logger := log.New(os.Stderr, "", 0)

    srv := sdk.NewServer()

    srv.HandleDataSource(pluginID, &MyDataSource{
        logger: logger,
    })

    if err := srv.Serve(); err != nil {
        logger.Fatal(err)
    }
}
```

Positive
: The Grafana backend plugin system uses the [go-plugin](https://github.com/hashicorp/go-plugin) library from [Hashicorp](https://www.hashicorp.com/), and while communication happens over gRPC, here we'll use a Go client library that wraps the boilerplate for you.

- Build the plugin binary.

```
go build -o ./dist/my-datasource_darwin_amd64 ./backend
```

In order for Grafana to discover our plugin, we have to build a binary with the following suffixes, depending on the machine you're using to run Grafana:

```
_linux_amd64
_darwin_amd64
_windows_amd64.exe
```

The binary needs to be bundled into `./dist` directory together with the frontend assets.

- Add a field `executable` to the `plugin.json` to make Grafana aware of our backend plugin.

```json
{
  "executable": "my-datasource"
}
```

The value should be the name of the binary, with the suffix removed.

- Restart Grafana and verify that your plugin is running:

```
ps aux | grep my-datasource
```

{{% /tutorials/step %}}
{{% tutorials/step title="Add a backend handler" %}}

- Add two structs to represent the query and the options:

**main.go**

```go
type Query struct {
    RefID  string `json:"refId"`
    Values string `json:"values"`
}

type Options struct {
    Path string `json:"path"`
}
```

- Implement the `Query` method.

```go

func (d *MyDataSource) Query(ctx context.Context, tr sdk.TimeRange, ds sdk.DataSourceInfo, queries []sdk.Query) ([]sdk.QueryResult, error) {
    var opts Options
    if err := json.Unmarshal(ds.JsonData, &opts); err != nil {
        return nil, err
    }

    var res []sdk.QueryResult

    for _, q := range queries {
        var query Query
        if err := json.Unmarshal(q.ModelJson, &query); err != nil {
            return nil, err
        }

        var values []int
        for _, val := range strings.Split(query.values, ",") {
            num, _ := strconv.Atoi(val)
            values = append(values, num)
        }

        res = append(res, sdk.QueryResult{
            RefID: query.RefID,
            DataFrames: []sdk.DataFrame{dataframe.New("", dataframe.Labels{},
                dataframe.NewField("timestamp", dataframe.FieldTypeTime, []time.Time{}),
                dataframe.NewField("value", dataframe.FieldTypeNumber, values),
            )},
        })
    }

    return res, nil
}
```

{{% /tutorials/step %}}
{{% tutorials/step title="Use the backend plugin from the client" %}}

Let's make the `testDatasource` call our backend to make sure it's responding correctly.

- Install `@grafana/runtime`, by running `yarn add --dev @grafana/runtime`.
- In `DataSource.ts`, import the `getBackendSrv`. `getBackendSrv` is a function that returns runtime information about the Grafana backend.

**DataSource.ts**

```ts
import { getBackendSrv } from "@grafana/runtime";
```

- Define the backend request:

```ts
interface Request {
  queries: any[];
  from?: string;
  to?: string;
}
```

- In `DataSource.ts`, add the following code:

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

- Confirm that the client is able to call our backend plugin by hitting **Save & Test** on your data source. It should give you a green message saying _Data source is working_.

{{% /tutorials/step %}}
{{% tutorials/step title="Debugging backend plugin" %}}
Insofar as bakend plugin is running as a [separate process](https://github.com/hashicorp/go-plugin#architecture), it's not possible to debug it as a part of Grafana server. Also, it's not possible to just run plugin with debugging config from IDE or code editor, because subprocess should be spawned by grafana-server. Fortunately, debugging is reachable by attaching [delve](https://github.com/go-delve/delve) debugger to running process.

First of all, you need to build plugin with several flags improving debugging experience. `-gcflags=all="-N -l"` disables compiler optimizations and inlining.

```
go build -gcflags=all="-N -l" -o ./dist/my-datasource_linux_amd64 ./backend
```

Restart grafana-server or kill running plugin instance to restart plugin.
```
pkill my-datasource
```

Now it's possible to attach to plugin process with `dlv attach`. Here's a script which runs delve in headless mode and attaches to plugin. Pay attention to `ptrace_scope` section if you're running Linux - attaching debugger might be prevented by default.

```bash
#!/bin/bash
if [ "$1" == "-h" ]; then
  echo "Usage: ${BASH_SOURCE[0]} [plugin process name] [port]"
  exit
fi

PORT="${2:-3222}"
PLUGIN_NAME="${1:-my-datasource}"

if [ "$OSTYPE" == "linux-gnu" ]; then
  ptrace_scope=`cat /proc/sys/kernel/yama/ptrace_scope`
  if [ "$ptrace_scope" != 0 ]; then
    echo "WARNING: ptrace_scope set to value other than 0, this might prevent debugger from connecting, try writing \"0\" to /proc/sys/kernel/yama/ptrace_scope.
Read more at https://www.kernel.org/doc/Documentation/security/Yama.txt"
    read -p "Set ptrace_scope to 0? y/N (default N)" set_ptrace_input
    if [ "$set_ptrace_input" == "y" ] || [ "$set_ptrace_input" == "Y" ]; then
      echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
    fi
  fi
fi

PLUGIN_PID=`pgrep ${PLUGIN_NAME}`
dlv attach ${PLUGIN_PID} --headless --listen=:${PORT} --api-version 2 --log
pkill dlv
```

Save script to `debug-backend.sh` and run it. You will get headless delve running on `3222` port. Finally, you can connect to delve from your IDE. This is an example configuration for [VS Code](https://code.visualstudio.com/):

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug backend plugin",
      "type": "go",
      "request": "attach",
      "mode": "remote",
      "port": 3222,
      "host": "127.0.0.1",
    },
  ]
}

```

{{% /tutorials/step %}}
