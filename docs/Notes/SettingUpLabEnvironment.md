Launch a CentOS 7 lab machine

Change passwords for both user and root

Install ChefDK

```
wget https://packages.chef.io/files/stable/chefdk/0.18.26/el/7/chefdk-0.18.26-1.el7.x86_64.rpm
sudo rpm -ivh chefdk-0.18.26-1.el7.x86_64.rpm
```

ChefDK version 0.18.26 was installed as per the course material, although newer versions had been released


Verify that ChefDK was installed correctly

`sudo chef-client --local-mode`
