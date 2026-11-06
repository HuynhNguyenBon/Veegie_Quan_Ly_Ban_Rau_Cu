const fs=require('fs'),vm=require('vm'),assert=require('assert/strict');
const JSZip=require('../admin/vendors/jszip/dist/jszip.min.js');
const elements=[];let blob;
function element(tag){const e={tagName:tag,children:[],value:'10',style:{},disabled:false,textContent:'',append(...v){this.children.push(...v)},add(v){this.children.push(v)},setAttribute(){},click(){},parentElement:null};elements.push(e);return e;}
const row=values=>({cells:values.map(innerText=>({innerText})),hidden:false,classList:{contains:()=>false},innerText:values.join(' '),nextElementSibling:null});
const parent=element('div');parent.insertBefore=()=>{};
const table={tBodies:[{rows:[row(['1','Cà rốt','Rau củ','53.000 ₫','49 kg','Đang bán','Sửa'])]}],tHead:{rows:[row(['Mã','Sản phẩm','Danh mục','Giá','Tồn kho','Trạng thái','Thao tác'])]},parentElement:parent};
const document={querySelectorAll:s=>s==='table.va-data-table'?[table]:[],createElement:element};
const context={document,window:{JSZip,print(){}},JSZip,Option:function(text,value){return{text,value}},URL:{createObjectURL:b=>{blob=b;return'blob:qa'},revokeObjectURL(){}},Blob,setTimeout:()=>{},navigator:{clipboard:{writeText:async()=>{}}}};
vm.runInNewContext(fs.readFileSync('admin/build/js/veggie-mvc.js','utf8'),context);
(async()=>{await elements.find(e=>e.textContent==='Xuất Excel').onclick();const zip=new JSZip(Buffer.from(await blob.arrayBuffer()));assert(zip.file('xl/workbook.xml'));const sheet=zip.file('xl/worksheets/sheet1.xml').asText();assert(sheet.includes('Cà rốt'));assert(sheet.includes('inlineStr'));fs.mkdirSync('backend/Veggie.Api/bin/export-qa',{recursive:true});fs.writeFileSync('backend/Veggie.Api/bin/export-qa/veggie.xlsx',Buffer.from(await blob.arrayBuffer()));console.log('PASS: XLSX contains workbook, relationships, Vietnamese data and valid ZIP entries');})().catch(e=>{console.error(e);process.exitCode=1});

