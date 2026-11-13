/* Dùng cùng dữ liệu sản phẩm cho thẻ hàng, xem nhanh và trang chi tiết. */
(() => {
 const products=window.VeggieCatalog?.products;
 if(!products)return;
 const money=n=>Number(n).toLocaleString('vi-VN')+'₫';
 window.VeggieProductUI = {
  resolve(trigger) {
   const id=Number(trigger.closest('[data-product-id]')?.dataset.productId);
   return products.find(p=>p.id===id);
  },
  afterModalClosed(callback) {
   const active=document.querySelector('.modal.show');
   if(!active){callback();return;}
   active.addEventListener('hidden.bs.modal',callback,{once:true});
   bootstrap.Modal.getInstance(active)?.hide();
  },
  showModal(id) {
   const modal=document.getElementById(id);
   if(modal)this.afterModalClosed(()=>bootstrap.Modal.getOrCreateInstance(modal).show());
  }
 };
 function price(node,p){if(!node)return;const span=document.createElement('span');span.textContent=money(p.price)+' / '+p.unit;node.replaceChildren(span);}
 document.querySelectorAll('.ltn__product-item').forEach(card=>{
  const image=card.querySelector('.product-img img');
  const id=Number(card.dataset.productId||image?.getAttribute('src')?.match(/product\/(\d+)\.png/)?.[1]);
  const p=products.find(p=>p.id===id);if(!p)return;
  card.dataset.productId=p.id;
  if(image){image.src=p.image;image.alt=p.name;}
  card.querySelectorAll('.product-title a').forEach(a=>{a.textContent=p.name;a.href='product-details.html?id='+p.id});
  card.querySelectorAll('.product-img>a').forEach(a=>a.href='product-details.html?id='+p.id);
  price(card.querySelector('.product-price'),p);
 });
 const detail=document.querySelector('.ltn__shop-details-inner');
 if(detail){
  const id=Number(new URL(location.href).searchParams.get('id')||1);
  const p=products.find(p=>p.id===id);
  if(p){
   detail.dataset.productId=p.id;document.title=p.name+' | Veggie';
   const info=detail.querySelector('.shop-details-info');const title=info?.querySelector('h3,h2');if(title)title.textContent=p.name;
   price(info?.querySelector('.product-price'),p);
   const category = window.VeggieCatalog.categories.find(c => c.id === p.category);
   const metadata = info?.querySelector('.modal-product-meta ul');
   if (metadata) {
    metadata.replaceChildren();
    const entry = document.createElement('li');
    const label = document.createElement('strong');
    label.textContent = 'Danh mục: ';
    const link = document.createElement('a');
    link.href = 'shop.html?category=' + encodeURIComponent(p.category);
    link.textContent = category?.name || p.category;
    entry.append(label, link);
    const inventory = document.createElement('li');
    inventory.textContent = p.stock > 0 ? `Còn hàng: ${p.stock} ${p.unit}` : 'Tạm hết hàng';
    metadata.append(entry, inventory);
   }
   const rating = info?.querySelector('.product-ratting');
   if (rating) {
    const link = document.createElement('a');
    link.href = '#liton_tab_details_1_2';
    link.textContent = p.rating > 0 ? `★ ${Number(p.rating).toFixed(1)}/5 · Xem đánh giá` : 'Chưa có đánh giá';
    link.addEventListener('click', () => document.querySelector('a[data-bs-toggle="tab"][href="#liton_tab_details_1_2"]')?.click());
    rating.replaceChildren(link);
   }
   detail.querySelectorAll('.ltn__shop-details-img-gallery img').forEach(img=>{img.src=p.image;img.alt=p.name});
   detail.querySelectorAll('.ltn__shop-details-img-gallery a').forEach(a=>a.href=p.image);
   for(const selector of ['.ltn__shop-details-large-img','.ltn__shop-details-small-img']){
    const gallery=detail.querySelector(selector);if(gallery)Array.from(gallery.children).slice(1).forEach(node=>node.remove());
   }
   const description=document.querySelector('.ltn__shop-details-tab-content-inner p');if(description)description.textContent=p.description;
  }
 }
 document.addEventListener('click',event=>{
  const trigger=event.target.closest('[data-bs-target="#quick_view_modal"]');
  const card=trigger?.closest('.ltn__product-item');if(!card)return;
  const p=products.find(p=>p.id===Number(card.dataset.productId));if(!p)return;
  const modal=document.getElementById('quick_view_modal');if(!modal)return;
  modal.dataset.productId=p.id;
  const title=modal.querySelector('.modal-product-info h3,.modal-product-info h2');if(title)title.textContent=p.name;
  const img=modal.querySelector('.modal-product-img img');if(img){img.src=p.image;img.alt=p.name;}
  price(modal.querySelector('.product-price'),p);
  const categories=modal.querySelector('.modal-product-meta ul');
  if(categories){
   const category=window.VeggieCatalog.categories.find(c=>c.id===p.category);
   categories.replaceChildren();
   const item=document.createElement('li');item.textContent='Danh mục: ';
   const link=document.createElement('a');link.href='shop.html?category='+encodeURIComponent(p.category);link.textContent=category?.name||p.category;
   item.append(link);categories.append(item);
  }
  const rating=modal.querySelector('.product-ratting');
  if(rating)rating.textContent=p.rating>0 ? '★ '+Number(p.rating).toFixed(1)+'/5' : 'Chưa có đánh giá';
  modal.querySelectorAll('a[href^="product-details.html"]').forEach(a=>a.href='product-details.html?id='+p.id);
 },true);
})();
