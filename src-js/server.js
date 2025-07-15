import express from "express";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import { z } from "zod";
const server = new McpServer({
    name: "mcp-streamable-http",
    version: "1.0.0",
});
// Get Chuck Norris joke tool
const getChuckJoke = server.tool("get-chuck-joke", "Get a random Chuck Norris joke", async () => {
    const response = await fetch("https://api.chucknorris.io/jokes/random");
    const data = await response.json();
    return {
        content: [
            {
                type: "text",
                text: data.value,
            },
        ],
    };
});
// Get Chuck Norris joke by category tool
const getChuckJokeByCategory = server.tool("get-chuck-joke-by-category", "Get a random Chuck Norris joke by category", {
    category: z.string().describe("Category of the Chuck Norris joke"),
}, async (params) => {
    const response = await fetch(`https://api.chucknorris.io/jokes/random?category=${params.category}`);
    const data = await response.json();
    return {
        content: [
            {
                type: "text",
                text: data.value,
            },
        ],
    };
});
// Get Chuck Norris joke categories tool
const getChuckCategories = server.tool("get-chuck-categories", "Get all available categories for Chuck Norris jokes", async () => {
    const response = await fetch("https://api.chucknorris.io/jokes/categories");
    const data = await response.json();
    return {
        content: [
            {
                type: "text",
                text: data.join(", "),
            },
        ],
    };
});
// Get Dad joke tool
const getDadJoke = server.tool("get-dad-joke", "Get a personalized dad joke based on the user's dad's name", {
    dadName: z.string().describe("Name of the user's dad"),
}, async ({ dadName }) => {
    return {
        content: [
            {
                type: "text",
                text: `Why did ${dadName} bring a ladder to the bar? Because he heard the drinks were on the house!`,
            },
        ],
    };
});
// Addition tool
const additionTool = server.tool("add", "Addition Tool", {
    a: z.number().describe("First number to add"),
    b: z.number().describe("Second number to add"),
}, async ({ a, b }) => {
    return {
        content: [
            {
                type: "text",
                text: `The sum of the numbers is: ${a + b}`,
            },
        ],
    };
});
const app = express();
app.use(express.json());
const transport = new StreamableHTTPServerTransport({
    sessionIdGenerator: undefined, // set to undefined for stateless servers
});
// Setup routes for the server
const setupServer = async () => {
    await server.connect(transport);
};
app.post("/mcp", async (req, res) => {
    console.log("Received MCP request:", req.body);
    try {
        await transport.handleRequest(req, res, req.body);
    }
    catch (error) {
        console.error("Error handling MCP request:", error);
        if (!res.headersSent) {
            res.status(500).json({
                jsonrpc: "2.0",
                error: {
                    code: -32603,
                    message: "Internal server error",
                },
                id: null,
            });
        }
    }
});
app.get("/mcp", async (req, res) => {
    console.log("Received GET MCP request");
    res.writeHead(405).end(JSON.stringify({
        jsonrpc: "2.0",
        error: {
            code: -32000,
            message: "Method not allowed.",
        },
        id: null,
    }));
});
app.delete("/mcp", async (req, res) => {
    console.log("Received DELETE MCP request");
    res.writeHead(405).end(JSON.stringify({
        jsonrpc: "2.0",
        error: {
            code: -32000,
            message: "Method not allowed.",
        },
        id: null,
    }));
});
// Start the server
const PORT = process.env.PORT || 3000;
setupServer()
    .then(() => {
    app.listen(PORT, () => {
        console.log(`MCP Streamable HTTP Server listening on port ${PORT}`);
    });
})
    .catch((error) => {
    console.error("Failed to set up the server:", error);
    process.exit(1);
});
