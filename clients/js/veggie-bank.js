(() => {
  window.VeggieBank = {
    show(code, total) {
      const dialog = document.createElement("dialog");
      dialog.className = "veggie-bank-dialog";
      dialog.setAttribute("aria-label", "Thông tin chuyển khoản");
      const title = document.createElement("h2");
      title.textContent = "Chuyển khoản Vietcombank";
      const detail = document.createElement("p");
      detail.textContent = "Chủ tài khoản: HUYNH NGUYEN BON · Số tài khoản: 1042923574";
      const amount = document.createElement("p");
      amount.textContent = "Số tiền: " + Number(total).toLocaleString("vi-VN") + " ₫ · Nội dung: " + code;
      const instruction = document.createElement("p");
      instruction.textContent = "Sau khi quét QR, nhập đúng số tiền và mã đơn ở trên. Cửa hàng xác nhận thanh toán sau khi kiểm tra tiền nhận được.";
      const image = document.createElement("img");
      image.src = "img/payments/vietcombank-qr.png?v=2";
      image.alt = "QR Vietcombank của HUYNH NGUYEN BON";
      const close = document.createElement("button");
      close.type = "button";
      close.className = "theme-btn-1 btn";
      close.textContent = "Đóng";
      close.addEventListener("click", () => dialog.close());
      dialog.addEventListener("close", () => dialog.remove(), { once: true });
      dialog.append(title, detail, amount, image, instruction, close);
      document.body.append(dialog);
      dialog.showModal();
    }
  };
})();

