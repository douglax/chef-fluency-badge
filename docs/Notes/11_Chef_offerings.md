## Chef Offerings

### Open source vs Premium

What's Open Source?

Refers to something people can modify and share
* OSS means anyone can inspect, modify and enhance the code
* The legal terms of OSS licenses differ dramatically from proprietary software
  * For example: MIT license is very permissive regarding change and redistribution

All internet user benefit from open Source

The world is full of "source code"
* Blueprints
* Rules

Applying open source principle imply a willingnes to share, collaborate transparently, embracing failure as a means of improving, and encouraging other to do the same.

How does open source apply to Chef?

Chef's core product offerings are open source:
* Chef
* Habitat
* Inspec

Each core product has built a strong, open community
* You can browse recipes and compliance profiles for free in the Chef Supermarket
* You can browse Habitat plans for free in the package registry
* You can find and connect with community members:
  * Forum / Mailing List
  * Chat (IRC + Slack)
* Product suggestions come from the community

Chef's proprietary offering is built on top of this foundation

#### Chef's Premium Offerings

Chef Automate provides a centralized hub of information to unite your Dev and Ops  team

Chef Support Subscriptions
* Standard (standard office hours mon-fri)
* Premium (24/7)
* Customer Success

Chef Solution Services

Chef Training & Certifications

### Habitat

Habitat exist to solve the problem of how organizations build, deploy and manage applications.

"What if we simply focused in on what it means to be easy to build, easy to manage, and easy to deploy?"

The answer: Application Automation
* Automation can't come from the platform, but must travel with the application
* Runtime & Infrastructure layers: decoupled


#### Habitat Benefits

You can take an application, wrap it in a layer of application Automation

The resulting package can be deployed on the infrastructure or runtime that suits it best

You can manage it the same way it exists on premise, on top of a  PaaS, or even in a container orchestration system
* This is accomplished because of two main components:
  * a robust, safe, simple, and secure software packaging system
  * a supervisor which manages the lifecycle of the services declared in the packages


#### How do I use Habitat?

You can start with the _hab_ command line interface to scaffold a new project

You define a _plan.sh_ with instructions to build and install the application


### Chef Compliance and Inspec

#### COmpliance as Code

Chef Compliance is a standalone server that allows you to scan nodes to see if they match your compliance requirements

Just like how recipes are "infrastructure as code" compliance profiles are "compliance as code"

"Compliance as code" increases your:
* velocity
* consistency
* scale
* feedback

DevOps principles now extend yo your compliance and security teams

#### Benefits of Chef Compliance

Chef Compliance is agentless
* No software needs to be preinstalled (not even Chef) for compliance scans to occur
* Scans on a Windows operating system communicate over WinRM
* Scans on a Linux operating system communicate over SSH

Chef Compliance provides some standard compliance profiles to start with

Chef Compliance allows you to be proactive by providing compliance reports from your Scans

Compliance profiles are expressed in Domain-specific-language (DSL) called Inspec, which is designed to be human-readable
* Auditors didn't want to write bash commands to express their tests
* The DSL was heavily influenced by ServerSpec

#### Inspec

By writing compliance profiles in InSpec, you can easily integrate automated tests that check for adherence to policy into any stage of your deployment pipeline

```
control'sshd-21'
  title 'Set SSH Protocol to 2'
  desc 'A detailed description'
  impact 1.0 #this is critical
  ref 'compliance guide, section 2.1'

  describe sshd_config do
   its ('Protocol') {should cmp 2}
  end
end
```

#### Using Inspec

Inspec is included in the ChefDK

You can start using it with the _inspec_ command line interface

Common InSpec commands:
* inspec init TEMPLATE  -> Scaffolds a new project
* inspec check PATH  -> Verify all tests at the specified PATH
* inspec exec PATHS  -> run all test files at the specified PATH
* inspec shell  -> open an interactive debugging shell

Remote scan example:
`inspec exec my_compliance_profile.rb -t ssh://bob@host.node -i bob.rsa`


#### Getting Started with Chef compliance and InSpec

You can download Chef Compliance separately from Chef, however, Chef Compliance is being moved into Chef Automate, be sure to try it there

For local development, consider writing InSpec compliance profiles in your cookbooks and running them with Test Kitchen


### Chef Automate: overview

#### Chef Automate

Chef Automate provides a centralized hub of informatino to unite your Dev and Ops teams

