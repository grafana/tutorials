---
title: Build a panel plugin with D3.js
summary: Learn how to use D3.js in your panel plugins.
id: build-a-panel-plugin-with-d3
categories: ["plugins"]
tags: beginner
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/tutorials/issues/new
weight: 60
---

{{< tutorials/step title="Introduction" >}}

Panels are the building blocks of Grafana, and allow you to visualize data in different ways. This tutorial gives you a hands-on walkthrough of creating your own panel using [D3.js](https://d3js.org/).

For more information about panels, refer to the documentation on [Panels](https://grafana.com/docs/grafana/latest/features/panels/panels/).

In this tutorial, you'll:

- Build a simple, but complete bar graph panel
- Learn how to use D3.js to build a panel using data-driven transformations

### Prerequisites

- Grafana 7.0
- NodeJS
- yarn

{{< /tutorials/step >}}
{{< tutorials/step title="Set up your environment" >}}

{{< tutorials/shared "set-up-environment" >}}

{{< /tutorials/step >}}
{{< tutorials/step title="Create a new plugin" >}}

{{< tutorials/shared "create-plugin" >}}

{{< /tutorials/step >}}
{{< tutorials/step title="Data-driven transformations" >}}

[D3.js](https://d3js.org/) is a JavaScript library for manipulating documents based on data. It lets you transform arbitrary data into HTML, and is commonly used for creating visualizations.

In fact, D3.js is already bundled with Grafana, and you can access it by importing the `d3` package.

1. Install the D3 type definitions:

   ```
   yarn add @types/d3
   ```

1. Import the `select` function from `d3` in **SimplePanel.tsx**:

   ```ts
   import { select } from 'd3';
   ```

1. Import `useRef` and `useEffect` from `react`:

   ```ts
   import React, { useRef, useEffect } from 'react';
   ```

1. Replace the content of the SimplePanel component with the following:

   ```ts
   export const SimplePanel: React.FC<Props> = ({ options, data, width, height }) => {
     const theme = useTheme();

     const d3Container = useRef(null);

     const values = [4, 8, 15, 16, 23, 42];

     useEffect(() => {
       if (d3Container.current) {
         const chart = select(d3Container.current)
           .attr('width', width)
           .attr('height', height);

         chart
           .append('text')
           .text('Hello world')
           .attr('x', 10)
           .attr('y', 10)
           .attr('fill', theme.palette.greenBase);
       }
     }, [width, height, values, d3Container.current]);

     return <svg ref={d3Container}></svg>;
   };
   ```

1. Run `yarn dev`, and reload Grafana to reflect the changes you've made.

{{< /tutorials/step >}}
{{< tutorials/step title="Build a graph from data" >}}

You've seen how to use D3.js to create a container element with some hard-coded text in it. Next, you'll build the graph from actual data.

1. Update the panel with the following code:

   ```ts
   export const SimplePanel: React.FC<Props> = ({ options, data, width, height }) => {
     const theme = useTheme();

     const d3Container = useRef(null);

     const values = [4, 8, 15, 16, 23, 42];

     useEffect(() => {
       if (d3Container.current) {
         const maxValue = Math.max.apply(
           Math,
           values.map(o => o)
         );

         const barHeight = height / values.length;

         const chart = select(d3Container.current)
           .html('')
           .append('svg')
           .attr('width', width)
           .attr('height', height);

         const bars = chart
           .selectAll('rect')
           .data(values)
           .enter()
           .append('rect');

         bars
           .attr('height', barHeight - 1)
           .attr('width', d => (d / maxValue) * width)
           .attr('transform', (d, i) => {
             return 'translate(0,' + i * barHeight + ')';
           })
           .attr('fill', theme.palette.greenBase);
       }
     }, [width, height, values, d3Container.current]);

     return <div ref={d3Container}></div>;
   };
   ```

1. Run `yarn dev`, and reload Grafana to see a bar chart that dynamically resizes to fit the panel.

Congratulations, you've created a dynamic bar chart! Still, you've only touched the surface of what's possible with D3. To learn more, check out the [D3 Gallery](https://github.com/d3/d3/wiki/Gallery).

{{< /tutorials/step >}}
{{< tutorials/step title="Complete example" >}}

```ts
import React, { useRef, useEffect } from 'react';
import { PanelProps } from '@grafana/data';
import { SimpleOptions } from 'types';
import { useTheme } from '@grafana/ui';

import { select } from 'd3';

interface Props extends PanelProps<SimpleOptions> {}

export const SimplePanel: React.FC<Props> = ({ options, data, width, height }) => {
  const theme = useTheme();

  const d3Container = useRef(null);

  const values = [4, 8, 15, 16, 23, 42];

  useEffect(() => {
    if (d3Container.current) {
      const maxValue = Math.max.apply(
        Math,
        values.map(o => o)
      );

      const barHeight = height / values.length;

      const chart = select(d3Container.current)
        .attr('width', width)
        .attr('height', height);

      const bars = chart
        .selectAll('rect')
        .data(values)
        .enter()
        .append('rect');

      bars
        .attr('height', barHeight - 1)
        .attr('width', d => (d / maxValue) * width)
        .attr('transform', (d, i) => {
          return 'translate(0,' + i * barHeight + ')';
        })
        .attr('fill', theme.palette.greenBase);
    }
  }, [width, height, values, d3Container.current]);

  return <svg ref={d3Container}></svg>;
};
```
{{< /tutorials/step >}}
{{< tutorials/step title="Congratulations" >}}

Congratulations, you made it to the end of this tutorial!

{{< /tutorials/step >}}
