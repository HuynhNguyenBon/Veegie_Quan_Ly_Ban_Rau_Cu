(() => {
  const articles = [
    { id: "chon-rau-cu", title: "Cách chọn rau củ tươi ngon mỗi ngày", image: "img/blog/1.jpg", intro: "Một giỏ rau củ ngon bắt đầu từ việc quan sát kỹ và chọn lượng vừa đủ cho bữa ăn.", sections: [["Quan sát trước khi chọn", "Chọn rau có màu sắc tự nhiên, lá còn nguyên và không bị dập úng. Với củ, ưu tiên bề mặt chắc, ít vết nứt và không có mùi lạ. Không chỉ dựa vào kích thước hay độ bóng để đánh giá chất lượng."], ["Chọn theo món ăn và mùa vụ", "Lên danh sách món ăn trước khi mua. Chọn nhiều nhóm rau lá, rau ăn quả và củ để thực đơn đa dạng. Sản phẩm theo mùa là lựa chọn thuận tiện để thay đổi bữa ăn."], ["Kiểm tra khi nhận hàng", "Đối chiếu tên và số lượng trong đơn. Nếu phát hiện sản phẩm dập hỏng, chụp lại tình trạng và liên hệ Veggie cùng mã đơn để được hỗ trợ."]] },
    { id: "bao-quan-thuc-pham", title: "Bảo quản thực phẩm để giữ trọn dinh dưỡng", image: "img/blog/2.jpg", intro: "Phân loại và sắp xếp đúng giúp thực phẩm dễ sử dụng, hạn chế dập hỏng và giảm lãng phí.", sections: [["Phân loại ngay khi nhận", "Tách rau lá, củ, trái cây và các thực phẩm sống. Bỏ phần bị dập; giữ thực phẩm dùng ngay ở khu vực riêng với thịt cá sống để hạn chế tiếp xúc chéo."], ["Theo hướng dẫn trên sản phẩm", "Với hàng đóng gói, đọc điều kiện bảo quản, ngày sử dụng và hướng dẫn sau khi mở. Thực phẩm cần làm lạnh nên được đưa vào nơi bảo quản phù hợp sớm sau khi nhận."], ["Sắp xếp để dùng hết", "Đặt thực phẩm mua trước ở phía dễ nhìn, chia lượng đủ cho từng bữa và ghi ngày mở bao bì. Kiểm tra tình trạng trước khi chế biến; không dùng thực phẩm có dấu hiệu hỏng."]] },
    { id: "tu-nong-trai-den-ban-an", title: "Từ nông trại đến bàn ăn của bạn", image: "img/blog/3.jpg", intro: "Hiểu các bước của một đơn hàng giúp bạn chủ động từ lúc chọn món đến khi nhận thực phẩm.", sections: [["Chọn và xác nhận sản phẩm", "Xem danh mục, đơn vị bán và giá tại Cửa hàng. Số lượng khả dụng được hệ thống kiểm tra lại khi bạn đặt đơn."], ["Đóng gói và giao hàng", "Thông tin người nhận và địa chỉ được dùng để chuẩn bị giao hàng. Cửa hàng cập nhật các bước xác nhận, đang giao và hoàn tất để bạn theo dõi trong tài khoản."], ["Nhận và phản hồi", "Kiểm tra sản phẩm khi nhận. Giữ mã đơn để tra cứu lịch sử hoặc gửi lời nhắn tới Veggie khi cần trao đổi về đơn hàng."]] },
    { id: "rau-cu-cho-gia-dinh", title: "Bữa ăn xanh cho cả gia đình", image: "img/blog/4.jpg", intro: "Mua sắm có kế hoạch giúp gia đình lựa chọn thực phẩm phù hợp và sử dụng hiệu quả.", sections: [["Lập thực đơn đơn giản", "Bắt đầu từ số người ăn và số bữa cần chuẩn bị. Kết hợp các loại rau củ quen thuộc với một vài lựa chọn theo mùa để thực đơn không lặp lại."], ["So sánh đúng đơn vị", "Đọc đơn vị kg, túi, hộp hoặc gói trước khi so sánh giá. Chọn số lượng phù hợp với nhu cầu thay vì chỉ nhìn vào giá của một sản phẩm."], ["Chia sẻ công việc trong nhà", "Ghi lại những gì đã có trong bếp, giao một người kiểm tra danh sách và chọn ngày mua phù hợp. Cách này giúp tránh mua trùng và dùng hết thực phẩm đã có."]] },
    { id: "meo-giu-rau-tuoi", title: "Mẹo giữ rau củ tươi lâu hơn", image: "img/blog/2.jpg", intro: "Những thao tác nhỏ sau khi mua giúp rau củ bớt dập và dễ sử dụng trong các bữa tiếp theo.", sections: [["Giữ nguyên vẹn khi chưa dùng", "Tránh cắt nhỏ toàn bộ rau củ ngay khi nhận nếu chưa cần chế biến. Loại bỏ phần hỏng và hạn chế làm dập trong quá trình di chuyển, sắp xếp."], ["Hạn chế độ ẩm dư", "Không để rau bị ngâm trong nước đọng khi cất giữ. Nếu đã rửa, để ráo và chọn cách đóng gói phù hợp với từng loại; xem hướng dẫn bảo quản nếu sản phẩm có nhãn."], ["Dùng trước phần dễ hỏng", "Ưu tiên chế biến rau lá hoặc phần đã cắt trước, sau đó mới đến các loại củ còn nguyên. Đánh dấu ngày mua và kiểm tra thường xuyên để điều chỉnh thực đơn."]] }
  ];
  document.querySelectorAll(".ltn__blog-item").forEach(card => {
    const title=card.querySelector(".ltn__blog-title")?.textContent.replace(/\s+/g," ").trim();
    const article=articles.find(a=>a.title===title || (a.id==="rau-cu-cho-gia-dinh" && title==="Rau củ tươi sạch cho mọi nhà"));
    if(article)card.querySelectorAll('a[href^="blog-details.html"]').forEach(a=>a.href="blog-details.html?article="+article.id);
  });
  const main=document.getElementById("veggie-article");
  if(main){
    const id=new URLSearchParams(location.search).get("article")||articles[0].id;
    const article=articles.find(a=>a.id===id);
    main.replaceChildren();
    if(article){
      document.title=article.title+" | Veggie";
      const title=document.createElement("h2"),image=document.createElement("img"),intro=document.createElement("p");
      title.textContent=article.title;image.src=article.image;image.alt=article.title;image.className="veggie-article-image";intro.textContent=article.intro;
      main.append(title,image,intro);
      for(const [heading,body] of article.sections){const h=document.createElement("h3"),p=document.createElement("p");h.textContent=heading;p.textContent=body;main.append(h,p);}
      const related=document.createElement("nav");related.className="veggie-article-related";related.setAttribute("aria-label","Bài viết khác");
      for(const other of articles.filter(a=>a.id!==id)){const link=document.createElement("a");link.href="blog-details.html?article="+other.id;link.textContent=other.title;related.append(link);}
      main.append(related);
    }else{const title=document.createElement("h2");title.textContent="Không tìm thấy bài viết";main.append(title);}
  }
  const forms=[...document.querySelectorAll('footer .footer-newsletter form,.ltn__newsletter-area form,.ltn__newsletter-widget form')];
  forms.forEach(form=>{
    form.classList.add("veggie-newsletter-form");
    const input=form.querySelector('input[type="email"]');if(input){input.required=true;input.maxLength=254;input.setAttribute("aria-label","Email đăng ký bản tin");}
  });
  window.addEventListener("submit",async event=>{
    const form=event.target;if(!forms.includes(form))return;
    event.preventDefault();event.stopImmediatePropagation();
    const button=form.querySelector('button');if(button.disabled)return;
    let status=form.nextElementSibling;
    if(!status?.classList.contains('veggie-newsletter-status')){status=document.createElement('p');status.className='veggie-newsletter-status';status.setAttribute('role','status');form.after(status);}
    button.disabled=true;status.textContent='Đang đăng ký…';
    try{
      const response=await fetch('/api/newsletter',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({email:form.querySelector('input[type="email"]').value.trim()})});
      const result=await response.json().catch(()=>({}));
      status.textContent=response.ok?result.message:response.status===429?'Bạn gửi quá nhiều yêu cầu. Vui lòng thử lại sau một phút.':'Chưa đăng ký được. Vui lòng thử lại.';
      if(response.ok)form.reset();
    }catch{status.textContent='Không kết nối được máy chủ. Vui lòng thử lại.';}finally{button.disabled=false;}
  },true);
})();