Chef Automate provides "Visibility" into the health and compliance of their system.

Chef Automate enforces a "workflow" for code to build and ship to production with the necessary controls for audit and compliance

#### How does Chef Automate workf?

You still develop locally on your Chef workstation with the ChefDK

You will configure _knife_ to point to your Chef Automate instance
* Be sure to _knife bootstrap_ your nodes to the Chef Automate instance
* Be sure to _knife cookbook upload_ or _berks upload_ your cookbooks
* Runners need to be installed for your Workflows to execute

With these elements in place, Chef Automate relies on:
* Chef cookbooks
* Habitat plans
* InSpec compliance profiles

Your development workflow will be familiar if you have used Chef Server

#### Getting Started with Chef Automate

Host in the cloud with AWS OpsWorks for Chef Automate
* AWS will spin up a working Chef Automate instance within 20 minutes
* You can immediatly begin to attach nodes with _knife bootstrap_
* AWS also provides a StarterKit that already preconfigures _knife_ to manage your instance
  * A _userdata.sh_ is provided if you want to launch new EC2 instances that automatically bootstrap
  * You can automatically attach nodes with the provided StarterKit _userdata.sh_ file for EC2

You can also host Chef Automate on AWS with one of Chef's CloudFormation templates

You can also host on premise by installing a binary from
http://downloads.chef.io/automate



### Chef Automate: workflow


Chef Automate provides a workflow for managing changes:
* through the pipeline from a local workstation
* through automated tests
* out to production

Chef Automate handles many types of systems:
* Upload cookbooks to Chef Server
* Publish cookbooks to Chef Supermarket
* Release code or artifacts to GitHub
* Push artifacts to production in real time

#### Pipeline Stages: Verify

The purpose of the Verify stage is to run checks before human code review

Chef Automate allows users to review "patchsets" from the user interface
* You can also integrate Chef Automate with existing (e.g.: Github, Bitbucket)
* Changes are submitted with the _delivery review_ command
  * This triggers the Verify stage
* Changes are approved by clicking the "Approve" button


#### Pipeline Stages: build

Clicking the "Approve" button from the Verify stage triggers the Build stage

The Build stage re-runs the same phases as the Verify stage
* Upon success, quality and security phases are run

The publish phase is the final phase in the Build stage
* Build artifacts can be delivered to an artifact repository such as:
  * Chef server
  * Chef Supermarket
  * JFrog Artifactory

#### Pipeline Stages: Aceptance

The Acceptance stage is the first stage to assess build artifacts
* The build artifacts were generated and published in the previous stage

This is the stage where your team decides wheter the change should be delivered through the pipeline out to its final destination

Infrastructure is provisioned and the build artifacts are deployed
* The deployment is verified with:
  * Automated smoke tests
  * Functional tests
  * Ad-Hoc tests
  * Manual User Acceptance tests

#### Pipeline Stages: Union

The Union stage is the first of the three shared delivery pipeline Stages
* This means that the environments are running artifacts with multiple projects
* Each previous stage ran isolation

The purpose of the Union stage is to test the artifacts in context of the system as a whole
* You are able to test for interactions between interdependent projects
* The phases of this stage include: Provision, Deploy, Smoke, Functional


Any project that depends on an artifact in Union must prove compatibility
* Any broken dependencies must be resolved before continuing
* If there is a problem, cooperating teams need to discuss the right fix
* Sometimes a fix may require a change on a different project than the broken project
* Chef Automate is fundamentally a "roll-forward" system, you won't be able to roll-back


#### Pipeline Stages: Rehearsal

Rehearsal increases confidence in the artifacts and the deployment
* Rehearsal repeats the exact same phases as Union, but in different environment
* Similarly to Union, this environment is meant to bring interdependent projects together

If a failure occurs in union, Rehearsal plays a different and critical purpose
* You will have confidence that your latest fix:
  * Specifically addresses the failure that was exposed in Union
  * Works in a clean environment that never saw the failure

The rehearsal stage is an opportunity to test the change in an environment that didn't see failure as it goes through the Provision, Deploy, Smoke and Functional phases

#### Pipeline Stages: Delivered

Delivered is the final stage of the pipeline

The delivered stage runs through the same phases as Union and Rehearsal:
* Provision
* Deploy
* Smoke
* Functional

You are responsible for what "delivered" means for your system
* This could mean that a change is deployed to receive production traffic
* This could mean publishing a final set of artifacts for your customers
