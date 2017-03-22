## Roles and Environments

### Setting up a new node

In order to demonstrate the use of roles and environments we need to have more than one acting node.

So the first thing we need to do is to bootstrap a new node

`knife bootstrap 172.17.0.2 -N chefnode2 -x kitchen -P kitchen --sudo`

Of course, some of the values will change according to your working setup


Check if the node has been created

```
knife node show chefnode2

Node Name:   chefnode2
Environment: _default
FQDN:        3d0fcda87040
IP:          172.17.0.2
Run List:    
Roles:       
Recipes:     
Platform:    centos 7.3.1611
Tags:        
```

#### Create a new database cookbooks

In workstation's chef-repo directory

`chef generate cookbook cookbooks/postgresql`

Modify postgresql default recipe

```
package 'postgresql' do
        notifies :run, 'execute[postgresql-init]'
end

execute 'postgresql-init' do
        command 'postgresql-setup initdb'
        action :nothing
end

service 'postgresql' do
        action [:enable, :start]
end
```

Check for ruby and foodcritic syntax and style

```
ruby -c cookbooks/postgresql/recipes/default.rb
foodcritic cookbooks/postgresql/recipes/default.rb
```

Add files to version control and commit and push changes



### Understanding Roles

#### Roles

A role describes a run_list of recipes (or roles) that are executed on a node.

How might you specify which recipes are to be run on different sets of nodes, without manually modifying each nodes run_list each time a run_list change is required?

Role for webservers
```
{
  "name":"web",
  "description":"Role for our web server nodes for wordpress application",
  "json_class":"Chef::Role",
  "default_attributes":{

  },
  "override_attributes":{

  },
  "chef_type":"role",
  "run_list":[
      "recipe[apache2]",
      "recipe[apache2::websites]",
      "role[monitoring]"
  ],
  "env_run_lists":{

  }
}
```


Role for database servers

```
{
  "name":"database",
  "description":"Database servers for wordpress application",
  "json_class":"Chef::Role",
  "default_attributes":{

  },
  "override_attributes":{

  },
  "chef_type":"role",
  "run_list":[
      "recipe[postgreSQL]",
      "recipe[postgreSQL::create_databases]",
      "role[monitoring]"
  ],
  "env_run_lists":{

  }
}
```


Role for haproxy

```
{
  "name":"haproxy",
  "description":"Haproxy load balancer for webnodes",
  "json_class":"Chef::Role",
  "default_attributes":{

  },
  "override_attributes":{

  },
  "chef_type":"role",
  "run_list":[
      "recipe[haproxy]",
      "role[monitoring]"
  ],
  "env_run_lists":{

  }
}
```

Role for monitoring included in the db, haproxy and web roles

```
{
  "name":"monitoring",
  "description":"recipes that make up the monitorion stack required for all nodes",
  "json_class":"Chef::Role",
  "default_attributes":{

  },
  "override_attributes":{

  },
  "chef_type":"role",
  "run_list":[
      "recipe[nagios]",
      "recipe[collectd]"
  ],
  "env_run_lists":{

  }
}
```


When you assign a role to a node you do so in its run list.

`knife node run_list set nodename "role[web]"`

All recipes and roles assigned to the web role run list will be executed on this node.

This is useful -for example- when you're switching from Apache to nginx, you don't have to change all the web nodes configuration individually. You only need to modify the role.

In summary, when you assign a role to a node, you do so in its run_list and this allows you to configure many nodes in a similar fashion because we don't need to create a long list in each node, you simply give it a role or all the roles it needs to accomplish the node's desired function.

After making a change to the roles, how can we force the new run list to execute on nodes with a given role assigned to them?

1) Wait for chef-client on the nodes to execute if chef-client is set to run at intervals.
2) Execute **knife ssh**

`knife ssh "role:web" "sudo chef-client" -x user -P password`


Last command is similar to search, it will look for all the nodes who has the role web and then execute the `sudo chef-client` command in them. Last part of command are the credentials.


### Hands on: Creating roles

From the server Web UI, remove the items in the current run_list for first node

From the workstation, identify your editor's path and assign it to to the EDITOR environment variable

```
which vim
/usr/bin/vim

export EDITOR=/usr/bin/vim
```

Create a new role

`knife role create web`

Modify recently created role, add recipes to run_list

```
{
  "name": "web",
  "description": "",
  "json_class": "Chef::Role",
  "default_attributes": {

  },
  "override_attributes": {

  },
  "chef_type": "role",
  "run_list": [
          "recipe[apache]",
          "recipe[apache::websites]",
          "recipe[apache::motd]"
  ],
  "env_run_lists": {

  }
}
```

You may notice that no file were created when we issued the last command, the reason is that knife created it directly into the Chef server. Every time the role is modified with knife it will reflect the changes in the server.

The alternative to this is to create a roles directory, create JSON files for the roles and upload them manually to Chef server.

Edit the role with

`knife role edit web`

To assign this role to a node, we need to modify its run_list

`knife node run_list set chefnode "role[web]"`

If you need to modifythe role, you can do it with a single command, instead of doing it on every node that holds that role.

`knife role edit web`

_remove motd recipe and ensure correct JSON format_


Pull the node information

