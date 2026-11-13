(() => {
  const form = document.getElementById("veggie-checkout-form");
  if (!form) return;
  const summary = form.querySelector(".veggie-order-summary");
  summary.querySelector("h2").textContent = "Đơn hàng";
  const bankPayment = summary.querySelector('input[value="Chuyển khoản"]');
  bankPayment.value = "BankTransfer";
  const button = summary.querySelector('button[type="submit"]');
  button.textContent = "Đặt hàng";
  const city = form.elements.namedItem("city");
  const cart = window.VeggieCart;
  const promoInput = document.getElementById("veggie-promotion-code");
  const promoButton = document.getElementById("veggie-promotion-apply");
  const promoStatus = document.getElementById("veggie-promotion-status");
  const suggestions = document.getElementById("veggie-promotion-suggestions");
  const pointsHint = document.getElementById("veggie-points-hint");
  const breakdown = document.getElementById("veggie-order-breakdown");
  const money = value => new Intl.NumberFormat("vi-VN").format(value || 0) + " ₫";
  let activePromo = "";
  let lastPayload, requestId, quoteVersion = 0;

  fetch("/api/account/me").then(response => response.ok ? response.json() : null).then(user => {
    if (!user) return;
    form.elements.email.value = user.email;
    form.elements.email.readOnly = true;
  }).catch(() => {});

  async function readJson(response) {
    try { return await response.json(); } catch { return {}; }
  }

  async function loadAddresses() {
    try {
      const response = await fetch("/api/account/addresses");
      if (!response.ok) return;
      const addresses = await response.json();
      if (!addresses.length) return;

      const label = document.createElement("label");
      label.textContent = "Địa chỉ giao hàng đã lưu";
      const select = document.createElement("select");
      select.className = "form-select";
      select.append(new Option("Nhập địa chỉ khác", ""));
      addresses.forEach((address, index) => {
        select.append(new Option(address.fullName + " · " + address.address + ", " + address.city, String(index)));
      });
      select.addEventListener("change", () => {
        if (select.value === "") return;
        const address = addresses[Number(select.value)];
        form.elements.namedItem("name").value = address.fullName;
        form.elements.phone.value = address.phone;
        form.elements.address.value = address.address;
        city.value = address.city;
      });
      label.append(select);
      label.className = "veggie-saved-address";
      form.querySelector(".veggie-delivery-fields").before(label);
      const preferred = addresses.findIndex(address => address.isDefault);
      const fields = [form.elements.namedItem("name"), form.elements.phone, form.elements.address, city];
      if (preferred >= 0 && fields.every(field => !field.value)) {
        select.value = String(preferred);
        select.dispatchEvent(new Event("change"));
      }
    } catch {
      // Manual entry is still available if the address request fails.
    }
  }
  void loadAddresses();

  const status = document.createElement("p");
  status.setAttribute("role", "status");
  summary.append(status);

  function currentItems() {
    const products = window.VeggieCatalog?.products || [];
    return cart.getItems().map(({ name, image, quantity }) => ({
      id: products.find(product => product.name === name && product.image === image)?.id,
      quantity,
    }));
  }

  function showQuote(quote) {
    breakdown.replaceChildren();
    const row = (label, value, className = "") => {
      const line = document.createElement("p");
      line.className = className;
      const name = document.createElement("span");
      name.textContent = label;
      const amount = document.createElement("strong");
      amount.textContent = value;
      line.append(name, amount);
      breakdown.append(line);
    };
    row("Tạm tính", money(quote.subtotal));
    if (quote.discount > 0) row("Mã " + quote.promotionCode, "−" + money(quote.discount), "veggie-order-discount");
    row("Phí giao hàng", quote.shippingFee ? money(quote.shippingFee) : "Miễn phí");
    row("Tổng thanh toán", money(quote.total), "veggie-order-total");
  }

  async function requestQuote(code = activePromo) {
    const version = ++quoteVersion;
    const items = currentItems();
    if (!items.length || items.some(item => !item.id)) {
      breakdown.replaceChildren();
      return { ok: false, message: "Giỏ hàng chưa có sản phẩm hợp lệ." };
    }
    try {
      const response = await fetch("/api/orders/quote", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ items, promotionCode: code || null }),
      });
      const result = await readJson(response);
      if (version !== quoteVersion) return { ok: false, stale: true };
      if (response.redirected && /\/login(?:\.html)?(?:\?|$)/i.test(response.url))
        return { ok: false, message: "Hãy đăng nhập để xem mã khuyến mãi và tính đơn hàng." };
      if (!response.ok) return { ok: false, message: result.message || "Chưa thể tính đơn hàng. Hãy đăng nhập rồi thử lại." };
      if (!Number.isFinite(Number(result.total))) return { ok: false, message: "Hãy đăng nhập để xem mã khuyến mãi và tính đơn hàng." };
      showQuote(result);
      return { ok: true, result };
    } catch {
      return { ok: false, message: "Không kết nối được máy chủ để tính đơn hàng." };
    }
  }

  async function refreshQuote() {
    const result = await requestQuote(activePromo);
    if (result.ok || result.stale) return;
    if (activePromo) {
      const rejectedCode = activePromo;
      activePromo = "";
      promoInput.value = "";
      promoButton.textContent = "Áp dụng";
      promoStatus.textContent = result.message || `Mã ${rejectedCode} không còn áp dụng được.`;
      await requestQuote("");
    } else if (result.message && cart.getItems().length) {
      status.textContent = result.message;
    }
  }

  promoButton.addEventListener("click", async () => {
    const code = promoInput.value.trim().toUpperCase();
    if (activePromo && (!code || code === activePromo)) {
      activePromo = "";
      promoInput.value = "";
      promoButton.textContent = "Áp dụng";
      promoStatus.textContent = "Đã bỏ mã khuyến mãi.";
      promoButton.disabled = true;
      await refreshQuote();
      promoButton.disabled = false;
      return;
    }
    if (!code) {
      promoStatus.textContent = "Nhập mã khuyến mãi trước khi áp dụng.";
      promoInput.focus();
      return;
    }
    promoButton.disabled = true;
    promoStatus.textContent = "Đang kiểm tra mã…";
    activePromo = code;
    const result = await requestQuote(activePromo);
    if (result.ok) {
      promoInput.value = code;
      promoStatus.textContent = `Đã áp dụng ${code}. ${result.result.promotionDescription || ""}`;
      promoButton.textContent = "Bỏ mã";
    } else if (!result.stale) {
      activePromo = "";
      promoButton.textContent = "Áp dụng";
      promoStatus.textContent = result.message || "Không áp dụng được mã này.";
      await requestQuote("");
    }
    promoButton.disabled = false;
  });
  promoInput.addEventListener("keydown", event => {
    if (event.key === "Enter") { event.preventDefault(); promoButton.click(); }
  });

  fetch("/api/promotions/available", { cache: "no-store" })
    .then(response => response.ok ? response.json() : [])
    .then(promotions => {
      for (const promo of promotions) {
        const wrapper = document.createElement("div");
        const use = document.createElement("button");
        use.type = "button";
        use.className = "veggie-promotion-chip";
        use.textContent = promo.code;
        use.title = promo.description;
        const detail = document.createElement("small");
        detail.textContent = promo.description;
        use.addEventListener("click", () => {
          promoInput.value = promo.code;
          promoButton.click();
        });
        wrapper.append(use, detail);
        suggestions.append(wrapper);
      }
    }).catch(() => {});

  fetch("/api/loyalty", { cache: "no-store" })
    .then(response => response.ok ? response.json() : null)
    .then(data => {
      if (data) pointsHint.textContent = `Bạn đang có ${new Intl.NumberFormat("vi-VN").format(data.balance)} điểm. Xem quà đổi điểm trong mục Tài khoản.`;
    }).catch(() => {});

  document.addEventListener("veggie:cart", () => { void refreshQuote(); });
  void refreshQuote();

  window.addEventListener("submit", async (event) => {
    if (event.target !== form) return;
    event.preventDefault();
    event.stopPropagation();
    if (button.disabled) return;
    const items = currentItems();
    if (items.some(item => !item.id)) {
      status.textContent = "Giỏ có sản phẩm không còn khớp danh mục. Hãy xóa sản phẩm cũ và thêm lại từ Cửa hàng.";
      return;
    }
    if (!items.length) return;
    const { name, phone, address, city: cityValue, note } = Object.fromEntries(new FormData(form));
    const paymentMethod = form.elements.payment.value;
    const payload = { name, phone, address, city: cityValue, note, items, paymentMethod, promotionCode: activePromo || null };
    const serialized = JSON.stringify(payload);
    if (serialized !== lastPayload) {
      lastPayload = serialized;
      requestId = crypto.randomUUID();
    }
    button.disabled = true;
    status.textContent = "Đang đặt hàng…";
    try {
      const response = await fetch("/api/orders", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ ...payload, requestId }),
      });
      if (response.status === 401 || (response.redirected && /\/login(?:\.html)?(?:\?|$)/i.test(response.url))) {
        location.href = "login.html?returnTo=checkout";
        return;
      }
      const result = await readJson(response);
      if (!response.ok) {
        status.textContent = result.message || "Vui lòng kiểm tra thông tin đặt hàng.";
        return;
      }
      cart.clear();
      form.hidden = true;
      const message = document.getElementById("veggie-checkout-summary");
      message.innerHTML = `
        <section class="veggie-order-confirmation" aria-labelledby="veggie-order-confirmation-title">
          <span class="veggie-order-confirmation-icon" aria-hidden="true">✓</span>
          <h2 id="veggie-order-confirmation-title" tabindex="-1">Đặt hàng thành công</h2>
          <dl>
            <div><dt>Mã đơn hàng</dt><dd data-order-code></dd></div>
            <div><dt>Tổng thanh toán</dt><dd data-order-total></dd></div>
            <div data-order-discount hidden><dt>Đã giảm</dt><dd></dd></div>
          </dl>
          <a class="theme-btn-1 btn" href="account.html#don-hang">Xem đơn hàng</a>
          <a class="veggie-order-confirmation-shop" href="shop.html">Tiếp tục mua sắm</a>
        </section>`;
      message.querySelector("[data-order-code]").textContent = result.code;
      message.querySelector("[data-order-total]").textContent = money(result.total);
      if (result.discount > 0) {
        const discount = message.querySelector("[data-order-discount]");
        discount.querySelector("dd").textContent = money(result.discount);
        discount.hidden = false;
      }
      message.querySelector("h2").focus();
      if (paymentMethod === "BankTransfer") window.VeggieBank?.show(result.code, result.total);
    } catch {
      status.textContent = "Không xác nhận được kết quả. Hãy kiểm tra lịch sử đơn trước khi gửi lại.";
    } finally {
      button.disabled = false;
    }
  }, true);
})();
