# GitHub Codespaces

Using codespaces with Jetbrains Gateway

1. **Start Codespace SSH Tunnel**: In your local terminal, run the GitHub CLI command to set up an SSH tunnel to your Codespace. The command is typically:
   ```shell
   gh codespace ssh --server-port <local-port>
   ```
   > Replace `<local-port>` with a free port number like _2222_ or _57873_.
2. Open JetBrains Gateway.
3. Choose New Connection under the SSH provider.
4. Configure the connection details:
   * Host: localhost
   * Port: The <local-port> you used in the gh codespace ssh command.
   * Username: Often codespace (but check your specific Codespace configuration).
   * Authentication Type: Use a key pair or password as configured for your GitHub CLI authentication.
5. Click Check Connection and Continue.
6. Select IDE and Connect: Gateway will prompt you to select the specific JetBrains IDE (IntelliJ, PyCharm, etc.) to install as the backend on your Codespace. Once selected, it will download the matching JetBrains Client to your local machine, and your remote IDE session will open.


## Stoping a codespace using GitHub CLI

1. List all your Codespaces:
    ```shell
   gh codespace list
    ```
2. Stop a specific Codespace
    ```shell
    gh codespace stop -c <codespace-name>
    ```
   > Or if you only have one active Codespace, simply: `gh codespace stop`

## Delete a Codespace (optional)
```
gh codespace delete -c <codespace-name>
```
