const http = require('http');
const port = process.env.PORT || 6000;

const html = `<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>Project Compass - Simple Server</title>
    <style>body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial;padding:2rem;background:#fafafa;color:#111}</style>
  </head>
  <body>
    <h1>Project Compass</h1>
    <p>This is a lightweight fallback server to verify the site can load.</p>
    <p>Vite dev server (if running) is at its own port; this server listens on port ${port}.</p>
  </body>
</html>`;

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
  res.end(html);
});

server.listen(port, () => {
  console.log(`Simple server running: http://localhost:${port}/`);
});
