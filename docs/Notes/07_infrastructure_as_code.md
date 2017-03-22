### Infrastructure as Code

Advantages and reasons of defining  your infrastructure as code

* Flexibility
* Version control of infrastructure
* Human-readable infrastructure - the code is the documentation!
* Create testable infrastructures just like testable code!
* Easily scalable to thousands of systems, multiple clouds, and on-premises
* Use existing cookbooks created on Chef Supermarket as well as automate deployments and compliance


#### Rolling back vs Rolling forward

Rolling backward: Roll back the environment or code to a previous state (Restore / Blue-Green)
Con: A roll back musr succeed for **ALL** components in your environment or it fails. Generally a riskier method of fixink issues.


Rolling forward: Rolling forward means, understanding the current issue and implementing a permanent fix applied going forward. In Chef is Generally best practice to roll forward rather than roll backwards.

The time it takes to rolling back a fix (and the risk implied) is actually worst than implementing a fix and rolling the fix forward

Rolling back means taking the whole environment down

In Rolling forward the environment won't necessarily be down, maybe just a component is.

 
