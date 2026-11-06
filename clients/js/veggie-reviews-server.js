(() => {
  const id = Number(new URLSearchParams(location.search).get("id"));
  const list = document.querySelector(".ltn__comment-inner");
  const area = document.querySelector(".ltn__comment-reply-area");
  if (!Number.isSafeInteger(id) || id < 1 || !list || !area) return;
  if (location.hash === "#liton_tab_details_1_2") {
    const showReviews = () => document.querySelector('a[href="#liton_tab_details_1_2"]')?.click();
    if (window.jQuery) window.jQuery(showReviews);
    else window.addEventListener("load", showReviews, { once: true });
  }
  const url = "/api/products/" + id + "/reviews";
  list.textContent = "Đang tải đánh giá…";
  area.innerHTML = '<h3>Đánh giá sản phẩm</h3><form><fieldset class="veggie-review-stars"><legend>Số sao</legend><label><input type="radio" name="rating" value="1" required><span>★</span><span class="sr-only">1 sao</span></label><label><input type="radio" name="rating" value="2" required><span>★</span><span class="sr-only">2 sao</span></label><label><input type="radio" name="rating" value="3" required><span>★</span><span class="sr-only">3 sao</span></label><label><input type="radio" name="rating" value="4" required><span>★</span><span class="sr-only">4 sao</span></label><label><input type="radio" name="rating" value="5" required><span>★</span><span class="sr-only">5 sao</span></label></fieldset><textarea name="comment" aria-label="Nhận xét" placeholder="Nhận xét của bạn" maxlength="2000" required></textarea><button type="submit" class="theme-btn-1 btn">Lưu đánh giá</button><p role="status"></p></form>';
  const form = area.querySelector("form");
  const status = form.querySelector('[role="status"]');
  const button = form.querySelector("button");
  async function refresh() {
    try {
      const response = await fetch(url);
      if (!response.ok) throw new Error();
      const reviews = await response.json();
      list.replaceChildren();
      for (const review of reviews) {
        const row = document.createElement("article");
        row.className = "veggie-review-entry";
        const name = document.createElement("strong");
        name.textContent = review.name;
        const stars = document.createElement("span");
        stars.className = "veggie-review-score";
        stars.textContent = "★".repeat(review.rating) + "☆".repeat(5 - review.rating);
        stars.setAttribute("aria-label", review.rating + " trên 5 sao");
        const comment = document.createElement("p");
        comment.textContent = review.comment;
        if (review.avatar) {
          const photo = document.createElement("img");
          photo.src = review.avatar;
          photo.alt = "";
          row.append(photo);
        }
        const date = document.createElement("time");
        date.textContent = review.createdAt ? new Date(review.createdAt).toLocaleDateString("vi-VN") : "";
        row.append(name, stars, date, comment);
        list.append(row);
      }
      if (!reviews.length) list.textContent = "Chưa có đánh giá.";
    } catch {
      list.textContent = "Không tải được đánh giá.";
    }
  }
  window.addEventListener("submit", async (event) => {
    if (event.target !== form) return;
    event.preventDefault();
    event.stopPropagation();
    if (button.disabled) return;
    button.disabled = true;
    try {
      const response = await fetch(url, {
        method: "PUT", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ rating: Number(form.elements.rating.value), comment: form.elements.comment.value.trim() }),
      });
      if (response.status === 401) {
        const link = document.createElement("a");
        link.href = "login.html";
        link.textContent = "Đăng nhập để đánh giá";
        status.replaceChildren(link);
      } else if (response.ok) {
        status.textContent = "Đã lưu đánh giá.";
        await refresh();
      } else {
        const error = await response.json().catch(()=>({})); status.textContent = error.message || "Kiểm tra số sao và nội dung nhận xét.";
      }
    } catch {
      status.textContent = "Không lưu được đánh giá. Vui lòng thử lại.";
    } finally {
      button.disabled = false;
    }
  }, true);
  void refresh();
})();

