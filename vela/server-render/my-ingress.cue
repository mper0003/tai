"my-ingress": {
	alias: ""
	annotations: {}
	attributes: {
		appliesToWorkloads: []
		conflictsWith: []
		podDisruptive:   false
		workloadRefPath: ""
	}
	description: "My specific ingress trait definition."
	labels: {}
	type: "trait"
}

template: {
    parameter: {
        domain: string
    }

    outputs: service: {
        apiVersion: "v1"
        kind:       "Service"
        spec: {
            selector:
                app: context.name
            ports: [
                {
                    port:       80
                    targetPort: 80
                },
            ]
        }
    }

    outputs: ingress: {
        apiVersion: "networking.istio.io/v1beta1"
        kind:       "VirtualService"
        metadata:
            name: context.name
        spec: {
        		hosts: [parameter.domain]
        		gateways: [
        			"istio-system/external"
        		]
        		http: [{
        			route: [{
        				destination: host: context.name
        			}],
        			timeout: "30s"
        		}]
        }
    }
}
