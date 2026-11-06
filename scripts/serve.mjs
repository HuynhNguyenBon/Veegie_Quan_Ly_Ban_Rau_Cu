import http from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('../', import.meta.url));
const types = { '.html': 'text/html; charset=utf-8', '.css': 'text/css', '.js': 'text/javascript', '.json': 'application/json', '.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.gif': 'image/gif', '.svg': 'image/svg+xml', '.woff': 'font/woff', '.woff2': 'font/woff2', '.ttf': 'font/ttf', '.ico': 'image/x-icon', '.mp4': 'video/mp4' };
const server = http.createServer(async (req, res) => {
  try {
    const url = new URL(req.url, 'http://localhost');
    if (url.pathname === '/') { res.writeHead(302, { Location: '/clients/index.html' }); return res.end(); }
    if (url.pathname === '/admin' || url.pathname === '/admin/') { res.writeHead(302, { Location: '/admin/production/index.html' }); return res.end(); }
    const decoded = decodeURIComponent(url.pathname);
    const segments = decoded.split(/[\\/]/).filter(Boolean);
    if (segments.some(s => s.startsWith('.')) || !['clients', 'admin'].includes(segments[0])) { res.writeHead(404); return res.end('Not found'); }
    let target = path.resolve(root, '.' + decoded);
    if (!target.startsWith(root)) { res.writeHead(403); return res.end('Forbidden'); }
    if ((await stat(target)).isDirectory()) target = path.join(target, 'index.html');
    const body = await readFile(target);
    res.writeHead(200, { 'Content-Type': types[path.extname(target).toLowerCase()] || 'application/octet-stream', 'Cache-Control': 'no-cache' });
    res.end(req.method === 'HEAD' ? undefined : body);
  } catch { res.writeHead(404); res.end('Not found'); }
});
server.on('error', error => { console.error(`Khong mo duoc Veggie: ${error.message}`); process.exitCode = 1; });
server.listen(Number(process.env.PORT || 3000), '127.0.0.1', () => console.log(`Veggie: http://localhost:${server.address().port}\nQuan tri: http://localhost:${server.address().port}/admin/`));
