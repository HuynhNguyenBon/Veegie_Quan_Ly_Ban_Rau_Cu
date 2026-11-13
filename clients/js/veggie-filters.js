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
    // Broad food terms describe a group, not a literal substring in a name.
    const groupKey = q.replace(/[^a-z0-9]+/g, " ").trim();
    const categoryGroups = {
      rau: "rau-cu", "rau cu": "rau-cu", "rau xanh": "rau-cu",
      "trai cay": "trai-cay", "hoa qua": "trai-cay",
      thit: "thit", ca: "ca", "hai san": "ca", "ca hai san": "ca",
    };
    const group = categoryGroups[groupKey];
    const nameGroups = {
      nam: p => /\bnam\b/.test(norm(p.name)) && p.category === "rau-cu",
      hat: p => /\bhat\b/.test(norm(p.name)) && p.category === "thuc-pham-khac",
      sua: p => /\bsua\b|\bpho mai\b/.test(norm(p.name)) && p.category === "thuc-pham-khac",
      dau: p => /\bdau\b/.test(norm(p.name)) && ["rau-cu", "thuc-pham-khac"].includes(p.category),
      bot: p => /\bbot\b/.test(norm(p.name)),
    };
    const matches=p=> group ? p.category === group : nameGroups[groupKey] ? nameGroups[groupKey](p) :
      !q||norm(p.name).includes(q)||(words.length>0&&words.every(w=>norm(p.name+' '+(p.description||'')).split(/[^a-z0-9]+/).includes(w)));
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
    if (q && !sort) {
      const rank = p => { const name = norm(p.name); return name === q ? 0 : name.startsWith(q) ? 1 : name.includes(q) ? 2 : 3; };
      list.sort((a, b) => rank(a) - rank(b) || Number(b.stock > 0) - Number(a.stock > 0));
    }
    if (sort === "Giá thấp đến cao") list.sort((a, b) => a.price - b.price);
    else if (sort === "Giá cao đến thấp") list.sort((a, b) => b.price - a.price);
    else if (sort === "Mới nhất") list.sort((a, b) => b.id - a.id);
    else if (sort === "Bán chạy") list.sort((a, b) => (b.soldQuantity||0) - (a.soldQuantity||0));
    return list;
  },
};


