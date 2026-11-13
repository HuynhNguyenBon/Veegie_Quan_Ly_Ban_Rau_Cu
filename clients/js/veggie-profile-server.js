(async () => {
  const panel = document.querySelector(".veggie-account-gate");
  if (!panel || panel.dataset.profileLoaded) return;
  panel.dataset.profileLoaded = "true";
  try {
    const response = await fetch("/api/account/me");
    if (response.status === 401) return;
    if (!response.ok) throw new Error();
    const user = await response.json();
    const heading = document.createElement("h2");
    heading.textContent = "Xin chào, " + user.name;
    const history = document.createElement("div");
    history.setAttribute("role", "status");
    panel.classList.add("veggie-profile");
    const header = document.createElement("div");
    header.className = "veggie-profile-header";
    const identity = document.createElement("div");
    identity.className = "veggie-profile-identity";
    const avatar = document.createElement("button");
    avatar.type = "button"; avatar.setAttribute("aria-label", "Tùy chọn ảnh đại diện");
    avatar.className = "veggie-profile-avatar";
    if (user.avatar) {
      const image = document.createElement("img");
      image.src = user.avatar;
      image.alt = "Ảnh đại diện";
      avatar.append(image);
    } else avatar.textContent = user.name.trim().charAt(0).toUpperCase();
    identity.append(avatar, heading);
    const cover = document.createElement("div");
    cover.className = "veggie-profile-cover";
    const coverImage = user.coverImage || "img/bg/13.jpg";
    const coverView = document.createElement("button");
    coverView.type = "button";
    coverView.className = "veggie-cover-view";
    coverView.setAttribute("aria-label", "Xem ảnh bìa");
    const coverPhoto = document.createElement("img");
    coverPhoto.src = coverImage;
    coverPhoto.alt = "Ảnh bìa";
    coverView.append(coverPhoto);
    const coverEdit = document.createElement("button");
    coverEdit.type = "button";
    coverEdit.className = "veggie-cover-edit";
    coverEdit.textContent = "Chỉnh sửa ảnh bìa";
    cover.append(coverView, coverEdit);

    const menu = document.createElement("div");
    menu.className = "veggie-avatar-menu";
    menu.hidden = true;
    avatar.setAttribute("aria-expanded", "false");
    const feedback = document.createElement("p");
    feedback.setAttribute("role", "status");
    const picker = document.createElement("input");
    picker.type = "file";
    picker.accept = "image/png,image/jpeg";
    picker.hidden = true;
    let changeCover = false;

    function viewPhoto(src, title) {
      const dialog = document.createElement("dialog");
      dialog.className = "veggie-photo-dialog";
      dialog.setAttribute("aria-label", title);
      const image = document.createElement("img");
      image.src = src;
      image.alt = title;
      const close = document.createElement("button");
      close.type = "button";
      close.textContent = "Đóng";
      close.addEventListener("click", () => dialog.close());
      dialog.addEventListener("close", () => dialog.remove(), { once: true });
      dialog.append(close, image);
      document.body.append(dialog);
      dialog.showModal();
    }

    function choosePhoto(isCover) {
      menu.hidden = true;
      avatar.setAttribute("aria-expanded", "false");
      changeCover = isCover;
      picker.click();
    }

    if (user.avatar) {
      const view = document.createElement("button");
      view.type = "button";
      view.textContent = "Xem ảnh đại diện";
      view.addEventListener("click", () => {
        menu.hidden = true;
        avatar.setAttribute("aria-expanded", "false");
        viewPhoto(user.avatar, "Ảnh đại diện");
      });
      menu.append(view);
    }
    const choose = document.createElement("button");
    choose.type = "button";
    choose.textContent = "Chọn ảnh đại diện";
    choose.addEventListener("click", () => choosePhoto(false));
    menu.append(choose);
    avatar.after(menu);
    avatar.addEventListener("click", () => {
      menu.hidden = !menu.hidden;
      avatar.setAttribute("aria-expanded", String(!menu.hidden));
    });
    coverView.addEventListener("click", () => viewPhoto(coverImage, "Ảnh bìa"));
    coverEdit.addEventListener("click", () => choosePhoto(true));
    picker.addEventListener("change", async () => {
      const photo = picker.files[0];
      if (!photo) return;
      picker.value = "";
      if (photo.size > 2 * 1024 * 1024) {
        feedback.textContent = "Ảnh tối đa 2 MB.";
        return;
      }
      const data = new FormData();
      data.set("name", user.name);
      data.set("phone", user.phoneNumber || "");
      data.set("avatar", photo);
      data.set("cover", String(changeCover));
      try {
        feedback.textContent = "Đang lưu ảnh…";
        const response = await fetch("/api/account/profile", { method: "PUT", body: data });
        if (!response.ok) throw new Error();
        location.reload();
      } catch {
        feedback.textContent = "Không lưu được ảnh. Hãy chọn ảnh PNG hoặc JPEG.";
      }
    });
    const bar = document.createElement("div");
    bar.className = "veggie-profile-bar";
    const editButton = document.createElement("button");
    editButton.type = "button";
    editButton.className = "theme-btn-1 btn";
    editButton.textContent = "Chỉnh sửa hồ sơ";
    editButton.setAttribute("aria-expanded", "false");
    bar.append(identity, editButton);
    header.append(cover, bar, picker, feedback);
    const ordersSection = document.createElement("section");
    const ordersTitle = document.createElement("h3");
    ordersTitle.textContent = "Lịch sử mua hàng";
    ordersSection.append(ordersTitle, history);
    const orderNotice = sessionStorage.getItem("veggie-order-notice");
    if (orderNotice) {
      sessionStorage.removeItem("veggie-order-notice");
      const notice = document.createElement("p");
      notice.className = "veggie-order-notice";
      notice.setAttribute("role", "status");
      notice.textContent = orderNotice;
      ordersTitle.after(notice);
    }
    const details = document.createElement("section");
    details.innerHTML = '<h3>Thông tin tài khoản</h3><form class="veggie-profile-edit"><label>Họ và tên<input name="name" maxlength="120" required></label><label>Email<input type="email" readonly></label><label>Số điện thoại<input name="phone" type="tel" maxlength="25"></label><label>Địa chỉ<input name="address" maxlength="400" autocomplete="street-address"></label><div class="veggie-profile-actions"><button type="submit" class="theme-btn-1 btn">Lưu thông tin</button></div><p role="status"></p></form>';
    const editProfile = details.querySelector("form");
    editProfile.elements.namedItem("name").value = user.name;
    editProfile.querySelector('[type="email"]').value = user.email || "";
    editProfile.elements.phone.value = user.phoneNumber || "";
    editProfile.elements.address.value = user.address || "";
    editProfile.addEventListener("submit", async event => {
      event.preventDefault();
      const button = editProfile.querySelector("button");
      const feedback = editProfile.querySelector('[role="status"]');
      const data = new FormData(editProfile);
      button.disabled = true;
      try {
        const result = await fetch("/api/account/profile", { method: "PUT", body: data });
        if (!result.ok) throw new Error();
        location.reload();
      } catch {
        feedback.textContent = "Không lưu được. Kiểm tra thông tin hoặc chọn ảnh PNG/JPEG.";
        button.disabled = false;
      }
    });
    panel.replaceChildren(header, details, ordersSection);

    const loyaltySection = document.createElement("section");
    loyaltySection.className = "veggie-loyalty-section";
    loyaltySection.innerHTML = `
      <h3>Điểm Veggie & đổi quà</h3>
      <div class="veggie-loyalty-overview">
        <div class="veggie-loyalty-wallet-copy">
          <span class="veggie-loyalty-eyebrow">Ví điểm của bạn</span>
          <p class="veggie-loyalty-wallet-value"><strong class="veggie-loyalty-points">—</strong><span>điểm</span></p>
          <p class="veggie-loyalty-rule"></p>
        </div>
        <span class="veggie-loyalty-wallet-icon" aria-hidden="true"><i class="fa fa-gift"></i></span>
        <div class="veggie-loyalty-progress">
          <div class="veggie-loyalty-progress-label"><span class="veggie-loyalty-next-label">Đang tìm phần quà phù hợp…</span><strong class="veggie-loyalty-next-points"></strong></div>
          <div class="veggie-loyalty-progress-track" role="progressbar" aria-label="Tiến độ tích điểm đổi quà" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0"><span></span></div>
        </div>
      </div>
      <p class="veggie-loyalty-feedback" role="status" aria-live="polite"></p>
      <div class="veggie-rewards-heading"><div><h4>Quà dành cho bạn</h4><p>Dùng điểm tích lũy để đổi voucher hoặc quà tặng từ Veggie.</p></div><span class="veggie-reward-count"></span></div>
      <div class="veggie-reward-grid"></div>
      <div class="veggie-loyalty-history-grid"><div class="veggie-redemption-history"></div><div class="veggie-points-history"></div></div>`;
    const loyaltyFeedback = loyaltySection.querySelector(".veggie-loyalty-feedback");
    const rewardGrid = loyaltySection.querySelector(".veggie-reward-grid");
    const loyaltyPoints = loyaltySection.querySelector(".veggie-loyalty-points");
    const loyaltyRule = loyaltySection.querySelector(".veggie-loyalty-rule");
    const nextLabel = loyaltySection.querySelector(".veggie-loyalty-next-label");
    const nextPoints = loyaltySection.querySelector(".veggie-loyalty-next-points");
    const progress = loyaltySection.querySelector(".veggie-loyalty-progress-track");
    const rewardCount = loyaltySection.querySelector(".veggie-reward-count");
    const numberFormat = new Intl.NumberFormat("vi-VN");
    const loyaltyStatus = { issued: "Voucher sẵn sàng dùng", pending: "Chờ cửa hàng giao quà", fulfilled: "Đã giao/đã nhận", used: "Voucher đã sử dụng", expired: "Voucher đã hết hạn" };

    async function loadLoyalty() {
      try {
        const response = await fetch("/api/loyalty", { cache: "no-store" });
        if (!response.ok) throw new Error();
        const data = await response.json();
        loyaltyPoints.textContent = numberFormat.format(data.balance);
        loyaltyRule.textContent = `Mỗi ${numberFormat.format(data.currencyPerPoint)}₫ trong đơn hàng giao thành công giúp bạn nhận 1 điểm.`;
        const nextReward = data.rewards
          .filter(reward => reward.stock !== 0 && reward.pointsCost > data.balance)
          .sort((a, b) => a.pointsCost - b.pointsCost)[0];
        const canRedeem = data.rewards.some(reward => reward.stock !== 0 && reward.pointsCost <= data.balance);
        if (nextReward) {
          nextLabel.textContent = `Mục tiêu tiếp theo · ${nextReward.name}`;
          nextPoints.textContent = `Còn ${numberFormat.format(nextReward.pointsCost - data.balance)} điểm`;
          const percent = Math.min(100, Math.round(data.balance / nextReward.pointsCost * 100));
          progress.setAttribute("aria-valuenow", String(percent));
          progress.querySelector("span").style.width = `${percent}%`;
        } else if (canRedeem) {
          nextLabel.textContent = "Bạn đã đủ điểm để đổi quà";
          nextPoints.textContent = "Sẵn sàng đổi";
          progress.setAttribute("aria-valuenow", "100");
          progress.querySelector("span").style.width = "100%";
        } else {
          nextLabel.textContent = data.rewards.length ? "Quà hiện chưa khả dụng" : "Veggie đang chuẩn bị quà tặng";
          nextPoints.textContent = "";
          progress.setAttribute("aria-valuenow", "0");
          progress.querySelector("span").style.width = "0%";
        }
        rewardCount.textContent = `${data.rewards.length} phần quà`;
        rewardGrid.replaceChildren();
        if (!data.rewards.length) {
          const emptyRewards = document.createElement("p");
          emptyRewards.className = "veggie-loyalty-empty";
          emptyRewards.textContent = "Cửa hàng đang chuẩn bị thêm phần quà. Bạn quay lại sau nhé.";
          rewardGrid.append(emptyRewards);
        }
        for (const reward of data.rewards) {
          const card = document.createElement("article");
          const affordable = data.balance >= reward.pointsCost;
          const outOfStock = reward.stock === 0;
          card.className = `veggie-reward-card${affordable ? " is-affordable" : " is-locked"}`;
          const cardTop = document.createElement("div");
          cardTop.className = "veggie-reward-card-top";
          const icon = document.createElement("span");
          icon.className = "veggie-reward-icon";
          icon.setAttribute("aria-hidden", "true");
          const iconGlyph = document.createElement("i");
          iconGlyph.className = `fas ${reward.rewardType === "voucher" ? "fa-ticket-alt" : "fa-gift"}`;
          icon.append(iconGlyph);
          const type = document.createElement("span");
          type.className = "veggie-reward-type";
          type.textContent = reward.rewardType === "voucher" ? "VOUCHER ƯU ĐÃI" : "QUÀ THÀNH VIÊN";
          cardTop.append(icon, type);
          const title = document.createElement("h4");
          title.textContent = reward.name;
          title.className = "veggie-reward-title";
          const description = document.createElement("p");
          description.textContent = reward.description;
          description.className = "veggie-reward-description";
          const costRow = document.createElement("div");
          costRow.className = "veggie-reward-cost-row";
          const cost = document.createElement("strong");
          cost.className = "veggie-reward-cost";
          cost.textContent = numberFormat.format(reward.pointsCost) + " điểm";
          costRow.append(cost);
          const stock = document.createElement("small");
          stock.className = "veggie-reward-stock";
          stock.textContent = reward.stock === null ? "Không giới hạn" : reward.stock > 0 ? `Còn ${reward.stock} phần` : "Tạm hết quà";
          costRow.append(stock);
          const availability = document.createElement("p");
          availability.className = "veggie-reward-availability";
          availability.textContent = outOfStock ? "Quà đang tạm hết." : affordable ? "Bạn đã có đủ điểm để đổi." : `Còn thiếu ${numberFormat.format(reward.pointsCost - data.balance)} điểm.`;
          const redeem = document.createElement("button");
          redeem.type = "button";
          redeem.className = "theme-btn-1 btn";
          redeem.textContent = outOfStock ? "Tạm hết quà" : affordable ? (reward.rewardType === "voucher" ? "Đổi voucher" : "Đổi quà") : "Chưa đủ điểm";
          redeem.disabled = !affordable || outOfStock;
          redeem.addEventListener("click", async () => {
            if (!window.confirm(`Dùng ${numberFormat.format(reward.pointsCost)} điểm để đổi “${reward.name}”?`)) return;
            redeem.disabled = true;
            loyaltyFeedback.textContent = "Đang đổi quà…";
            try {
              const result = await fetch(`/api/loyalty/rewards/${reward.id}/redeem`, { method: "POST" });
              const message = await result.json().catch(() => ({}));
              if (!result.ok) throw new Error(message.message || "Chưa đổi được quà. Hãy tải lại trang và thử lại.");
              loyaltyFeedback.textContent = message.code ? `${message.message} Mã của bạn: ${message.code}` : message.message;
              await loadLoyalty();
            } catch (error) {
              loyaltyFeedback.textContent = error.message;
              redeem.disabled = false;
            }
          });
          card.append(cardTop, title, description, costRow, availability, redeem);
          rewardGrid.append(card);
        }

        const redemptions = document.createElement("div");
        redemptions.className = "veggie-redemption-list";
        const redemptionTitle = document.createElement("h4");
        redemptionTitle.textContent = "Quà đã đổi";
        redemptions.append(redemptionTitle);
        if (!data.redemptions.length) {
          const empty = document.createElement("p");
          empty.className = "veggie-loyalty-empty";
          empty.textContent = "Bạn chưa đổi quà. Chọn một phần quà ở phía trên để bắt đầu nhé.";
          redemptions.append(empty);
        }
        for (const item of data.redemptions) {
          const row = document.createElement("article");
          const text = document.createElement("span");
          text.textContent = `${item.rewardName} · ${loyaltyStatus[item.status] || item.status} · ${new Date(item.redeemedAt).toLocaleDateString("vi-VN")}`;
          row.className = "veggie-redemption-entry";
          row.append(text);
          if (item.code) {
            const code = document.createElement("code");
            code.textContent = item.code;
            row.append(code);
            const expiry = document.createElement("small");
            expiry.textContent = item.expiresAt ? `Hạn dùng ${new Date(item.expiresAt).toLocaleDateString("vi-VN")}` : "";
            row.append(expiry);
            const copy = document.createElement("button");
            copy.type = "button";
            copy.textContent = "Sao chép mã";
            copy.addEventListener("click", async () => {
              try { await navigator.clipboard.writeText(item.code); copy.textContent = "Đã sao chép"; }
              catch { copy.textContent = item.code; }
            });
            row.append(copy);
          }
          redemptions.append(row);
        }
        loyaltySection.querySelector(".veggie-redemption-history").replaceChildren(redemptions);

        const pointHistory = document.createElement("div");
        pointHistory.className = "veggie-points-list";
        const historyTitle = document.createElement("h4");
        historyTitle.textContent = "Lịch sử điểm";
        pointHistory.append(historyTitle);
        if (!data.transactions.length) {
          const empty = document.createElement("p");
          empty.className = "veggie-loyalty-empty";
          empty.textContent = "Điểm sẽ được cộng sau khi đơn hàng của bạn giao thành công.";
          pointHistory.append(empty);
        }
        for (const item of data.transactions) {
          const row = document.createElement("article");
          row.className = "veggie-points-entry";
          const delta = item.pointsDelta > 0 ? `+${numberFormat.format(item.pointsDelta)}` : numberFormat.format(item.pointsDelta);
          const amount = document.createElement("strong");
          amount.className = `veggie-points-delta${item.pointsDelta < 0 ? " is-negative" : ""}`;
          amount.textContent = `${delta} điểm`;
          const note = document.createElement("span");
          note.textContent = item.note;
          const date = document.createElement("time");
          date.dateTime = item.createdAt;
          date.textContent = new Date(item.createdAt).toLocaleDateString("vi-VN");
          row.append(amount, note, date);
          pointHistory.append(row);
        }
        loyaltySection.querySelector(".veggie-points-history").replaceChildren(pointHistory);
      } catch {
        loyaltyPoints.textContent = "—";
        loyaltyRule.textContent = "Chưa tải được ví điểm. Hãy thử tải lại trang.";
        nextLabel.textContent = "Không tải được thông tin phần quà";
        nextPoints.textContent = "";
      }
    }
    await loadLoyalty();
    panel.append(loyaltySection);

    const ordersResponse = await fetch("/api/orders");
    if (!ordersResponse.ok) throw new Error();
    const orders = await ordersResponse.json();
    if (!orders.length) history.textContent = "Bạn chưa có đơn hàng.";
    const gatewayResponse = await fetch("/api/momo/availability");
    const gateway = gatewayResponse.ok ? await gatewayResponse.json() : { enabled: false };
    for (const order of orders) {
      const row = document.createElement("article");
      row.className = "veggie-order-card";
      const total = new Intl.NumberFormat("vi-VN").format(order.total);
      const top=document.createElement("div"),code=document.createElement("strong"),status=document.createElement("span"),meta=document.createElement("p");
      top.className="veggie-order-card-top";code.textContent=order.code;
      status.className="veggie-order-badge";status.textContent=({pending:"Chờ xác nhận",confirmed:"Đã xác nhận",shipping:"Đang giao",delivered:"Đã giao",cancelled:"Đã hủy"}[order.status]||order.status);
      top.append(code,status);
      meta.textContent="Ngày đặt: "+new Date(order.createdAt).toLocaleDateString("vi-VN")+" · Tổng tiền: "+total+" ₫";
      row.append(top,meta);

      if (order.status !== "cancelled" && order.paymentMethod === "BankTransfer" && order.paymentStatus !== "paid") {
        const payment=document.createElement("p");payment.textContent="Chuyển khoản · Chờ cửa hàng kiểm tra tiền";row.append(payment);
        const transfer = document.createElement("button");
        transfer.type = "button";
        transfer.textContent = "Xem QR chuyển khoản";
        transfer.addEventListener("click", () => window.VeggieBank?.show(order.code, order.total));
        row.append(transfer);
      }
      if (order.paymentStatus === "paid") row.append("Đã thanh toán");
      else if(order.paymentMethod === "COD")row.append("Thanh toán khi nhận hàng");
      if (order.status === "pending" && order.paymentStatus !== "paid" && order.paymentMethod !== "BankTransfer" && gateway.enabled) {
        const pay = document.createElement("button");
        pay.type = "button";
        pay.className = "theme-btn-1 btn";
        pay.textContent = "Thanh toán MoMo Test";
        pay.addEventListener("click", async () => {
          pay.disabled = true;
          try {
            const response = await fetch("/api/momo/" + order.code.slice(2), { method: "POST" });
            const result = await response.json();
            if (!response.ok) throw new Error(result.message || "Chưa mở được MoMo.");
            const target = new URL(result.payUrl);
            if (target.protocol !== "https:" || target.hostname !== "test-payment.momo.vn") throw new Error("Đường dẫn MoMo không hợp lệ.");
            location.href = target.href;
          } catch (error) {
            pay.disabled = false;
            let feedback = row.querySelector('[role="status"]');
            if (!feedback) {
              feedback = document.createElement("span");
              feedback.setAttribute("role", "status");
              row.append(feedback);
            }
            feedback.textContent = error.message || "Không kết nối được MoMo.";
          }
        });
        row.append(" ", pay);
      }
      const actions=document.createElement("div");actions.className="veggie-order-actions";
      const detailButton=document.createElement("button");detailButton.type="button";detailButton.textContent="Xem chi tiết";
      detailButton.onclick = async () => {
        detailButton.disabled = true;
        try {
          const result = await fetch("/api/orders/" + order.code.slice(2));
          if (!result.ok) throw new Error();
          const data = await result.json();
          const money = value => new Intl.NumberFormat("vi-VN").format(value) + " ₫";
          const dialog = document.createElement("dialog");
          dialog.className = "veggie-order-dialog veggie-order-detail";
          dialog.setAttribute("aria-label", "Chi tiết đơn hàng " + order.code);
          dialog.innerHTML = '<button type="button">Đóng</button><h3></h3><dl></dl><h4>Sản phẩm trong đơn hàng</h4><div class="veggie-profile-table-wrap"><table class="veggie-profile-orders"><thead><tr><th scope="col">Ảnh</th><th scope="col">Sản phẩm</th><th scope="col">Giá</th><th scope="col">Số lượng</th><th scope="col">Thành tiền</th></tr></thead><tbody></tbody></table></div><h4>Thông tin giao hàng</h4><dl></dl>';
          dialog.querySelector("h3").textContent = "Chi tiết đơn hàng " + order.code;
          const [summary, delivery] = dialog.querySelectorAll("dl");
          function addField(list, label, value) {
            const term = document.createElement("dt");
            const detail = document.createElement("dd");
            term.textContent = label;
            detail.textContent = value || "—";
            list.append(term, detail);
            return detail;
          }
          addField(summary, "Ngày đặt", new Date(data.createdAt).toLocaleDateString("vi-VN"));
          if (data.subtotal > 0) addField(summary, "Tạm tính", money(data.subtotal));
          if (data.discountAmount > 0) addField(summary, "Khuyến mãi " + (data.promotionCode || ""), "−" + money(data.discountAmount));
          if (data.shippingFee > 0) addField(summary, "Phí giao hàng", money(data.shippingFee));
          const state = addField(summary, "Trạng thái", status.textContent);
          state.className = "veggie-order-badge";
          state.dataset.orderStatus = data.status;
          const methods = { COD: "Thanh toán khi nhận hàng", BankTransfer: "Chuyển khoản ngân hàng", MoMo: "MoMo", MoMoTest: "MoMo Test" };
          addField(summary, "Phương thức thanh toán", methods[order.paymentMethod] || order.paymentMethod);
          addField(summary, "Tổng tiền", money(data.totalPrice));
          const table = dialog.querySelector("tbody");
          const reviews = document.createElement("section");
          reviews.innerHTML = '<h4>Đánh giá sản phẩm</h4><table class="veggie-order-reviews"><thead><tr><th scope="col">Sản phẩm</th><th scope="col">Đánh giá</th></tr></thead><tbody></tbody></table>';
          const reviewRows = reviews.querySelector("tbody");
          const reviewed = new Set();
          for (const item of data.items) {
            const row = table.insertRow();
            const photo = row.insertCell();
            if (item.image) {
              const img = document.createElement("img");
              img.src = item.image.startsWith("/") ? item.image : "/clients/" + item.image;
              img.alt = item.name;
              photo.append(img);
            } else photo.textContent = "—";
            const product = row.insertCell();
            const link = document.createElement("a");
            link.href = "product-details.html?id=" + item.productId;
            link.textContent = item.name;
            product.append(link);
            if (data.status === "delivered" && !reviewed.has(item.productId)) {
              reviewed.add(item.productId);
              const reviewRow = reviewRows.insertRow();
              reviewRow.insertCell().textContent = item.name;
              const review = document.createElement("a");
              review.href = link.href + "#liton_tab_details_1_2";
              review.textContent = "Đánh giá";
              review.className = "theme-btn-1 btn";
              reviewRow.insertCell().append(review);
            }
            row.insertCell().textContent = money(item.price);
            row.insertCell().textContent = item.quantity;
            row.insertCell().textContent = money(item.price * item.quantity);
          }
          addField(delivery, "Người nhận", data.address?.fullName);
          addField(delivery, "Địa chỉ", data.address?.address);
          addField(delivery, "Thành phố", data.address?.city);
          addField(delivery, "Số điện thoại", data.address?.phone);
          if (reviewRows.rows.length) dialog.append(reviews);
          const dialogActions = document.createElement("div");
          dialogActions.className = "veggie-order-actions";
          for (const action of actions.querySelectorAll("button[data-order-action]")) {
            const button = action.cloneNode(true);
            button.onclick = action.onclick;
            dialogActions.append(button);
          }
          dialog.append(dialogActions);
          dialog.querySelector("button").onclick = () => dialog.close();
          dialog.addEventListener("close", () => { dialog.remove(); detailButton.focus(); }, { once: true });
          document.body.append(dialog);
          dialog.showModal();
        } catch {
          alert("Không tải được chi tiết đơn.");
        } finally {
          detailButton.disabled = false;
        }
      };
      actions.append(detailButton);
      function orderAction(label, endpoint, question) {
        const button = document.createElement("button");
        button.type = "button";
        button.dataset.orderAction = endpoint;
        button.textContent = label;
        button.onclick = async event => {
          if (!confirm(question)) return;
          const trigger = event.currentTarget;
          trigger.disabled = true;
          try {
            const result = await fetch("/api/orders/" + order.code.slice(2) + "/" + endpoint, { method: "POST" });
            if (!result.ok) {
              const error = await result.json().catch(() => ({}));
              throw new Error(error.message || "Không thực hiện được thao tác.");
            }
            sessionStorage.setItem("veggie-order-notice", endpoint === "cancel"
              ? "Đơn hàng đã hủy và sản phẩm đã được hoàn kho."
              : "Đã xác nhận nhận hàng. Bạn có thể đánh giá sản phẩm.");
            location.hash = "don-hang";
            location.reload();
          } catch (error) {
            alert(error.message);
            trigger.disabled = false;
          }
        };
        actions.append(button);
      }
      if(order.status==='pending'&&order.paymentStatus!=='paid')orderAction('Hủy đơn','cancel','Bạn muốn hủy đơn chưa được cửa hàng xác nhận? Nếu đã chuyển tiền, hãy liên hệ cửa hàng trước khi hủy.');
      if(order.status==='shipping')orderAction('Đã nhận hàng','received','Bạn xác nhận đã nhận đủ hàng và hoàn tất thanh toán?');
      row.append(actions);
      history.append(row);
    }
    const addresses = await fetch("/api/account/addresses");
    if (addresses.ok) {
      const addressSection = document.createElement("section");
      const addressTitle = document.createElement("h3");
      addressTitle.textContent = "Địa chỉ giao hàng";
      addressSection.append(addressTitle);
      const saved = await addresses.json();
      if (!saved.length) addressSection.append("Chưa có địa chỉ giao hàng.");
      let editingId = null;
      for (const address of saved) {
        const row = document.createElement("article");row.className="veggie-address-card";
        const name=document.createElement("strong"),phone=document.createElement("p"),locationText=document.createElement("p"),actions=document.createElement("div");
        name.textContent=address.fullName;phone.textContent=address.phone;locationText.textContent=address.address+", "+address.city;actions.className="veggie-address-card-actions";
        row.append(name,phone,locationText,actions);
        if (address.isDefault) {
          const badge=document.createElement("span");badge.className="veggie-address-default";badge.textContent="Mặc định";name.after(badge);
        } else {
          const makeDefault = document.createElement("button");
          makeDefault.type = "button";
          makeDefault.textContent = "Đặt mặc định";
          makeDefault.addEventListener("click", async () => {
            makeDefault.disabled = true;
            try {
              const result = await fetch("/api/account/addresses/" + address.id + "/default", { method: "PUT" });
              if (!result.ok) throw new Error();
              location.reload();
            } catch {
              makeDefault.disabled = false;
              makeDefault.textContent = "Chưa lưu được, thử lại";
            }
          });
          actions.append(makeDefault);
        }
        const edit = document.createElement("button");
        edit.type = "button";
        edit.textContent = "Sửa địa chỉ";
        edit.addEventListener("click", () => {
          form.hidden=false;
          editingId = address.id;
          for (const field of ["fullName", "phone", "address", "city"]) {
            form.elements.namedItem(field).value = address[field];
          }
          form.querySelector('[type="submit"]').textContent = "Lưu thay đổi";
          form.elements.fullName.focus();
        });
        actions.append(edit);
        addressSection.append(row);
      }
      const form = document.createElement("form");
      form.className = "veggie-address-form";
      form.hidden = true;
      form.innerHTML = '<label>Người nhận <input name="fullName" maxlength="120" required></label><label>Số điện thoại <input name="phone" type="tel" maxlength="25" required></label><label>Địa chỉ <input name="address" maxlength="400" required></label><label>Tỉnh/thành phố <input name="city" maxlength="100" required></label><button type="submit" class="theme-btn-1 btn">Thêm địa chỉ</button><p role="status"></p>';
      form.addEventListener("submit", async event => {
        event.preventDefault();
        const button = form.querySelector("button");
        const status = form.querySelector('[role="status"]');
        button.disabled = true;
        try {
          const path = editingId === null ? "/api/account/addresses" : "/api/account/addresses/" + editingId;
          const result = await fetch(path, {
            method: editingId === null ? "POST" : "PUT", headers: { "Content-Type": "application/json" },
            body: JSON.stringify(Object.fromEntries(new FormData(form))),
          });
          if (!result.ok) throw new Error();
          location.reload();
        } catch {
          status.textContent = "Không lưu được địa chỉ. Hãy kiểm tra thông tin và thử lại.";
          button.disabled = false;
        }
      });
      const actions = document.createElement("div");
      actions.className = "veggie-profile-actions";
      actions.append(form.querySelector('button[type="submit"]'));
      const cancel=document.createElement("button");cancel.type="button";cancel.textContent="Hủy";
      cancel.addEventListener("click",()=>{form.reset();editingId=null;form.hidden=true;form.querySelector('[type="submit"]').textContent="Thêm địa chỉ";});actions.append(cancel);
      form.querySelector('[role="status"]').before(actions);
      const addAddress=document.createElement("button");addAddress.type="button";addAddress.className="theme-btn-1 btn veggie-add-address";addAddress.textContent="Thêm địa chỉ mới";
      addAddress.addEventListener("click",()=>{editingId=null;form.reset();form.hidden=false;form.querySelector('[type="submit"]').textContent="Thêm địa chỉ";form.elements.fullName.focus();});
      addressSection.append(addAddress,form);
      panel.append(addressSection);
    }

    const notifications = await fetch("/api/notifications");
    if (!notifications.ok) throw new Error();
    const section = document.createElement("section");
    const title = document.createElement("h3");
    title.textContent = "Thông báo";
    section.append(title);
    for (const item of await notifications.json()) {
      const row = document.createElement("p");
      row.textContent = item.message + " ";
      if (!item.isRead) {
        const button = document.createElement("button");
        button.type = "button";
        button.textContent = "Đánh dấu đã đọc";
        button.addEventListener("click", async () => {
          button.disabled = true;
          try {
            const result = await fetch("/api/notifications/" + item.id + "/read", { method: "PUT" });
            if (!result.ok) throw new Error();
            button.remove();
          } catch {
            button.disabled = false;
            button.textContent = "Thử lại";
          }
        });
        row.append(button);
      }
      section.append(row);
    }
    if (section.childElementCount === 1) section.append("Chưa có thông báo.");
    panel.append(section);
    panel.classList.add("veggie-profile-layout");
    const main=document.createElement("div");main.className="veggie-profile-main";
    for(const item of [...panel.children])if(item!==header)main.append(item);
    const member=document.createElement("p");member.className="veggie-member-label";member.textContent="Thành viên cửa hàng Veggie";heading.after(member);
    const nav=document.createElement("nav");nav.className="veggie-profile-nav";nav.setAttribute("aria-label","Các mục tài khoản");
    const addressSection = main.querySelector("section:has(.veggie-address-form)");
    const overview = document.createElement("section");
    overview.innerHTML = '<h3>Bảng điều khiển</h3><p></p><a href="#don-hang">Xem đơn hàng</a>';
    overview.querySelector("p").textContent = "Bạn có " + orders.length + " đơn hàng và " +
      (addressSection?.querySelectorAll(".veggie-address-card").length || 0) + " địa chỉ giao hàng.";
    overview.append(section);
    const password = document.createElement("section");
    password.innerHTML = '<h3>Đổi mật khẩu</h3><form class="veggie-profile-edit"><label>Mật khẩu hiện tại<input name="currentPassword" type="password" required maxlength="128" autocomplete="current-password"></label><label>Mật khẩu mới<input name="newPassword" type="password" required minlength="8" maxlength="128" autocomplete="new-password"></label><label>Nhập lại mật khẩu mới<input name="confirmPassword" type="password" required minlength="8" maxlength="128" autocomplete="new-password"></label><div class="veggie-profile-actions"><button class="theme-btn-1 btn" type="submit">Đổi mật khẩu</button></div><p role="status"></p></form>';
    password.querySelector("form").addEventListener("submit", async event => {
      event.preventDefault();
      const form = event.currentTarget;
      const status = form.querySelector('[role="status"]');
      const button = form.querySelector("button");
      const data = Object.fromEntries(new FormData(form));
      if (data.newPassword !== data.confirmPassword) {
        status.textContent = "Mật khẩu nhập lại không khớp.";
        return;
      }
      button.disabled = true;
      try {
        const result = await fetch("/api/account/change-password", {
          method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(data)
        });
        const message = await result.json().catch(() => ({}));
        if (!result.ok) throw new Error(message.message || "Không đổi được mật khẩu. Vui lòng thử lại.");
        form.reset();
        status.textContent = message.message;
        const login = document.createElement("a");
        login.href = "login.html";
        login.textContent = " Đăng nhập lại";
        status.append(login);
      } catch (error) {
        status.textContent = error.message;
        button.disabled = false;
      }
    });
    const sections = [
      ["tong-quan", "Bảng điều khiển", "home", overview],
      ["don-hang", "Đơn hàng", "file-alt", ordersSection],
      ["diem-thuong", "Điểm & đổi quà", "gift", loyaltySection],
      ["dia-chi", "Địa chỉ", "map-marker", addressSection],
      ["thong-tin", "Chi tiết tài khoản", "user", details],
      ["doi-mat-khau", "Đổi mật khẩu", "lock", password]
    ].filter(([, , , content]) => content);
    for (const [id, label, icon, content] of sections) {
      content.id = id;
      const link = document.createElement("a");
      link.href = "#" + id;
      link.textContent = label;
      const symbol = document.createElement("i");
      symbol.className = "fas fa-" + icon;
      symbol.setAttribute("aria-hidden", "true");
      link.append(symbol);
      nav.append(link);
    }
    function showSection() {
      const active = sections.find(([id]) => "#" + id === location.hash) || sections[0];
      for (const [id, , , content] of sections) {
        content.hidden = id !== active[0];
        nav.querySelector('a[href="#' + id + '"]').setAttribute("aria-current", id === active[0] ? "page" : "false");
      }
    }
    editButton.removeAttribute("aria-expanded");
    editButton.addEventListener("click", () => { location.hash = "thong-tin"; showSection(); editProfile.elements.name.focus(); });
    window.addEventListener("hashchange", showSection);
    main.prepend(overview);
    main.append(password);
    showSection();
    header.append(nav);panel.append(main);
    if (orders.length) {
      const table = document.createElement("table");
      table.className = "veggie-profile-orders";
      table.innerHTML = '<thead><tr><th scope="col">Đơn hàng</th><th scope="col">Ngày đặt</th><th scope="col">Trạng thái</th><th scope="col">Tổng tiền</th><th scope="col">Hành động</th></tr></thead><tbody></tbody>';
      history.querySelectorAll(".veggie-order-card").forEach((card, index) => {
        const order = orders[index];
        const row = table.tBodies[0].insertRow();
        row.insertCell().textContent = order.code;
        row.insertCell().textContent = new Date(order.createdAt).toLocaleDateString("vi-VN");
        const badge = card.querySelector(".veggie-order-badge");
        badge.dataset.orderStatus = order.status;
        row.insertCell().append(badge);
        row.insertCell().textContent = new Intl.NumberFormat("vi-VN").format(order.total) + " ₫";
        card.querySelector(".veggie-order-card-top").remove();
        card.querySelector("p").remove();
        row.insertCell().append(...card.childNodes);
      });
      history.classList.add("veggie-profile-table-wrap");
      history.replaceChildren(table);
    }
    if(addressSection){const grid=document.createElement("div");grid.className="veggie-address-grid";grid.append(...addressSection.querySelectorAll(".veggie-address-card"),addressSection.querySelector(".veggie-add-address"));addressSection.querySelector(".veggie-address-form").before(grid);}

  } catch {
    const error = document.createElement("p");
    error.textContent = "Không tải được thông tin tài khoản. Vui lòng thử lại.";
    panel.append(error);
  }
})();














