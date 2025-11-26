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

## Build and push an image from a Dockerfile

1. Run the following az acr build command, which builds the image and, after the image is successfully built, pushes it
   to your registry. a
    ```shell
    az acr build --image sample/hello-world:v1  \
    --registry myContainerRegistry \
    --file Dockerfile .
    ```
2. Run the following command to list the repositories in your registry.
    ```shell
    az acr repository list --name myContainerRegistry --output table
    ```
3. Run the following command to list the tags on the sample/hello-world repository.
    ```shell
    az acr repository show-tags --name myContainerRegistry \
    --repository sample/hello-world --output table
    ```

___

## Run the image in the ACR

Run the `sample/hello-world:v1` container image from your container registry with the az acr run command.
The following example uses `$Registry` to specify the registry where you run the command.
Replace `myContainerRegistry` with the name you
used earlier.

```shell
az acr run --registry myContainerRegistry \
    --cmd '$Registry/sample/hello-world:v1' /dev/null
```

The `cmd` parameter in this example runs the container in its default configuration, but `cmd` supports other docker run
parameters or even other docker commands.


> Once you finished delete resource group in https://portal.azure.com

## Troubleshooting

Maybe you'll need to run this

```shell
az provider register --namespace Microsoft.ContainerRegistry
```

You can check the registration process using:

```shell
az provider show -n Microsoft.ContainerRegistry
```