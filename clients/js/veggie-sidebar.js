(() => {
  const sidebar = document.querySelector(".ltn__shop-sidebar"),
    shop = window.VeggieShop,
    data = window.VeggieCatalog;
  if (!sidebar || !shop || !data) return;
  const { products, categories } = data;
  const money = (n) => Number(n).toLocaleString("vi-VN") + "₫";
  const menu = sidebar.querySelector(".ltn__menu-widget ul");
  menu.replaceChildren();
  function choice(list, label, key, value, count) {
    const li = document.createElement("li"),
      a = document.createElement("a");
    const url = new URL(location.href);
    if (value) url.searchParams.set(key, value);
    else url.searchParams.delete(key);
    url.searchParams.set("page", "1");
    a.href = url.pathname + url.search;
    a.textContent = label + (count === undefined ? "" : ` (${count})`);
    a.dataset.filterKey = key;
    a.dataset.filterValue = value;
    a.addEventListener("click", (event) => {
      event.preventDefault();
      shop.setFilters({ [key]: value });
    });
    li.append(a);
    list.append(li);
  }
  choice(menu, "Tất cả sản phẩm", "category", "", products.length);
  categories.forEach((c) =>
    choice(
      menu,
      c.name,
      "category",
      c.id,
      products.filter((p) => p.category === c.id).length,
    ),
  );
  const tags = sidebar.querySelector(
    ".ltn__tagcloud-widget:not(.ltn__size-widget) ul",
  );
  tags.replaceChildren();
  ["rau", "nấm", "hạt", "thịt", "cá", "sữa", "đậu", "bột"].forEach((q) =>
    choice(tags, q, "q", q),
  );
  const stock = sidebar.querySelector(".ltn__color-widget");
  stock.className = "widget ltn__tagcloud-widget veggie-stock-widget";
  stock.querySelector("h4").textContent = "Tình trạng hàng";
  const stocks = stock.querySelector("ul");
  stocks.replaceChildren();
  [
    ["", "Tất cả"],
    ["available", "Còn hàng"],
    ["low", "Sắp hết hàng"],
    ["out", "Hết hàng"],
  ].forEach(([value, label]) => choice(stocks, label, "stock", value));
  const form = sidebar.querySelector(".ltn__search-widget form"),
    input = form.querySelector("input");
  input.value = new URL(location.href).searchParams.get("q") || "";
  form.addEventListener("submit", (event) => {
    event.preventDefault();
    shop.setFilters({ q: input.value.trim(), search: null });
  });
  const recommended = sidebar.querySelector(
    ".ltn__top-rated-product-widget>ul",
  );
  recommended.replaceChildren();
  [...products]
    .sort((a, b) => b.rating - a.rating)
    .slice(0, 3)
    .forEach((p) => {
      const li = document.createElement("li"),
        a = document.createElement("a"),
        img = document.createElement("img"),
        text = document.createElement("span");
      a.className = "veggie-sidebar-product";
      a.href = "product-details.html?id=" + p.id;
      img.src = p.image;
      img.alt = p.name;
      text.textContent = p.name + " · " + money(p.price);
      a.append(img, text);
      li.append(a);
      recommended.append(li);
    });
  const reset = document.createElement("button");
  reset.type = "button";
  reset.className = "theme-btn-1 btn veggie-reset-filters";
  reset.textContent = "Xóa bộ lọc";
  reset.addEventListener("click", () => {
    shop.clearFilters();
    input.value = "";
    if (window.jQuery) {
      const slider = window.jQuery(sidebar.querySelector(".slider-range"));
      slider.slider("values", [0, max]);
    }
  });
  sidebar.prepend(reset);
  const max =
    Math.ceil(Math.max(...products.map((p) => p.price)) / 5000) * 5000;
  let syncing = false;
  const result = document.createElement("p");
  result.setAttribute("role", "status");
  result.className = "veggie-sidebar-count";
  reset.after(result);
  if (window.jQuery)
    window.jQuery(() => {
      const slider = window.jQuery(sidebar.querySelector(".slider-range"));
      slider.slider("option", "max", max);
      const params = new URL(location.href).searchParams;
      const values = [
        Number(params.get("min") || 0),
        Number(params.get("max") || max),
      ];
      slider.slider("values", values);
      sidebar.querySelector(".amount").value =
        money(values[0]) + " – " + money(values[1]);
      slider.on("slidechange", (_, ui) => {
        if (!syncing)
          shop.setFilters({
            min: ui.values[0] || null,
            max: ui.values[1] === max ? null : ui.values[1],
          });
      });
    });
  function active() {
    const params = new URL(location.href).searchParams;
    input.value = params.get("q") || "";
    result.textContent =
      window.VeggieFilters.apply(products, params).length + " sản phẩm phù hợp";
    sidebar.querySelectorAll("[data-filter-key]").forEach((a) => {
      const selected =
        (params.get(a.dataset.filterKey) || "") === a.dataset.filterValue;
      a.classList.toggle("veggie-filter-active", selected);
      a.setAttribute("aria-current", selected ? "true" : "false");
    });
    if (window.jQuery) {
      const slider = window.jQuery(sidebar.querySelector(".slider-range"));
      if (slider.hasClass("ui-slider")) {
        syncing = true;
        const values = [
          Number(params.get("min") || 0),
          Number(params.get("max") || max),
        ];
        slider.slider("values", values);
        sidebar.querySelector(".amount").value =
          money(values[0]) + " – " + money(values[1]);
        syncing = false;
      }
    }
  }
  document.addEventListener("veggie:filters", active);
  window.addEventListener("popstate", active);
  active();
})();
