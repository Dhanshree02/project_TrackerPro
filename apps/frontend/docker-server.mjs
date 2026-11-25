import { createServer } from "node:http";
import { request as httpRequest } from "node:http";
import { readFile } from "node:fs/promises";
import { extname, join, normalize } from "node:path";
import { fileURLToPath } from "node:url";
import { gzip } from "node:zlib";
import { promisify } from "node:util";
import handler from "./dist/server/server.js";

const gzipAsync = promisify(gzip);
const clientRoot = fileURLToPath(new URL("./dist/client/", import.meta.url));
const port = Number(process.env.PORT || 80);
const apiTarget = process.env.API_PROXY_TARGET || "http://backend:8080";

const mime = {
  ".js": "text/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".svg": "image/svg+xml",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".webp": "image/webp",
  ".gif": "image/gif",
  ".ico": "image/x-icon",
  ".woff": "font/woff",
  ".woff2": "font/woff2",
  ".json": "application/json",
  ".map": "application/json",
  ".txt": "text/plain; charset=utf-8",
  ".html": "text/html; charset=utf-8",
};

function requestProto(req) {
  const forwarded = String(req.headers["x-forwarded-proto"] || "").split(",")[0].trim().toLowerCase();
  return forwarded === "https" ? "https" : "http";
}

function proxyToApi(req, res, pathAndQuery) {
  const target = new URL(pathAndQuery, apiTarget);
  const headers = { ...req.headers, host: target.host };
  headers["x-forwarded-host"] = req.headers.host || "";
  headers["x-forwarded-proto"] = requestProto(req);
  const upstream = httpRequest(
    target,
    { method: req.method, headers },
    (upstreamRes) => {
      res.writeHead(upstreamRes.statusCode || 502, upstreamRes.headers);
      upstreamRes.pipe(res);
    },
  );
  upstream.on("error", () => {
    if (!res.headersSent) res.writeHead(502, { "content-type": "text/plain; charset=utf-8" });
    res.end("API unavailable");
  });
  req.pipe(upstream);
}

async function sendBytes(req, res, status, headers, body) {
  const type = String(headers["content-type"] || "");
  const compressible = /text\/|javascript|json|svg/.test(type);
  const acceptsGzip = String(req.headers["accept-encoding"] || "").includes("gzip");
  if (compressible && acceptsGzip && body.length > 1024) {
    const zipped = await gzipAsync(body);
    headers["content-encoding"] = "gzip";
    headers["content-length"] = String(zipped.length);
    res.writeHead(status, headers);
    res.end(zipped);
    return;
  }
  headers["content-length"] = String(body.length);
  res.writeHead(status, headers);
  res.end(body);
}

async function serveStatic(req, res, pathname) {
  const rel = normalize(decodeURIComponent(pathname)).replace(/^[/\\]+/, "");
  if (!rel || rel.includes("..")) {
    res.writeHead(400);
    res.end();
    return;
  }
  try {
    const body = await readFile(join(clientRoot, rel));
    await sendBytes(
      req,
      res,
      200,
      {
        "content-type": mime[extname(rel)] || "application/octet-stream",
        "cache-control": pathname.startsWith("/assets/")
          ? "public, max-age=31536000, immutable"
          : "public, max-age=3600",
      },
      body,
    );
  } catch {
    res.writeHead(404);
    res.end();
  }
}

function responseHeaders(response) {
  const headers = {};
  response.headers.forEach((value, key) => {
    if (key.toLowerCase() === "set-cookie") return;
    headers[key] = value;
  });
  const cookies = typeof response.headers.getSetCookie === "function" ? response.headers.getSetCookie() : [];
  if (cookies.length) headers["set-cookie"] = cookies;
  delete headers["content-length"];
  delete headers["content-encoding"];
  return headers;
}

const server = createServer(async (req, res) => {
  try {
    const host = req.headers.host || "localhost";
    const url = new URL(req.url || "/", `${requestProto(req)}://${host}`);
    if (url.pathname.startsWith("/api/") || url.pathname === "/api" || url.pathname.startsWith("/hangfire")) {
      proxyToApi(req, res, url.pathname + url.search);
      return;
    }
    if (url.pathname.startsWith("/assets/") || url.pathname === "/favicon.ico") {
      await serveStatic(req, res, url.pathname);
      return;
    }

    const chunks = [];
    for await (const chunk of req) chunks.push(chunk);
    const body = Buffer.concat(chunks);
    const headers = { ...req.headers };
    delete headers["transfer-encoding"];
    delete headers["content-length"];
    if (body.length) headers["content-length"] = String(body.length);

    const request = new Request(url, {
      method: req.method,
      headers,
      body: req.method === "GET" || req.method === "HEAD" ? undefined : body,
    });
    const response = await handler.fetch(request);
    const payload = Buffer.from(await response.arrayBuffer());
    await sendBytes(req, res, response.status, responseHeaders(response), payload);
  } catch (error) {
    console.error(error);
    if (!res.headersSent) res.writeHead(500, { "content-type": "text/plain; charset=utf-8" });
    res.end("Application failed to render");
  }
});

server.listen(port, "0.0.0.0", () => {
  console.log(`Pulse PMO frontend listening on ${port}`);
});
