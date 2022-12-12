# Deploy workflow
Using this configuration rendering of the resources (and environment configuration) happens at the server side.
Also, the workflow and policy resources must exist before the `Application` is created, that is, they need to be applied before
possible using sync waves if you are using ArgoCD.
