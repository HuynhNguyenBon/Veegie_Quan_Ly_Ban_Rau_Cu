(() => {
  const form = document.getElementById("contact-form");
  if (!form || form.dataset.serverContact) return;
  form.dataset.serverContact = "true";
  const quote = location.pathname.endsWith("/quote.html");
  if(form.elements.message)form.elements.message.maxLength=quote?1500:1800;
  if (quote && !form.elements.quoteProduct) {
    document.getElementById("veggie-contact-title").textContent = "Yêu cầu báo giá";
    const details = document.createElement("fieldset");
    details.className = "veggie-quote-fields";
    details.innerHTML = '<legend>Thông tin cần báo giá</legend><label>Sản phẩm cần mua<input name="quoteProduct" maxlength="180" placeholder="Ví dụ: Bông cải xanh" required></label><label>Số lượng và đơn vị<input name="quoteQuantity" maxlength="60" placeholder="Ví dụ: 10 kg" required></label><label>Ngày cần giao<input name="quoteDate" type="date"></label>';
    form.elements.message.before(details);
    form.elements.message.placeholder = "Ghi chú thêm về yêu cầu báo giá";
    form.elements.message.required = false;
    form.elements.message.maxLength = 1650;
    form.querySelector('[type="submit"]').textContent = "Gửi yêu cầu báo giá";
  }
  const deliveryDate = form.elements.quoteDate;
  if (deliveryDate) {
    const now = new Date();
    deliveryDate.min = [
      now.getFullYear(),
      String(now.getMonth() + 1).padStart(2, "0"),
      String(now.getDate()).padStart(2, "0"),
    ].join("-");
  }
  const status = document.createElement("p");
  status.setAttribute("role", "status");
  form.append(status);
  const button = form.querySelector('[type="submit"]');
  window.addEventListener("submit", async (event) => {
    if (event.target !== form) return;
    event.preventDefault();
    event.stopPropagation();
    if (button.disabled) return;
    const { name, email, phone, message, quoteProduct, quoteQuantity, quoteDate } = Object.fromEntries(new FormData(form));
    const content = quote
      ? ["[Yêu cầu báo giá]", "Sản phẩm: " + quoteProduct, "Số lượng: " + quoteQuantity,
        "Ngày cần giao: " + (quoteDate || "Chưa xác định"), message].join("\n")
      : [form.querySelector("select")?.selectedOptions[0]?.textContent.trim(), message].filter(Boolean).join("\n");
    button.disabled = true;
    status.textContent = "Đang gửi…";
    try {
      const response = await fetch("/api/contacts", {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name, email, phone, message: content }),
      });
      if (response.ok) form.reset();
      status.textContent = response.ok ? "Đã lưu yêu cầu. Thông báo sẽ được chuyển đến email của cửa hàng."
        : response.status === 400 ? "Vui lòng kiểm tra thông tin và độ dài nội dung."
        : "Chưa gửi được yêu cầu. Vui lòng thử lại.";
    } catch {
      status.textContent = "Chưa gửi được yêu cầu. Vui lòng thử lại.";
    } finally {
      button.disabled = false;
    }
  }, true);
})();




