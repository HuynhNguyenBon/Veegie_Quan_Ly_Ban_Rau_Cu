(() => {
  const key = "veggie.html.wishlist.v1";
  let items = [], account = false, loading = false;
  try {
    const stored = JSON.parse(localStorage.getItem(key) || "[]");
    if (Array.isArray(stored))
      items = stored.filter(
        (p) =>
          p &&
          typeof p.name === "string" &&
          typeof p.image === "string" &&
          Number.isFinite(p.price),
      );
  } catch {}
  const esc = (s) =>
    String(s).replace(
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
  const money = (n) => Number(n).toLocaleString("vi-VN") + "₫";
  function render() {
    document.querySelectorAll('.ltn__utilize-buttons a[href="wishlist.html"] sup').forEach(badge => badge.textContent = items.length);
    const body = document.querySelector(".veggie-wishlist-table tbody");
    if (!body) return;
    body.innerHTML = items.length
      ? items
          .map(
            (p, i) =>
              `<tr><td><button data-wish-remove="${i}" aria-label="Bỏ yêu thích ${esc(p.name)}">×</button></td><td><a href="product-details.html?id=${p.id}"><img src="${esc(p.image)}" alt="${esc(p.name)}"></a></td><td><a href="product-details.html?id=${p.id}">${esc(p.name)}</a></td><td>${money(p.price)}</td><td>${p.stock === 0 ? 'Hết hàng' : 'Còn hàng'}</td><td><button class="theme-btn-2 btn" data-wish-cart="${i}">Thêm vào giỏ</button></td></tr>`,
          )
          .join("")
      : '<tr><td colspan="6" class="veggie-wishlist-empty"><h3>Danh sách yêu thích đang trống</h3><p>Nhấn biểu tượng trái tim ở sản phẩm bạn muốn lưu.</p><a class="theme-btn-1 btn" href="shop.html">Khám phá cửa hàng</a></td></tr>';
  }
  window.VeggieWishlist = {
    async connect() {
      loading = true;
      try {
        const response = await fetch("/api/wishlist");
        if (response.status === 401) return;
        if (!response.ok) throw new Error();
        const products = window.VeggieCatalog?.products || [];
        items = (await response.json()).map(id => products.find(p => p.id === id)).filter(Boolean);
        account = true;
        render();
      } catch {
        showError();
      } finally {
        loading = false;
      }
    },
  };
  function showError() {
    let status = document.getElementById("veggie-wishlist-status");
    if (!status) {
      status = document.createElement("p");
      status.id = "veggie-wishlist-status";
      status.setAttribute("role", "alert");
      (document.querySelector(".veggie-wishlist-table") || document.body).before(status);
    }
    status.textContent = "Không đồng bộ được danh sách yêu thích. Vui lòng thử lại.";
  }
  async function change(product, method) {
    try {
      const response = await fetch("/api/wishlist/" + product.id, { method });
      if (!response.ok) throw new Error();
      if (method === "DELETE") items = items.filter(item => item.id !== product.id);
      else if (!items.some(item => item.id === product.id)) items.push(product);
      document.getElementById("veggie-wishlist-status")?.remove();
      render();
      return true;
    } catch {
      showError();
      return false;
    }
  }
  function save() {
    try {
      localStorage.setItem(key, JSON.stringify(items));
    } catch {}
    render();
  }
  document.addEventListener(
    "click",
    async (event) => {
      const remove = event.target.closest("[data-wish-remove]");
      if (remove) {
        event.preventDefault();
        if (loading) return;
        if (account) { void change(items[Number(remove.dataset.wishRemove)], "DELETE"); return; }
        items.splice(Number(remove.dataset.wishRemove), 1);
        save();
        return;
      }
      const buy = event.target.closest("[data-wish-cart]");
      if (buy) {
        event.preventDefault();
        window.VeggieCart?.add(items[Number(buy.dataset.wishCart)]);
        buy.textContent = "Đã thêm vào giỏ";
        return;
      }
      const add = event.target.closest(
        '[data-bs-target="#liton_wishlist_modal"]',
      );
      if (!add) return;
      event.preventDefault();
      event.stopImmediatePropagation();
      const product = window.VeggieProductUI?.resolve(add);
      if (!product || loading || add.dataset.saving) return;
      const { name, image, price } = product;
      add.dataset.saving = "true";
      let success = true;
      if (account) {
        success = await change(product, "PUT");
      } else if (!items.some((p) => p.name === name && p.image === image)) {
        items.push(product);
        save();
      }
      delete add.dataset.saving;
      if (!success) return;
      const modal = document.getElementById("liton_wishlist_modal");
      if (modal) {
        const title = modal.querySelector(".modal-product-info h5");
        if (title) title.textContent = name;
        const img = modal.querySelector(".modal-product-img img");
        if (img) {
          img.src = image;
          img.alt = name;
        }
      }
      window.VeggieProductUI?.showModal("liton_wishlist_modal");
    },
    true,
  );
  document.addEventListener(
    "submit",
    (event) => {
      const form = event.target;
      if (
        !form.closest(".ltn__login-area") ||
        !form.querySelector('input[type="password"]')
      )
        return;
      event.preventDefault();
      let status = form.querySelector('[role="status"]');
      if (!status) {
        status = document.createElement("p");
        status.setAttribute("role", "status");
        form.append(status);
      }
      status.textContent =
        "Đây là giao diện đăng nhập/đăng ký. Chức năng xác thực sẽ được kết nối trong phần ASP.NET; hiện bạn chưa đăng nhập.";
    },
    true,
  );
  render();
})();

