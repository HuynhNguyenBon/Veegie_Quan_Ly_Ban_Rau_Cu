(async () => {
  const cart = window.VeggieCart;
  const products = window.VeggieCatalog?.products;
  if (!cart || !products) return;
  const toLines = () => cart.getItems().map(item => ({
    id: products.find(p => p.name === item.name && p.image === item.image)?.id,
    quantity: item.quantity,
  })).filter(item => item.id);
  try {
    const response = await fetch("/api/cart");
    if (response.status === 401) return;
    if (!response.ok) throw new Error();
    const lines = await response.json();
    if (sessionStorage.getItem("veggie.merge-cart")) {
      const merged = new Map(lines.map(line => [line.id, line]));
      for (const line of toLines()) {
        const quantity = Math.min(99, (merged.get(line.id)?.quantity || 0) + line.quantity);
        merged.set(line.id, { id: line.id, quantity });
      }
      const result = await fetch("/api/cart", {
        method: "PUT", headers: { "Content-Type": "application/json" },
        body: JSON.stringify([...merged.values()]),
      });
      if (!result.ok) throw new Error();
      lines.splice(0, lines.length, ...merged.values());
      localStorage.removeItem("veggie.html.cart.v1");
      sessionStorage.removeItem("veggie.merge-cart");
    }
    cart.restore(lines.flatMap(line => {
      const product = products.find(p => p.id === line.id);
      return product ? [{ ...product, id: product.name + "|" + product.image, quantity: line.quantity }] : [];
    }));
    let pending = Promise.resolve();
    document.addEventListener("veggie:cart", () => {
      const body = JSON.stringify(toLines());
      pending = pending.then(async () => {
        const result = await fetch("/api/cart", {
          method: "PUT", headers: { "Content-Type": "application/json" },
          body, keepalive: true,
        });
        if (!result.ok) throw new Error();
      }).catch(() => console.error("Không đồng bộ được giỏ hàng Veggie."));
    });
  } catch {
    console.error("Không tải được giỏ hàng Veggie.");
  }
})();




