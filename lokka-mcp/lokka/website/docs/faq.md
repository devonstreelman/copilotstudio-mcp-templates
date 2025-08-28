---
sidebar_position: 5
title: 👨‍💻 FAQs
---

## Who built this?

Lokka is a personal project by Merill Fernando a Product Manager at Microsoft. To learn more about me and my other projects, visit my website at [merill.net](https://merill.net).

I built this as a proof of concept to demonstrate the capabilities of using LLMs and MCPs for Microsoft 365 administration tasks.

This project is open source and available on [GitHub](https://github.com/merill/lokka).

## What is the difference between Lokka and Copilot?

Copilot is an enterprise grade AI solution from Microsoft and is natively integrated with Microsoft 365 while Lokka is an open source MCP server implementation for Microsoft Graph API.

Lokka is a simple middleware that allows you to use any compatible AI model and client.

This means you can experiment using paid offerings like Claude and Cursor or use open source models like Llama from Meta or Phi from Microsoft Research and run them completely offline on your own hardware.

:::note
Lokka is not a replacement for Copilot and is not affiliated with Microsoft.
:::

## Can I use this in production?

We recommend using Lokka in a test environment for exploration and testing purposes. The aim of this project is to provide a playground to expirement with using LLMs for Microsoft 365 administration tasks.

:::note

Lokka is not a production-ready solution and should not be used in a production environment. It is a proof of concept to demonstrate the capabilities of using LLMs for Microsoft 365 administration tasks.

:::

## Is this a Microsoft product?

No, Lokka is not a Microsoft product and is not affiliated with Microsoft.

## How do I report issues?

If you encounter any issues or have suggestions for improvements, please open an issue on the [GitHub repository](https://github.com/merill/lokka/issues].

## I'm seeing this error message, what should I do?

### TypeError `[ERR_INVALID_ARG_TYPE]`: The "path" argument must be of type string. Received undefined

Make sure you have the the latest version of Node.js installed (v22.10.0 or higher). See [MCP Sever issues](https://github.com/merill/lokka/issues/3) for other tips.
