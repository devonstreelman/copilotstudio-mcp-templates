// Shared constants for the Lokka MCP Server
export const LokkaClientId = "a9bac4c3-af0d-4292-9453-9da89e390140";
export const LokkaDefaultTenantId = "common";
export const LokkaDefaultRedirectUri = "http://localhost:3000";
// Default Graph API version based on USE_GRAPH_BETA environment variable
export const getDefaultGraphApiVersion = () => {
    return process.env.USE_GRAPH_BETA !== 'false' ? "beta" : "v1.0";
};
