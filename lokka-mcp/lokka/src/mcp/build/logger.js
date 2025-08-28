import { appendFileSync } from "fs";
import { join } from "path";
const LOG_FILE = join(import.meta.dirname, "mcp-server.log");
function formatMessage(level, message, data) {
    const timestamp = new Date().toISOString();
    const dataStr = data
        ? `\n${JSON.stringify(data, null, 2)}`
        : "";
    return `[${timestamp}] [${level}] ${message}${dataStr}\n`;
}
export const logger = {
    info(message, data) {
        const logMessage = formatMessage("INFO", message, data);
        appendFileSync(LOG_FILE, logMessage);
    },
    error(message, error) {
        const logMessage = formatMessage("ERROR", message, error);
        appendFileSync(LOG_FILE, logMessage);
    },
    // debug(message: string, data?: unknown) {
    //   const logMessage = formatMessage(
    //     "DEBUG",
    //     message,
    //     data,
    //   );
    //   appendFileSync(LOG_FILE, logMessage);
    // },
};
