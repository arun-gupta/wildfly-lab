== Role Based Access Control

Role Based Access Control (RBAC) is the ability to restrict access to system or certain portions of it to authorized users. For JBoss AS 7.x, the web-based administrative console had an all-or-nothing approach. This means user authenticated with management security realm will have all the privileges. This may not be appropriate for mission-critical deployments and a finer-grained control may be required. WildFly 8 introduces RBAC using different roles.

*Purpose*: This section explains how to configure and use RBAC for WildFly.

There are seven pre-defined roles in two different categories. First four roles are where users are locked out of sensitive data and the next three level roles where users are allowed to deal with sensitive data.

The pre-defined roles are explained below:

[cols="2,8a", options="header"]
|=================

| Role | Permissions

| Monitor
| - Has the fewest permissions
- Can only read configuration and current runtime state
- No access to sensitive resources or data or audit logging resources

| Operator
| - All permissions of Monitor
- Can modify the runtime state, e.g. reload or shutdown the server, pause/resume JMS destination, flush database connection pool.
- Does not have permission to modify persistent state.

| Maintainer
| - All permissions of Operator
- Can modify the persistent state, e.g. deploy an application, setting up new data sources, add a JMS destination

| Deployer
| - All permissions of Maintainer
- Permission is restricted to applications only, cannot make changes to container configuration

| Administrator
| - All permissions of Maintainer
- View and modify sensitive data such as access control system
- No access to administrative audit logging system

| Auditor
| - All permissions of Monitor
- View and modify resources to administrative audit logging system
- Cannot modify sensitive resources or data outside auditing, can read any sensitive data

| Super User
| - Has all the permissions
- Equivalent to administrator in previous versions

|=================

=== Default super user

By default, any user added to the management realm and not belonging to a group is in ``Super User'' role.

. Start the server as standalone instance if not already running:
+
[source]
----
./bin/standalone.sh
----
+
. Access Admin Console at http://localhost:9990/console. This prompts for authentication as shown:
+
image::images/rbac-authentication-required.png[title="Authentication for Admin Console"]
+
Enter the user name `sheldon' and password `bazinga' (as created earlier). Admin console should look like:
+
image::images/rbac-admin-console-superuser-default.png[title="Super user default view"]
+
This view shows:
+
.. A new `Administration' tab that allows to map users to roles. This will be done in a later section.
+
.. Information about the logged in user is shown on top-right as:
+
image::images/rbac-superuser-information.png[title="Super user menu"]
+
Notice the logged in user name is shown.
+
.. A user in `Super User'' role can act to run in any role by clicking on `Run as'. Click on `Run as' and select drop-down list box to see the list of available roles as:
+
image::images/rbac-run-as-roles.png[title="Run as roles"]
+
.. Select the `Monitor' role and click on `Run As'.
+
The application has to be reloaded for changes to take effect. Click on `Confirm' to reload the application. After the reload, clicking on the user on top-right in admin console will display the selected role as `Run as Monitor' as shown:
+
image::images/rbac-run-as-monitor.png[title="Run as monitor"]
+
... Click on `Manage Deployments' and check that `Add', `Remove', and similar buttons are not present as shown:
+
image::images/rbac-run-as-monitor-deployments.png[title="Manage deployments as monitor"]
+
... Click on `Profile', `Data Sources' and check that all data sources are visible but not editable. This is identified by the fact that `Add', `Remove', and `Disable' buttons are not available as shown.
+
image::images/rbac-run-as-monitor-data-sources.png[title="Data sources as monitor"]
+
... Click on `Administration' tab and make sure the user does not have access to it as shown:
+
image::images/rbac-run-as-monitor-administration.png[title="Administration as monitor"]
+
.. Feel free to select other roles and observe how different options are enabled/disabled.

=== Configure `rbac' access control provider

WildFly 8 comes with two access control providers:

- `simple' provider, the default one, gives all privileges to any authenticated administrator. This provides compatibility with older releases.
- `rbac' provider allows you to setup configuration that will map users to different roles.

