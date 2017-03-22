### Node object

The node object is made up of groups of attributes and the node run-lists

What is and attribute?

* An attribute is a specific piece of data about the node
  * cpu information
  * ip address
  * hostname
  * memory
  * swap
  * etc

Attributes are collected bt a tool called **ohai**

Chef-client automatically executes ohai and stores the data (attributes) about a node in the object.

This node object information can be used within the recipes named node.

This information combined with the nodes run-lists is called the **node object**.

The node object is stored in a JSON (JavaScript Object Notation) file on the server.


### Working with Ohai  and Node Attributes

In the bootstraped node you can get a lot of information of the node by simply typing `ohai`

If you're looking for an specific attribute you can retrieve it by passing it as a parameter

`ohai ipaddress`

All of these attributes can be used within the cookbooks code

There can be also be retrieved a set of attributes by using the grep command.

`ohai | grep cpu`

```
"cpu": {
     "mount": "/sys/fs/cgroup/cpuset",
       "cpuset"
         "cpuset"
         "/sys/fs/cgroup/cpu,cpuacct",
         "/sys/fs/cgroup/cpuset"
     "/sys/fs/cgroup/cpu,cpuacct": {
         "cpuacct",
         "cpu"
     "/sys/fs/cgroup/cpuset": {
         "cpuset"
     "cgroup,/sys/fs/cgroup/cpu,cpuacct": {
       "mount": "/sys/fs/cgroup/cpu,cpuacct",
         "cpuacct",
         "cpu"
     "cgroup,/sys/fs/cgroup/cpuset": {
       "mount": "/sys/fs/cgroup/cpuset",
         "cpuset"
```

#### Using node attributes in cookbooks

 Modify default recipe, add the following _if_ block at the beginning


 ```
 if node['platform_family'] == "rhel"
  package = "httpd"
elsif node['platform_family'] == "debian"
  package = "apache2"
end
 ```  

 And replace package_name package within package resource  


 #### Using variable interpolation

create a new recipe called motd.rb


 ```
 hostname = node['hostname']

file '/etc/motd' do
        content "The hostname is: #{hostname}"
end     
 ```


 Notice that content changed from single quotes to double quotes in order to allow variable interpolation

update cookbook's metadata to version 0.2.1

Push to git

```
git add .
git commit -am "added motd and changed apache default for node attributes"
git push origin master
```

Upload cookbook to server

`knife cookbook upload apache`

Add the motd recipe to the run_list

`knife node run_list add chefnode 'recipe[motd]'`


 And finally, enforce the converge at the node by issuing chef-client

 `chef-client`

 You'll notice that it failed because it could not find a motd cookbook. We need to first remove it from the run list

`knife node run_list remove chefnode 'recipe[motd]'`

Now that it's been removed, add the right version to run_list

`knife node run_list add chefnode 'recipe[apache::motd]'`


 ### Understanding Search

 Chef search allows a search from either a knife or within a recipe in order to search any data that is indexed by the Chef server.

 Data is stored within Chef server indexes (5 of them):

 * Client
 * Data bags
 * Environments
 * Nodes
 * Roles

#### Knife Query syntax

`knife search INDEX "key:search_pattern"`

Note: if no index is passed, then the default "node" is applied.

Key is a field name found in the JSON description of an indexable object on the Chef server and search_pattern defines what will be searched for.

Index can either be a role, node, client, environment, or data bag.

The search pattern can include certain regular expressions to form a search query.
This is supported in knife as well as when using search within a recipe.

The goal of search is to find a node that has certain information associated with it.

#### Data bags:

A data bag is a global variable that is stored as JSON data and is accesible from a Chef server. A data bag is indexed for searching and can be loaded by a recipe or accessed during a search.

Example use cases:
* Storing API and APP id information
* Storing users to be added to a system


#### Using Search for dynamic orchestration

Scenario: Discover all nodes with a role of "web" and add them to a load balancer.

web_nodes = search('role', 'role:web')

role = The index we are going to search
role:web = The key:search_pattern


#### Search

knife search node 'platform_family:rhel'
knife search node 'recipes:apache\:\:default'
knife search node 'platform:centos or platform:debian'

Regular Expressions in search:

```
knife search node 'platform*:ubuntu'
knife search node 'platfor?:centos'
knife search 'network_interfaces_addresses:*'
```

The * replaces zero or more characters with a wildcard
The ? replaces a single character with a wildcard


#### Search flags

\-i  will show the node ID
\-a attribute_name will display the specified attribute from the search query results
\-r will show the run_lists for the query results

knife search '*:*' -r

will yield the same results as

knife search '*:*' -a run_list



#### Hands on

```
knife search node 'platform_family:rhel'
1 items found

Node Name:   chefnode
Environment: _default
FQDN:        localhost
IP:          192.168.122.37
Run List:    recipe[apache], recipe[apache::websites], recipe[apache::motd]
Roles:       
Recipes:     apache, apache::default, apache::websites, apache::motd
Platform:    centos 7.3.1611
Tags:        
```

```
knife search node 'recipes:apache'
1 items found

Node Name:   chefnode
Environment: _default
FQDN:        localhost
IP:          192.168.122.37
Run List:    recipe[apache], recipe[apache::websites], recipe[apache::motd]
Roles:       
Recipes:     apache, apache::default, apache::websites, apache::motd
Platform:    centos 7.3.1611
Tags:        
```


```
knife search node 'recipes:apache\:\:motd'
1 items found

Node Name:   chefnode
Environment: _default
FQDN:        localhost
IP:          192.168.122.37
Run List:    recipe[apache], recipe[apache::websites], recipe[apache::motd]
Roles:       
Recipes:     apache, apache::default, apache::websites, apache::motd
Platform:    centos 7.3.1611
Tags:        
```


```
knife search node 'platform:centos' -a hostname
1 items found

chefnode:
  hostname: chefnode
```


Search all the nodes in the system

`knife search '*:*'`


Return all of the ip addresses of the nodes in the system

`knife search '*:*' -a ipaddress`

Keep in mind that so far we haven't querying directly any node in the system, but only querying information stored in the Chef server
