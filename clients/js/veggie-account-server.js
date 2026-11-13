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

  const showVerifyForm = (email, hint) => {
    const verifyForm = document.createElement("form");
    verifyForm.className = "ltn__form-box contact-form-box veggie-verify-code-form";
    verifyForm.innerHTML = '<div class="veggie-verify-code-icon" aria-hidden="true"><i class="fas fa-envelope-open-text"></i></div><p class="veggie-verify-code-eyebrow">BẢO MẬT TÀI KHOẢN</p><h3>Nhập mã xác minh</h3><p id="veggie-verification-hint" class="veggie-verify-code-hint"></p><label for="veggie-verification-code">Mã gồm 8 chữ số</label><input id="veggie-verification-code" class="veggie-verify-code-input" name="code" type="text" inputmode="numeric" autocomplete="one-time-code" pattern="[0-9]{8}" minlength="8" maxlength="8" required placeholder="00000000" aria-describedby="veggie-verification-hint"><button class="theme-btn-1 btn reverse-color btn-block" type="submit">Xác minh email</button><p class="veggie-verify-code-status" role="status" aria-live="polite"></p>';
    verifyForm.querySelector(".veggie-verify-code-hint").textContent = hint;
    form.hidden = true;
    form.after(verifyForm);
    verifyForm.addEventListener("submit", async verifyEvent => {
      verifyEvent.preventDefault();
      const verifyStatus = verifyForm.querySelector('[role="status"]');
      const verifyButton = verifyForm.querySelector("button");
      verifyButton.disabled = true;
      verifyStatus.textContent = "Đang xác minh…";
      try {
        const verifyResponse = await fetch("/api/account/verify-email", {
          method: "POST", headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ email, code: verifyForm.elements.code.value.trim() })
        });
        const verifyResult = await verifyResponse.json();
        if (!verifyResponse.ok) throw new Error(verifyResult.message || "Mã chưa đúng. Hãy kiểm tra lại email.");
        verifyStatus.textContent = verifyResult.message;
        verifyForm.querySelector("input").remove();
        verifyButton.remove();
        const login = document.createElement("a");
        login.href = "login.html";
        login.className = "theme-btn-1 btn reverse-color btn-block";
        login.textContent = "Đăng nhập";
        verifyForm.append(login);
      } catch (error) {
        verifyStatus.textContent = error.message || "Không xác minh được. Vui lòng thử lại.";
        verifyButton.disabled = false;
      }
    });
  };

  const showResendOption = (email) => {
    const message = document.createElement("p");
    message.textContent = "Nếu tài khoản này chưa xác minh, bạn có thể yêu cầu gửi mã mới.";
    const button = document.createElement("button");
    button.type = "button";
    button.className = "theme-btn-1 btn reverse-color btn-block";
    button.textContent = "Gửi mã xác minh";
    button.addEventListener("click", async () => {
      button.disabled = true;
      message.textContent = "Đang gửi mã…";
      try {
        const response = await fetch("/api/account/resend-verification", {
          method: "POST", headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ email })
        });
        const result = await response.json();
        if (!response.ok) throw new Error(result.message || "Chưa gửi được mã. Hãy thử lại.");
        showVerifyForm(email, result.message);
        message.remove();
        button.remove();
      } catch (error) {
        message.textContent = error.message || "Không gửi được mã. Hãy thử lại.";
        button.disabled = false;
      }
    });
    status.replaceChildren(message, button);
  };

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
          showVerifyForm(request.email, result.message);
          return;
        }
        if (mode === "login") sessionStorage.setItem("veggie.merge-cart", "1");
        const checkout = new URLSearchParams(location.search).get("returnTo") === "checkout";
        location.href = checkout ? "checkout.html" : "account.html";
        return;
      }
      const error = await response.json();
      if (mode === "register" && response.status === 409) {
        status.textContent = error.message || "Email đã được đăng ký.";
        showResendOption(request.email);
        return;
      }
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







