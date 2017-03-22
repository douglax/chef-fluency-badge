## Recipes and Cookbooks

### Recipes

Recipes are a collection of resources, defined and written using patterns. Helper code such as loops and if statements, can be written around those resources to help customize the configurations of specific nodes. For example, _if_ or _case_ statements around packages names.

Very simple, Chef defines a recipe as the most fundamental configuration element within the organization.

A recipe:
* Is created using Ruby
* Is a collectionof resources defined using patterns; helper code is added using Ruby
* Must define everything that is required to configure part of a system
* Must be stored in a cookbook
* May be included in a recipe (include_recipe)
* May use the results of a search query and read the contents of a data bag
* May have a dependency on one (or more) recipes
* May tag a node to facilitate the creation of arbitrary groupings
* Must be added to a run-list before it can be used by the chef-client
* Is always executed in the same order as listed in a run-list
* If included multiple times in a run-list, will only be executed once

### Chef resource ordering execution

Resources are executed in the order that they are listed/created within a recipe, starting with the first recipe in a run-list.

There are "directives" that can change the order in which resources are executed

* **notifies**: A notification property that allows a resource to notify another resource to take action when its state changes.

* **suscribes**: A notification propertythat allows a resource to listen to another resource and then take action if the state of the resource being listened to changes.

```
service "httpd" do
end

cookbook_file "/etc/httpd/conf/httpd.conf" do
  owner 'root'
  group 'root'
  mode '0644'
  source 'httpd.conf'
  notifies :restart, "service[http]"
end
```

The following code does pretty much the same, but it uses suscribes in the service block

```
service "httpd" do
  suscribes :reload, "cookbook_file[ "/etc/httpd/conf/httpd.conf]"
end

cookbook_file "/etc/httpd/conf/httpd.conf" do
  owner 'root'
  group 'root'
  mode '0644'
  source 'httpd.conf'
end
```

In later example, service httpd is "listening" for a change of configuration in httpd.conf file.


### A Brief look at run-list
A run-listis a list of cookbooks/recipes that are to be executed on the given node.

Example:
`run_list "recipe[base]","recipe[apache]","recipe[selinux_policy]"`

chef-client will execute the base recipe followed by apache, selinux_policy

`run_list "recipe[base::recipe]","recipe[apache::recipe]","recipe[selinux_policy::recipe]"`

If :: is omitted, then **only** the default recipe will be executed, even though several recipes exist in the cookbook.

Recipes that have a dependency relationship with the invoked ones, will be executed as well.

Note: if for any reason a recipe is assigned to a node more than once (via roles/environments/etc.) chef-client will only execute it **one** time.

### include_recipe

A recipe can include a recipe from an external cookbook

For example, including the mod_php recipe in an already-existing recipe

`include_recipe 'cookbook_name::recipe_name'`

Note: include_recipe 'cookbook_name::recipe_name' will, by default, translate to 'cookbook_name::default' the default recipe.

Important: If a recipe is being included from an external cookbook, then it's important to create a dependency on that cookbook in the metadata.rb


## Cookbooks

A cookbook is the fundamental unit of configuration and policy distribution when using Chef.

Cookbooks contain the following information:
* Recipes
* Attribute files
* File distributions
* Templates
* Any extension to Chef such as libraries and custom resources


A chef cookbook defines a scenario. For example, an Apache cookbook would define everything needed to install and configure Apache.
 Modules and additional Apache configurations required for our application can be broken out into individual recipes within the cookbook.

 ### Cookbooks: README.md

 The cookbook readme file, located inside of cookbooks/cookbookname/README.md is a description of the cookbook's features that is written using Markdown.

 Markdown is text-to-HTML conversion tool for making easy to write structurally valid HTML.

 ### Cookbooks:

 Cookbook metadata is located in cookbooks/cookbookname/metadata.rb. Each cookbook requires certain metadate information.

 Common Metadate settings for Chef Fluency Badge

 * **Chef version**: Allows you to specify which version of Chef the cookbook requires to operate correctly.
 * **dependes**: Allows you to specify if there are any other cookbook dependencies, including the same cookbook but a different version (think back to include_recipe)
 * **version**: Specifies the version of the cookbook. Chef server stores the versions differently, allowing for version control of cookbooks within Chef server.


metadata.rb looks pretty much like this:

```
name 'mycookbook'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'all_rights'
description 'Installs/Configures mycookbook'
long_description 'Installs/Configures mycookbook'
version '0.1.0'
depends 'mysql','>=1.0'
```

### Cookbooks: Default cookbook recipe

