# Tai Kubernetes playground

```shell
sed '/admin.enabled/a \
  accounts.alice: login \
' scripts/argocd-cm-dev.yaml
```

```shell
sed '/data:/a \
  accounts.alice: login \
' scripts/argocd-cm-dev.yaml
```

```shell
kubectl patch cm argocd-cm --patch-file scripts/patch.yaml -n argocd --dry-run=server --output=yaml
```

kubectl patch cm argocd-cm -p '{"data":{"accounts.alice":"login","accounts.marlene":"login"}}' -n argocd --dry-run=server --output=yaml

## OPA Gatekeeper
### Environment setup
* `k3d cluster create local`
* install OPA Gatekeeper
```shell
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.10.0/deploy/gatekeeper.yaml
```
*
In OPA the `input` keyword is a reserved global variable whose value is the
Kubernetes AdmissionReview object, [refer](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#webhook-request-and-response)
`input.review.object` as per above docs:
>   # object is the new object being admitted.
>   # It is null for DELETE operations.

`input.parameters` refers to the fields declared in the `crd.spec` of the constraint template.

#### Good Gatekeeper resources
1. [Gatekeeper examples, basic and advanced][00]
1. [Amazon intro to gatekeeper][01]

[00]: https://open-policy-agent.github.io/gatekeeper/website/docs/examples/
[01]: https://www.eksworkshop.com/intermediate/310_opa_gatekeeper/intro/
