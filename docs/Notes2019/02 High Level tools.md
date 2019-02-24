## High Level Tools


### Chef Server

ssh into host

download Chef server

curl -O link_to_chef_server

rpm -Uvh chef.rpm

chef-server-ctl reconfigure    

(takes some time)


See what's actually running 

chef-server-ctl service-list

Everything with a star * is running

* Create first user

chef-server-ctl user-create username firstname lastname email 'p@ssw0rd' --filename /home/user/username.pem

* Create organization

chef-server-ctl org-create orgname 'Extended Organization Name' --association_user username --filename  /home/user/org-validator.pem

** Organization must start with lowercase

* Install chef manage

chef-server-ctl install chef-manage

chef-server-ctl reconfigure

chef-manage-ctl reconfigure

### ChefDK

Download rpm and install it

Verify version

chef --version

Sometimes your local version of Ruby may cause conflict with Chef, so you may try your own Chef environment

chef shell-init bash

eval "$(chef shell-init bash)"

To set this permanently when ever the system starts

echo 'eval "$(chef shell-init bash)"' >> ~/.bash_profile


### Chef repo

Is the part where we store all of the policies we create when we're working with chef

To list the options:

chef generate --help

Create first (generated) repo

chef generate repo generated-chef-repo

cd generated-chef-repo

### chef knife

knife is the utility we use to interact with the chef server most of the time

knife configure


Put client key in /home/user/.chef/user.pem

scp user@remotehost:/<path_to_key>/user.pem  ~/.chef/user.pem

* Credentials file

~/.chef/credentials

Contains basic connection information to interact with Chef server

Test config

knife node list

Gets an error due to self-signed certificate

knife ssl fetch


###Boostraping a node with knife and chef-client

knife bootstrap --help

From chep-repo dir

knife bootstrap user@host -N nodename -x user -P 'p@ssw0rd' --sudo

knife node list

#### what happens during chef-client execution

1. Get configuration data - Read information from client.rb file and Ohai attributes.
2. Authenticate w/ Chef server - Utilizes RSA key & node name to authenticate with Chef server. Will generate a new RSA key if this is the first connection.
3. Get/rebuild the node object - Pull node object from Chef server if this isn’t the first chef-client run. After the pull, the node object is rebuilt based on the node’s current state.
4. Expand the run-list - Compiles the list of roles and recipes to be applied.
5. Synchronize cookbooks - Request and download all of the files from cookbooks on the Chef server that are necessary to converge the run list and are different from the files already existing on the node.
6. Reset node attributes - Rebuild the attributes on the node object.
7. Compile the resource collection - Load the necessary Ruby code to converge the run-list.
8. Converge the node - Execute the run-list.
9. Update the node object, process exception & report handlers - Update the node object on the Chef server after the chef-client run finishes successfully. Also executing the exception and report handlers in the proper order.
10. Stop, wait for the next run - The chef-client waits until the next time it is executed


### SuperMarket

Public supermarket.chef.io

Store and publish cookbooks

You can have your own supermarket, in your own internal company

Berkshelf - Dependency manager
Stove - used to version and publish cookbooks to a supermarket (either public or private).

Berkshelf file determines what supermarket to use

### Test kitchen

Used to write test for automation

### Troubleshooting network issues

add -VV to any knife command for extended verbose output

* Check that FQDN and IP address match for cloud servers

whatsmydns.net

modify /etc/hosts to match hosts and private ip addr













