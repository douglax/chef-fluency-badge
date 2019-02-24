## Lower Level Tools

### Cookbooks

A cookbook is a collection of smaller building blocks that make up a useful, shareable piece of configuration.

A cookbook defines a scenario and contains everything that is required to support that scenario.

chef generate cookbook  cookbooks/cb_name

### Recipes

`sudo chef-client --local-mode cookbooks/my_cookbook/recipes/default.rb`

chef-zero is the chef server that runs locally in memory

### Resources

A resource is a statement of configuration policy that:

* Describes the desired state for a configuration item
* Declares the steps needed to bring that item to the desired state
* Specifies a resource type—such as package, template, or service
* Lists additional details (also known as resource properties), as necessary
* Are grouped into recipes, which describe working configurations

```
type 'name' do
   attribute 'value'
   action :type_of_action
end
```

### Nodes

When we speak about a “node” in Chef there are two things that we can be talking about:

    The “node” object that is stored on the Chef Server
    The device (server, virtual machine, router, etc.) managed using chef-client

Inspect a node

`knife node show nodename`

Extended info in json format

`knife node show -F json -l web-node1`

### Run Lists

A run-list defines all of the information necessary for Chef to configure a node into the desired state. A run-list is:

* An ordered list of roles and/or recipes that are run in the exact order defined in the run-list; if a recipe appears more than once in the run-list, the chef-client will not run it twice
* Always specific to the node on which it runs; nodes may have a run-list that is identical to the run-list used by other nodes
* Stored as part of the node object on the Chef server
* Maintained using knife and then uploaded from the workstation to the Chef server, or maintained using Chef Automate


#### Run List format

A run-list must be in one of the following formats: fully qualified, cookbook, or default. Both roles and recipes must be in quotes, for example:

'role[NAME]'

or

'recipe[COOKBOOK::RECIPE]'

Use a comma to separate roles and recipes when adding more than one item the run-list:

'recipe[COOKBOOK::RECIPE],COOKBOOK::RECIPE,role[NAME]'

Setting a Run-List

`knife node run_list add web-node1 'recipe[bcf_nginx::default]'`

SSH to the node to run chef client

`knife ssh 'name:web-node1' 'sudo chef-client' -x user`

We didn’t need to know the IP address or FQDN of the web-node1 because it’s stored in the Chef Server as part of the node object.


### Roles

A role is “a way to define certain patterns and processes that exist across nodes in an organization as belonging to a single job function”. A simple way to think of this is that a role is a repeatable, named run-list that can also define shared attributes

A role is a way for us to specify a run-list and give it a name and potentially give some attributes to that run-list, and we can use this run-list as a repeatable block in our infrastructure


`knife role create rolename`

`knife node run_list add webnode1 'role[base]' --before 'recipe[nginx]'`

### Environments

An environment is a way to map an organization’s real-life workflow to what can be configured and managed when using Chef server. Every organization begins with a single environment called the _default environment, which cannot be modified (or deleted).

`knife environment create staging --description 'Pre-production, staging environment for internal access only.'`

`knife environment list`

`knife node environment_set nodename envname`

### Attributes

Attributes are variable pieces of data that are associated with a node or set when a recipe is run. These attributes can be used to within recipes to change how resources are applied.

An attribute is a specific detail about a node. Attributes are used by the chef-client to understand:

    The current state of the node
    What the state of the node was at the end of the previous chef-client run
    What the state of the node should be at the end of the current chef-client run

Attributes are defined by:

    The state of the node itself
    Cookbooks (in attribute files and/or recipes)
    Roles
    Environments

During every chef-client run, the chef-client builds the attribute list using:

    Data about the node collected by Ohai
    The node object that was saved to the Chef server at the end of the previous chef-client run
    The rebuilt node object from the current chef-client run, after it is updated for changes to cookbooks (attribute files and/or recipes), roles, and/or environments, and updated for any changes to the state of the node itself

After the node object is rebuilt, all of the attributes are compared, and then the node is updated based on attribute precedence. At the end of every chef-client run, the node object that defines the current state of the node is uploaded to the Chef server so that it can be indexed for search.

So how does the chef-client determine which value should be applied? Keep reading to learn more about how attributes work, including more about the types of attributes, where attributes are saved, and how the chef-client chooses which attribute to apply.


### Data Bags and Dependencies

Data bags are pieces of JSON data that are stored in the Chef Server. They're searchable and also available within recipes.

Data bags store global variables as JSON data. Data bags are indexed for searching and can be loaded by a cookbook or accessed during a search.

`knife data bag create users`

`openssl passwd -1 "secure_password"`

`knife data bag from file users data_bags/users/user.json`







