# Build and run a container image with Azure Container Registry Tasks

1. Create a resource group for the resources needed for this exercise
    ```shell
    az group create --location eastus --name myResourceGroup
    ```
   See groups by running 
    ```shell
    az group list # az group list -o table
    ```
2. Create a basic container registry
    ```shell
   az acr create --resource-group myResourceGroup \
    --name myContainerRegistry --sku Basic
    ```
   See your container registry containers running 
   ```shell
   az acr list -o table
   ```

### Build and push an image from a Dockerfile


## Troubleshooting

Maybe you'll need to run this

```shell
az provider register --namespace Microsoft.ContainerRegistry
```

You can check the registration process using:
```shell
az provider show -n Microsoft.ContainerRegistry
```