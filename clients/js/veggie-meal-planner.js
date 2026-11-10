(() => {
  "use strict";

  const recipes = [
    {
      id: "pumpkin-pork-soup",
      title: "Canh bí đỏ hầm sườn",
      type: "meat",
      typeLabel: "Món nhà",
      minutes: 35,
      baseServings: 2,
      description: "Món canh ấm bụng, hợp cho bữa cơm gia đình.",
      image: "img/recipes/canh-bi-do-ham-suon.png",
      ingredients: [
        { name: "Bí đỏ", amount: 0.5, measure: "kg" },
        { name: "Sườn cốt lết heo", amount: 1, measure: "khay" },
      ],
      steps: "Rửa sườn, chần sơ rồi hầm đến mềm. Thêm bí đỏ và nấu vừa chín; nêm muối, tiêu và hành lá nếu có.",
    },
    {
      id: "chicken-broccoli",
      title: "Ức gà xào bông cải",
      type: "meat",
      typeLabel: "Nhanh gọn",
      minutes: 25,
      baseServings: 2,
      description: "Đạm nạc và rau xanh trong một món xào dễ làm.",
      image: "img/recipes/uc-ga-xao-bong-cai.png",
      ingredients: [
        { name: "Ức gà tây", amount: 1, measure: "khay" },
        { name: "Bông cải xanh", amount: 0.4, measure: "kg" },
      ],
      steps: "Thái gà vừa ăn, áp chảo chín tới. Xào tỏi thơm nếu có, cho bông cải vào đảo nhanh rồi nêm vừa ăn.",
    },
    {
      id: "salmon-salad",
      title: "Cá hồi áp chảo và salad",
      type: "seafood",
      typeLabel: "Hải sản",
      minutes: 25,
      baseServings: 2,
      description: "Cá hồi nóng ăn cùng rau giòn và vị chanh thanh nhẹ.",
      image: "img/recipes/ca-hoi-ap-chao-salad.png",
      ingredients: [
        { name: "Cá hồi phi lê", amount: 1, measure: "khay" },
        { name: "Xà lách rocket", amount: 1, measure: "túi" },
        { name: "Dưa leo", amount: 0.25, measure: "kg" },
        { name: "Chanh xanh", amount: 1, measure: "túi" },
      ],
      steps: "Thấm khô cá, áp chảo vàng hai mặt. Trộn rau và dưa leo; vắt chanh, thêm dầu ăn và dùng kèm.",
    },
    {
      id: "tofu-mushroom",
      title: "Đậu phụ xào nấm và cải thìa",
      type: "vegetarian",
      typeLabel: "Món chay",
      minutes: 20,
      baseServings: 2,
      description: "Bữa chay nhanh với nấm mềm, cải xanh và đậu phụ.",
      image: "img/recipes/dau-phu-xao-nam-cai-thia.png",
      ingredients: [
        { name: "Đậu phụ", amount: 1, measure: "hộp" },
        { name: "Nấm bào ngư", amount: 1, measure: "túi" },
        { name: "Cải thìa", amount: 1, measure: "túi" },
      ],
      steps: "Chiên áp chảo đậu phụ. Xào tỏi nếu có và nấm, cho cải thìa vào đảo nhanh; thêm đậu phụ và nêm xì dầu.",
    },
    {
      id: "shrimp-vegetables",
      title: "Tôm xào rau củ",
      type: "seafood",
      typeLabel: "Hải sản",
      minutes: 20,
      baseServings: 2,
      description: "Tôm ngọt tự nhiên kết hợp rau củ nhiều màu sắc.",
      image: "img/recipes/tom-xao-rau-cu.png",
      ingredients: [
        { name: "Tôm bóc nõn", amount: 1, measure: "khay" },
        { name: "Cà rốt", amount: 0.25, measure: "kg" },
        { name: "Đậu cô ve", amount: 0.25, measure: "kg" },
      ],
      steps: "Sơ chế tôm và rau củ. Xào tôm vừa chuyển màu, thêm rau củ và đảo đến chín tới; nêm theo khẩu vị, thêm hành lá nếu có.",
    },
  ];

  const money = (value) => Math.round(value).toLocaleString("vi-VN") + "₫";
  const escapeHtml = (value) => String(value).replace(/[&<>"']/g, (char) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[char]);
  const state = { servings: 2, budget: 250000, diet: "all", products: [], cards: new Map() };
  const grid = document.getElementById("meal-grid");
  const status = document.getElementById("meal-status");
  const count = document.getElementById("meal-result-count");
  const toast = document.getElementById("meal-toast");
  const toastMessage = document.getElementById("meal-toast-message");

  function showToast(message) {
    if (!toast || !toastMessage || typeof toast.showModal !== "function") return;
    toastMessage.textContent = message;
    if (!toast.open) toast.showModal();
  }

  toast?.querySelector(".meal-dialog-close")?.addEventListener("click", () => toast.close());
  toast?.querySelector(".meal-dialog-continue")?.addEventListener("click", () => toast.close());
  toast?.addEventListener("click", (event) => {
    if (event.target === toast) toast.close();
  });

  function productFor(name) {
    return state.products.find((product) => String(product.name).trim().toLocaleLowerCase("vi") === name.toLocaleLowerCase("vi"));
  }

  function mealFor(recipe) {
    const lines = recipe.ingredients.map((ingredient) => {
      const product = productFor(ingredient.name);
      const amount = ingredient.amount * state.servings / recipe.baseServings;
      const quantity = Math.max(1, Math.ceil(amount - 1e-9));
      return { ...ingredient, amount, quantity, product, lineTotal: product ? product.price * quantity : 0 };
    });
    return { recipe, lines, total: lines.reduce((sum, line) => sum + line.lineTotal, 0), available: lines.every((line) => line.product && line.product.stock >= line.quantity) };
  }

  function amountLabel(line) {
    const shown = Number.isInteger(line.amount) ? String(line.amount) : line.amount.toLocaleString("vi-VN", { maximumFractionDigits: 2 });
    return `${shown} ${line.measure}`;
  }

  function selectedTotal(card, root) {
    const checked = [...root.querySelectorAll("[data-meal-line]:checked")];
    const selected = checked.map((input) => card.lines[Number(input.dataset.mealLine)]).filter(Boolean);
    return { selected, total: selected.reduce((sum, line) => sum + line.lineTotal, 0) };
  }

  function updateAddButton(root, card) {
    const button = root.querySelector("[data-add-meal]");
    if (!button) return;
    const { selected, total } = selectedTotal(card, root);
    button.disabled = !selected.length;
    button.textContent = selected.length ? `Thêm ${selected.length} nguyên liệu · ${money(total)}` : "Chọn nguyên liệu muốn mua";
  }

  function render() {
    if (!state.products.length) return;
    state.budget = Math.max(0, Number(document.getElementById("meal-budget").value) || 0);
    state.cards.clear();
    const meals = recipes.map(mealFor).filter((meal) => meal.available)
      .filter((meal) => state.diet === "all" || meal.recipe.type === state.diet)
      .filter((meal) => state.budget === 0 || meal.total <= state.budget);
    count.textContent = `${meals.length} gợi ý · ${state.servings} người`;
    if (!meals.length) {
      grid.innerHTML = "";
      status.textContent = "Chưa có món phù hợp với ngân sách, khẩu vị và tồn kho hiện tại. Thử tăng ngân sách hoặc đổi lựa chọn nhé.";
      return;
    }
    status.textContent = "";
    grid.innerHTML = meals.map((card) => {
      state.cards.set(card.recipe.id, card);
      const image = escapeHtml(new URL(card.recipe.image, document.baseURI).href);
      const ingredientRows = card.lines.map((line, index) => {
        const unavailable = !line.product || line.product.stock < line.quantity;
        const buyLabel = line.product ? `${line.quantity} ${line.product.unit}` : "Không có trong cửa hàng";
        return `<li class="meal-ingredient${unavailable ? " unavailable" : ""}">
          <input type="checkbox" id="${escapeHtml(card.recipe.id)}-ingredient-${index}" data-meal-line="${index}" ${unavailable ? "disabled" : "checked"} aria-label="Chọn ${escapeHtml(line.name)}" />
          <label for="${escapeHtml(card.recipe.id)}-ingredient-${index}">
            <span><span class="meal-ingredient-name">${escapeHtml(line.name)}</span><span class="meal-ingredient-detail">Dùng ${escapeHtml(amountLabel(line))} · mua ${escapeHtml(buyLabel)}</span></span>
            <span class="meal-ingredient-price">${line.product ? money(line.lineTotal) : "—"}</span>
          </label>
        </li>`;
      }).join("");
      return `<article class="meal-card" data-meal-card="${escapeHtml(card.recipe.id)}">
        <div class="meal-card-top">
          <img class="meal-card-image" src="${image}" alt="${escapeHtml(card.recipe.title)} đã nấu" loading="lazy" />
          <div class="meal-card-summary">
            <div class="meal-card-badges"><span class="meal-badge">${escapeHtml(card.recipe.typeLabel)}</span><span class="meal-badge time">${card.recipe.minutes} phút</span></div>
            <h3>${escapeHtml(card.recipe.title)}</h3>
            <p>${escapeHtml(card.recipe.description)}</p>
            <div class="meal-card-cost"><strong>${money(card.total)}</strong><span>ước tính nguyên liệu</span></div>
          </div>
        </div>
        <div class="meal-card-body">
          <h4>Nguyên liệu cho ${state.servings} người</h4>
          <ul class="meal-ingredient-list">${ingredientRows}</ul>
          <p class="meal-steps"><strong>Cách nấu:</strong> ${escapeHtml(card.recipe.steps)}</p>
          <button class="meal-add-button" type="button" data-add-meal="${escapeHtml(card.recipe.id)}">Thêm nguyên liệu · ${money(card.total)}</button>
        </div>
      </article>`;
    }).join("");
  }

  document.querySelectorAll("[data-servings]").forEach((button) => button.addEventListener("click", () => {
    state.servings = Number(button.dataset.servings);
    document.querySelectorAll("[data-servings]").forEach((choice) => {
      const active = choice === button;
      choice.classList.toggle("is-active", active);
      choice.setAttribute("aria-pressed", String(active));
    });
    render();
  }));
  document.getElementById("meal-budget").addEventListener("input", render);
  document.querySelectorAll("[data-diet]").forEach((button) => button.addEventListener("click", () => {
    state.diet = button.dataset.diet;
    document.querySelectorAll("[data-diet]").forEach((choice) => {
      const active = choice === button;
      choice.classList.toggle("is-active", active);
      choice.setAttribute("aria-pressed", String(active));
    });
    render();
  }));
  document.addEventListener("veggie:cart", () => {
    const cartCount = document.getElementById("meal-cart-count");
    if (cartCount && window.VeggieCart) cartCount.textContent = String(window.VeggieCart.getItems().reduce((sum, item) => sum + item.quantity, 0));
  });

  grid.addEventListener("change", (event) => {
    const root = event.target.closest("[data-meal-card]");
    if (root) updateAddButton(root, state.cards.get(root.dataset.mealCard));
  });
  grid.addEventListener("click", (event) => {
    const button = event.target.closest("[data-add-meal]");
    if (!button) return;
    const card = state.cards.get(button.dataset.addMeal);
    const root = button.closest("[data-meal-card]");
    const { selected } = selectedTotal(card, root);
    if (!selected.length || !window.VeggieCart) return;
    selected.forEach((line) => window.VeggieCart.add({ ...line.product, quantity: line.quantity }));
    const cartCount = document.getElementById("meal-cart-count");
    if (cartCount) cartCount.textContent = String(window.VeggieCart.getItems().reduce((sum, item) => sum + item.quantity, 0));
    showToast(`Đã thêm ${selected.length} nguyên liệu vào giỏ.`);
  });

  async function load() {
    try {
      const response = await fetch("/api/catalog", { headers: { Accept: "application/json" } });
      if (!response.ok) throw new Error("catalog");
      const catalog = await response.json();
      state.products = Array.isArray(catalog.products) ? catalog.products : [];
      if (!state.products.length) throw new Error("empty catalog");
      const cartCount = document.getElementById("meal-cart-count");
      if (cartCount && window.VeggieCart) cartCount.textContent = String(window.VeggieCart.getItems().reduce((sum, item) => sum + item.quantity, 0));
      render();
    } catch {
      status.textContent = "Không tải được danh mục cửa hàng. Hãy kiểm tra ứng dụng và kết nối cơ sở dữ liệu rồi tải lại trang.";
      count.textContent = "";
    }
  }

  load();
})();
