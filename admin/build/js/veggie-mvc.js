(()=>{
 document.querySelectorAll('[data-preview]').forEach(input=>input.addEventListener('change',()=>{
  let box=input.parentElement.querySelector('.va-photo-preview');if(!box){box=document.createElement('div');box.className='va-photo-preview';input.parentElement.append(box);}box.querySelectorAll('img').forEach(i=>URL.revokeObjectURL(i.src));box.replaceChildren();
  if(input.files.length>6){input.setCustomValidity('Chọn tối đa 6 ảnh.');input.reportValidity();return;}input.setCustomValidity('');for(const file of input.files){const img=document.createElement('img');img.src=URL.createObjectURL(file);img.alt=file.name;img.style='width:70px;height:70px;object-fit:cover;margin:5px';box.append(img);}
 }));
 document.querySelectorAll('table.va-data-table').forEach(table=>{
  const rows=[...table.tBodies[0].rows].filter(r=>!r.classList.contains('va-edit-row'));if(!rows.length)return;
  const tools=document.createElement('div');tools.className='va-table-tools';const search=document.createElement('input');search.placeholder='Tìm trong bảng…';search.setAttribute('aria-label','Tìm trong bảng');search.style.maxWidth='260px';tools.append(search);
  const pager=document.createElement('div');pager.className='va-pager';let page=1;let filtered=rows;const size=document.createElement('select');size.setAttribute('aria-label','Số dòng mỗi trang');size.style.width='100px';for(const n of [10,25,50,100])size.add(new Option(n+' dòng',n));tools.append(size);
  const summary=document.createElement('span');const prev=document.createElement('button'),next=document.createElement('button');prev.type=next.type='button';prev.textContent='Trang trước';next.textContent='Trang sau';pager.append(prev,summary,next);
  const cells=row=>[...row.cells].slice(0,-1).map(c=>c.innerText.replace(/\s+/g,' ').trim());
  function draw(){const count=Number(size.value),pages=Math.max(1,Math.ceil(filtered.length/count));page=Math.min(page,pages);rows.forEach(r=>{r.hidden=true;if(r.nextElementSibling?.classList.contains('va-edit-row'))r.nextElementSibling.hidden=true;});filtered.slice((page-1)*count,page*count).forEach(r=>r.hidden=false);summary.textContent=`Trang ${page}/${pages} · ${filtered.length} kết quả`;prev.disabled=page===1;next.disabled=page===pages;}
  search.oninput=()=>{filtered=rows.filter(r=>r.innerText.toLocaleLowerCase('vi').includes(search.value.toLocaleLowerCase('vi')));page=1;draw();};size.onchange=()=>{page=1;draw();};prev.onclick=()=>{page--;draw();};next.onclick=()=>{page++;draw();};
  function button(text,action){const b=document.createElement('button');b.type='button';b.textContent=text;b.onclick=action;tools.append(b);}
  button('Sao chép',async()=>{try{await navigator.clipboard.writeText(filtered.map(r=>cells(r).join('\t')).join('\n'));summary.textContent='Đã sao chép bảng.';}catch{summary.textContent='Trình duyệt không cho phép sao chép.';}});
  button('Xuất CSV',()=>{const safe=v=>{v=/^[=+@-]/.test(v)?"'"+v:v;return '"'+v.replaceAll('"','""')+'"';};const text=[cells(table.tHead.rows[0]),...filtered.map(cells)].map(r=>r.map(safe).join(',')).join('\r\n');const url=URL.createObjectURL(new Blob(['\ufeff',text],{type:'text/csv;charset=utf-8'}));const a=document.createElement('a');a.href=url;a.download='veggie-danh-sach.csv';a.click();URL.revokeObjectURL(url);});
  button('Xuất Excel',async()=>{if(!window.JSZip)return;const zip=new JSZip(),xml=v=>String(v).replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;').replaceAll('"','&quot;');const data=[cells(table.tHead.rows[0]),...filtered.map(cells)];
   zip.file('[Content_Types].xml','<?xml version="1.0" encoding="UTF-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/></Types>');
   zip.file('_rels/.rels','<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>');
   zip.file('xl/workbook.xml','<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="Veggie" sheetId="1" r:id="rId1"/></sheets></workbook>');
   zip.file('xl/_rels/workbook.xml.rels','<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/></Relationships>');
   zip.file('xl/worksheets/sheet1.xml','<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>'+data.map((row,i)=>'<row r="'+(i+1)+'">'+row.map((v,j)=>'<c r="'+String.fromCharCode(65+j)+(i+1)+'" t="inlineStr"><is><t xml:space="preserve">'+xml(v)+'</t></is></c>').join('')+'</row>').join('')+'</sheetData></worksheet>');
   const url=URL.createObjectURL(zip.generate({type:'blob',mimeType:'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'}));const a=document.createElement('a');a.href=url;a.download='veggie-danh-sach.xlsx';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);
  });
  button('In / lưu PDF',()=>{filtered.forEach(r=>r.hidden=false);window.print();draw();});table.parentElement.insertBefore(tools,table);table.parentElement.append(pager);draw();
 });
})();


(()=>{document.querySelectorAll('.va-dashboard-top .va-panel-title,.va-dashboard-bottom .va-panel-title').forEach(title=>{const controls=document.createElement('span');controls.className='va-panel-controls';const b=document.createElement('button');b.type='button';b.setAttribute('aria-label','Thu gọn '+title.querySelector('h2').textContent);b.setAttribute('aria-expanded','true');b.innerHTML='<i class="fa fa-chevron-up"></i>';b.onclick=()=>{const panel=title.parentElement,closed=panel.classList.toggle('va-panel-collapsed');b.setAttribute('aria-expanded',String(!closed));b.innerHTML='<i class="fa fa-chevron-'+(closed?'down':'up')+'"></i>';};controls.append(b);title.append(controls);});})();
document.querySelectorAll(".va-header-menu").forEach(menu => {
  menu.addEventListener("toggle", () => {
    if (menu.open) document.querySelectorAll(".va-header-menu[open]").forEach(other => {
      if (other !== menu) other.open = false;
    });
  });
  document.addEventListener("click", event => { if (!menu.contains(event.target)) menu.open = false; });
  menu.addEventListener("keydown", event => {
    if (event.key === "Escape") { menu.open = false; menu.querySelector("summary").focus(); }
  });
});
document.querySelector(".va-create-product")?.addEventListener("reset", event => {
  const form = event.currentTarget;
  form.querySelector("[data-preview]").setCustomValidity("");
  form.querySelectorAll(".va-photo-preview img").forEach(img => URL.revokeObjectURL(img.src));
  form.querySelectorAll(".va-photo-preview").forEach(preview => preview.remove());
});
