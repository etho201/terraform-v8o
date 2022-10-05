# terraform-v8o

Deploy Oracle OCNE and Verrazzano with Terraform (and Ansible)

## Getting Started:

### Prerequisites:
- [ ] Podman (or Docker)
- [ ] OCI Cloud Credentials

### Deployment:

1. Build the container with:

    ```bash
    podman build -t terraform-v8o .
    ```

2. Add your OCI credentials to the `variables.tfvars` file. A sample file ([`variables.tfvars.sample`](./terraform.tfvars.sample)) is provided, but you'll need to input all your `OCID`'s into the file and name it `variables.tfvars`.

3. Exec into the container with:

    ```bash
    podman run -v $(pwd):/tmp --workdir /tmp --rm -it terraform-v8o
    ```

4. Use Terraform within the container to provision and deploy your OCNE + Verrazzano environment.

    ```bash
    terraform init
    terraform apply
    ```

## Verify the installation:

### OCNE

1. Once Terraform is complete, SSH into the control-plane instance, and run:

    ```bash
    olcnectl module instances --config-file myenvironment.yaml
    ```

    > The state should be `installed` for all instances/modules.

### Verrazzano

1. Verrazzano takes a while to bring up the various applications. You can run a `kubectl wait` command to be certain that everything is up and running.

    ```
    kubectl wait \
        --timeout=30m \
        --for=condition=InstallComplete verrazzano/example-verrazzano
    ```
    
    > This will run for a while, but once completed, it should return with: `verrazzano.install.verrazzano.io/example-verrazzano condition met`

2. Verrazzano installs multiple objects in multiple namespaces. In the verrazzano-system namespaces, all the pods in the Running state, does not guarantee, but likely indicates that Verrazzano is up and running.

    ```bash
    kubectl get pods -n verrazzano-system
    ```

---

## Access:

1. Follow the guide provided in the Verrazzano documentation to learn how to access the various components.

   - https://verrazzano.io/latest/docs/access/

2. TLDR? You can get a list of endpoints for all the v8o consoles with:

    ```bash
    kubectl get vz -o jsonpath="{.items[].status.instance}" | jq .
    ```

    #### Login credentials:

    Username: `verrazzano`

    Password: *Retrieve the password from the secret*

    ```bash
    kubectl get secret \
    --namespace verrazzano-system verrazzano \
    -o jsonpath={.data.password} | base64 \
    --decode; echo
    ```