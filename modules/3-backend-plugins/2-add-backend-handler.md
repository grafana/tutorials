# Add a backend handler

1. Add two structs to represent the query and the options:

```go
type Query struct {
	RefID  string `json:"refId"`
	Values string `json:"values"`
}

type Options struct {
	Path string `json:"path"`
}
```

2. Implement the `Query` method.

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
        RefID:      query.RefID,
        DataFrames: []sdk.DataFrame{dataframe.New("", dataframe.Labels{},
            dataframe.NewField("timestamp", dataframe.FieldTypeTime, []time.Time{}),
            dataframe.NewField("value", dataframe.FieldTypeNumber, values),
        )},
		})
	}

	return res, nil
}
```
