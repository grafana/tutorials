# Create a backend plugin

In the previous part of this guide, we looked at how to get started with writing data source plugins for Grafana. For many data sources, integrating a custom data source can be done completely in the Grafana browser client. For others, you might want the plugin to be able to continue running even after closing your browser window, such as alerting, or authentication.

Luckily, Grafana has support for _backend plugins_, which lets your data source plugin communicate with a process running on the server.

Last time, we started writing a data source plugin that would read CSV files. Let's see how a backend plugin lets you read a file on the server and return the data back to the client.

1.  Create another directory `backend` in your project root directory, containing a `main.go` file. 

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

> The Grafana backend plugin system uses the [go-plugin](https://github.com/hashicorp/go-plugin) library from [Hashicorp](https://www.hashicorp.com/), and while communication happens over gRPC, here we'll use a Go client library that wraps the boilerplate for you.

2. Build the plugin binary.

In order for Grafana to discover our plugin, we have to build a binary with the following suffixes, depending on the machine you're using to run Grafana:

```
_linux_amd64
_darwin_amd64
_windows_amd64.exe
```

I'm running Grafana on my MacBook, so I'll go ahead and build a Darwin binary:

```
go build -o ./dist/csv-datasource_darwin_amd64 ./backend
```

The binary needs to be bundled into `./dist` directory together with the frontend assets.

3. Add a field `executable` to the `plugin.json` to make Grafana aware of our backend plugin.

```json
{
  "executable": "my-datasource"
}
```

The value should be the name of the binary, with the suffix removed.

4. Restart Grafana and verify that your plugin is running:

```
$ ps aux | grep csv-datasource
```
