(() => {
  const button = document.getElementById("resend-verification");
  if (!button) return;
  button.addEventListener("click", async () => {
    const form = button.closest("form");
    const email = form.querySelector('[name="email"]');
    if (!email.reportValidity()) return;
    const status = form.querySelector('[role="status"]');
    button.disabled = true;
    try {
      const response = await fetch("/api/account/resend-verification", {
        method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ email: email.value.trim() })
      });
      const result = await response.json().catch(() => ({}));
      status.textContent = result.message || "Hãy thử lại sau một phút.";
    } catch { status.textContent = "Không kết nối được máy chủ."; }
    finally { button.disabled = false; }
  });
})();
