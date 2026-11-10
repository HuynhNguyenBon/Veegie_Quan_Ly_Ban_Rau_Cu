(() => {
  const form = document.getElementById("account-security-form");
  if (!form) return;
  const query = new URLSearchParams(location.hash.slice(1));
  const token = query.get("token") || "";
  const purpose = query.get("purpose");
  // Keep the token in memory, not browser history, referrers or localStorage.
  history.replaceState(null, "", location.pathname);
  const reset = purpose === "reset";
  document.getElementById("security-title").textContent = reset ? "Đặt lại mật khẩu" : "Xác minh email";
  const fields = document.getElementById("security-passwords");
  fields.hidden = !reset;
  fields.querySelectorAll("input").forEach(input => { input.disabled = !reset; });
  const button = form.querySelector('button[type="submit"]');
  button.textContent = reset ? "Lưu mật khẩu mới" : "Xác minh email";
  const status = form.querySelector('[role="status"]');
  if (!/^[a-f0-9]{64}$/i.test(token) || !["verify", "reset"].includes(purpose)) {
    status.textContent = "Hãy mở liên kết trong email để tiếp tục. Bạn có thể yêu cầu liên kết mới ở trang đăng nhập.";
    button.disabled = true;
  }
  form.addEventListener("submit", async event => {
    event.preventDefault();
    if (button.disabled) return;
    if (reset && form.elements.password.value !== form.elements.confirmPassword.value) {
      status.textContent = "Mật khẩu nhập lại không khớp."; return;
    }
    button.disabled = true;
    status.textContent = "Đang xử lý…";
    try {
      const body = reset ? { token, password: form.elements.password.value, confirmPassword: form.elements.confirmPassword.value } : { token };
      const response = await fetch("/api/account/" + (reset ? "reset-password" : "verify-email"), {
        method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body)
      });
      const result = await response.json().catch(() => ({}));
      status.textContent = result.message || (response.status === 429 ? "Hãy thử lại sau một phút." : "Vui lòng kiểm tra thông tin đã nhập.");
      if (response.ok) { form.reset(); fields.hidden = true; button.hidden = true; }
      else button.disabled = false;
    } catch { status.textContent = "Không kết nối được máy chủ. Vui lòng thử lại."; button.disabled = false; }
  });
})();
