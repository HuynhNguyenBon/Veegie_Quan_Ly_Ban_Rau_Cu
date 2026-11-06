/* Tiện ích frontend cho các thao tác còn trống trong template quản trị. */
(() => {
  const page = location.pathname.split("/").pop();
  function notice(message, undo) {
    const n = document.createElement("div");
    n.className = "veggie-admin-notice";
    n.setAttribute("role", "status");
    const text = document.createElement("span");
    text.textContent = message;
    n.append(text);
    if (undo) {
      const b = document.createElement("button");
      b.className = "btn btn-default btn-xs";
      b.textContent = "Hoàn tác";
      b.onclick = () => {
        undo();
        n.remove();
      };
      n.append(b);
    }
    const close = document.createElement("button");
    close.textContent = "×";
    close.setAttribute("aria-label", "Đóng");
    close.onclick = () => n.remove();
    n.append(close);
    document.body.append(n);
  }
  function modal(title, content) {
    const d = document.createElement("dialog");
    d.className = "veggie-admin-dialog";
    const close = document.createElement("button");
    close.textContent = "×";
    close.className = "pull-right btn btn-default";
    close.onclick = () => d.close();
    const h = document.createElement("h2");
    h.textContent = title;
    d.append(close, h, content);
    d.addEventListener("close", () => d.remove());
    document.body.append(d);
    d.showModal();
    return d;
  }
  function invalidate(row) {
    if (window.jQuery) {
      const table = row.closest("table");
      if (window.jQuery.fn.dataTable?.isDataTable(table))
        window.jQuery(table).DataTable().row(row).invalidate("dom").draw(false);
    }
  }
  document.querySelectorAll('.top_nav a[href="javascript:;"]').forEach((a) => {
    if (/Profile/i.test(a.textContent)) a.href = "profile.html";
  });
  document.querySelectorAll("form").forEach((form) => {
    if (form.closest(".login_content")) {
      const submit = form.querySelector("a.submit");
      if (submit) {
        const b = document.createElement("button");
        b.type = "submit";
        b.className = submit.className;
        b.textContent = "Duyệt quản trị mẫu";
        submit.replaceWith(b);
      }
      const p = document.createElement("p");
      p.textContent =
        "Chỉ là giao diện mẫu, chưa xác thực bằng backend. Không dùng mật khẩu thật.";
      form.append(p);
    }
  });
  document.addEventListener(
    "submit",
    (event) => {
      const form = event.target;
      if (form.closest("dialog")) return;
      event.preventDefault();
      if (!form.reportValidity()) return;
      if (form.closest(".login_content")) {
        if (form.closest(".registration_form")) {
          notice("Thông tin đăng ký mẫu hợp lệ. Tài khoản thật chưa được tạo.");
          return;
        }
        sessionStorage.setItem("veggie.admin.demo", "true");
        location.href = "index.html";
        return;
      }
      const values = {};
      form.querySelectorAll("input,textarea,select").forEach((input, i) => {
        if (input.type === "password" || input.type === "file") return;
        values[input.name || input.id || "field-" + i] = input.value;
      });
      try {
        localStorage.setItem(
          "veggie.admin.draft." + page,
          JSON.stringify(values),
        );
      } catch {}
      notice(
        "Đã lưu bản nháp biểu mẫu trong trình duyệt. Chưa gửi đến máy chủ.",
      );
    },
    true,
  );
  const search = document.querySelector(".title_right .input-group input");
  const go = search?.closest(".input-group")?.querySelector("button");
  if (go) {
    const run = () => {
      const q = search.value.trim().toLowerCase();
      if (!q) return notice("Nhập từ khóa để tìm trong trang.");
      const rows = [
        ...document.querySelectorAll(
          ".right_col tbody tr,.right_col .profile_view",
        ),
      ];
      if (rows.length) {
        let count = 0;
        rows.forEach((row) => {
          row.hidden = !row.textContent.toLowerCase().includes(q);
          if (!row.hidden) count++;
        });
        notice(
          "Tìm thấy " + count + " kết quả. Xóa từ khóa để hiện lại tất cả.",
        );
      } else {
        const match = [
          ...document.querySelectorAll("#sidebar-menu a[href]"),
        ].find((a) => a.textContent.toLowerCase().includes(q));
        if (match) location.href = match.href;
        else notice("Không tìm thấy mục phù hợp.");
      }
    };
    go.onclick = run;
    search.addEventListener("keydown", (e) => {
      if (e.key === "Enter") {
        e.preventDefault();
        run();
      }
    });
    search.addEventListener("input", () => {
      if (!search.value)
        document
          .querySelectorAll(".right_col tbody tr,.right_col .profile_view")
          .forEach((n) => (n.hidden = false));
    });
  }
  if (window.Dropzone) window.Dropzone.autoDiscover = false;
  document.querySelectorAll("form.dropzone").forEach((form) => {
    form.action = "#";
    form.innerHTML = "";
    const label = document.createElement("label");
    label.textContent = "Chọn tệp để xem trước (chưa tải lên máy chủ)";
    const input = document.createElement("input");
    input.type = "file";
    input.multiple = true;
    const list = document.createElement("div");
    list.className = "veggie-file-previews";
    input.onchange = () => {
      list.replaceChildren();
      for (const file of input.files) {
        const item = document.createElement("div");
        item.className = "veggie-file-preview";
        const name = document.createElement("p");
        name.textContent =
          file.name + " · " + Math.ceil(file.size / 1024) + " KB";
        item.append(name);
        if (file.type.startsWith("image/")) {
          const image = document.createElement("img");
          const url = URL.createObjectURL(file);
          image.src = url;
          image.onload = () => URL.revokeObjectURL(url);
          item.append(image);
        }
        const remove = document.createElement("button");
        remove.type = "button";
        remove.textContent = "Bỏ chọn";
        remove.className = "btn btn-default btn-sm";
        remove.onclick = () => item.remove();
        item.append(remove);
        list.append(item);
      }
    };
    label.append(input);
    form.append(label, list);
  });
  document.addEventListener(
    "click",
    (event) => {
      const button = event.target.closest("a,button");
      if (!button) return;
      const label = button.textContent.trim();
      if (button.matches(".reset_pass")) {
        event.preventDefault();
        const p = document.createElement("p");
        p.textContent =
          "Chức năng khôi phục mật khẩu sẽ được kết nối với ASP.NET. Chưa có email được gửi.";
        modal("Hỗ trợ tài khoản", p);
        return;
      }
      if (
        page === "invoice.html" &&
        /Generate PDF|Submit Payment/.test(label)
      ) {
        event.preventDefault();
        if (/PDF/.test(label)) {
          window.print();
          return;
        }
        const p = document.createElement("p");
        p.textContent =
          "Đây là hóa đơn mẫu. Chưa phát sinh thanh toán; dịch vụ thanh toán sẽ được tích hợp ở backend.";
        modal("Thông tin thanh toán mẫu", p);
        return;
      }
      const row = button.closest("tr");
      if (
        page === "projects.html" &&
        row &&
        /^(View|Edit|Delete)$/.test(label)
      ) {
        event.preventDefault();
        if (label === "View") {
          location.href = "project_detail.html";
          return;
        }
        if (label === "Delete") {
          const parent = row.parentNode,
            next = row.nextSibling;
          row.remove();
          notice("Đã ẩn dòng mẫu.", () =>
            parent.insertBefore(row, next?.isConnected ? next : null),
          );
          return;
        }
        const form = document.createElement("form");
        [...row.cells].slice(0, -1).forEach((cell, i) => {
          if (cell.querySelector("img")) return;
          const label = document.createElement("label");
          label.textContent = "Trường " + (i + 1);
          const input = document.createElement("input");
          input.className = "form-control";
          input.value = cell.textContent.trim();
          input.dataset.column = i;
          label.append(input);
          form.append(label);
        });
        const save = document.createElement("button");
        save.type = "submit";
        save.className = "btn btn-success";
        save.textContent = "Lưu thay đổi";
        form.append(save);
        const d = modal("Sửa dữ liệu mẫu", form);
        form.addEventListener("submit", (e) => {
          e.preventDefault();
          form
            .querySelectorAll("input")
            .forEach(
              (input) =>
                (row.cells[Number(input.dataset.column)].textContent =
                  input.value),
            );
          invalidate(row);
          d.close();
          notice("Đã cập nhật dòng trong giao diện.");
        });
        return;
      }
      const contact = button.closest(".profile_view");
      if (page === "contacts.html" && contact && button.tagName === "BUTTON") {
        event.preventDefault();
        if (button.querySelector(".fa-comments-o"))
          location.href = "inbox.html?compose=1";
        else location.href = "profile.html";
        return;
      }
      if (page === "inbox.html") {
        const hint =
          button.getAttribute("data-original-title") || button.title || label;
        if (/^(Reply|Forward)$/.test(hint)) {
          event.preventDefault();
          const compose = document.querySelector(".compose");
          if (compose) compose.style.display = "block";
          document.getElementById("editor")?.focus();
          notice(
            "Soạn " +
              (hint === "Reply" ? "phản hồi" : "thư chuyển tiếp") +
              " mẫu; chưa gửi email.",
          );
          return;
        }
        if (hint === "Print") {
          event.preventDefault();
          window.print();
          return;
        }
        if (hint === "Trash") {
          event.preventDefault();
          const view = button.closest(".inbox-body");
          if (view) {
            view.hidden = true;
            notice("Đã ẩn thư mẫu.", () => (view.hidden = false));
          }
          return;
        }
        if (button.id === "send") {
          event.preventDefault();
          const message = document.getElementById("editor")?.textContent.trim();
          if (!message) return notice("Vui lòng nhập nội dung thư.");
          try {
            localStorage.setItem("veggie.admin.mail-draft", message);
          } catch {}
          notice("Đã lưu bản nháp thư trong trình duyệt. Chưa gửi email.");
          return;
        }
      }
      if (
        button.tagName === "A" &&
        ["#", "javascript:;", "javascript:void(0)"].includes(
          button.getAttribute("href"),
        )
      ) {
        event.preventDefault();
        if (
          button.closest(".dt-buttons,.dataTables_paginate") ||
          button.hasAttribute("data-toggle") ||
          button.hasAttribute("data-edit") ||
          button.querySelector(".fa-star,.fa-star-o") ||
          button.parentElement.querySelector("ul")
        )
          return;
        if (button.querySelector(".glyphicon-fullscreen")) {
          if (document.fullscreenElement) document.exitFullscreen();
          else
            document.documentElement
              .requestFullscreen()
              .catch(() =>
                notice("Trình duyệt chưa cho phép chế độ toàn màn hình."),
              );
          return;
        }
        notice(
          "Mục này thuộc dữ liệu mẫu. Chức năng nghiệp vụ sẽ được kết nối ở phần ASP.NET.",
        );
      }
    },
    true,
  );
  if (
    page === "inbox.html" &&
    new URL(location.href).searchParams.has("compose")
  ) {
    const compose = document.querySelector(".compose");
    if (compose) compose.style.display = "block";
  }
})();
