const http = require('http');
const startPort = parseInt(process.env.PORT || '6000', 10) || 6000;

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
    <p>Vite dev server (if running) is at its own port; this server attempts to listen starting at ${startPort}.</p>
  </body>
</html>`;

const makeServer = () =>
  http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(html);
  });

const tryListen = (portToTry, maxTries = 10) => {
  const srv = makeServer();
  srv.on('error', (err) => {
    if (err && err.code === 'EADDRINUSE' && maxTries > 0) {
      tryListen(portToTry + 1, maxTries - 1);
    } else {
      console.error('Server failed to start:', err);
      process.exit(1);
    }
  });

  srv.listen(portToTry, () => {
    console.log(`Simple server running: http://localhost:${portToTry}/`);
  });
};

tryListen(startPort);
