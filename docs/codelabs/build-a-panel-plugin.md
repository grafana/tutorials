summary: Build a panel plugin
id: build-a-panel-plugin
categories: Plugins
tags: beginner
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/grafana

# Build a panel plugin

## Overview

Duration: 1

### What you'll learn

- Build a panel plugin.

### What you'll need

- Grafana version 6.4+
- NodeJS
- yarn

## Create a new panel plugin

Duration: 1

Tooling for modern web development can be tricky to wrap your head around. While you certainly could write you own webpack configuration, for this guide, I'm going to use grafana-toolkit.

[grafana-toolkit](https://github.com/grafana/grafana/tree/master/packages/grafana-toolkit) is a CLI application that aims to simplify Grafana plugin development, so that you can focus on code, and the toolkit takes care of building and testing it for us.

- Create a panel plugin from template, using the `plugin:create` command:

```
npx grafana-toolkit plugin:create codelab1
```

- Change directory.

```
cd codelab1
```

- Download necessary dependencies:

```
yarn install
```

- Build the plugin:

```
yarn dev
```

## The render function

Since Grafana 6.X, panels are ReactJS components. The simplest panel consists of a single function, the `render` function.

The `render` function returns the content of the panel.

### Display the health of a service

Service health is one of the first things you want to monitor. In this exercise, you'll build a panel that tells you if a service is healthy or not.

You'll use the background color of the panel to be able to tell when the service is healthy (green), or when it's unhealthy (red).

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

Positive
: `this.props` gives us the current dimensions of the panel, which you're using here to fill the whole panel.

Next, you'll add a switch to toggle the color of the panel using _options_.

## Configure your panel

Sometimes you want to offer the users of your panel to configure the behavior of your plugin.

A _panel editor_ allows your panel to accept user input, or _options_.

A panel editor is a React component that extends `PureComponent<PanelEditorProps<SimpleOptions>>`, where `SimpleOptions` is a TypeScript interface that defines the available options.

You can register the editor to the plugin in `module.ts`.

```ts
new PanelPlugin<SimpleOptions>(SimplePanel)
  .setEditor(SimpleEditor);
```

**SimpleEditor.tsx**

```tsx
<FormField label="Text" labelWidth={5} inputWidth={20} type="text" onChange={this.onTextChanged} value={options.text || ''} />
```

The `onChange` attribute on the `FormField` lets you update the panel properties. Here, `onTextChanged` is a function that updates the panel properties whenever the value of the `FormField` changes.

```tsx
onTextChanged = ({ target }: any) => {
  this.props.onOptionsChange({ ...this.props.options, text: target.value });
};
```

In **SimplePanel.tsx**, you can then access the options from the panel properties.

```tsx
const { options, data, width, height } = this.props;
```

```tsx
<div>{options.text}</div>
```

### Add more options

To be able to test our panel, you'll be adding Switch to toggle the health of our service.

- Import the Switch component from the Grafana UI package.

**SimpleEditor.tsx**

```tsx
import { Switch } from '@grafana/ui';
```

- Add the Switch to the render function.

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
  this.props.onOptionsChange({ ...this.props.options, healthy: !this.props.options.healthy });
};
```

## Use time-series data

The panel properties also contains the results from a data source query.

```tsx
const { data } = this.props;
```

Access the time series by accessing the `data.series` field.

### Set color based on time series value

Let's make the background color change depending on the last value in the time series. If the value is greater than zero, the service healthy.

**SimplePanel.tsx**

```tsx
let color;

let values = data.series[0].fields[0].values;
let current = values.get(values.length-1);

if (current > 0) {
  color = '#00ff00';
} else {
  color = '#ff0000';
}
```
