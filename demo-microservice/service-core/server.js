const http = require('http');
const os = require('os');

const SERVICE_NAME = process.env.SERVICE_NAME || "Unknown Service";

const server = http.createServer((req, res) => {
  res.writeHead(200);
  res.end(`${SERVICE_NAME} responding from pod: ${os.hostname()}\n`);
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Running ${SERVICE_NAME} on port ${PORT}`);
});
