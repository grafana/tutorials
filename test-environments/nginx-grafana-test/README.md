## grafana-nginx-test

### Introduction

This script is designed to quickly test the Grafana Nginx tutorial. With one command, it will deploy grafana and Nginx to a fresh virtual machine on GCP. It will then configure nginx to serve Grafana using either a traditional path, or a sub-path setup. You can follow this guide for detailed instructions.

## Prerequisites

- a GCP account connected to your Grafana email
- `gcloud` installed and configured
- `gcloud auth application-default` enabled
    - to enable this feature, run `gcloud auth application-default login`
    - connect to GCP using your grafana gmail account
    - Visit [the gcloud docs](https://cloud.google.com/sdk/gcloud/reference/auth/application-default) for more details
- Terraform version 1.0.7+ installed
- An `ssh` key pair. You will need to copy the absolute path to a public key and paste it into the terraform configuration.

## Step One - Download and Configure the Script

With the prerequisites met, you can now download and configure the script. First, you will clone the repo; then you will add an SSH key to `terraform.tfvars`.

Clone this repo:

```sh
git clone https://github.com/grafana/tutorials.git
```

Now move into the project's root directory:

```sh
cd tutorials
```

You will run all remaining commands from here.

Next, you must add the absolute path to a local ssh public key. This ssh key-pair will allow you to enter and interact with the virtual machine. Keys are often stored in `~/.ssh`. You can follow this guide to create one.

Note down the path to your public ssh key. It might look something like this:

```
~/.ssh/my-new-key.pub
```

Open the `terraform.tfvars` file using `nano`, `VS Code` or your preferred editor:

```
code ./terraform.tfvars
```

Find the line beginning `gce_ssh_pub_key_file` and replace the corresponding value with the path to your public ssh key (be sure to replace `my-new-key.pub` with your own filename):

```ini
gce_ssh_pub_key_file = "~/.ssh/my-new-key.pub"
...
```

Save and close the file. You are now ready to configure terraform and execute the script.

## Step Two - Configure Terraform

This script is designed to work on Grafana's internal GCP account, and inside a particular project called `raintank-dev`. In this step you will verify that your `gcloud` application is correctly pointed at this account and project.

First, verify that you are logged in to GCP using your grafana account. Run this command:

```
gcloud auth application-default login
```

A browser window will open. Choose your Grafana email and agree to the prompts. Your `gcloud` cli is now pointed at Grafana's internal GCP account.

Now point `gcloud` at the correct project. Run this command:

```
gcloud config set project raintank-dev
```

You will see an output like this:

```
Updated property [core/project].
```

you are now ready to run the script. In the future, if you don't change your `gcloud` settings, you can skip directly to Step Three.

## Step Three - Run and Modify the Test Script

To execute the script, run this command:

```
./grafana-nginx-test.sh
```

This will kick off a terraform build, which will provision a fresh VM on GCP and then provision Grafana and Nginx. After a minute or so, the script will finish. When it does, you will see an output like this:

```sh
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

instance_ip = "104.197.43.55"

current configuration:                                  VALID

           ssh access:              ssh grafana@104.197.43.55
            web login:                   http://104.197.43.55
        subpath login:           http://104.197.43.55/grafana
```

You can now enter the VM to inspect the server and its software, or open a browser and verify that Nginx is properly serving Grafana.

### Testing Nginx on a sub-path

You will note that the output above lists two login URLS. By default, this script sets up a normal nginx reverse proxy. You would view this using the `web login` URL. But you can serve Grafana on a sub-path as well. To do this, you must adjust one line in the `terraform.tfvars` file and then rerun the script.

Reopen `terraform.tfvars` and locate the following line:

```
build                = "binary" # or "binary-subpath"
```

Change the value to `binary-subpath` like so:

```
build                = "binary-subpath"
```

Save and close the file.

Now rerun the script. When it completes, try viewing the Grafana login using the `subpath login` URL.

## Accessing the test server 

This script will launch a standalone Grafana binary in a detached `tmux` session. This will keep Grafana running after Terraform disconnects. To explore the VM, connect to it using the `ssh` command listed in your output. It will look something like this (but with a different ip):

```sh
ssh grafana@104.197.43.55
```

After using `ssh` to enter the VM, run this command to list all active tmux sessions:

```sh
tmux ls
```

You will see an output like this:

```output
grafanaBinary: 1 windows (created Fri Oct  8 01:50:51 2021)
```

Access your detached session using the `tmux` `a` command:

```
tmux a -t grafanaBinary
```

You should now see the output from the `grafana-server`'s logs.

Use the following key combination to detach the session and return to the main shell: 

Press `CTRL + b`. Let go and quickly press `d`. 

## Cleaning Up and Destroying the Test Server

**It is important to destroy all your resources on GCP when you are done testing.** Resources are billed on an hourly rate, even if they are totally idle. To destroy your test VM, run the following commnand:

```
terraform destroy
```

When prompted to approve the destruction (it should say that there are 3 resources to be destroyed), type `yes` and press `ENTER`.

You have now installed, configured, and executed the test script. You have also destroyed all your test resources. You can perform this cycle as many times as needed, testing out new nginx configurations along the way.