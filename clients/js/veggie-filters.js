/* Các điều kiện lọc dùng chung, không gọi backend. */
window.VeggieFilters = {
  normalize(value) {
    return String(value || "")
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/đ/gi, "d")
      .toLowerCase()
      .trim();
  },
  apply(products, params) {
    const norm = this.normalize;
    const q = norm(params.get("q") || params.get("search"));
    const stop=new Set('toi muon mua tim kiem cho minh can san pham rat ngon co ban cua hang hay giup voi nhung mot cac va la duoc khong bao nhieu gia xin nao nay ay cu'.split(' '));
    let words=[...new Set(q.split(/[^a-z0-9]+/).filter(w=>w&&!stop.has(w)))];
    if(words.some(w=>["heo","ga","bo","vit","cuu"].includes(w)))words=words.filter(w=>w!=="thit");
    const matches=p=>!q||norm(p.name).includes(q)||(words.length>0&&words.every(w=>norm(p.name+' '+(p.description||'')).split(/[^a-z0-9]+/).includes(w)));
    const category = params.get("category"),
      unit = params.get("unit"),
      stock = params.get("stock");
    const min = Number(params.get("min") || 0),
      max = params.has("max") ? Number(params.get("max")) : Infinity;
    const list = products.filter(
      (p) =>
        matches(p) &&
        (!category || p.category === category) &&
        (!unit || p.unit === unit) &&
        p.price >= min &&
        p.price <= max &&
        (!stock ||
          (stock === "available"
            ? p.stock > 0
            : stock === "low"
              ? p.stock > 0 && p.stock <= 20
              : p.stock === 0)),
    );
    const sort = params.get("sort") || "";
    if (sort.includes("thấp")) list.sort((a, b) => a.price - b.price);
    else if (sort.includes("cao")) list.sort((a, b) => b.price - a.price);
    else if (sort === "Mới nhất") list.sort((a, b) => b.id - a.id);
    else if (sort === "Bán chạy") list.sort((a, b) => (b.soldQuantity||0) - (a.soldQuantity||0));
    return list;
  },
};


