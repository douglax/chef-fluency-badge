### Imperative vs Declarative Approach to Configuration Management

Imperative VS Declarative

Chef is considered an Imperative configuration management tool.

Ansible and Puppet are both considered declarative configuration management tools.

But what's the difference between Imperative and Declarative languages?

* Imperative describes "how" you're going to implement the code (in our case, the configuration on a node).
* Declarative describes "the end result" or the "desired result" but does not describe how to implement that result. That is left up to the executor.

**Imperative**

```
if node['platform'] == "debian"
  execute "install apache2" do
    commnad "apt-get install apache2 -y"
  end
end
```

Imperative approach provides more Flexibility


**Declarative**

`package 'apache2'`


With Chef, resources are executed in the order they are listed in the page.

This is considered an Imperative approach because it places resources correctly within a recipe and allows the ability to determine execution order and "how" the configuration is put into place.

### Push vs Pull

Push deployment occurs when the deployment of infrastructure changes are pushed from a central location (server) to the nodes.


Pull deployment is when each node polls/queries a central location for changes and applies those changes locally on the node


**Chef does both!**
Up until this point we've been working with "pull deployments" because chef-client runs in intervals and pulls cookbook changes from the server.


#### Chef Push Jobs

Chef push jobs is a Chef server extension that allows jobs to be executed against a node, without the dependency of a chef-client run.

A separate agent is running on the node listening to the Chef push jobs server for any jobs that might be sent.

A job is an action or command that is to be executed against a set of nodes.

A search query made to the Chef server is what determines "which" nodes receive the push job.


**Knife SSH**

* Requires SSH keys or sudo permissions
* No corrective action if a job fails
* Hard to scale to large amounts of nodes
* Requires scripting if you want to schedule a command

**Push Jobs**

* An installed agent much like chef-client is listening to the chef server and requires no additional authentication
* Is a resource type that is managed with knife and recipes
* Can be used within recipes to orchestrate actions between nodes


### Windows describe

This part covers Windows Desired State Configuration


Windows DSC is a PowerShell task-based command-line shell and scripting language that was developed by Microsoft.

DSC (Desired State Configuration) is a PowerShell feature which provides a set of language extensions, cmdlets and resources for Windows nodes.

Essentially, it's a tool for configuration management on Windows machines using PowerShell. The DSC is exposed as configuration data from within the Windows PowerShell but Chef uses Ruby.

The _dsc_resource_ type allows the DSC to be used in Chef recipes along with any custom resources that have been added to the PowerShell environment.


### Removing Resources from a Recipe

Chef recipes are used to describe a desired state of configuration. If a resource type is removed from within a recipe, then the resource it manages is no longer evaluated by the chef-client during a chef-client run.

The underlying resource will be very simply stay in the state of the last chef-client run (unless it's changed manually).