```
knife node show chefnode

Node Name:   chefnode
Environment: _default
FQDN:        localhost
IP:          192.168.122.37
Run List:    role[web]
Roles:       
Recipes:     apache, apache::default, apache::websites, apache::motd
Platform:    centos 7.3.1611
Tags:  
```

We still need the nodes to retrieve the changes from the Chef server, so , instead of log in into each of them and issuing the chef-client command, we're going to do it from the workstation by issuing a search based command  

`knife ssh "role:web" "sudo chef-client" -x user -P `

This means: for each node that has the role web, execute the 'sudo chef-client' command using the credentials that follow.

```
.
.
.
Chef Client finished, 0/4 resources updated in 01 minutes 00 seconds
```

Let's do the same for postgresql nodes

First of all, we need to upload the postgresql cookbook to the server

`knife cookbook upload postgresql`

Now we can create a role for the database nodes

`knife role create database`

This role will only exectued the default recipe of the postgresql role

```
{
  "name": "database",
  "description": "",
  "json_class": "Chef::Role",
  "default_attributes": {

  },
  "override_attributes": {

  },
  "chef_type": "role",
  "run_list": [
          "recipe[postgresql]"
  ],
  "env_run_lists": {

  }
}
```

Assign the newly created role to the second node

`knife node run_list set chefnode2 "role[database]"`

Before testing it, let's make a little change to the default recipe

Add the immediately attribute

```
package 'postgresql' do
        notifies :run, 'execute[postgresql-init]', :immediately
end
```

Save it and upload it to the Chef server

`knife cookbook upload postgresql`


As in the previous case, search for nodes that has the database role and exeute chef-client command

`knife ssh "role:database" "sudo chef-client" -x kitchen - P`

Finally, check the status of both nodes for services running

```
knife node show chefnode
knife node show chefnode2
```

### Example: Using Search in recipes

Edit the websites.rb recipe in Apache cookbook
Add the following lines at the end of recipe

```
webnodes = search('node', 'role:web')

webnodes.each do |node|
  puts node
end
```

Upload cookbook to Chef server

`knife cookbook upload apache`

From the chef web node, perform sudo client

`sudo chef-client`

 Notice the part of chef-client output in which _puts_ is displaying the nodes found in the search

 ```
 .
 .
- apache (0.2.1)
Installing Cookbook Gems:
Compiling Cookbooks...
node[chefnode]
.
.
 ```

 ### Understanding Environments


#### Implementing Web node Apache Cookbook changes

Scenario: You've been tasked with making changes to the Apache cookbook from 1.0 to 2.0 verions. These changes need to go through the Testing, Q/A and staging environments before production, but limit the cookbook version only to specific environments?

For this scenario:

Cookbook development (2.0) --> Testing env (2.0) --> QA env (2.0) --> Staging env (2.0) - Production env (1.0)

We want staging at the latest version but production an the previous stable one

Understanding chef environments

When a node is bootstraped, it belongs to the _default_ environment

The default environment cannot be modified  

Environments allow you to assign roles that contain a specific cookbook version to a group of nodes, while also allowing a certain cookbook version to execute given the environment "configurations".

A more simple way of thinking about it is "generally every environment is associated with one or more cookbooks or cookbooks versions"

A environment configuration file

```
name 'Production'
description 'Production Environment'
cookbook 'apache', '=1.0'

name 'Staging'
description 'Staging Environment Before Production'
cookbook 'apache', '=2.0'
```


### Bootstraping the staging node

Create a new CentOS 7 node in any of the conventional ways (VM, container, cloud instance ,etc) and bootstrap it

`knife bootstrap 54.88.28.98 -N chefstaging -x user --sudo`

Verify that the node has been actually created

`knife node show`

Assign the web role to the new node

`knife node run_list add chefstaging 'role[web]'`

Review the web role configuration

```
knife role show web

chef_type:           role
default_attributes:
description:         
env_run_lists:
json_class:          Chef::Role
name:                web
override_attributes:
run_list:
  recipe[apache]
  recipe[apache::websites]
```

It has Apache default and websites recipes.

It will run the latest version of the cookbook since nothing else has been specified


Now, we'd like to change the apache cookbook version so it will match staging

Modify metadata.rb and change version from 0.2.1 to 1.0 and upload new version to Chef server

`knife cookbook upload apache`

Just for the sake of distinguishing different versions, let's modify websites recipe and add version at the end of Hello World message

`content 'Hello world! v1.0'`

Upload the cookbook again to reflect the changes

`knife cookbook upload apache`


Repeat the exercise for a version 2.0 so there will be 1.0 and 2.0 in the server. Modify websites  recipe as well as metadata.rb to 2.0. Upload the cookbook

### Creating and using environments

In this part, we are going to create the staging and production Chef environments and apply them to our nodes.

From the Chef server web UI, go to policy -> environments and click on Create  

Name: staging
Description: This is going to run the latest Apache cookbook

Click next

In the Override Attributes window, select

Name: apache
Operator:  equal (=)
Version: 2.0.0

Click Add, then Create environment


Do the same for production environment

Name: production
Description: Runs the current production cookbook version
apache = 1.0.0


 Now go to Nodes, select staging node, modify its environment to staging and save it

 Do the similar to production

 When we run the chef-client on those nodes, it will run the cookbooks assigned to them


 Now, login into each of the nodes and run sudo chef-client, you should notice the version in each converge.

 Also, you can point your browser to each of the nodes and verify that the correspondent web pages is served.
