## Infrastructure as Code


#### Benefits of IaC

Lowers cost by: reducing the human time required to provision and manage infrastructur

Improves speed of:  provisioning (the machine can run the steps faster than a human can type)

Improves:  Stability and Security

#### Where does Chef fit in?

Chef provides a: Domain Specific Language (DSL) for specifying IaC and the automation to deploy, configure, and manage servers based on that code

Utilizes a declarative approach:  allowing the specification of what the final configuration should be and not the steps neccesary to make it happen

Chef is divided:  multiple parts: Chef DK, Chef Server, and Chef Client


## Desired State Configuration

Specifiy a server configuraiton's end result, not the steps to get there

"Test and repair" approach allows Chef to only make changes necessary to get a server back to the desired state configuration

If a server already has the desired configuration, no changes occur


### Imperative vs Declarative

Imperative: 

```
yum install nginx

systemctl start nginx
systemctl enable nginx
```

Declarative:

```
package "nginx"

service "nginx" do
    action [:enable, :start]
end

