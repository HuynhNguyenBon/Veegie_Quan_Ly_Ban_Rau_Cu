const assert=require('node:assert/strict');
const fs=require('node:fs');
const vm=require('node:vm');
for(const file of fs.readdirSync('clients').filter(f=>f.endsWith('.html'))){
 const html=fs.readFileSync('clients/'+file,'utf8');
 assert(!/Your range|Search your keyword|Brooklyn|login-register\.html/.test(html),file+' còn nội dung sai');
 assert(html.includes('js/veggie-wishlist.js'),file+' thiếu script yêu thích');
 assert(!/<a href="#">\s*Về chúng tôi/.test(html),file+' menu giới thiệu chưa có liên kết');
}
const account=fs.readFileSync('clients/account.html','utf8');
assert(account.includes('Bạn chưa đăng nhập'));assert(!account.includes('liton_tab_1_2'));assert(!account.includes('3.000.000₫'));assert(!account.includes('Hướng dẫn chọn rau củ'));
const contact=fs.readFileSync('clients/contact.html','utf8');assert(contact.includes('openstreetmap.org'));assert(!contact.includes('mb--100'));
const css=fs.readFileSync('clients/css/veggie.css','utf8');assert(css.includes('--ltn__heading-font: Arial'));assert(css.includes('veggie-logo-light.svg'));
const body={},events={},memory=new Map(),added=[];
const document={querySelectorAll:()=>[],querySelector:()=>body,getElementById:()=>null,addEventListener:(name,fn)=>events[name]=fn};
const localStorage={getItem:k=>memory.get(k)||null,setItem:(k,v)=>memory.set(k,v)};
vm.runInNewContext(fs.readFileSync('clients/js/veggie-wishlist.js','utf8'),{document,localStorage,window:{VeggieCart:{add:p=>added.push(p)},VeggieProductUI:{resolve:()=>({id:1,name:"Đào tươi",image:"img/product/1.png",price:65000}),showModal:()=>{}}}});
assert(body.innerHTML.includes('Danh sách yêu thích đang trống'));
const card={querySelector:s=>s==='.product-title'?{textContent:'Đào tươi'}:s==='.product-img img'?{getAttribute:()=> 'img/product/1.png'}:s==='.product-price span'?{textContent:'65.000₫'}:null};
const add={closest:()=>card,dataset:{}};events.click({preventDefault(){},stopImmediatePropagation(){},target:{closest:s=>s.includes('liton_wishlist_modal')?add:null}});
const saved=JSON.parse(memory.get('veggie.html.wishlist.v1'));assert.equal(saved.length,1);assert.equal(saved[0].name,'Đào tươi');assert.equal(saved[0].image,'img/product/1.png');assert.equal(saved[0].price,65000);
events.click({preventDefault(){},target:{closest:s=>s==='[data-wish-cart]'?{dataset:{wishCart:'0'}}:null}});assert.equal(added.length,1);
events.click({preventDefault(){},target:{closest:s=>s==='[data-wish-remove]'?{dataset:{wishRemove:'0'}}:null}});assert(body.innerHTML.includes('Danh sách yêu thích đang trống'));
console.log('PASS: 17 trang, menu giới thiệu, trạng thái chưa đăng nhập, font/logo, bản đồ và thêm/xóa yêu thích đúng sản phẩm.');