The default cookbook recipe is default.rb which is create with the cookbook. The main part of the configuration for the cookbook generally lives here. For example, installing packages and starting services for the cookbook scenario (i.e Apache/MariaDB).

What does the default cookbook mean?

If you were to include a cookbook without a recipe in a run list, then by default it would run cookbookname::default recipe.


** `run_list "recipe[apache]"` **

This is the same as: ** `run_list "recipe[apache:default]"` **

Use the apache cookbook and add the default recipe to the node's run-list. All other recipes in the cookbook, unless include_recipe is used, are ignored.


### Generating a cookbook

Good practicewould be to have a _cookbooks_ directory and have all of them inside

`chef generate cookbook cookbooks/cookbookname`

To run a single recipe in local mode

`chef-client --local-mode cookbooks/cookbookname/recipes/default.rb`

## Cookbooks Pro-tips

### Pro-tip 1: Be familiar with the ChefDK generators

Available generators:
* chef generate app   -> Generate an application repo
* chef generate cookbook  -> Generate a single cookbook
* chef generate recipe  -> Generate a new recipe
* chef generate attribute  -> Generate and attributes file
* chef generate template  -> Generate a file Template
* chef generate file -> Generate a cookbook file   
* chef generate lwrp  -> Generate a light weight recourse/provider
* chef generate repo -> Generate a Chef code repository
* chef generate policyfile  -> Generate a Policyfile for use with install/push commands
* chef generate generator -> copy ChefDK's generator cookbook to customize
* chef generate build-cookbook  -> Generate a build cookbook for _delivery_ commands


chef generate app provides a complete directory structure for cookbooks, tests ,etc.

Berksfile is used to specify which internal or external Supermarkets you're going to use, as well as if there's dependencies with other cookbooks.

chefignore specifies the files to be ignored when cookbooks is going to be uploaded to server

Unit tests are used for an in-memory implementation of Chef server for fast assessment of the cookbook (Chefspec)

### Pro-tip 2: Upload environments from a file

Upload environments into Chef server from a file and store the file in an app repo

An environment is a map of the organization and what can be configured and managed using Chef server

Every organization starts with a single environment called default.json . This environment cannot be modified or deleted

Additional environments can be created to reflect the organization's patterns and workflows.

Examples: Development, testing, staging, production


Often, environments are associated with cookbooks versions

You can manage environments from the chef server, but when you do it from the cookbook you can use knife environment from file and create the environments in the chef server.

```
environments/environment.json:
{
  "name": "example",
  "description": "This is an example environment defined as JSON",
  "chef_type": "environment",
  "json_class": "Chef::Environment",
  "default_attributes": {},
  "override_attributes": {},
  "cookbook_versions": {
    "example": "=1.0.0"
  }
}
```

### Pro-tip 3: Upload roles from a file


```
roles/example.json:
{
  "name": "example",
  "description": "This is an example role defined as JSON",
  "chef_type": "role",
  "json_class": "Chef::Role",
  "default_attributes": {},
  "override_attributes": {},
  "run_list": [
    "recipe[example]"
  ]
}
```


### Pro-tip 4: Manage your dependencies

One way to manage your dependencies is to "vendor" the dependency into your repository:
* `knife cookbook site install httpd` -> copy the httpd cookbook from the Supermarkets
*  `knife cookbook upload httpd` -> Upload the dependency into Chef server
  * You can only upload one cookbook at a time with the _knife cookbook upload_

Another way to manage your dependencies is with Berkshelf
* Berkshelf is included with the ChefDK with the **berks** command.
* You can specify a public or private Supermarket within your _Berskfile_ and declare cookbooks that you depend on
* `berks install`  -> Fetch dependencies from the Supermarket
* `berks upload` -> Upload all dependencies and sub-dependencies to Chef server
  * Supply the **SSL_CERT_FILE** environment variable or pass in the **--no-ssl-verify flag** to configure berks to communicate with Chef server

### Pro-tip 5: Use Wrapper cookbooks

Wrapper cookbooks allow you to modify the behavior of upstream cookbooks without forking or vendoring them


To create a wrapper cookbook
* Generate a wrapper cookbook (e.g.: `chef generate cookbook mycompany-ntp`)
* Add the dependency (i.e: Add `depends 'ntp'` to your metadata.rb or add _cookbook 'ntp'_ to your Berskfile)
* Override attributes:
  * mycompany-ntp/attributes/default.rb:
  * `default['ntp']['peers']=['ntp1.mycompany.com','ntp2.mycompany.com']`
* Include the original cookbook in your recipes
  * mycompany-ntp/recipes/default.rb:
  * `include_recipe 'ntp'`




Vendor a third-party cookbook into your repository
