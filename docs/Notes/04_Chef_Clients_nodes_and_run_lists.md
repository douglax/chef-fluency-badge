## Chef client, nodes and run lists


### Exercise: Create an Apache cookbook

`chef generate cookbook cookbooks/apache`

_Prefer previous command instead of knife for cookbook creation since knife is being deprecated, at least for this purpose_
Update: use knife to works with chef server or objects in the server, Chef to work in the workstation


It is a good practice to modify *metadata.rb* as soon as cookbook is created, and updated (version) when modified.

Edit metadata.rb

```
name 'apache'
maintainer 'Alex'
maintainer_email 'you@example.com'
license 'all_rights'
description 'Installs/Configures apache'
long_description 'Installs/Configures apache'
version '0.1.0'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/apache/issues' if respond_to?(:issues_url)

# The `source_url` points to the development reposiory for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/apache' if respond_to?(:source_url)
```

Modify default recipe


```
# Cookbook:: apache
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

package 'apache' do
        package_name 'http'
        action :install
end

service 'apache2' do
        service_name 'httpd'
        action [:start, enable]
end
```

Notice that we assigned the resource name ourselves and it is different from the actual package so we had to specify it.
We didn't have to specify the install action -since it is the default for the resource package- but we did it anyway.


Verify its syntax using plain Ruby compiler and correctness using foodcritic

`ruby -c recipes/default.rb`
`foodcritic recipes/default.rb`


Create a new recipe called websites.rb

```
file 'default www' do
  path '/var/www/html/index.html'
  content 'Hello world!'
end
```

Upload cookbook to Chef server, from chef-repo directory


`knife cookbook upload apache`

Push to source control repo

```
git add .
git commit -am "Adding basic Apache server"
git push -u origin master
```


### Managing node run-lists

In  workstation, check what nodes are available in the environment

`knife node list`

Add a run list to the node

`knife node run_list add chefnode 'recipe[apache]'`

To check what run lists are assigned to a node

`knife node show chefnode`

for long View

`knife node show -l chefnode`

### Simulate a convergence in the node

If you'd like to test the effects of the converge in the node but not actually enforce the changes, you may try a why run

From the node host run:

`chef-client --why-run`

--why-run may also be replaced by -W

```
[2017-03-19T14:06:49-04:00] INFO: Forking chef instance to converge...
Starting Chef Client, version 12.19.36
[2017-03-19T14:06:49-04:00] INFO: *** Chef 12.19.36 ***
[2017-03-19T14:06:49-04:00] INFO: Platform: x86_64-linux
[2017-03-19T14:06:49-04:00] INFO: Chef-client pid: 2666
[2017-03-19T14:06:52-04:00] INFO: Run List is [recipe[apache]]
[2017-03-19T14:06:52-04:00] INFO: Run List expands to [apache]
[2017-03-19T14:06:52-04:00] INFO: Starting Chef Run for chefnode
[2017-03-19T14:06:52-04:00] INFO: Running start handlers
[2017-03-19T14:06:52-04:00] INFO: Start handlers complete.
**resolving cookbooks for run list: ["apache"]**
[2017-03-19T14:06:53-04:00] INFO: Loading cookbooks [apache@0.1.0]
Synchronizing Cookbooks:
[2017-03-19T14:06:53-04:00] INFO: Storing updated cookbooks/apache/recipes/default.rb in the cache.
  - apache (0.1.0)
Installing Cookbook Gems:
Compiling Cookbooks...
Converging 2 resources
Recipe: apache::default
  * yum_package[apache] action install[2017-03-19T14:06:53-04:00] INFO: Processing yum_package[apache] action install (apache::default line 7)

    - Would install version 2.4.6-45.el7.centos of package httpd
  * service[apache2] action start[2017-03-19T14:06:58-04:00] INFO: Processing service[apache2] action start (apache::default line 13)

    * Service status not available. Assuming a prior action would have installed the service.
    * Assuming status of not running.
    - Would start service service[apache2]
  * service[apache2] action enable[2017-03-19T14:06:58-04:00] INFO: Processing service[apache2] action enable (apache::default line 13)

    * Service status not available. Assuming a prior action would have installed the service.
    * Assuming status of not running.
    - Would enable service service[apache2]
[2017-03-19T14:06:58-04:00] WARN: In why-run mode, so NOT performing node save.
[2017-03-19T14:06:58-04:00] INFO: Chef Run complete in 6.110095584 seconds

Running handlers:
[2017-03-19T14:06:58-04:00] INFO: Running report handlers
Running handlers complete
[2017-03-19T14:06:58-04:00] INFO: Report handlers complete
Chef Client finished, 3/3 resources would have been updated
```

Notice that no tasks for other than  default recipe are executed, this is because we only specified the cookbook name and no recipes or run_list, so only default recipe is enforced.

Now run chef-client for real in node

`chef-client`

To include the websites recipe in the converge, we have to choices

 1) to add it to the run list
 2) to include it in the default recipe

Let's go for the second one, modifiy default recipe to include websites

Add the following task:

`include_recipe 'apache::websites'`

Update metadata file to update version to 0.1.1

Upload cookbook to server

`knife cookbook upload apache`

Go back to the node and run chef client

`chef-client`


### Add website recipe to the run list

Now that we include website recipe, let's remove it from default recipe and add it manually to the run_list

Remove the following line from default recipe:

`include_recipe 'apache::websites'`

Upload new cookbook to server

`knife cookbook upload apache`

Add recipe to the run list

`knife node run_list add chefnode 'recipe[apache::websites]'`

Run chef-client in the node

`chef client`

To tell the server that websites should run before default recipe, we could use -b modifier

`knife node run_list add chefnode 'recipe[apache::websites]' -b recipe[apache]`

If we'd like to change it back and execute it after default, we could use -a modifier

To remove items from run_list

`knife node run_list remove chefnode 'recipe[apache::websites], recipe[apache]'`


### chef-client configuration

The chef client connects and communicates with the chef server where convergence ocurrs. It Downloads the most recent run-lists assigned to it.
From there, chef client will compile the node object using Ohai, it will take the configuration and cookbooks and recipes, databags and roles and environments and it will run a convergence and tests to see if the node is in the desired state of configuration and -if not- repairs it so that it is. So **All of the work of configuration is on the node itself** . This allows the chef server to scale a lot easier. Chef client also allows us to use why mode, allows us to use _local mode_ for testing as well.

There's a lot of options to use with chef-client. The primary role of chef-client is to
* register and authenticate the node at the chef server
* build the node object
* synchronize the cookbooks
* compiling the resource collection by loading each of the required cookbooks, recipes, attributes so on and so forth
* taking required appropiated actions to configure the node during the convergence
* looking for exceptions and notifications and handling each as required

The chef configuration -in the node host- is at  **/etc/chef**

**/etc/chef/client.rb**

```
chef_server_url  "https://douglax1.mylabserver.com/organizations/linuxacademy"
validation_client_name "chef-validator"
log_location   STDOUT
node_name "chefnode"
trusted_certs_dir "/etc/chef/trusted_certs"
```

Notice that there is a truste certificate (.crt) at /etc/chef/trusted_certs
