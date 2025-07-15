from fastapi import FastAPI, Request, HTTPException, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from typing import Dict, List, Optional, Any, Union, Literal
import httpx
import uvicorn
import json
import os
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="MCP Streamable HTTP Server")

# MCP Protocol Models
class ContentItem(BaseModel):
    type: str
    text: str

class ToolResponse(BaseModel):
    content: List[ContentItem]

class ToolDescription(BaseModel):
    name: str
    description: str
    parameters: Dict[str, Any]

class InitializeParams(BaseModel):
    capabilities: Dict[str, Any]
    clientInfo: Dict[str, str]
    protocolVersion: str
    sessionContext: Dict[str, Any]

class ListToolsResult(BaseModel):
    tools: List[ToolDescription]

class InitializeResult(BaseModel):
    protocolVersion: str
    serverInfo: Dict[str, str]
    capabilities: Dict[str, Any]

# In-memory storage for MCP tools
tools = {}

def tool(name: str, description: str, params_schema: Optional[Dict] = None):
    """Decorator to register a tool function"""
    def decorator(func):
        tools[name] = {
            "description": description,
            "params_schema": params_schema or {},
            "function": func
        }
        return func
    return decorator

# MCP Protocol Methods
async def handle_initialize(params: InitializeParams) -> InitializeResult:
    """Handle MCP initialize method"""
    logger.info(f"Initializing MCP server for client: {params.clientInfo}")
    return InitializeResult(
        protocolVersion=params.protocolVersion,
        serverInfo={
            "name": "MCP Python Server",
            "version": "1.0.0"
        },
        capabilities={
            "tool": {"enabled": True},
            "listTools": {"enabled": True},
            "executeTool": {"enabled": True}
        }
    )

async def handle_list_tools() -> ListToolsResult:
    """Return spec‑compliant list of tools."""
    return ListToolsResult(
        tools=[
            ToolDescription(
                name=name,
                description=t["description"],
                parameters={                # <-- MUST be 'parameters'
                    "type": "object",
                    "properties": t["params_schema"],
                    "required": list(t["params_schema"].keys()),
                },
            )
            for name, t in tools.items()
        ]
    )

@tool(
    name="get-chuck-joke",
    description="Get a random Chuck Norris joke"
)
async def get_chuck_joke() -> ToolResponse:
    async with httpx.AsyncClient() as client:
        response = await client.get("https://api.chucknorris.io/jokes/random")
        data = response.json()
        return ToolResponse(
            content=[ContentItem(type="text", text=data["value"])]
        )

@tool(
    name="get-chuck-joke-by-category",
    description="Get a random Chuck Norris joke by category",
    params_schema={"category": {"type": "string", "description": "Category of the Chuck Norris joke"}}
)
async def get_chuck_joke_by_category(category: str) -> ToolResponse:
    async with httpx.AsyncClient() as client:
        response = await client.get(f"https://api.chucknorris.io/jokes/random?category={category}")
        data = response.json()
        return ToolResponse(
            content=[ContentItem(type="text", text=data["value"])]
        )

@tool(
    name="get-chuck-categories",
    description="Get all available categories for Chuck Norris jokes"
)
async def get_chuck_categories() -> ToolResponse:
    async with httpx.AsyncClient() as client:
        response = await client.get("https://api.chucknorris.io/jokes/categories")
        data = response.json()
        return ToolResponse(
            content=[ContentItem(type="text", text=", ".join(data))]
        )

@tool(
    name="get-dad-joke",
    description="Get a personalized dad joke based on the user's dad's name",
    params_schema={"dadName": {"type": "string", "description": "Name of the user's dad"}}
)
async def get_dad_joke(dadName: str) -> ToolResponse:     # <-- camelCase here too
    return ToolResponse(
        content=[ContentItem(
            type="text",
            text=f"Why did {dadName} bring a ladder to the bar? Because he heard the drinks were on the house!"
        )]
    )

@app.post("/mcp")
@app.post("/mcp/")               # also accept trailing slash to stop 307
async def handle_mcp(request: Request):
    raw = await request.body()
    logger.info(f"Received: {raw}")

    try:
        data = await request.json()
    except json.JSONDecodeError:
        return _json_error(-32700, "Parse error: Invalid JSON")

    method = data.get("method")
    if not method:
        return _json_error(-32600, "Invalid Request: 'method' is required", data.get("id"))

    # ---- initialize ---------------------------------------------------
    if method == "initialize":
        try:
            params = InitializeParams(**data.get("params", {}))
            result = await handle_initialize(params)
            return _json_result(result.dict(), data.get("id"))
        except Exception as e:
            logger.exception("initialize failed")
            return _json_error(-32602, f"Invalid params: {e}", data.get("id"))

    # ---- session‑less notification (no response expected) ------------
    if method == "notifications/initialized":
        logger.info("Client sent initialized notification")
        return None

    # ---- list tools ---------------------------------------------------
    if method == "tools/list":
        result = await handle_list_tools()
        return _json_result(result.dict(), data.get("id"))

    # ---- call tool ----------------------------------------------------
    if method == "tools/call":
        params = data.get("params", {})
        tool_name = params.get("name")
        arguments = params.get("arguments", {}) or {}

        if tool_name not in tools:
            return _json_error(-32601, f"Tool not found: {tool_name}", data.get("id"))

        try:
            result = await tools[tool_name]["function"](**arguments)
            return _json_result(result.dict(), data.get("id"))
        except TypeError as e:
            return _json_error(-32602, f"Invalid params: {e}", data.get("id"))
        except Exception as e:
            logger.exception("tool execution failed")
            return _json_error(-32603, f"Internal error: {e}", data.get("id"))

    # ---- fallback -----------------------------------------------------
    return _json_error(-32601, f"Method not found: {method}", data.get("id"))

# --- routes that just reject unsupported verbs ----------------------
@app.get("/mcp", status_code=405)
@app.get("/mcp/", status_code=405)
async def handle_mcp_get():
    return _json_error(-32000, "Method not allowed.", None)

@app.delete("/mcp", status_code=405)
@app.delete("/mcp/", status_code=405)
async def handle_mcp_delete():
    return _json_error(-32000, "Method not allowed.", None)

def _json_result(result, _id):
    return {"jsonrpc": "2.0", "result": result, "id": _id}

def _json_error(code, message, _id=None):
    status_map = {
        -32700: status.HTTP_400_BAD_REQUEST,  # parse error
        -32600: status.HTTP_400_BAD_REQUEST,  # invalid request
        -32601: status.HTTP_404_NOT_FOUND,    # method not found
        -32602: status.HTTP_400_BAD_REQUEST,  # invalid params
        -32603: status.HTTP_500_INTERNAL_SERVER_ERROR,  # internal
    }
    return JSONResponse(
        status_code=status_map.get(code, status.HTTP_500_INTERNAL_SERVER_ERROR),
        content={"jsonrpc": "2.0", "error": {"code": code, "message": message}, "id": _id},
    )

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8000))
    logger.info(f"Starting server on port {port}")
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=port,
        log_level="info",
        reload=True
    )