. Configure `rbac' access control provider by giving the following command:
+
[source]
----
jboss-cli.sh -c --command="/core-service=management/access=authorization:write-attribute(name=provider,value=rbac)"
----
+
This command will change authorization provider to ``rbac'' and will produce the output as:
+
[source]
----
{
    "outcome" => "success",
    "response-headers" => {
        "operation-requires-reload" => true,
        "process-state" => "reload-required"
    }
}
----
. The server needs to be restarted as the authorization provider is changed. Give the following command to restart the server:
+
[source]
----
./bin/jboss-cli.sh -c --command="reload"
----
+
TIP: If the server is running in managed domain then it can be restarted by additionally specifying `--host=master` in the command.
+
Check the server log to confirm server restarted, look for specific time stamps.
+
. Any existing roles need to be explicitly mapped after the access control provider is changed. Map the user `sheldon' to the role `Super User' by giving the following command:
+
[source]
----
jboss-cli.sh -c --command="/core-service=management/access=authorization/role-mapping=SuperUser/include=user-sheldon:add(name=sheldon,type=USER)"
----
. On top-right in admin console, click on the username and click on `Logout' and then `Confirm'.
+
. Enter the login credentials again (username is `sheldon' and password is `bazinga') to login back into the admin console.

=== Map users, groups, and roles

WildFly introduces the concept of ``groups'' in security realms. Users can be directly associated with a role, or can belong to a group and then a group can be associated with a role.

. Add two users in different groups using `bin/adduser.sh` script
.. Add first user in a group by giving the following command:
+
[source]
----
add-user.sh -u penny -p penny1 -g just4fun
Added user 'penny' to file '/Users/arungupta/workspaces/wildfly/build/target/wildfly-8.0.0.Final-SNAPSHOT/standalone/configuration/mgmt-users.properties'
Added user 'penny' to file '/Users/arungupta/workspaces/wildfly/build/target/wildfly-8.0.0.Final-SNAPSHOT/domain/configuration/mgmt-users.properties'
Added user 'penny' with groups just4fun to file '/Users/arungupta/workspaces/wildfly/build/target/wildfly-8.0.0.Final-SNAPSHOT/standalone/configuration/mgmt-groups.properties'
Added user 'penny' with groups just4fun to file '/Users/arungupta/workspaces/wildfly/build/target/wildfly-8.0.0.Final-SNAPSHOT/domain/configuration/mgmt-groups.properties'
----
.. Add another user in a different group by giving the following command:
+
[source]
----
add-user.sh -u leonard -p leonard1 -g geek
Added user 'leonard' to file '/Users/arungupta/workspaces/wildfly/build/target/wildfly-8.0.0.Final-SNAPSHOT/standalone/configuration/mgmt-users.properties'
Added user 'leonard' to file '/Users/arungupta/workspaces/wildfly/build/target/wildfly-8.0.0.Final-SNAPSHOT/domain/configuration/mgmt-users.properties'
Added user 'leonard' with groups geek to file '/Users/arungupta/workspaces/wildfly/build/target/wildfly-8.0.0.Final-SNAPSHOT/standalone/configuration/mgmt-groups.properties'
Added user 'leonard' with groups geek to file '/Users/arungupta/workspaces/wildfly/build/target/wildfly-8.0.0.Final-SNAPSHOT/domain/configuration/mgmt-groups.properties'
----
+
These commands creates the following users:
+
[width="50%", options="header"]
|=================
| User | Password | Group
| penny | penny1 | just4fun
| leonard | leonard1 | geek
|=================
+
Both users are added for standalone instance and managed domain.
+
. Click on `Administration' tab to see an output as:
+
image::images/rbac-admin-users-default.png[title="Administration tab in admin console"]
+
Previously assigned user/role mapping is already shown here.
. Click on `Add' to assign a new role to user mapping. Type `penny' in `User' textbox and select `Monitor' role as shown:
+
image::images/rbac-admin-users-penny.png[title="Assigning role to Penny"]
+
Click on `Save'.
+
NOTE: Multiple roles may be assigned to each user.
. Assign `Administrator' role to user `leonard'. The updated admin console looks like as shown:
+
image::images/rbac-admin-users-role-assigned.png[title="Roles assigned to users"]
+
TIP: Groups, and thus all users in that group, can be assigned one or more roles by clicking on `GROUPS' tab.

=== Logging in as different users

. Click on top-right and select `Logout' to log out of admin console. Login again by using the username `penny' and password `penny1'. Note that this user was assigned `Monitor' role.
+
. Top-right of admin console shows the logged in user name.
+
image::images/rbac-penny-information.png[title="Information about Penny"]
+
Note that `Run as' is not available any more.
+
. Click on `Manage Deployments' to see the output as shown:
+
image::images/rbac-run-as-monitor-deployments.png[title="Deployments for user Penny"]
+
This role permits only monitoring and `Add', `Remove', `En/Disable', and `Replace' buttons are not available.
. Click on `Administration' tab to see a permissiond denied output as:
+
image::images/rbac-run-as-monitor-administration.png[title="Administration for user Penny"]
+
. Click on top-right and select `Logout' to log out of admin console. Login again by using the username `leonard' and password `leonard1'. Note that this user was assigned `Administrator' role.
+
. Top-right of admin console shows the logged in user name.
+
image::images/rbac-leonard-information.png[title="Information about Leonard"]
+
Note that `Run as' is not available any more.
+
. Click on `Deployments' and confirm that new deployments can be added or existing can be replace, removed, enabled or disabled by the presence of buttons.
+
. Click on `Administration' tab and confirm that all information is visible and editable.

=== Filtering out commands in `jboss-cli'

CLI or `jboss-cli' can authenticate against local WildFly without prompting the user for a username and password. This mechanism only works if the user running the CLI has read access to the ``standalone/tmp/auth'' directory or ``domain/tmp/auth'' folder under the respective WildFly installation. If the local mechanism fails then the CLI will fallback to prompting for a username and password.

Alternatively authentication can be forced by explicitly specifying `user` and `password` options.

. Connect using `jboss-cli' using the following command:
+
[source]
----
jboss-cli.sh --user=penny --password=penny1 -c
----
+
Note that the user `penny' is in Monitor role.
+
. Type `data-source` on the CLI console and TAB to see the following output:
+
[source]
----
[standalone@localhost:9990 /] data-source 
--help                               flush-gracefully-connection-in-pool  
--name=                              flush-idle-connection-in-pool        
add                                  flush-invalid-connection-in-pool     
disable                              read-resource                        
enable                               remove                               
flush-all-connection-in-pool         test-connection-in-pool
----
+
Note that all commands and attributes, even those not permitted for Monitor role, are shown.
+
. Try to add a new data source using the following command:
+
[source]
----
[standalone@localhost:9990 /] data-source add --name=testDataSource
----
+
This command gives the following error:
+
[source]
----
JBAS013456: Unauthorized to execute operation 'add' for resource '[
    ("subsystem" => "datasources"),
    ("data-source" => "testDataSource")
]' -- "JBAS013475: Permission denied"
----
+
This is because `Monitor' role does not have permission to add data sources.
+
. Type `exit` or `quit` to exit out of CLI console.
+
. Edit `bin/jboss-cli.xml` and change the following element:
+
[source]
----
<access-control>false</access-control>
----
+
to
+
[source]
----
<access-control>true</access-control>
----
+
This element filter out the command and attribute suggestions displayed based on user's permissions.
+
. Connect using `jboss-cli' using the following command:
+
[source]
----
./bin/jboss-cli.sh --user=penny --password=penny1 -c
----
+
. Type `data-source` on the CLI console and TAB to see the following output:
+
[source]
----
[standalone@localhost:9990 /] data-source
--help         --name=        read-resource
----
+
Note that only permitted commands and attributes are shown.
+
TIP: Try some other commands and see which ones are accessible or not.

