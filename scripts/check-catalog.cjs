const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const crypto=require('node:crypto');
const vm=require('node:vm');
const context={window:{}};
vm.runInNewContext(fs.readFileSync('clients/js/veggie-catalog.js','utf8'),context);
const {products}=context.window.VeggieCatalog;
assert.equal(products.length,181,'Cần đúng 181 mặt hàng');
assert.equal(new Set(products.map(p=>p.id)).size,181,'ID bị trùng');
const normalize=s=>s.normalize('NFC').trim().toLocaleLowerCase('vi');
assert.equal(new Set(products.map(p=>normalize(p.name))).size,181,'Tên mặt hàng bị trùng');
const hashes=new Map();
for(const p of products){
 assert(!/\bcombo\b|–\s*gói\s*\d+/i.test(p.name),'Không dùng combo/quy cách để tăng số lượng: '+p.name);
 const file=path.resolve('clients',p.image);assert(fs.existsSync(file),'Thiếu ảnh '+p.name);
 const hash=crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
 assert(!hashes.has(hash),'Ảnh trùng: '+p.name+' / '+hashes.get(hash));hashes.set(hash,p.name);
}
for(let page=0;page<10;page++)assert.equal(products.slice(page*18,(page+1)*18).length,18);
console.log('PASS: 181 tên/ID/ảnh duy nhất, không combo tăng số lượng, 10 trang đầu đều 18 sản phẩm.');

