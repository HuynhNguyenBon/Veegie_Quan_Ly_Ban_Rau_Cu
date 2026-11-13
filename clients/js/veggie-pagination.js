/* Phân trang danh mục thật ở frontend, dùng chung cho chế độ lưới và danh sách. */
(() => {
  const products = window.VeggieCatalog?.products;
  const pagination = document.querySelector(".ltn__pagination");
  if (!products || !pagination) return;
  const pageSize = 18;
  let current = Number(new URL(location.href).searchParams.get("page")) || 1;
  const views = [
    ...document.querySelectorAll(".ltn__product-tab-content-inner"),
  ]
    .map((view) => {
      const card = view.querySelector(".ltn__product-item");
      return card
        ? {
            row: card.parentElement.parentElement,
            template: card.parentElement.cloneNode(true),
          }
        : null;
    })
    .filter(Boolean);
  function rows() {
    const url = new URL(location.href);
    return window.VeggieFilters.apply(products, url.searchParams);
  }
  const money = (n) => n.toLocaleString("vi-VN") + "₫";
  function makeCard(template, p) {
    const node = template.cloneNode(true),
      card = node.querySelector(".ltn__product-item");
    card.dataset.productId = p.id;
    node.querySelectorAll(".product-img img").forEach((img) => {
      img.src = p.image;
      img.alt = p.name;
      img.loading = "lazy";
    });
    node.querySelectorAll(".product-title a").forEach((a) => {
      a.textContent = p.name;
      a.href = "product-details.html?id=" + p.id;
    });
    node
      .querySelectorAll(".product-img>a")
      .forEach((a) => (a.href = "product-details.html?id=" + p.id));
    const price = node.querySelector(".product-price");
    if (price) {
      price.replaceChildren();
      const value = document.createElement("span");
      value.textContent = money(p.price) + ' / ' + p.unit;
      price.append(value);
    }
    node
      .querySelectorAll(".product-brief p")
      .forEach((n) => (n.textContent = p.description));
    node.querySelectorAll(".product-badge").forEach((n) => n.remove());
    return node;
  }
  function select(page) {
    current = page;
    const url = new URL(location.href);
    url.searchParams.set("page", current);
    url.hash = "";
    history.pushState(null, "", url.pathname + url.search);
    render();
  }
  function button(text, page, label, disabled = false) {
    const li = document.createElement("li"),
      b = document.createElement("button");
    b.type = "button";
    b.textContent = text;
    b.setAttribute("aria-label", label);
    b.disabled = disabled;
    if (page === current) {
      li.className = "active";
      b.setAttribute("aria-current", "page");
    }
    b.addEventListener("click", () => select(page));
    li.append(b);
    return li;
  }
  function render() {
    if (sorting) {
      sorting.value =
        new URL(location.href).searchParams.get("sort") || "Sắp xếp mặc định";
      if (
        window.jQuery?.fn.niceSelect &&
        window.jQuery(sorting).next("div.nice-select").length
      )
        window.jQuery(sorting).niceSelect("update");
    }
    const list = rows(),
      total = Math.max(1, Math.ceil(list.length / pageSize));
    current = Math.max(1, Math.min(current, total));
    const visible = list.slice((current - 1) * pageSize, current * pageSize);
    views.forEach(({ row, template }) =>
      row.replaceChildren(...visible.map((p) => makeCard(template, p))),
    );
    if (!visible.length)
      views.forEach(({ row }) => {
        const empty = document.createElement("p");
        empty.className = "col-12 veggie-filter-empty";
        empty.textContent =
          "Không có sản phẩm phù hợp. Hãy thay đổi hoặc xóa bộ lọc.";
        row.append(empty);
      });
    document
      .querySelectorAll(".showing-product-number span")
      .forEach(
        (n) =>
          (n.textContent = `Hiển thị ${list.length ? (current - 1) * pageSize + 1 : 0}–${Math.min(current * pageSize, list.length)} / ${list.length} sản phẩm`),
      );
    const ul = pagination.querySelector("ul");
    ul.replaceChildren();
    ul.append(button("«", current - 1, "Trang trước", current === 1));
    for (let page = 1; page <= total; page++) {
      if (
        total > 5 &&
        page > 3 &&
        page < total &&
        Math.abs(page - current) > 1
      ) {
        const previous = ul.lastElementChild;
        if (!previous?.classList.contains("pagination-gap")) {
          const gap = document.createElement("li"),
            mark = document.createElement("span");
          gap.className = "pagination-gap";
          mark.textContent = "…";
          mark.setAttribute("aria-hidden", "true");
          gap.append(mark);
          ul.append(gap);
        }
        continue;
      }
      ul.append(button(String(page), page, "Trang " + page));
    }
    ul.append(button("»", current + 1, "Trang sau", current === total));
  }
  const sorting = document.querySelector(".short-by select");
  function filters(patch) {
    const url = new URL(location.href);
    for (const [key, value] of Object.entries(patch)) {
      if (value === null || value === "") url.searchParams.delete(key);
      else url.searchParams.set(key, value);
    }
    url.searchParams.set("page", "1");
    url.hash = "";
    history.pushState(null, "", url.pathname + url.search);
    current = 1;
    render();
    document.dispatchEvent(new CustomEvent("veggie:filters"));
  }
  window.VeggieShop = {
    setFilters: filters,
    clearFilters() {
      const url = new URL(location.href);
      history.pushState(null, "", url.pathname);
      current = 1;
      render();
      document.dispatchEvent(new CustomEvent("veggie:filters"));
    },
  };
  if (sorting) {
    sorting.value =
      new URL(location.href).searchParams.get("sort") || "Sắp xếp mặc định";
    const change = () => filters({ sort: sorting.value });
    if (window.jQuery) window.jQuery(sorting).on("change", change);
    else sorting.addEventListener("change", change);
  }
  window.addEventListener("popstate", () => {
    current = Number(new URL(location.href).searchParams.get("page")) || 1;
    render();
  });
  render();
})();
