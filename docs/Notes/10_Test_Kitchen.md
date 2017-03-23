## Test Kitchen

Your infrastructures deserves tests too

Test Kitchen is a test harness for your "infrastructure as code"

Supports multiple platforms (i.e.: CentOS, Ubuntu, Windows, etc.)

Run your recipes on various cloud providers and hypervisors in isolation

Use already familiar testing frameworks (i.e.: Rspec, Serverspec, etc)

Test Kitchen also knows how to handle dependencies woth cookbooks.

Test Kitchen Encourages Test-Driven Development (TDD)

Test-Driven Development is a software development process.
* Requirements are turned into tests
* Software is only improved to pass tests

RED -> GREEN -> Refactor

Test Kitchen allows you to apply the "red, green, refactor" workflow to your "code as infrastructure"


RED:  

Add a test

Run all tests and see if the new test fails (it will)

GREEN:

Write the code

Run tests

REFACTOR:

Refactor code

Repeat


#### Getting started with Test Kitchen

The **kitchen** command is included in the ChefDK
  * or it can be installed via: gem install test-kitchen


Helpful commands:

* kitchen init  -> Create a boilerplate .kitchen.yml
* kitchen list  -> List all instances
* kitchen create  -> Create one or more instances
* kitchen converge  -> Converge one or more instances
* kitchen verify  -> Verify one or more instances
* kitchen destroy  -> destroy one or more instances
* kitchen test  -> Executes kitchen {destroy, create, converge, verify, destroy} all-in-one
* kitchen login  -> Log in to one instance
* kitchen help  -> provides a list of available kitchen commands


#### understanding .kitchen.yml

```
---
driver:
  name: vagrant

provisioner:
  name: chef_zero
  # You may wish to disable always updating cookbooks in CI or other testing environments.
  # For example:
  #   always_update_cookbooks: <%= !ENV['CI'] %>
  always_update_cookbooks: true

verifier:
  name: inspec
  format: junit
  output: ./inspec_output.xml

platforms:
  - name: centos-7.2

suites:
  - name: default
    run_list:
      - recipe[webserver_test::default]
    verifier:
      inspec_tests:
        - test/smoke/default
    attributes:
```

Driver:
* Responsible for creating a machine that we'll use to test our cookbook
* In this case, we're telling the Kitchen driver to use vagrant to create the instance to test.

Provisioner:
* Responsible for telling Test Kitchen how to run Chef to apply the cookbook to the instance in test

Platforms:
* List of operating systems we want to run our infrastructure code against

Suites:
* Defines what to test from our cookbook


### Test kitchen hands on example

On your workstation make sure that Docker is installed and running

`sudo systemctl start docker`

Install the kitchen docker gem

`chef exec gem install kitchen-docker`

Create a new cookbook

`chef generate cookbook my_cookbook`

Inside of the cookbook directory, modify .kitchen.yml

Change driver from vagrant to docker and just leave the ubuntu-16.04 platforms

The next thing we need to do is to run a converge into the kitchen machine

`kitchen converge`

This will take the cookbook recipes (default, as specified in .kitchen.yml), create a docker container, run chef inside of it using chef_zero, and put the configuration in place. Then it will stay there as a running instance

We can check all of the running container by issuing:

`kitchen list`

```
Instance             Driver  Provisioner  Verifier  Transport  Last Action  Last Error
default-ubuntu-1604  Docker  ChefZero     Inspec    Ssh        Converged    <None>
```

Out of the box, there are a couple of test already defined, so we can verify them by running:

`kitchen verify`

```
-----> Starting Kitchen (v1.15.0)
-----> Setting up <default-ubuntu-1604>...
       Finished setting up <default-ubuntu-1604> (0m0.00s).
-----> Verifying <default-ubuntu-1604>...
       Loaded  

Target:  ssh://kitchen@localhost:32768


  User root
     ✔  should exist
     ↺  This is an example test, replace with your own test.
  Port 80
     ✔  should not be listening
     ↺  This is an example test, replace with your own test.

Test Summary: 2 successful, 0 failures, 2 skipped
       Finished verifying <default-ubuntu-1604> (0m0.29s).
-----> Kitchen is finished. (0m1.57s)
```

Let's now create a new test, modify default_test.rb

Remove the test regarding port 80 and add the following one, this will test that package cowsay should be installed.

```
describe package('cowsay') do
   it { should be_installed }
end
```  

Run a verification on the node to test the new rule, it should fail since cowsay is not installed in the testing instance

`kitchen verify`

```
-----> Starting Kitchen (v1.15.0)
-----> Verifying <default-ubuntu-1604>...
       Loaded  

Target:  ssh://kitchen@localhost:32768


  User root
     ✔  should exist
     ↺  This is an example test, replace with your own test.
  System Package
     ∅  cowsay should be installed
     expected that `System Package cowsay` is installed

Test Summary: 1 successful, 1 failures, 1 skipped
>>>>>> ------Exception-------
>>>>>> Class: Kitchen::ActionFailed
>>>>>> Message: 1 actions failed.
>>>>>>     Verify failed on instance <default-ubuntu-1604>.  Please see .kitchen/logs/default-ubuntu-1604.log for more details
>>>>>> ----------------------
>>>>>> Please see .kitchen/logs/kitchen.log for more details
>>>>>> Also try running `kitchen diagnose --all` for configuration
```

Now, let's write the code to make it succeed. Modify default recipe and add the following code

`package 'cowsay'`


 Now we need to converge and verify, or just run kitchen test to do it in a single command

 `kitchen test`

 ```
 Target:  ssh://kitchen@localhost:32769


  User root
     ✔  should exist
     ↺  This is an example test, replace with your own test.
  System Package
     ✔  cowsay should be installed

Test Summary: 2 successful, 0 failures, 1 skipped
       Finished verifying <default-ubuntu-1604> (0m0.38s).
-----> Destroying <default-ubuntu-1604>...
       UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
       root                17877               17861               0                   10:34               ?                   00:00:00            /usr/sbin/sshd -D -o UseDNS=no -o UsePAM=no -o PasswordAuthentication=yes -o UsePrivilegeSeparation=no -o PidFile=/tmp/sshd.pid
       root                17951               17877               0                   10:34               ?                   00:00:00            sshd: kitchen@pts/0
       root                18709               17877               2                   10:36               ?                   00:00:00            sshd: kitchen@notty
       5d0633b037bb772247516bbd419fa37ac4adfe89e45de7483ae5be82685ffd44
       5d0633b037bb772247516bbd419fa37ac4adfe89e45de7483ae5be82685ffd44
       Finished destroying <default-ubuntu-1604> (0m1.63s).
       Finished testing <default-ubuntu-1604> (2m2.96s).
-----> Kitchen is finished. (2m4.26s)
 ```

 This time it succeeded
