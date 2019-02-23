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

* Install chef manage

chef-server-ctl install chef-manage

chef-server-reconfigure

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







