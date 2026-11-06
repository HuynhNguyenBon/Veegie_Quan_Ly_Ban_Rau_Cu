/* Giỏ hàng frontend: chỉ có sản phẩm sau khi người dùng bấm thêm vào giỏ. */
(() => {
  "use strict";
  const key = "veggie.html.cart.v1";
  let cart = [], serverOwned = false;
  try {
    const saved = JSON.parse(localStorage.getItem(key) || "[]");
    if (Array.isArray(saved))
      cart = saved.filter(
        (p) =>
          p &&
          typeof p.name === "string" &&
          Number.isFinite(p.price) &&
          p.price >= 0 &&
          p.quantity > 0 &&
          typeof p.image === "string",
      );
  } catch {}
  const money = (value) => Number(value || 0).toLocaleString("vi-VN") + "₫";
  const esc = (value) =>
    String(value).replace(
      /[&<>"']/g,
      (c) =>
        ({
          "&": "&amp;",
          "<": "&lt;",
          ">": "&gt;",
          '"': "&quot;",
          "'": "&#39;",
        })[c],
    );
  const empty =
    '<div class="veggie-cart-empty"><i class="icon-shopping-cart"></i><h4>Giỏ hàng đang trống</h4><p>Hãy chọn sản phẩm tươi ngon cho bữa ăn của bạn.</p><a href="shop.html" class="theme-btn-1 btn">Khám phá cửa hàng</a></div>';
  function productLink(item) {
    const product = window.VeggieCatalog?.products.find(p => p.name === item.name && p.image === item.image);
    return product ? "product-details.html?id=" + encodeURIComponent(product.id) : "shop.html";
  }
  function render() {
    const count = cart.reduce((n, p) => n + p.quantity, 0),
      total = cart.reduce((n, p) => n + p.price * p.quantity, 0);
    document
      .querySelectorAll('.mini-cart-icon sup, .ltn__utilize-buttons a[href="cart.html"] sup')
      .forEach((n) => (n.textContent = count));
    const drawer = document.getElementById("ltn__utilize-cart-menu");
    if (drawer) {
      drawer.querySelector(".mini-cart-product-area").innerHTML = cart.length
        ? cart
            .map(
              (p) =>
                `<div class="mini-cart-item clearfix"><div class="mini-cart-img"><a href="${productLink(p)}"><img src="${esc(p.image)}" alt="${esc(p.name)}"></a><button class="mini-cart-item-delete" data-cart-remove="${esc(p.id)}" aria-label="Xóa ${esc(p.name)}">×</button></div><div class="mini-cart-info"><h6><a href="${productLink(p)}">${esc(p.name)}</a></h6><span>${p.quantity} × ${money(p.price)}</span></div></div>`,
            )
            .join("")
        : empty;
      drawer.querySelector(".mini-cart-footer").hidden = !cart.length;
      drawer.querySelector(".mini-cart-sub-total span").textContent =
        money(total);
    }
    if (location.pathname.endsWith("/cart.html")) {
      const body = document.querySelector(".shoping-cart-table tbody");
      if (body)
        body.innerHTML = cart.length
          ? cart
              .map(
                (p) =>
                  `<tr><td><button data-cart-remove="${esc(p.id)}" aria-label="Xóa ${esc(p.name)}">×</button></td><td><img class="veggie-cart-table-image" src="${esc(p.image)}" alt="${esc(p.name)}"></td><td>${esc(p.name)}</td><td>${money(p.price)}</td><td><input type="number" min="1" max="99" value="${p.quantity}" data-cart-quantity="${esc(p.id)}" aria-label="Số lượng ${esc(p.name)}" style="width:75px;margin:0"></td><td>${money(p.price * p.quantity)}</td></tr>`,
              )
              .join("")
          : '<tr><td colspan="6">Giỏ hàng đang trống. <a href="shop.html">Khám phá cửa hàng →</a></td></tr>';
      const box = document.querySelector(".shoping-cart-total");
      if (box) {
        box.hidden = !cart.length;
        const cells = box.querySelectorAll("tr td:last-child");
        if (cells[0]) cells[0].textContent = money(total);
        if (cells[1]) cells[1].textContent = money(total >= 300000 ? 0 : 25000);
        if (cells[2]) cells[2].textContent = money(0);
        if (cells[3])
          cells[3].textContent = money(total + (total >= 300000 ? 0 : 25000));
      }
    }
  }
  function save() {
    try {
      if (!serverOwned) localStorage.setItem(key, JSON.stringify(cart));
    } catch {}
    render();
    if (typeof CustomEvent === "function")
      document.dispatchEvent?.(new CustomEvent("veggie:cart"));
  }
  window.VeggieCart = {
    restore(items) { serverOwned = true; cart = items; render(); document.dispatchEvent(new CustomEvent("veggie:cart")); },
    getItems: () => cart.map((p) => ({ ...p })),
    clear() {
      cart = [];
      save();
    },
    add(product) {
      const quantity = Math.max(1, Math.min(99, Number(product.quantity) || 1));
      const id = product.name + "|" + product.image;
      const existing = cart.find((p) => p.id === id);
      if (existing)
        existing.quantity = Math.min(99, existing.quantity + quantity);
      else cart.push({ ...product, id, quantity });
      save();
    },
  };
  document.addEventListener(
    "click",
    (event) => {
      const remove = event.target.closest("[data-cart-remove]");
      if (remove) {
        event.preventDefault();
        cart = cart.filter((p) => p.id !== remove.dataset.cartRemove);
        save();
        return;
      }
      const add = event.target.closest('[data-bs-target="#add_to_cart_modal"]');
      if (!add) return;
      event.preventDefault();
      event.stopImmediatePropagation();
      const item = add.closest(
        ".ltn__product-item,.modal-product-info,.ltn__shop-details-inner",
      );
      if (!item) return;
      const name =
        item.querySelector(".product-title,h3,h4,h2,h5")?.textContent.trim() ||
        "Sản phẩm";
      const image =
        item.querySelector(".product-img img")?.getAttribute("src") ||
        item
          .closest(".modal-content")
          ?.querySelector(".modal-product-img img")
          ?.getAttribute("src") ||
        document
          .querySelector(
            ".ltn__shop-details-img-gallery img,.modal-product-img img",
          )
          ?.getAttribute("src") ||
        "img/product/1.png";
      const raw = item.querySelector(".product-price span")?.textContent || "0";
      const price = raw.includes("$")
        ? Math.round(parseFloat(raw.replace(/[^0-9.]/g, "")) * 1000)
        : Number(raw.replace(/\D/g, ""));
      const quantity = Math.max(
        1,
        Math.min(
          99,
          Math.floor(
            Number(item.querySelector(".cart-plus-minus-box")?.value) || 1,
          ),
        ),
      );
      const id = name + "|" + image;
      const existing = cart.find((p) => p.id === id);
      if (existing)
        existing.quantity = Math.min(99, existing.quantity + quantity);
      else cart.push({ id, name, image, price, quantity });
      save();
      const modal = document.getElementById("add_to_cart_modal");
      if (modal) {
        const heading = modal.querySelector(".modal-product-info h5");
        if (heading) heading.textContent = name;
        const img = modal.querySelector(".modal-product-img img");
        if (img) {
          img.src = image;
          img.alt = name;
        }
      }
      window.VeggieProductUI?.showModal("add_to_cart_modal");
    },
    true,
  );
  document.addEventListener("change", (event) => {
    const input = event.target.closest("[data-cart-quantity]");
    if (!input) return;
    const p = cart.find((p) => p.id === input.dataset.cartQuantity);
    if (p) {
      p.quantity = Math.max(
        1,
        Math.min(99, Math.floor(Number(input.value) || 1)),
      );
      save();
    }
  });
  window.addEventListener("storage", (event) => {
    if (!serverOwned && event.key === key) {
      try {
        cart = JSON.parse(event.newValue || "[]");
        render();
      } catch {}
    }
  });
  document.addEventListener(
    "submit",
    (event) => {
      if (event.target.id !== "contact-form") return;
      event.preventDefault();
      const form = event.target;
      let status = form.querySelector('[role="status"]');
      if (!status) {
        status = document.createElement("p");
        status.setAttribute("role", "status");
        form.append(status);
      }
      status.textContent =
        "Đây là biểu mẫu giao diện; chức năng gửi lời nhắn sẽ được kết nối ở phần ASP.NET.";
    },
    true,
  );
  document.addEventListener("DOMContentLoaded", render, { once: true });
  render();
})();


