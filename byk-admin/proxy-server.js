const http = require('http');
const httpProxy = require('http-proxy');
const { createProxyMiddleware } = require('http-proxy-middleware');

const proxy = httpProxy.createProxyServer({});

const server = http.createServer((req, res) => {
  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  res.setHeader('Access-Control-Allow-Credentials', 'true');

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // Proxy to mock server
  proxy.web(req, res, { 
    target: 'http://localhost:3001',
    changeOrigin: true,
    secure: false
  });
});

server.listen(5001, () => {
  console.log('Proxy server listening on port 5001');
  console.log('Proxying requests to http://localhost:3001 (mock server)');
});