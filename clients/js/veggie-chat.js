(() => {
  const widget = document.createElement("aside");
  widget.className = "veggie-chat";
  widget.innerHTML = `
    <button type="button" aria-controls="veggie-chat-panel" aria-expanded="false" aria-label="Mở Veggie AI"><span aria-hidden="true">💬</span></button>
    <section id="veggie-chat-panel" aria-labelledby="veggie-chat-title" hidden>
      <header><h2 id="veggie-chat-title">Hỗ trợ trực tuyến</h2><button type="button" class="veggie-chat-close" aria-label="Đóng khung chat">×</button></header>
      <div class="veggie-chat-log" role="log" aria-label="Cuộc trò chuyện">
        <p>Xin chào 👋, tôi có thể giúp gì cho bạn?</p>
      </div>
      <p class="veggie-chat-note">Hỏi về sản phẩm và giao hàng. Tránh nhập thông tin cá nhân.</p>
      <form class="veggie-chat-form">
        <input type="text" aria-label="Câu hỏi của bạn" placeholder="Nhập tin nhắn..." maxlength="500" required>
        <button type="submit">Gửi</button>
      </form>
    </section>`;

  const toggle = widget.querySelector("button");
  const panel = widget.querySelector("section");
  const form = widget.querySelector("form");
  const input = form.querySelector("input");
  const log = widget.querySelector('[role="log"]');

  function setOpen(open) {
    panel.hidden = !open;
    toggle.setAttribute("aria-expanded", String(open));
    toggle.setAttribute("aria-label", open ? "Đóng Veggie AI" : "Mở Veggie AI");
    (open ? input : toggle).focus();
  }

  widget.querySelector(".veggie-chat-close").addEventListener("click", () => setOpen(false));
  toggle.addEventListener("click", () => setOpen(panel.hidden));
  widget.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && !panel.hidden) setOpen(false);
  });
  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    const button = form.querySelector('button[type="submit"]');
    if (button.disabled) return;
    const question = input.value.trim();
    if (!question) return;

    const message = document.createElement("p");
    message.className = "veggie-chat-question";
    message.textContent = question;
    const notice = document.createElement("p");
    notice.textContent = "Đang trả lời…";
    log.append(message, notice);
    log.scrollTop = log.scrollHeight;
    form.reset();
    input.focus();
    button.disabled = true;
    try {
      if (!document.querySelector('script[src^="js/veggie-cart-server.js"]')) {
        notice.textContent = "Hãy mở bản ASP.NET để sử dụng Veggie AI.";
        return;
      }
      const response = await fetch("/api/chat", {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ question })
      });
      if (response.status === 401) {
        notice.textContent = "Vui lòng đăng nhập để sử dụng Veggie AI.";
        return;
      }
      const result = await response.json();
      notice.textContent = result.answer || result.message || "Veggie AI chưa thể trả lời.";
    } catch {
      notice.textContent = "Không kết nối được Veggie AI. Vui lòng thử lại.";
    } finally {
      button.disabled = false;
      log.scrollTop = log.scrollHeight;
    }
  });

  document.body.append(widget);
  document.addEventListener('DOMContentLoaded',()=>{if(document.querySelector('script[src^="js/veggie-cart-server.js"]'))fetch('/api/chat/history',{cache:'no-store'}).then(r=>r.ok?r.json():[]).then(messages=>{for(const m of messages){const q=document.createElement('p'),a=document.createElement('p');q.className='veggie-chat-question';q.textContent=m.question;a.textContent=m.answer;log.append(q,a);}log.scrollTop=log.scrollHeight;}).catch(()=>{});},{once:true});
})();





