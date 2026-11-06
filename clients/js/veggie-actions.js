/* Các thao tác giao diện còn lại; không gửi dữ liệu tới dịch vụ bên ngoài. */
(() => {
  const money = (n) => Number(n).toLocaleString("vi-VN") + "₫";
  const read = (key, fallback) => {
    try {
      return JSON.parse(localStorage.getItem(key)) || fallback;
    } catch {
      return fallback;
    }
  };
  const write = (key, value) => {
    try {
      localStorage.setItem(key, JSON.stringify(value));
    } catch {}
  };
  document.querySelectorAll(".ltn__login-area form").forEach((form) => {
    if (!form.querySelector('input[type="password"]')) return;
    form.querySelectorAll('input[type="password"]').forEach((input) => {
      input.required = true;
      input.minLength = 8;
    });
    form.querySelectorAll("input").forEach((input) => {
      if (
        input.type === "password" ||
        input.type === "checkbox" ||
        input.type === "hidden"
      )
        return;
      if (input.name === "email" || /email/i.test(input.placeholder)) {
        input.type = "email";
        input.required = true;
      }
    });
  });
  document
    .querySelectorAll(
      '#contact-form [name="name"],#contact-form [name="email"],#contact-form [name="phone"],#contact-form [name="message"]',
    )
    .forEach((input) => (input.required = true));
  function status(text, form) {
    let node = form?.querySelector('[role="status"]');
    if (!node) {
      node = document.createElement("p");
      node.setAttribute("role", "status");
      if (form) form.append(node);
      else {
        node.className = "veggie-action-toast";
        document.body.append(node);
        setTimeout(() => node.remove(), 5000);
      }
    }
    node.textContent = text;
  }
  function dialog(title, content) {
    const d = document.createElement("dialog");
    d.className = "veggie-action-dialog";
    const close = document.createElement("button");
    close.type = "button";
    close.className = "veggie-dialog-close";
    close.textContent = "×";
    close.setAttribute("aria-label", "Đóng");
    close.onclick = () => d.close();
    const h = document.createElement("h2");
    h.textContent = title;
    d.append(close, h, content);
    d.addEventListener("close", () => d.remove());
    document.body.append(d);
    d.showModal();
    return d;
  }
  function requestEmail(title) {
    const form = document.createElement("form");
    form.className = "veggie-password-help";
    form.innerHTML =
      '<label>Email của bạn<input type="email" required autocomplete="email"></label><button class="theme-btn-1 btn">Gửi yêu cầu</button>';
    form.onsubmit = async (e) => {
      e.preventDefault();
      const button = form.querySelector("button");
      button.disabled = true;
      status("Đang gửi yêu cầu…", form);
      try {
        const response = await fetch("/api/account/forgot-password", {
          method: "POST", headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ email: form.querySelector("input").value.trim() })
        });
        const result = await response.json().catch(() => ({}));
        status(result.message || (response.status === 429 ? "Bạn gửi quá nhiều yêu cầu. Hãy thử lại sau một phút." : "Chưa gửi được yêu cầu. Vui lòng thử lại."), form);
      } catch { status("Không kết nối được máy chủ. Vui lòng thử lại.", form); }
      finally { button.disabled = false; }
    };
    dialog(title, form);
  }
  const cart = window.VeggieCart,
    checkout = document.getElementById("veggie-checkout-form");
  if (checkout) {
    function refreshOrder() {
      const items = cart.getItems(),
        total = items.reduce((n, p) => n + p.price * p.quantity, 0),
        shipping = total >= 300000 ? 0 : 25000;
      const box = document.getElementById("veggie-order-lines");
      box.replaceChildren();
      items.forEach((p) => {
        const line = document.createElement("p");
        line.textContent =
          p.name + " × " + p.quantity + " — " + money(p.price * p.quantity);
        box.append(line);
      });
      const summary = document.createElement("h3");
      const subtotal=document.createElement("p"), delivery=document.createElement("p");
      subtotal.className="veggie-order-cost";delivery.className="veggie-order-cost";
      subtotal.textContent="Tạm tính: "+money(total);
      delivery.textContent="Phí giao hàng: "+(total>=300000?"Miễn phí":money(items.length?shipping:0));
      box.append(subtotal,delivery);
      summary.textContent =
        "Tổng: " + money(total + (items.length ? shipping : 0));
      box.append(summary);
      checkout.hidden = !items.length;
      if (!items.length) {
        document.getElementById("veggie-checkout-summary").innerHTML =
          '<h2>Giỏ hàng đang trống</h2><a href="shop.html" class="theme-btn-1 btn">Chọn sản phẩm</a>';
      } else
        document.getElementById("veggie-checkout-summary").replaceChildren();
    }
    document.addEventListener("veggie:cart", refreshOrder);
    refreshOrder();
    checkout.onsubmit = (e) => {
      e.preventDefault();
      if (!checkout.reportValidity()) return;
      const items = cart.getItems();
      if (!items.length) {
        refreshOrder();
        return;
      }
      const total = items.reduce((n, p) => n + p.price * p.quantity, 0),
        shipping = total >= 300000 ? 0 : 25000;
      const data = Object.fromEntries(new FormData(checkout));
      const order = {
        ...data,
        id: Date.now(),
        code: "VG" + String(Date.now()).slice(-8),
        items,
        total: total + shipping,
        status: "Đơn thử đã tạo",
        date: new Date().toISOString(),
      };
      write("veggie.html.orders.v1", [
        order,
        ...read("veggie.html.orders.v1", []),
      ]);
      cart.clear();
      checkout.hidden = true;
      const result = document.getElementById("veggie-checkout-summary");
      result.replaceChildren();
      const heading = document.createElement("h2");
      heading.textContent = "Đã tạo đơn thử " + order.code;
      const p = document.createElement("p");
      p.textContent =
        "Tổng " +
        money(order.total) +
        ". Đơn chỉ lưu trong trình duyệt, chưa gửi đến cửa hàng và chưa thu tiền.";
      const a = document.createElement("a");
      a.href = "order-tracking.html";
      a.className = "theme-btn-1 btn";
      a.textContent = "Tra cứu đơn thử";
      result.append(heading, p, a);
    };
  }
  const tracking = location.pathname.endsWith("order-tracking.html")
    ? document.querySelector(".ltn__login-area form")
    : null;
  if (tracking) {
    const inputs = tracking.querySelectorAll("input");
    inputs[0].name = "code";
    inputs[0].required = true;
    inputs[1].name = "email";
    inputs[1].type = "email";
    inputs[1].required = true;
    tracking.onsubmit = (e) => {
      e.preventDefault();
      const code = inputs[0].value.trim().toUpperCase(),
        email = inputs[1].value.trim().toLowerCase();
      const order = read("veggie.html.orders.v1", []).find(
        (o) => o.code === code && o.email.toLowerCase() === email,
      );
      status(
        order
          ? `${order.code} · ${order.status} · ${money(order.total)}. Đây là dữ liệu thử trong trình duyệt.`
          : "Không tìm thấy đơn thử khớp mã đơn và email trên trình duyệt này.",
        tracking,
      );
    };
  }
  document.addEventListener(
    "submit",
    (event) => {
      const form = event.target;
      if (form.matches(".veggie-chat-form,.veggie-password-help,#account-security-form")) return;
      if (
        form.closest(".header-search-1-form,.ltn__utilize-menu-search-form")
      ) {
        event.preventDefault();
        const q = form.querySelector("input")?.value.trim() || "";
        location.href = "shop.html?q=" + encodeURIComponent(q);
        return;
      }
      if (
        form.closest(".ltn__shop-sidebar") ||
        form === tracking ||
        form === checkout
      )
        return;
      if (form.querySelector('input[type="password"]')) return;
      event.preventDefault();
      if (form.closest("footer")) {
        const email = form.querySelector('input[type="email"]');
        if (email) {
          email.required = true;
          if (!form.reportValidity()) return;
          write("veggie.html.newsletter.v1", email.value);
          status(
            "Đã lưu đăng ký bản tin mẫu trong trình duyệt; chưa gửi email.",
            form,
          );
        }
        return;
      }
      if (form.id === "contact-form") {
        if (!form.reportValidity()) return;
        const entry = {
          ...Object.fromEntries(new FormData(form)),
          date: new Date().toISOString(),
        };
        write("veggie.html.contacts.v1", [
          entry,
          ...read("veggie.html.contacts.v1", []),
        ]);
        status(
          "Đã lưu lời nhắn mẫu trong trình duyệt. Chưa gửi đến cửa hàng.",
          form,
        );
        return;
      }
      if (
        form.querySelector("textarea") &&
        form.closest(".ltn__shop-details-tab-content-inner")
      ) {
        const comment = form.querySelector("textarea").value.trim();
        if (!comment) return status("Vui lòng nhập nội dung đánh giá.", form);
        const p = document.createElement("p");
        p.className = "veggie-review-saved";
        p.textContent = "Đánh giá của bạn: " + comment;
        form.before(p);
        write("veggie.html.reviews.v1", [
          { product: new URL(location.href).searchParams.get("id"), comment },
          ...read("veggie.html.reviews.v1", []),
        ]);
        form.reset();
        status("Đã lưu đánh giá mẫu.", form);
        return;
      }
      status(
        "Đã ghi nhận yêu cầu trong giao diện mẫu. Chức năng gửi đến máy chủ sẽ kết nối ở phần ASP.NET.",
        form,
      );
    },
    true,
  );
  document.addEventListener(
    "click",
    (event) => {
      const compare = event.target.closest('a[title="So sánh"]');
      if (compare) {
        event.preventDefault();
        event.stopImmediatePropagation();
        const id = window.VeggieProductUI?.resolve(compare)?.id;
        const products = window.VeggieCatalog.products,
          first = products.find((p) => p.id === id) || products[0];
        const content = document.createElement("div"),
          select = document.createElement("select"),
          result = document.createElement("div");
        select.setAttribute("aria-label", "Chọn sản phẩm so sánh");
        select.className = "veggie-compare-select";
        products
          .filter((p) => p.id !== first.id)
          .forEach((p) => {
            const option = document.createElement("option");
            option.value = p.id;
            option.textContent = p.name;
            select.append(option);
          });
        function show() {
          const second = products.find((p) => p.id === Number(select.value));
          result.replaceChildren();
          for (const p of [first, second]) {
            if (!p) continue;
            const box = document.createElement("article"),
              img = document.createElement("img"),
              name = document.createElement("h3"),
              info = document.createElement("p");
            img.src = p.image;
            img.alt = p.name;
            name.textContent = p.name;
            info.className = "veggie-compare-price";
            info.textContent = money(p.price) + " / " + p.unit;
            const details = document.createElement("dl");
            const category = window.VeggieCatalog.categories.find(c => c.id === p.category)?.name || p.category;
            for (const [label,value] of [["Danh mục",category],["Tồn kho",p.stock>0 ? p.stock+" "+p.unit : "Hết hàng"],["Đơn vị bán",p.unit]]) {
              const term=document.createElement("dt"), definition=document.createElement("dd");
              term.textContent=label; definition.textContent=value;details.append(term,definition);
            }
            const link=document.createElement("a");link.href="product-details.html?id="+p.id;link.className="theme-btn-1 btn";link.textContent="Xem sản phẩm";
            box.append(img, name, info, details, link);
            result.append(box);
          }
        }
        result.className = "veggie-compare-grid";
        select.onchange = show;
        const label=document.createElement("label"); label.className="veggie-compare-control";label.textContent="So sánh với";label.append(select);
        content.append(label, result);
        const open=()=>{const d=dialog("So sánh sản phẩm", content);d.classList.add("veggie-compare-dialog");};
        if(window.VeggieProductUI)window.VeggieProductUI.afterModalClosed(open);else open();
        show();
        return;
      }
      const a = event.target.closest('a[href="#"],a[href="javascript:;"]');
      if (!a) return;
      event.preventDefault();
      if (
        a.hasAttribute("data-bs-toggle") ||
        a.querySelector(".fa-star,.fa-star-half-alt") ||
        a.parentElement.querySelector("ul") ||
        a.closest(".user-menu") ||
        a.closest(".ltn__utilize-menu") ||
        a.closest(".ltn__shop-sidebar")
      )
        return;
      const label = (a.textContent || a.title || "").trim();
      if (/quên.*mật khẩu/i.test(label)) {
        requestEmail("Yêu cầu hỗ trợ mật khẩu");
        return;
      }
      if (
        a.closest(".ltn__social-media") ||
        /Facebook|Twitter|Instagram|Youtube|Linkedin|Dribbble/i.test(a.title)
      ) {
        status(
          "Trang mạng xã hội của Veggie chưa được cấu hình. Bạn có thể liên hệ qua trang Liên hệ.",
        );
        return;
      }
      if (label)
        status(
          "Mục “" +
            label +
            "” hiện là nội dung mẫu; chưa có dịch vụ backend được kết nối.",
        );
    },
    true,
  );
  const tabs = [
    ...document.querySelectorAll(
      '.ltn__product-tab-area .ltn__tab-menu a[data-bs-toggle="tab"]',
    ),
  ];
  const catalogue = window.VeggieCatalog;
  if (catalogue && tabs.length === 5) {
    tabs.forEach((tab, index) => {
      const category = catalogue.categories[index];
      tab.textContent = category.name;
      const pane = document.querySelector(tab.getAttribute("href"));
      const row = pane?.querySelector(".row"),
        sample = row?.querySelector(".ltn__product-item");
      if (!sample) return;
      const template = sample.cloneNode(true),
        items = catalogue.products
          .filter((p) => p.category === category.id)
          .slice(0, 8),
        columns = [];
      for (let i = 0; i < items.length; i += 2) {
        const col = document.createElement("div");
        col.className = "col-12";
        for (const p of items.slice(i, i + 2)) {
          const card = template.cloneNode(true);
          card.dataset.productId = p.id;
          const img = card.querySelector(".product-img img");
          img.src = p.image;
          img.alt = p.name;
          card.querySelectorAll(".product-title a").forEach((a) => {
            a.textContent = p.name;
            a.href = "product-details.html?id=" + p.id;
          });
          card
            .querySelectorAll(".product-img>a")
            .forEach((a) => (a.href = "product-details.html?id=" + p.id));
          const price = card.querySelector(".product-price");
          price.replaceChildren();
          const span = document.createElement("span");
          span.textContent = money(p.price);
          price.append(span);
          col.append(card);
        }
        columns.push(col);
      }
      row.replaceChildren(...columns);
    });
  }
  if (catalogue)
    document.querySelectorAll(".ltn__category-item").forEach((card, index) => {
      const category =
        index === 0
          ? null
          : catalogue.categories[(index - 1) % catalogue.categories.length];
      card
        .querySelectorAll("a")
        .forEach(
          (a) =>
            (a.href =
              "shop.html" + (category ? "?category=" + category.id : "")),
        );
      const heading = card.querySelector("h5");
      if (heading) heading.textContent = category?.name || "Tất cả sản phẩm";
      const number = card.querySelector("h6");
      if (number)
        number.textContent =
          "(" +
          catalogue.products.filter(
            (p) => !category || p.category === category.id,
          ).length +
          " sản phẩm)";
    });
})();

