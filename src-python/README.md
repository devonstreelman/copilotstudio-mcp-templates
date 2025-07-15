# MCP Streamable HTTP Server (Python)

A Python implementation of the MCP (Model Context Protocol) Streamable HTTP Server using FastAPI.

## Features

- Implements the same functionality as the JavaScript/TypeScript version
- Built with FastAPI for high performance
- Asynchronous request handling
- Type hints and Pydantic models for better code quality
- Compatible with the MCP protocol

## Installation

1. Make sure you have Python 3.8+ installed
2. Create and activate a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

## Running the Server

```bash
uvicorn main:app --reload --port 3000
```

The server will be available at `http://localhost:3000`

## API Endpoints

- `POST /mcp` - Main MCP endpoint for tool execution
- `GET /` - Health check endpoint

## Available Tools

1. **get-chuck-joke** - Get a random Chuck Norris joke
2. **get-chuck-joke-by-category** - Get a Chuck Norris joke by category
3. **get-chuck-categories** - List all available Chuck Norris joke categories
4. **get-dad-joke** - Get a personalized dad joke
5. **add** - Add two numbers together

## Example Requests

### Get a random Chuck Norris joke
```json
{
  "jsonrpc": "2.0",
  "method": "get-chuck-joke",
  "id": "1"
}
```

### Add two numbers
```json
{
  "jsonrpc": "2.0",
  "method": "add",
  "params": {
    "a": 5,
    "b": 3
  },
  "id": "2"
}
```
