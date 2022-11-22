# How to Create Grafana Alerts Using InfluxDB and Flux Queries

## Introduction

Grafana’s unified alerting system represents a powerful new approach to identifying when something is wrong or needs attention.  Many Grafana users have their data stored in InfluxDB.  Originally InfluxDB used InfluxQL as the query language, but beginning with v1.8, the company introduced Flux, an open source functional data scripting language designed for querying, analyzing, and acting on data.  Flux unifies code for querying, processing, writing, and acting on data into a single syntax. The language is designed to be usable, readable, flexible, composable, testable, contributable, and shareable.

With the formalities out of the way, let’s dive into some examples…

## Example 1: How to Create a Basic Grafana Alert from a Single Flux Query

Alert when the temperature of tank A5 is less than 30 °C or greater than 60 °C.

First, we begin with the query of the data to obtain the time series graph of the temperature of tank A5:


```flux
from(bucket: "RetroEncabulator")
|> range(start: v.timeRangeStart, stop: v.timeRangeStop)
|> filter(fn: (r) => r["_measurement"] == "TemperatureData")
|> filter(fn: (r) => r["Tank"] == "A5")
|> filter(fn: (r) => r["_field"] == "Temperature")
|> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
|> yield(name: "mean")
```

![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-00.png)


Next, create a Reduce expression for above query to reduce the above to a single value:
![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-01.png)


Finally, create a math expression to be alerted on:
![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-02.png)

Preview of alerts when state is Normal…

![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-03.png)

…and when state is Alerting:

![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-04.png)

Note that the Reduce expression above is needed.  Without it, when previewing the results, Grafana would display invalid format of evaluation results for the alert definition B: looks like time series data, only reduced data can be alerted on.

💡Tip: In case your locale is still stubbornly using Fahrenheit, we can modify the above Flux query by adding (before the aggregateWindow statement) a map() function to to convert (or map) the values from °C to °F.  Note that we are not creating a new field.  We are simply remapping the existing value.

```flux
|> map(fn: (r) => ({r with _value: r._value * 1.8 + 32.0}))
```

## Example 2:  Title TK

Alert when the velocity of a vehicle reaches 88 mph and an object generates 1.21 jigowatts of electricity.  Assume each of the above data sources come from different buckets.

Query A:

```flux
from(bucket: "vehicles")
|> range(start: v.timeRangeStart, stop: v.timeRangeStop)
|> filter(fn: (r) => r["_measurement"] == "VehicleData")
|> filter(fn: (r) => r["VehicleType"] == "DeLorean")
|> filter(fn: (r) => r["VehicleYear"] == "1983")
|> filter(fn: (r) => r["_field"] == "velocity")
|> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
|> yield(name: "mean")
```

Query B:

```flux
from(bucket: "HillValley")
|> range(start: v.timeRangeStart, stop: v.timeRangeStop)
|> filter(fn: (r) => r["_measurement"] == "ElectricityData")
|> filter(fn: (r) => r["Location"] == "clocktower")
|> filter(fn: (r) => r["Source"] == "lightning")
|> filter(fn: (r) => r["_field"] == "power")
|> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
|> yield(name: "mean")
```

Reduce Query A to a single value:

![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-05.png)

Reduce Query B to a single value:

![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-06.png)

Create a math expression to be alerted on:

![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-07.png)

Preview of alerts:

![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-08.png)

💡Tip: If your data in InfluxDB happens to have an unnecessarily large number of digits to the right of the decimal (such as 1.2104705741732575 shown above), and you want your Grafana alerts to be more legible, try using {{ printf "%.2f"  $values.D.Value }} For example, in annotation Summary, we could write the following:

```
{{  $values.D.Labels.Source }} at the {{  $values.D.Labels.Location }} has generated {{ printf "%.2f"  $values.D.Value }} jigowatts.`
```

which will display as follows: 
![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-09.png)


## Example 3: Title TK

Alert when the power consumption (kWh) exceeds 5,000 kWh per day.  Let’s assume our electricity meter sends a reading to InfluxDB once per hour and contains the total kWh used for that hour.  The query & resulting time graph of the hourly data over a 7-day period is shown below:

```flux
from(bucket: "RetroEncabulator")
|> range(start: v.timeRangeStart, stop: v.timeRangeStop)
|> filter(fn: (r) => r["_measurement"] == "ElectricityData")
|> filter(fn: (r) => r["Location"] == "PlantD5")
|> filter(fn: (r) => r["_field"] == "power_consumed")
|> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
|> yield(name: "power")
```


![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-10.png)

Now, by simply changing the aggregateWindow function parameters, we can calculate the daily usage over the same 7-day period:

```flux
from(bucket: "RetroEncabulator")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "ElectricityData")
  |> filter(fn: (r) => r["Location"] == "PlantD5")
  |> filter(fn: (r) => r["_field"] == "power_consumed")
  |> aggregateWindow(every: 1d, fn: sum)
  |> yield(name: "power")
