---
title: Create users and teams
summary: Learn how to set up teams and users.
id: create-users-and-teams
categories: ["administration"]
tags: beginner
status: Published
authors: Grafana Labs
Feedback Link: https://github.com/grafana/tutorials/issues/new
draft: true
---

{{% tutorials/step duration="1" title="Introduction" %}}

This tutorial is useful for admins and others who want to learn how to manage users. In this tutorial, you'll add multiple users, organize them into teams, and make sure they're only able to access the resources they need.


### You'll learn to

- Add users.
- Assign users to teams.
- Manage dashboard access using folders.
- Override access for individual dashboards.

### Scenario

_Graphona_, a fictional telemarketing company, has asked you to configure Grafana for their teams.

In this scenario, you'll:
* Create users and organize them into teams. 
* Manage resource access for each user and team through roles and folders.

### Prerequisites

- Grafana 7.0
((Does it matter if it is installed, running on Docker, or accessed some other way?))

{{% /tutorials/step %}}
{{% tutorials/step title="Add users" %}}

In Grafana, all users are granted an _organization role_ that determines what resources they can access.

There are three types of organization roles in Grafana:

- **Admin -** For managing data sources, teams, and users within an organization.
- **Editor -** For creating and editing dashboards.
- **Viewer -** For viewing dashboards.


> **Note**: You can also configure Grafana to allow [anonymous access](https://grafana.com/docs/grafana/latest/auth/overview/#anonymous-authentication), to make dashboards available even to those who don't have a Grafana user account. That's how Grafana Labs made play.grafana.com publicly available.

### Exercise: Add a user

Graphona has asked you to add a group of early adopters.

| Name              | Email                     | Username          |
|-------------------|---------------------------|-------------------|
| Almaz Russom      | almaz.russom@example.com  | almaz.russom      |
| Brenda Tilman     | brenda.tilman@example.com | brenda.tilman     |
| Mada Rawdha Tahan | mada.rawdha.tahan@example | mada.rawdha.tahan |
| Yuan Yang         | yuan.yang@example.com     | yuan.yang         |

Repeat the following steps for each of the employees.

1. On the sidebar, click the **Server Admin** (shield) icon.
1. In the Users tab, click **New user**.
1. In **Name**, enter the name of the user.
1. In **E-mail**, enter the email of the user.
1. In **Username**, enter the username that the user will use to log in.
1. In **Password**, enter a password. The user will be able to change their password once they log in.
1. Click **Create** to create the user account.

When you create a user, they're granted the Viewer role, which means that they won't be able to make any changes to any of the resources in Grafana. That's ok for now, though. In the next step, you'll grant some users more permissions by adding them to a _team_.

{{% /tutorials/step %}}
{{% tutorials/step title="Assign users to teams" %}}

Instead of granting permissions to individual users, teams let you grant permissions to a group of users.

Teams are useful when onboarding new colleagues. If you add a user to a team, they will get access to the same resources as that team.

### Exercise: Create a team

In this exercise, you'll assign the users to their corresponding team:

| Username          | Team        |
|-------------------|-------------|
| brenda.tilman     | Marketing   |
| mada.rawdha.tahan | Marketing   |
| almaz.russom      | Engineering |
| yuan.yang         | Engineering |

Repeat the following steps for each team:

1. In the sidebar, click **Configuration** -> **Teams**.
1. Click **New team**.
1. In **Name**, enter the name of the team.
1. Click **Create**.

### Exercise: Add a user to a team

Repeat the following steps for each user:

1. In the sidebar, click **Configuration** -> **Teams**.
1. Click the team you want to add a user to.
1. Click **Add member**.
1. In the **Add team member** box, select the user.
1. Click **Add to team**.

{{% /tutorials/step %}}
{{% tutorials/step title="Manage resource access with folders" %}}

Use folders to organize collections of related dashboards.

### Exercise

The Marketing team is going to use Grafana for analytics, while the Engineering team wants to monitor the application they're building.

You'll be creating two folder, _Analytics_ and _Application_, where each team can add their own dashboards. The teams still want to be able to view each other's dashboards:

| Folder      | Team        | Permissions |
|-------------|-------------|-------------|
| Analytics   | Marketing   | Edit        |
|             | Engineering | View        |
| Application | Marketing   | View        |
|             | Engineering | Edit        |

Repeat the following steps for each folder.

#### Add a folder for each team:

1. In the sidebar, click **Dashboards** -> **Manage**.
1. To create a folder, click **New Folder**.
1. In the **Name** box, enter the name of the folder.
1. Click **Create**.

#### Remove Viewer role from folder permissions

By default, when you create a folder, users with the Viewer role are granted permission to view the folder.

In the example, Graphona wants to explicitly grant teams access to folders. To support this, you need to remove the Viewer role from the list of permissions:

1. Go to the **Permissions** tab.
1. Remove the Viewer role from the list, by clicking the red button on the right.

#### Grant folder permissions to a team:

1. Go to the **Permissions** tab, and click **Add Permission**.
1. In the **Add Permission For** dialog, make sure "Team" is selected in the first box.
1. In the second box, select the team to grant access to.
1. In the third box, select the access you want to grant.
1. Click **Save**.

{{% /tutorials/step %}}
{{% tutorials/step title="Define granular permissions" %}}

By using folders and teams, you avoid having to manage permissions for individual users.

However, there are times when you need to configure permissions on a more granular level. For these cases, Grafana allows you to override permissions for specific dashboards.

### Exercise

Graphona has hired a consultant to assist the Marketing team. The consultant should only be able to access the _SEO_ dashboard in the _Analytics_ folder.

| Name       | Email                            | Username   |
|------------|----------------------------------|------------|
| Luc Masson | luc.masson@exampleconsulting.com | luc.masson |

#### Add a new user

1. In the sidebar, click **Server Admin** -> **Users**.
1. Click **New user**.
1. In the **Name** box, enter the name of the user.
1. In the **Email** box, enter the email of the user.
1. In the **Username** box, enter the username that the user will use to log in.
1. In the **Password** box, enter a password. The user will be able to change 1.heir password once they log in.
1. Click **Create** to create the user.

#### Grant a user permission to view dashboard

1. In the sidebar, click **Dashboard** -> **Manage**.
1. In the Analytics folder, click the TODO dashboard.
1. In the top right corner, click the cog icon to go to **Dashboard settings**.
1. Go to the **Permissions** tab, and click **Add Permission**.
1. In the **Add Permission For** dialog, make sure "User" is selected in the first box.
1. In the second box, select the user to grant access to.
1. In the third box, select **View**.
1. Click **Save**.

{{% /tutorials/step %}}
{{% tutorials/step title="Congratulations" %}}

Congratulations, you made it to the end of this tutorial!

In this tutorial, you've configured Grafana for an organization:

- You've added users to your organization
- You've created teams to manage permissions for groups of users.
- You've configured permissions for folders and dashboard.

### Learn more

- What is an [Organization](https://grafana.com/docs/grafana/latest/guides/basic_concepts/#organization)?
- [Organization Roles](https://grafana.com/docs/grafana/latest/permissions/organization_roles/)
- [Permissions Overview](https://grafana.com/docs/grafana/latest/permissions/overview/)

{{% /tutorials/step %}}
