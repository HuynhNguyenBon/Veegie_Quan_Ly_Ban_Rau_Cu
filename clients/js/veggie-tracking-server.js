(() => {
  const form = document.querySelector(".ltn__login-area form");
  if (!form) return;
  const status = document.createElement("p");
  status.setAttribute("role", "status");
  form.append(status);
  const button = form.querySelector('button[type="submit"]');
  const labels = { pending: "Chờ xác nhận", confirmed: "Đã xác nhận", shipping: "Đang giao", delivered: "Đã giao" };
  window.addEventListener("submit", async (event) => {
    if (event.target !== form) return;
    event.preventDefault();
    event.stopPropagation();
    if (button.disabled) return;
    button.disabled = true;
    status.textContent = "Đang tra cứu…";
    try {
      const data = Object.fromEntries(new FormData(form));
      const response = await fetch("/api/orders/track", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ code: data.code, email: data.email }),
      });
      if (response.status === 401) {
        const link = document.createElement("a");
        link.href = "login.html";
        link.textContent = "Đăng nhập để tra cứu đơn hàng";
        status.replaceChildren(link);
        return;
      }
      const result = await response.json();
      status.textContent = response.ok
        ? result.code + " · " + (labels[result.status] || result.status) + " · " +
          new Intl.NumberFormat("vi-VN").format(result.total) + " ₫"
        : result.message || "Vui lòng kiểm tra mã đơn và email.";
    } catch {
      status.textContent = "Không tra cứu được. Vui lòng thử lại.";
    } finally {
      button.disabled = false;
    }
  }, true);
})();
