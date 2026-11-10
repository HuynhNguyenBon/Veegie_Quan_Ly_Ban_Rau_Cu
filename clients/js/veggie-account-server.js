(() => {
  const form = document.querySelector(".ltn__login-area form.contact-form-box");
  const mode = location.pathname.endsWith("/register.html") ? "register" : "login";
  if (!form || !/\/(login|register)\.html$/.test(location.pathname)) return;

  const status = document.createElement("p");
  status.setAttribute("role", "status");
  form.append(status);
  let sending = false;
  const resend = document.getElementById("resend-verification");
  if (resend) resend.hidden = true;

  window.addEventListener("submit", async (event) => {
    if (event.target !== form) return;
    event.preventDefault();
    event.stopPropagation();
    if (sending) return;

    const fields = new FormData(form);
    const request = Object.fromEntries(fields);
    if (mode === "register") {
      request.acceptPrivacyPolicy = fields.has("acceptPrivacyPolicy");
      if (request.password !== request.confirmpassword) {
        status.textContent = "Mật khẩu nhập lại không khớp.";
        return;
      }
    }
    sending = true;
    status.textContent = "Đang xử lý…";
    try {
      const response = await fetch("/api/account/" + mode, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(request),
      });
      if (response.ok) {
        if (mode === "register") {
          const result = await response.json();
          status.textContent = result.message;
          return;
        }
        if (mode === "login") sessionStorage.setItem("veggie.merge-cart", "1");
        const checkout = new URLSearchParams(location.search).get("returnTo") === "checkout";
        location.href = checkout ? "checkout.html" : "account.html";
        return;
      }
      const error = await response.json();
      if (error.adminPortal) {
        const link = document.createElement("a");
        link.href = "/admin/login";
        link.textContent = "Mở trang đăng nhập quản trị";
        status.replaceChildren(link);
        return;
      }
      if (resend) resend.hidden = response.status !== 403 || error.adminPortal === false;
      status.textContent = error.message || "Vui lòng kiểm tra thông tin đã nhập.";
    } catch {
      status.textContent = "Không kết nối được máy chủ. Vui lòng thử lại.";
    } finally {
      sending = false;
    }
  }, true);
})();







