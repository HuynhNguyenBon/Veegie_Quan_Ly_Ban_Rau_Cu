const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");
const sup = {},
  area = {},
  footer = {},
  total = {},
  events = {},
  memory = new Map();
const drawer = {
  querySelector: (s) =>
    ({
      ".mini-cart-product-area": area,
      ".mini-cart-footer": footer,
      ".mini-cart-sub-total span": total,
    })[s],
};
const document = {
  getElementById: (id) => (id === "ltn__utilize-cart-menu" ? drawer : null),
  querySelectorAll: () => [sup],
  addEventListener: (name, fn) => (events[name] = fn),
};
const localStorage = {
  getItem: (k) => memory.get(k) || null,
  setItem: (k, v) => memory.set(k, v),
};
vm.runInNewContext(fs.readFileSync("clients/js/veggie-cart.js", "utf8"), {
  document,
  localStorage,
  location: { pathname: "/clients/index.html" },
  window: { addEventListener() {} },
});
assert.equal(sup.textContent, 0);
assert.equal(footer.hidden, true);
assert(area.innerHTML.includes("Giỏ hàng đang trống"));
const item = {
  querySelector: (s) =>
    s === ".product-img img"
      ? { getAttribute: () => "img/product/1.png" }
      : s === ".product-title,h3,h4,h2,h5"
        ? { textContent: "Đào tươi" }
        : s === ".product-price span"
          ? { textContent: "65.000₫" }
          : s === ".cart-plus-minus-box"
            ? { value: "2" }
            : null,
  closest: () => null,
};
const add = { closest: () => item };
events.click({
  preventDefault() {}, stopImmediatePropagation() {},
  target: { closest: (s) => (s.includes("add_to_cart_modal") ? add : null) },
});
assert.equal(sup.textContent, 2);
assert.equal(footer.hidden, false);
assert.equal(total.textContent, "130.000₫");
const saved = JSON.parse(memory.get("veggie.html.cart.v1"));
assert.equal(saved.length, 1);
assert.equal(saved[0].price, 65000);
events.click({
  preventDefault() {},
  target: {
    closest: (s) =>
      s === "[data-cart-remove]"
        ? { dataset: { cartRemove: saved[0].id } }
        : null,
  },
});
assert.equal(sup.textContent, 0);
assert.equal(footer.hidden, true);
assert.equal(JSON.parse(memory.get("veggie.html.cart.v1")).length, 0);
console.log(
  "PASS: giỏ mới trống, thêm đúng số lượng/giá VNĐ, xóa về rỗng, ẩn thanh toán khi trống.",
);
