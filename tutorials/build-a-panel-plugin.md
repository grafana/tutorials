summary: Learn at how to create a custom visualization for your dashboards.
id: build-a-panel-plugin
categories: Plugins
tags: beginner
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/tutorials/issues/new

# Build a panel plugin

## Introduction

Duration: 1

Panels are the building blocks of Grafana, and allow you to visualize data in different ways. This tutorial gives you a hands-on walkthrough of creating your own panel from scratch.

For more information about panels, refer to the documentation on [Panels](https://grafana.com/docs/grafana/latest/guides/basic_concepts/#panel).

### What you'll build

In this tutorial, you'll build a simple, but complete panel that will visualize health of a service through the use of color.

### What you'll learn

- How to scaffold a panel plugin
- How to customize the panel through a panel editor

### What you'll need

- Grafana version 6.4+
- NodeJS
- yarn

## Create a new plugin

Duration: 1

[[**import** [create-plugin](shared/create-plugin.md)]]

## Render the panel

Since Grafana 6.x, panels are [React components](https://reactjs.org/docs/components-and-props.html). The simplest panel consists of a single function, the `render` function, which returns the content of the panel.

Prior to Grafana 6.0, plugins were written in [AngularJS](https://angular.io/). Even though we still support plugins written in AngularJS, we recommend that you write new plugins using React.

In this step, you'll customize how your panel looks, by editing its `render` function.

### Display the health of a service

Service health is one of the first things you start monitoring. Let's change the `render` function to return a `div` with a background color.
You'll use the background color of the panel to tell when the service is healthy (green), or when it's unhealthy (red).

- Change the `render` function of the SimplePanel component to return a `div` with a background color.

**SimplePanel.tsx**

```tsx
render() {
  const { width, height } = this.props;

  return (
    <div
      style={{
        width,
        height,
        backgroundColor: '#ff0000',
      }}
    ></div>
  );
}
```

`this.props` contains current dimensions of the panel, which you're using here to make the `div` fill the whole panel.

- Run `yarn dev`, and reload Grafana to reflect the changes you've made.

In the next step, you'll add a switch to toggle the color of the panel using _options_.

## Configure your panel

Sometimes you want to offer the users of your panel to configure the behavior of your plugin. By adding a _panel editor_ to your plugin, your panel will be able to accept user input, or _options_.

A panel editor is a React component that extends `PureComponent<PanelEditorProps<SimpleOptions>>`. Here, `SimpleOptions` is a TypeScript interface that defines the available options.

**SimpleEditor.tsx**

```tsx
export class SimpleEditor extends PureComponent<PanelEditorProps<SimpleOptions>> {
  onTextChanged = ({ target }: any) => {
    this.props.onOptionsChange({ ...this.props.options, text: target.value });
  };

  render() {
    const { options } = this.props;

    return (
      <div className="section gf-form-group">
        <h5 className="section-heading">Display</h5>
        <FormField label="Text" labelWidth={5} inputWidth={20} type="text" onChange={this.onTextChanged} value={options.text || ''} />
      </div>
    );
  }
}
```

The `onChange` attribute on the `FormField` lets you update the panel properties. Here, `onTextChanged` is a function that updates the panel properties whenever the value of the `FormField` changes.

### Add more options

To be able to test the panel, you'll be adding a `Switch` to simulate the health of the service.

- Import the `Switch` component from the `grafana/ui` package.

**SimpleEditor.tsx**

```tsx
import { Switch } from "@grafana/ui";
```

- Add the `Switch` to the `render` function.

```tsx
render() {
  const { options } = this.props;

  return (
    <div className="section gf-form-group">
      <h5 className="section-heading">Debug</h5>
      <Switch label="Healthy" checked={options.healthy} onChange={this.onHealthyChanged} />
    </div>
  );
}
```

- Add the `onHealthyChanged` callback to toggle between healthy and unhealthy whenever the user presses the switch.

```tsx
onHealthyChanged = ({ target }: any) => {
  this.props.onOptionsChange({
    ...this.props.options,
    healthy: !this.props.options.healthy
  });
};
```

- Update `SimplePanel` return a different color based on the current health.

```tsx
render() {
  const { options, width, height } = this.props;

  let color;
  if (options.healthy) {
    color = "#00ff00";
  } else {
    color = "#ff0000";
  }

  return (
    <div
      style={{
        width,
        height,
        backgroundColor: color,
      }}
    ></div>
  );
}
```

- Run `yarn dev`, and reload Grafana to reflect the changes you've made. Try toggling the switch to see that the background color changes.

## Access time series data

Most panels visualize dynamic data from a Grafana data source. In this step, you'll see how to access time series data from a data source.

You've already seen that the `this.props` object provides useful data to your panel. It also contains the results from a data source query, which you can access through the `data` property:

```tsx
const { data } = this.props;
```

Next, you'll make the background color of the panel change based on the results from a data source query.

### Data frames

Data sources in Grafana return the results of a query in a format called _data frames_. A data frame is a _columnar data structure_, which means values are organized by fields, rather then by records.

Columnar data is commonly used for analytics, as it can greatly reduce the amount data read.

Here's an example of what a query result can look like.

```json
{
  series: [
    {
      name: "My data frame",
      fields: [
        {
          name: "Time",
          type: "time",
          values: [1576578517623, 1576578518236, 1576578519714]
        },
        {
          name: "Value",
          type: "number",
          values: [0.0, 1.0, 2.0]
        }
      ],
      length: 3,
    }
  ]
}
```

### Set color based on time series value

Let's make the background color change depending on the last value in the time series. If the value is greater than zero, the service is healthy.

- In `SimplePanel`, set the color based on the last value in the data frame. If it's more than 0, we assume the service is healthy.

**SimplePanel.tsx**

```tsx
let color;

let values = data.series[0].fields[0].values;
let current = values.get(values.length - 1);

if (current > 0) {
  color = "#00ff00";
} else {
  color = "#ff0000";
}
```

- Run `yarn dev`, and reload Grafana to reflect the changes you've made.
