---
title: 🧩 Developer guide
sidebar_position: 4
---
import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

Follow this guide if you want to build Lokka from source to contribute to the project.

## Pre-requisites

- Follow the [installation guide](install) to install Node and the [advanced guide](install-advanced) if you wish to create a custom Entra application.
- Clone the Lokka repository from GitHub [https://github.com/merill/lokka](https://github.com/merill/lokka)

## Building the project

- Open a terminal and navigate to the Lokka project directory.
- Change into the folder `\src\mcp\`
- Run the following command to install the dependencies:

  ```bash
  npm install
  ```

- After the dependencies are installed, run the following command to build the project:

  ```bash
  npm run build
  ```
- When the build is complete, you will see a main.js file find the compiled files in the `\src\mcp\build\` folder.

## Configuring the agent
  
<Tabs>
  <TabItem value="claude" label="Claude" default>

- In Claude Desktop, open the settings by clicking on the hamburger icon in the top left corner.
- Select **File** > **Settings** (or press `Ctrl + ,`)
- In the **Developer** tab, click **Edit Config**
- This opens explorer, edit `claude_desktop_config.json` in your favorite text editor.
- Add the following configuration to the file, using the information you in the **Overview** blade of the Entra application you created earlier.

- Note: On Windows the path needs to be escaped with `\\` or use `/` instead of `\`.
  - E.g. `C:\\Users\\<username>\\Documents\\lokka\\src\\mcp\\build\\main.js` or `C:/Users/<username>/Documents/lokka/src/mcp/build/main.js`
- Tip: Right-click on `build\main.js` in VS Code and select `Copy path` to copy the full path.

```json
{
  "mcpServers": {
      "Lokka-Microsoft": {
          "command": "node",
          "args": [
              "<absolute-path-to-main.js>/src/mcp/build/main.js"
          ],
          "env": {
            "TENANT_ID": "<tenant-id>",
            "CLIENT_ID": "<client-id>",
            "CLIENT_SECRET": "<client-secret>"
          }
      }
  }
}
```

- Exit Claude Desktop and restart it.
  - Every time you make changes to the code or configuration, you need to restart Claude desktop for the changes to take effect.
  - Note: In Windows, Claude doesn't exit when you close the window, it runs in the background. You can find it in the system tray. Right-click on the icon and select **Quit** to exit the application completely.

### Testing the agent

#### Testing with Claude Desktop

- Open the Claude Desktop application.
- In the chat window on the bottom right you should see a hammer icon if the configuration is correct.
- Now you can start quering your Microsoft tenant using the Lokka agent tool.
- Some sample queries you can try are:
  - `Get all the users in my tenant`
  - `Show me the details for John Doe`
  - `Change John's department to IT` - Needs User.ReadWrite.All permission to be granted

</TabItem>
<TabItem value="vscode" label="VS Code">

### Pre-requisites

- Install the latest version of [VS Code - Insider](https://code.visualstudio.com/insiders/)
- Install the latest version of [GitHub Copilot in VS Code](https://code.visualstudio.com/docs/copilot/setup)

### VS Code

- In VS Code, open the Command Palette by pressing `Ctrl + Shift +P` (or `Cmd + Shift + P` on Mac).
- Type `MCP` and select `Command (stdio)`
- Select
  - Command: `node`
  - Server ID: `Lokka-Microsoft`
- Where to save configuration: `User Settings`
- This will open the `settings.json` file in VS Code.

- Add the following configuration to the file, using the information you in the **Overview** blade of the Entra application you created earlier.

- Note: On Windows the path needs to be escaped with `\\` or use `/` instead of `\`.
  - E.g. `C:\\Users\\<username>\\Documents\\lokka\\src\\mcp\\build\\main.js` or `C:/Users/<username>/Documents/lokka/src/mcp/build/main.js`
- Tip: Right-click on `build\main.js` in VS Code and select `Copy path` to copy the full path.

```json
"mcp": {
  "servers": {
      "Lokka-Microsoft": {
          "command": "node",
          "args": [
              "<absolute-path-to-main.js>/src/mcp/build/main.js"
          ],
          "env": {
            "TENANT_ID": "<tenant-id>",
            "CLIENT_ID": "<client-id>",
            "CLIENT_SECRET": "<client-secret>"
          }
      }
  }
}
```

- `File` > `Save` to save the file.

### Testing the agent

- Start a new instance of VS Code (File > New Window)
- Open `Copilot Edits` from `View` → `Copilot Edits`
- At the bottom of the Copilot Edits panel (below the chat box)
  - Select `Agent` (if it is showing `Edit`)
  - Select `Claude 3.7 Sonnet` (if it is showing `GPT-40`)

</TabItem>
</Tabs>

#### Testing with MCP Inspector

MCP Inspector is a tool that allows you to test and debug your MCP server directly (without an LLM). It provides a user interface to send requests to the server and view the responses.

See the [MCP Inspector](https://modelcontextprotocol.io/docs/tools/inspector) for more information.

```console
npx @modelcontextprotocol/inspector node path/to/server/main.js args...
```

## Learn about MCP

- [Model Context Protocol Tutorial by Matt Pocock](https://www.aihero.dev/model-context-protocol-tutorial) - This is a great tutorial that explains the Model Context Protocol and how to use it.
- [Model Context Protocol docs](https://modelcontextprotocol.io/introduction) - The official docs for the Model Context Protocol.
- [Model Context Protocol Clients](https://modelcontextprotocol.io/clients) - List of all the clients that support the Model Context Protocol.
