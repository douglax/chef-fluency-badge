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
