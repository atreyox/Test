// Renders preview screenshots of an exported place (see export_parts.luau).
//   node shoot.mjs <parts.json> <outDir> <view> [<view> ...]
// A view is  name|x,y,z|lookX,lookY,lookZ|fov|extra-query
// Needs: npm install (three) and Playwright with Chromium available.
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
let chromium;
try { ({ chromium } = require('playwright')); }
catch { ({ chromium } = require('/opt/node22/lib/node_modules/playwright')); }

const here = path.dirname(fileURLToPath(import.meta.url));
const [partsPath, outDir, ...views] = process.argv.slice(2);
const threeDir = process.env.THREE_DIR || path.join(here, 'node_modules', 'three');
fs.mkdirSync(outDir, { recursive: true });

const types = { '.js': 'text/javascript', '.html': 'text/html', '.json': 'application/json' };
const server = http.createServer((req, res) => {
  const url = decodeURIComponent(req.url.split('?')[0]);
  let file;
  if (url === '/parts.json') file = partsPath;
  else if (url.startsWith('/three/')) file = path.join(threeDir, url.slice('/three/'.length));
  else file = path.join(here, url === '/' ? 'render.html' : url);
  fs.readFile(file, (err, buf) => {
    if (err) { res.writeHead(404); res.end(); return; }
    res.writeHead(200, { 'content-type': types[path.extname(file)] || 'application/octet-stream' });
    res.end(buf);
  });
});
await new Promise(r => server.listen(0, r));
const port = server.address().port;

const browser = await chromium.launch({
  args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'],
});
for (const v of views) {
  const [name, pos, look, fov = '55', extra = ''] = v.split('|');
  const w = 1600, h = 900;
  const page = await browser.newPage({ viewport: { width: w, height: h } });
  page.on('console', m => { if (m.type() === 'error') console.log('console:', m.text()); });
  page.on('pageerror', e => console.log('pageerror:', e.message));
  const url = `http://localhost:${port}/render.html?pos=${pos}&look=${look}&fov=${fov}&w=${w}&h=${h}&${extra}`;
  await page.goto(url);
  await page.waitForFunction('window.__done === true', null, { timeout: 240000 });
  const file = path.join(outDir, `${name}.png`);
  await page.screenshot({ path: file });
  console.log('wrote', file);
  await page.close();
}
await browser.close();
server.close();
