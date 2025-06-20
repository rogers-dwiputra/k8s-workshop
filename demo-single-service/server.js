const http = require('http');
const os = require('os');

const server = http.createServer((req, res) => {
  res.writeHead(200);
  res.end(`Hello from pod: ${os.hostname()}\n`);
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}/`);
});
