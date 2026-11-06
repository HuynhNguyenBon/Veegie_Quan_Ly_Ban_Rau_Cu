import { readdir, readFile, stat, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
const root = fileURLToPath(new URL('../', import.meta.url));
const missingAssets = [], missingPages = [];
let pages = 0;
for (const folder of ['clients', 'admin/production']) {
  for (const entry of await readdir(path.join(root, folder))) {
    if (!entry.endsWith('.html')) continue;
    pages++;
    const file = path.join(folder, entry);
    const html = await readFile(path.join(root, file), 'utf8');
    for (const match of html.matchAll(/<(script|link|img|a|source)\b[^>]*?\b(src|href)\s*=\s*["']([^"']+)["']/gi)) {
      const [, tag, , ref] = match;
      if (/^(?:[a-z][a-z\d+.-]*:|#|\/\/)/i.test(ref)) continue;
      const clean = ref.split(/[?#]/)[0];
      if (!clean) continue;
      const target = clean.startsWith('/') ? path.join(root, clean) : path.resolve(root, folder, clean);
      try { await stat(decodeURIComponent(target)); } catch {
        const item = { file: file.replaceAll('\\', '/'), reference: ref };
        (tag.toLowerCase() === 'a' ? missingPages : missingAssets).push(item);
      }
    }
  }
}
await writeFile(path.join(root, 'template-audit.json'), JSON.stringify({ pages, missingAssets, missingPages }, null, 2));
console.log(`${pages} HTML pages checked; ${missingAssets.length} missing assets; ${missingPages.length} missing page links. See template-audit.json.`);
process.exitCode = missingAssets.length ? 1 : 0;