(()=>{const services=[["rau-cu","Rau củ tươi theo mùa","Chọn rau lá, củ và rau ăn quả theo nhu cầu bữa ăn.","img/service/1.jpg","Tuyển chọn rau củ","Xem thông tin sản phẩm, giá và lượng còn lại trước khi thêm vào giỏ.","shop.html?category=rau-cu"],["trai-cay","Trái cây cho gia đình","Đa dạng trái cây để dùng hằng ngày hoặc chuẩn bị quà tặng.","img/service/2.jpg","Chọn trái cây phù hợp","Đọc đơn vị bán và chọn lượng vừa đủ; kiểm tra tình trạng khi nhận hàng.","shop.html?category=trai-cay"],["giao-hang","Giao hàng tận nhà","Theo dõi đơn hàng từ lúc xác nhận đến khi giao thành công.","img/service/3.jpg","Thông tin giao hàng","Nhập đúng người nhận, số điện thoại và địa chỉ. Phí giao hàng 25.000₫, miễn phí cho đơn từ 300.000₫.","order-tracking.html"],["bao-gia","Báo giá theo số lượng","Gửi danh sách sản phẩm, số lượng và ngày cần giao để cửa hàng tư vấn.","img/banner/banner-1.jpg","Yêu cầu báo giá","Biểu mẫu báo giá được gửi tới cửa hàng. Giá và lịch giao chỉ được xác nhận khi cửa hàng phản hồi.","quote.html"],["bao-quan","Hướng dẫn bảo quản","Tham khảo cách sắp xếp và bảo quản thực phẩm sau khi nhận.","img/blog/2.jpg","Bảo quản sau mua","Phân loại rau củ, thịt cá và thực phẩm đóng gói; làm theo hướng dẫn của từng sản phẩm.","blog-details.html?article=bao-quan-thuc-pham"],["sau-mua","Hỗ trợ sau mua","Tra cứu đơn hàng và gửi phản hồi khi sản phẩm gặp vấn đề.","img/blog/3.jpg","Liên hệ hỗ trợ","Chuẩn bị mã đơn, mô tả vấn đề và ảnh tình trạng sản phẩm để cửa hàng kiểm tra.","contact.html"]];const main=document.getElementById('veggie-service-detail');if(main){const id=new URLSearchParams(location.search).get('service')||'rau-cu';const item=services.find(s=>s[0]===id);main.replaceChildren();if(item){document.title=item[1]+' | Veggie';const title=document.createElement('h2'),intro=document.createElement('p'),image=document.createElement('img'),heading=document.createElement('h3'),body=document.createElement('p'),link=document.createElement('a');title.textContent=item[1];intro.textContent=item[2];image.src=item[3];image.alt=item[1];image.className='veggie-service-image';heading.textContent=item[4];body.textContent=item[5];link.href=item[6];link.className='theme-btn-1 btn';link.textContent='Tiếp tục';main.append(title,intro,image,heading,body,link);document.querySelector('.ltn__breadcrumb-inner h1').textContent=item[1];}else main.textContent='Không tìm thấy dịch vụ.';}const steps=[...document.querySelectorAll('.ltn__our-journey-wrap>ul>li')];steps.forEach((step,i)=>{const button=step.querySelector('button');if(!button)return;button.addEventListener('click',()=>{steps.forEach(other=>{other.classList.toggle('active',other===step);other.querySelector('button')?.setAttribute('aria-pressed',String(other===step));});});button.setAttribute('aria-pressed',String(step.classList.contains('active')));});})();
