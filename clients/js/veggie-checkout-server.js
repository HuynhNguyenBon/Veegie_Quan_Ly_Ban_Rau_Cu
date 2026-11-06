(() => {
  const form = document.getElementById("veggie-checkout-form");
  if (!form) return;
  const summary = form.querySelector(".veggie-order-summary");
  summary.querySelector("h2").textContent = "Đơn hàng";
  const bankPayment = summary.querySelector('input[value="Chuyển khoản"]');
  bankPayment.value = "BankTransfer";
  bankPayment.closest("label").replaceChildren(bankPayment, " Chuyển khoản Vietcombank");
  const button = summary.querySelector('button[type="submit"]');
  button.textContent = "Đặt hàng";
  const city = form.elements.namedItem("city");
  fetch("/api/account/me").then(response=>response.ok?response.json():null).then(user=>{
    if(!user)return;
    form.elements.email.value=user.email;
    form.elements.email.readOnly=true;
  }).catch(()=>{});
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

  let lastPayload, requestId;
  window.addEventListener("submit", async (event) => {
    if (event.target !== form) return;
    event.preventDefault();
    event.stopPropagation();
    if (button.disabled) return;
    const cart = window.VeggieCart;
    const products = window.VeggieCatalog?.products || [];
    const items = cart.getItems().map(({ name, image, quantity }) => ({
      id: products.find((product) => product.name === name && product.image === image)?.id,
      quantity,
    }));
    if (items.some((item) => !item.id)) {
      status.textContent = "Giỏ có sản phẩm không còn khớp danh mục. Hãy xóa sản phẩm cũ và thêm lại từ Cửa hàng.";
      return;
    }
    if (!items.length) return;
    const { name, phone, address, city, note } = Object.fromEntries(new FormData(form));
    const paymentMethod = form.elements.payment.value;
    const payload = { name, phone, address, city, note, items, paymentMethod };
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
      if (response.status === 401) {
        location.href = "login.html?returnTo=checkout";
        return;
      }
      const result = await response.json();
      if (!response.ok) {
        status.textContent = result.message || "Vui lòng kiểm tra thông tin đặt hàng.";
        return;
      }
      cart.clear();
      form.hidden = true;
      const message = document.getElementById("veggie-checkout-summary");
      message.textContent = "Đã đặt đơn " + result.code + ". Tổng tiền: " +
        new Intl.NumberFormat("vi-VN").format(result.total) + " ₫. ";
      const link = document.createElement("a");
      link.href = "account.html";
      link.textContent = "Xem lịch sử đơn hàng";
      message.append(link);
      if (paymentMethod === "BankTransfer") window.VeggieBank?.show(result.code, result.total);
    } catch {
      status.textContent = "Không xác nhận được kết quả. Hãy kiểm tra lịch sử đơn trước khi gửi lại.";
    } finally {
      button.disabled = false;
    }
  }, true);
})();




