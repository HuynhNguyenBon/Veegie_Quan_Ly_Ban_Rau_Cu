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
  area.innerHTML = '<form class="veggie-review-form"><h3>Thêm đánh giá</h3><div class="veggie-review-rating"><strong id="veggie-rating-label">Số sao:</strong><div class="veggie-review-stars" role="group" aria-labelledby="veggie-rating-label"><label><input type="radio" name="rating" value="1" required><span aria-hidden="true">★</span><span class="sr-only">1 sao</span></label><label><input type="radio" name="rating" value="2" required><span aria-hidden="true">★</span><span class="sr-only">2 sao</span></label><label><input type="radio" name="rating" value="3" required><span aria-hidden="true">★</span><span class="sr-only">3 sao</span></label><label><input type="radio" name="rating" value="4" required><span aria-hidden="true">★</span><span class="sr-only">4 sao</span></label><label><input type="radio" name="rating" value="5" required><span aria-hidden="true">★</span><span class="sr-only">5 sao</span></label></div></div><div class="veggie-review-comment"><textarea name="comment" aria-label="Nhận xét" placeholder="Nhập đánh giá của bạn ..." maxlength="2000" required></textarea><i class="fas fa-pencil-alt" aria-hidden="true"></i></div><button type="submit" class="theme-btn-1 btn">GỬI</button><p role="status"></p></form>';
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
        const details = document.createElement("div");
        const name = document.createElement("strong");
        name.textContent = review.name;
        const stars = document.createElement("span");
        stars.className = "veggie-review-score";
        stars.textContent = "★".repeat(review.rating) + "☆".repeat(5 - review.rating);
        stars.setAttribute("aria-label", review.rating + " trên 5 sao");
        const comment = document.createElement("p");
        comment.textContent = review.comment;
        const photo = document.createElement("span");
        photo.className = "veggie-review-avatar";
        photo.textContent = (review.name || "?").trim().charAt(0).toUpperCase();
        photo.setAttribute("aria-hidden", "true");
        if (review.avatar) {
          const image = document.createElement("img");
          image.src = review.avatar;
          image.alt = "";
          image.addEventListener("error", () => image.remove(), { once: true });
          photo.append(image);
        }
        const date = document.createElement("time");
        if (review.createdAt) {
          date.dateTime = review.createdAt;
          date.textContent = new Date(review.createdAt).toLocaleDateString("vi-VN").replaceAll("/", "-");
        }
        details.append(name, stars, comment);
        row.append(photo, details, date);
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

