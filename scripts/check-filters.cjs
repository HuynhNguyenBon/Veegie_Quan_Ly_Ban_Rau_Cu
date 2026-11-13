const fs = require("node:fs"),
  vm = require("node:vm"),
  assert = require("node:assert/strict");
const context = { window: {}, URLSearchParams };
vm.runInNewContext(
  fs.readFileSync("clients/js/veggie-catalog.js", "utf8"),
  context,
);
vm.runInNewContext(
  fs.readFileSync("clients/js/veggie-filters.js", "utf8"),
  context,
);
const { products, categories } = context.window.VeggieCatalog,
  filter = context.window.VeggieFilters;
assert.equal(filter.apply(products, new URLSearchParams()).length, products.length);
assert.equal(filter.apply(products, new URLSearchParams({ q: 'ca rot goi 500g' }))[0].name, 'Cà rốt gói 500g');
assert.equal(filter.apply(products, new URLSearchParams({ q: 'thit heo xay' }))[0].name, 'Thịt heo xay');
for (const [q, category] of [['rau','rau-cu'], ['rau củ','rau-cu'], ['thịt','thit'], ['cá','ca'], ['hải sản','ca'], ['trái cây','trai-cay']]) {
  const found = filter.apply(products, new URLSearchParams({ q }));
  assert.equal(found.length, products.filter(p => p.category === category).length, q + ' phải lấy đủ nhóm thực phẩm');
  assert(found.every(p => p.category === category));
}
assert(filter.apply(products, new URLSearchParams({q:'rau'})).some(p=>p.name === 'Bông cải xanh'));
assert(!filter.apply(products, new URLSearchParams({q:'cá'})).some(p=>p.name === 'Cà rốt'));
assert(!filter.apply(products, new URLSearchParams({q:'đậu'})).some(p=>p.name === 'Dâu tây'));
const vegetablePackages = filter.apply(products, new URLSearchParams({q:'rau',unit:'gói',max:'25000'}));
assert(vegetablePackages.length > 0);
assert(vegetablePackages.every(p => p.category === 'rau-cu' && p.unit === 'gói' && p.price <= 25000));
for (const c of categories) {
  const found = filter.apply(products, new URLSearchParams({ category: c.id }));
  assert(found.length > 0);
  assert(found.every((p) => p.category === c.id));
}
const sample = products[0];
assert(
  filter
    .apply(products, new URLSearchParams({ q: filter.normalize(sample.name) }))
    .some((p) => p.id === sample.id),
);
const combined = filter.apply(
  products,
  new URLSearchParams({
    category: sample.category,
    unit: sample.unit,
    min: sample.price,
    max: sample.price,
  }),
);
assert(combined.some((p) => p.id === sample.id));
assert(
  combined.every(
    (p) =>
      p.category === sample.category &&
      p.unit === sample.unit &&
      p.price === sample.price,
  ),
);
const low = filter.apply(products, new URLSearchParams({ stock: "low" }));
assert(low.every((p) => p.stock > 0 && p.stock <= 20));
const sorted = filter.apply(
  products,
  new URLSearchParams({ sort: "Giá thấp đến cao" }),
);
assert(sorted.every((p, i) => !i || sorted[i - 1].price <= p.price));
assert.equal(
  filter.apply(
    products,
    new URLSearchParams({ q: "mặt hàng không tồn tại xyz" }),
  ).length,
  0,
);
function element() {
  return {
    children: [],
    attrs: {},
    events: {},
    className: "",
    setAttribute(k, v) {
      this.attrs[k] = v;
    },
    addEventListener(k, fn) {
      this.events[k] = fn;
    },
    append(...n) {
      this.children.push(...n);
    },
    replaceChildren(...n) {
      this.children = n;
    },
    get lastElementChild() {
      return this.children.at(-1);
    },
    get classList() {
      return { contains: (n) => this.className.split(" ").includes(n) };
    },
  };
}
const row = element(),
  ul = element();
function card() {
  const n = element();
  n.card = { dataset: {} };
  n.querySelector = (s) => (s === ".ltn__product-item" ? n.card : null);
  n.querySelectorAll = () => [];
  n.cloneNode = card;
  return n;
}
const first = { parentElement: { parentElement: row, cloneNode: card } };
const pagination = { querySelector: () => ul };
const location = { href: "http://localhost/clients/shop.html" };
const document = {
  querySelector: (s) => (s === ".ltn__pagination" ? pagination : null),
  querySelectorAll: (s) =>
    s === ".ltn__product-tab-content-inner"
      ? [{ querySelector: () => first }]
      : [],
  createElement: element,
  dispatchEvent() {},
};
Object.assign(context, {
  document,
  location,
  URL,
  history: {
    pushState(_, __, url) {
      location.href = "http://localhost" + url;
    },
  },
  CustomEvent: class {
    constructor(name) {
      this.type = name;
    }
  },
});
context.window.addEventListener = () => {};
vm.runInNewContext(
  fs.readFileSync("clients/js/veggie-pagination.js", "utf8"),
  context,
);
assert.equal(row.children.length, 18);
const page1 = row.children.map((n) => n.card.dataset.productId);
const page2 = ul.children
  .map((n) => n.children[0])
  .find((n) => n.textContent === "2");
page2.events.click();
assert(location.href.endsWith("page=2"));
assert.equal(row.children.length, 18);
assert(row.children.every((n) => !page1.includes(n.card.dataset.productId)));
context.window.VeggieShop.setFilters({ category: sample.category });
assert(location.href.includes("page=1"));
assert(
  row.children.every(
    (n) =>
      products.find((p) => p.id === n.card.dataset.productId).category ===
      sample.category,
  ),
);
context.window.VeggieShop.clearFilters();
assert.equal(row.children.length, 18);
assert(!location.href.includes("category="));
console.log(
  "PASS: tìm không dấu, 5 danh mục, lọc kết hợp giá/đơn vị/tồn kho, sắp xếp, chuyển trang và xóa bộ lọc.",
);