```


![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-11.png)

Reduce Query A to a single value:

![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-12.png)

Create a math expression to be alerted on and set the evaluation behavior:


![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-13.png)

Preview of alerts:

![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-14.png)

## Example 4: Title TK

Let’s return to example 1, but this time let’s assume we have 5 tanks (A5, B4, C3, D2, and E1).  We can create a multidimensional alert to notify us when a value is exceeded on any tank is less than 30 °C or greater than 60 °C.

```flux
from(bucket: "HyperEncabulator")
|> range(start: v.timeRangeStart, stop: v.timeRangeStop)
|> filter(fn: (r) => r["_measurement"] == "TemperatureData")
|> filter(fn: (r) => r["MeasType"] == "actual")
|> filter(fn: (r) => r["Tank"] == "A5" or r["Tank"] == "B4" or r["Tank"] == "C3" or r["Tank"] == "D2" or r["Tank"] == "E1")
|> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
|> yield(name: "mean")
```

💡Tip: If the tanks were shut down every night from 23:00 to 07:00, they would possibly fall below the 30 °C threshold.  If one did not want to receive alerts during those hours, one can use the Flux function hourSelection() which filters rows by time values in a specified hour range.

```flux
|> hourSelection(start: 7, stop: 23)`
```


![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-15.png)

Again, we create a Reduce expression for above query to reduce each of the above to a single value:

![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-16.png)

Finally, create a math expression to be alerted on:

![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-17.png)

## Example 5: TITLE TK

Continuing with this same dataset, let’s assume that each tank has a temperature controller with a setpoint value that is also being stored in InfluxDB.  Better yet, let’s mix things up and assume each tank has a different setpoint, where we always need to be within 3 degrees of the setpoint.


| Tank        | Setpoint    | Allowable Range (±3) |
| ----------- | ----------- | -------------------- |
| A5          | 45          | 42 to 48             |
| B4          | 55          | 52 to 58             |
| C3          | 60          | 57 to 63             |
| D2          | 72          | 69 to 75             |
| E1          | 80          | 77 to 83             |

We can create another multidimensional alert to cover all 5 tanks, and use Flux to compare the setpoint and actual value for each tank.  One multidimensional alert can monitor 5 separate tanks, each with different setpoints and actual values, but one common "allowable threshold" (i.e. a temperature difference of ±3 degrees).

```flux
from(bucket: "HyperEncabulator")
 |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
 |> filter(fn: (r) => r["_measurement"] == "TemperatureData")
 |> filter(fn: (r) => r["MeasType"] == "actual" or r["MeasType"] == "setpoint")
 |> filter(fn: (r) => r["Tank"] == "A5" or r["Tank"] == "B4" or r["Tank"] == "C3" or r["Tank"] == "D2" or r["Tank"] == "E1")
 |> filter(fn: (r) => r["_field"] == "Temperature")
 |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
 |> pivot(rowKey:["_time"], columnKey: ["MeasType"], valueColumn: "_value")
 |> map(fn: (r) => ({ r with _value: (r.setpoint - r.actual)}))
 |> rename(columns: {_value: "difference"})
 |> keep(columns: ["_time", "difference", "Tank"])
 |> drop(columns: ["actual", "setpoint"])
 |> yield(name: "mean")
```

Note in the above that we are calculating the difference between the actual and the setpoint.  The way Grafana parses the result from InfluxDB is that if a _value column is found, it is assumed to be a time-series.  The quick workaround is to add the following:

```flux
 |> rename(columns: {_value: "something"})
```

The above query results in this time series:

![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-18.png)

Again, we create a Reduce expression for above query to reduce each of the above to a single value:

![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-19.png)

Finally, create a math expression to be alerted on:

![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-20.png)

The preview of alert states is as follows:

![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-21.png)
![image here](https://raw.githubusercontent.com/grafana/tutorials/master/content/tutorials/assets/flux-alert-22.png)

Flux queries and Grafana Unified Alerting are a powerful combination to identify practically any alertable conditions in your dataset, or across your entire system

