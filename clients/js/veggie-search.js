(() => {
  const catalog = window.VeggieCatalog;
  const filters = window.VeggieFilters;
  if (!catalog || !filters) return;

  const money = value => Number(value).toLocaleString('vi-VN') + '₫';
  const popularTerms = ['Đào tươi', 'Đu đủ chín', 'Dâu tây', 'Bơ sáp', 'Xoài chín'];
  const categoryIcons = {
    'rau-cu': '🥬',
    'trai-cay': '🍎',
    thit: '🥩',
    ca: '🐟',
    'thuc-pham-khac': '🛒',
  };
  const normalize = value => filters.normalize(value);

  document.querySelectorAll('.header-search-1-form form,.ltn__utilize-menu-search-form form').forEach(form => {
    const input = form.querySelector('input');
    if (!input || form.dataset.veggieSearchReady) return;
    form.dataset.veggieSearchReady = 'true';
    form.style.position = 'relative';
    input.autocomplete = 'off';
    input.setAttribute('aria-expanded', 'false');

    const panel = document.createElement('section');
    panel.className = 'veggie-search-panel';
    panel.setAttribute('aria-label', 'Gợi ý tìm kiếm sản phẩm');
    panel.hidden = true;
    form.append(panel);
    let suppressFocusOpen = false;

    const makeLink = (label, href, className) => {
      const anchor = document.createElement('a');
      anchor.textContent = label;
      anchor.href = href;
      if (className) anchor.className = className;
      return anchor;
    };

    const makeHeading = (label, sectionName) => {
      const heading = document.createElement('div');
      heading.className = 'veggie-search-section-heading';
      heading.textContent = label;
      if (sectionName) heading.setAttribute('aria-label', sectionName);
      return heading;
    };

    function render() {
      panel.replaceChildren();
      const query = input.value.trim();
      const heading = document.createElement('div');
      heading.className = 'veggie-search-heading';
      const title = document.createElement('strong');
      title.textContent = query ? 'Kết quả tìm kiếm' : 'Khám phá sản phẩm';
      const close = document.createElement('button');
      close.type = 'button';
      close.textContent = '×';
      close.setAttribute('aria-label', 'Đóng gợi ý');
      close.addEventListener('click', () => {
        panel.hidden = true;
        input.setAttribute('aria-expanded', 'false');
        suppressFocusOpen = true;
        input.focus();
        suppressFocusOpen = false;
      });
      heading.append(title, close);
      panel.append(heading);

      const categories = document.createElement('div');
      categories.className = 'veggie-search-category-section';
      categories.append(makeHeading('DANH MỤC PHỔ BIẾN'));
      const categoryList = document.createElement('div');
      categoryList.className = 'veggie-search-categories';
      catalog.categories.forEach(category => {
        const anchor = makeLink('', 'shop.html?category=' + encodeURIComponent(category.id));
        const icon = document.createElement('span');
        icon.setAttribute('aria-hidden', 'true');
        icon.textContent = categoryIcons[category.id] || '🛍️';
        const name = document.createElement('span');
        name.textContent = category.name;
        anchor.append(icon, name);
        categoryList.append(anchor);
      });
      categories.append(categoryList);
      panel.append(categories);

      const keywords = document.createElement('div');
      keywords.className = 'veggie-search-keyword-section';
      keywords.append(makeHeading('TỪ KHÓA GỢI Ý'));
      const normalizedQuery = normalize(query);
      let terms = popularTerms;
      if (normalizedQuery) {
        const matches = catalog.products
          .filter(product => normalize(product.name).includes(normalizedQuery))
          .map(product => product.name);
        terms = [...new Set(matches)].slice(0, 5);
      }
      if (!terms.length) terms = popularTerms;
      const keywordList = document.createElement('div');
      keywordList.className = 'veggie-search-keywords';
      terms.forEach(term => {
        const button = document.createElement('button');
        button.type = 'button';
        button.className = 'veggie-search-keyword';
        button.innerHTML = '<span aria-hidden="true">⌕</span><span></span><span aria-hidden="true">→</span>';
        button.children[1].textContent = term;
        button.addEventListener('click', () => {
          input.value = term;
          render();
          input.focus();
        });
        keywordList.append(button);
      });
      keywords.append(keywordList);
      panel.append(keywords);

      const results = query
        ? filters.apply(catalog.products, new URLSearchParams({ q: query }))
        : popularTerms
            .map(term => catalog.products.find(product => normalize(product.name) === normalize(term)))
            .filter(Boolean);
      const productSection = document.createElement('div');
      productSection.className = 'veggie-search-product-section';
      productSection.append(makeHeading(query ? 'SẢN PHẨM PHÙ HỢP' : 'SẢN PHẨM ĐƯỢC QUAN TÂM'));
      const productList = document.createElement('div');
      productList.className = 'veggie-search-products';
      results.slice(0, 8).forEach(product => {
        const anchor = makeLink('', 'product-details.html?id=' + encodeURIComponent(product.id), 'veggie-search-product');
        const image = document.createElement('img');
        image.src = product.image || 'img/veggie-logo.svg';
        image.alt = product.name;
        image.loading = 'lazy';
        const name = document.createElement('strong');
        name.textContent = product.name;
        const price = document.createElement('small');
        price.textContent = `${money(product.price)} / ${product.unit}`;
        anchor.append(image, name, price);
        productList.append(anchor);
      });
      if (!results.length) {
        const empty = document.createElement('p');
        empty.className = 'veggie-search-empty';
        empty.textContent = 'Không tìm thấy sản phẩm. Thử từ khóa khác nhé.';
        productSection.append(empty);
      } else {
        productSection.append(productList);
      }
      panel.append(productSection);

      const allResults = makeLink(
        query ? 'Xem tất cả kết quả →' : 'Xem toàn bộ cửa hàng →',
        'shop.html' + (query ? '?q=' + encodeURIComponent(query) : ''),
        'veggie-search-all',
      );
      panel.append(allResults);
      panel.hidden = false;
      input.setAttribute('aria-expanded', 'true');
    }

    input.addEventListener('focus', () => {
      if (!suppressFocusOpen) render();
    });
    input.addEventListener('input', render);
    form.addEventListener('submit', event => {
      event.preventDefault();
      const query = input.value.trim();
      if (query) window.location.href = 'shop.html?q=' + encodeURIComponent(query);
      else render();
    });
    form.addEventListener('keydown', event => {
      if (event.key === 'Escape') {
        panel.hidden = true;
        input.setAttribute('aria-expanded', 'false');
      }
    });
    document.addEventListener('click', event => {
      if (!form.contains(event.target)) {
        panel.hidden = true;
        input.setAttribute('aria-expanded', 'false');
      }
    });
  });
})();
