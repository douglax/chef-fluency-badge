## Chef Server

The Chef server is the central location which acts as an artifact repository or "hub" that stores cookbooks, cookbook versions, facts about the node, data bags and metadata information about nodes.

All metadata of a node, when it is registered with Chef server, is stored on the Chef server.

The metadata is populated and sent to the server with chef-client, which is an application that runs on the node.

Configuration enforcement is not handled by the Chef server, instead, the desired state configuration is enforced when chef-client runs and a "convergence" happens, allowing for easy scalability.

### Installation


* Download Chef server from download.chef.io
`wget path_to_download`

* Install the rpm

  `rpm -ivh chef-server-core.rpm`

* Reconfigure server

  `chef-server-ctl reconfigure`

* Create an user

  `chef-server-ctl user-create alex Alejandro Acosta alxacostaa@gmail.com 'somepasswd' --filename alex_at_linuxacademy`

* Create an organization and associate previously created user as admin

  `chef-server-ctl org-create linuxacademy 'Linux Academy, Inc' --association_user alex --filename linuxacademy-validator.pem`

* Install chef-manage for web GUI tools

  `chef-server-ctl install chef-manage`

* Reconfigure chef manage

  `chef-manage-ctl reconfigure`

### Bootstraping a node

Open browser and go to Chef server URL or IP address
Log in with previously created user

Go to _Administration_ click in the organization we created previously and then _Download Starter kit._

This will reset the .pem file so you have to be caution with this step

After confirming the reset of the file, it will be downloaded to your workstation. Then it will be up to you to copy it to the node.
scp, filezilla , etc.

Add the user to the wheel group

`sudo usermod -a -G wheel user`

Now we need to tell our _workstation_ that it is ok to communicate with our Chef server even though we don't have a CA signed certificate.

`sudo knife ssl fetch`


To Bootstrap our node we're going to do it from the workstation

`knife bootstrap nodeipaddr -N nodename --ssh-user user --sudo`

knife bootstrap 192.168.122.37 -N chefnode --ssh-user alex --sudo

When -N nodename is omitted the default is the node's hostname

--ssh-user can be substituted with -x



### Chef Solo vs Chef Zero vs Chef Server

#### Chef Solo

Chef Solo is an open source version of chief-client

* Chef Solo does not rely on a Chef server for centralized distribution but instead runs off of local cookbooks.
* Chef Solo does not have any type of authentication in order for it to run.
* Chef Solo is run independently on a node
  * For example, if you only have one node to manage.


#### Chef Zero

Chef Zero is a lightweight Chef Server that runs in-memory on the local node.
* Allows chef-client to run against the chef-repo as if it was running against Chef Server.
* Useful for testing and validating the behavior of chef-client against our cookbooks, recipes, and run-lists before uploading those to the Chef Server for usage.

#### Chef Server

Chef server is a central point of management for nodes within an environment.

* Authentication is required for the nodes to communicate with the Chef Server.
* During a convergence the chef-client pulls updated cookbook, recipe, roles, and environment information from Chef Server.
* Chef Server is used for managing many different nodes and different node scenario configurations within an environment.
