---
title: Build a Panel Plugin
summary: Learn at how to create a custom visualization for your dashboards.
id: build-a-panel-plugin
categories: ["plugins"]
tags: beginner
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/tutorials/issues/new
---

{{% tutorials/step duration="1" title="Introduction" %}}

Panels are the building blocks of Grafana. They allow you to visualize data in different ways. While Grafana has several types of panels already built-in, you can also build your own panel, to add support other visualizations.

For more information about panels, refer to the documentation on [Panels](https://grafana.com/docs/grafana/latest/guides/basic_concepts/#panel).

### What you'll build

In this tutorial, you'll build a simple, but complete panel that will visualize health of a service through the use of color.

### What you'll learn

- How to create a plugin

### What you'll need

- Grafana version 7.0+
- NodeJS
- yarn

{{% /tutorials/step %}}
{{% tutorials/step duration="1" title="Set up your environment" %}}

{{< tutorials/shared "set-up-environment" >}}

{{% /tutorials/step %}}
{{% tutorials/step duration="1" title="Create a new plugin" %}}

{{< tutorials/shared "create-plugin" >}}

{{% /tutorials/step %}}
{{% tutorials/step duration="1" title="Anatomy of a plugin" %}}

{{< tutorials/shared "plugin-anatomy" >}}

{{% /tutorials/step %}}
{{% tutorials/step title="Panel plugins" %}}

Since Grafana 6.x, panels are [ReactJS components](https://reactjs.org/docs/components-and-props.html). The simplest panel consists of a single function, the `render` function, which returns the content of the panel.

Prior to Grafana 6.0, plugins were written in [AngularJS](https://angular.io/). Even though we still support plugins written in AngularJS, we highly recommend that you write new plugins using ReactJS.

### The `render` function

The `render` function in `SimplePanel.tsx` determines how Grafana displays the panel in a dashboard.

### Panel properties

The [PanelProps](https://github.com/grafana/grafana/blob/747b546c260f9a448e2cb56319f796d0301f4bb9/packages/grafana-data/src/types/panel.ts#L27-L40) interface exposes runtime information about the panel, such as panel dimensions, and the current time range.

You can access the panel properties through `this.props`, as seen in your plugin.

**SimplePanel.js**

```js
const { options, data, width, height } = this.props;
```

### Development workflow

Next, you'll learn the basic workflow of making a change to your panel, building it, and reloading Grafana to reflect the change you made.

First, you need to add your panel to a dashboard:

1. Open Grafana in your browser.
1. Create a new dashboard, and select **Choose Visualization** in the **New Panel** view.
1. Select your panel from the list of visualizations.
1. Save the dashboard.

Now that you can view your panel, make a change to the panel plugin:

1. In the panel `render` function, change the fill color of the circle.
1. Run `yarn dev` to build the plugin.
1. In the browser, reload Grafana with the new changes.

{{% /tutorials/step %}}
{{% tutorials/step title="Configure your panel" %}}

Sometimes you want to offer the users of your panel to configure the behavior of your plugin. By adding a _panel editor_ to your plugin, your panel will be able to accept user input, or _options_.

A panel editor is a React component that extends `PureComponent<PanelEditorProps<SimpleOptions>>`. Here, `SimpleOptions` is a TypeScript interface that defines the available options.

```js
export const defaults: SimpleOptions = {
  text: 'The default text!',
};
```

Just like the panel itself, the panel editor is a React component, which returns a form that lets users update the value of the options defined by `SimpleOptions`.

**SimpleEditor.tsx**

```js
<FormField label="Text" labelWidth={5} inputWidth={20} type="text" onChange={this.onTextChanged} value={options.text || ''} />
```

The `onChange` attribute on the `FormField` lets you update the panel properties. Here, `onTextChanged` is a function that updates the panel properties whenever the value of the `FormField` changes.

You can update the value of an option, by calling `this.props.onOptionsChange`:

```js
onTextChanged = ({ target }: any) => {
    this.props.onOptionsChange({ ...this.props.options, text: target.value });
  };
```
{{% /tutorials/step %}}
{{% tutorials/step title="Access time series data" %}}

Most panels visualize dynamic data from a Grafana data source. You've already seen that the `this.props` object provides useful data to your panel. It also contains the results from a data source query, which you can access through the `data` property:

```js
const { data } = this.props;
```

### Data frames

Data sources in Grafana return the results of a query in a format called _data frames_. A data frame is a _columnar data structure_, which means values are organized by fields, rather than by records.

Columnar data is a common occurrence in analytics, as it can greatly reduce the amount data read.

Here's an example of what a query result that contains a data frame can look like:

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

The current panel implementation only displays the number of series returned. Try changing it to display the current value, i.e. the last value in a series.
{{% /tutorials/step %}}
{{% tutorials/step title="Congratulations" %}}

Congratulations, you made it to the end of this tutorial!

{{% /tutorials/step %}}
