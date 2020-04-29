---
title: Package your plugin
---

Once you're happy with your plugin, it's time to package it, and submit to the plugin repository.

For users to be able to use the plugin without building it themselves, you need to make a production build of the plugin, and commit to a release branch in your repository.

#### Create a plugin release

1. Create a branch called `releases`:
   ```
   git checkout -b releases
   ```

1. Do a production build
   ```
   yarn build
   ```

1. Add the `dist` directory:
   ```
   git add -f dist
   ```

1. Create the release commit:
   ```
   git commit -m "Release <version>"
   ```

1. Create a release tag:
   ```
   git tag -a <version>
   ```

1. Push to GitHub:
   ```
   git push --follow-tags
   ```

#### Submit the plugin

For a plugin to be published on [Grafana Plugins](https://grafana.com/grafana/plugins), it needs to be added to the [grafana-plugin-repository](https://github.com/grafana/grafana-plugin-repository).

1. Fork the [grafana-plugin-repository](https://github.com/grafana/grafana-plugin-repository)

1. Add your plugin to the `repo.json` file in the project root directory:
   ```json
   {
     "id": "<plugin id>",
     "type": "<plugin type>",
     "url": "https://github.com/<username>/my-plugin",
     "versions": [
       {
         "version": "<version>",
         "commit": "<git sha>",
         "url": "https://github.com/<username>/my-plugin"
       }
     ]
   }
   ```

1. [Create a pull request](https://github.com/grafana/grafana-plugin-repository/pull/new/master).

Once your plugin has been accepted, it'll be published on [Grafana Plugin](https://grafana.com/grafana/plugins), available for anyone to [install](https://grafana.com/docs/grafana/latest/plugins/installation)!

> We're auditing every plugin that's added to make sure it's ready to be published. This means that it might take some time before your plugin is accepted. We're working on adding more automated tests to improve this process.
