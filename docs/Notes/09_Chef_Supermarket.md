## Chef Supermarket


Chef Supermarket is 100% free, everything uploaded is available to any Chef user to use within any of their environments at no cost.

There is no shopping cart functionality. Supermarketis free.

Chef Supermarket can be run on a machine, on your network, within your own environment, at no additional cost. <- This is called a private Supermarket

All of the public Chef Supermarket can be downloaded in your private Supermarket.

The job of public Chef Supermarket is to host community built cookbooks.


### Using a private Supermarket

A private Supermarket, located behind your firewall, can be installed on a local machine in your environment.

Using Berkshelf multiple Supermarket installations can be specified, for example, a local one, and the public Chef Supermarket. In the event that a cookbook book is not available on one, it pulls from the other.

How can we modify cookbooks from Chef Supermarket without forking??

Cookbook Wrappers!

Chef Supermarket is more than just a cookbook repository!!

Chef Supermarket is a site for uploading and downloading community built (and a lot of Chef built) cookbooks.

Cookbooks available on the Chef Supermarket are available and accessible to all Chef users


* Chef Supermarket can be part of your deployment process. Example: a cookbook can't go into production unless it has been uploaded to a private Supermarket

* Using Berkshelf, cookbooks can be deployed directly from the Chef Supermarket and use multiple installations of Chef Supermarket to help resolve dependency issues.




2:13
