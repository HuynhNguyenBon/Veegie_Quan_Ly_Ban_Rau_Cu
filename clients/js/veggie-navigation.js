(() => {
  "use strict";

  const mealPlannerPage = "meal-planner.html";

  function pageFromPath(pathname) {
    const segments = pathname.toLowerCase().split("/").filter(Boolean);
    const lastSegment = segments.at(-1);
    if (!lastSegment) return "index.html";
    return lastSegment.includes(".") ? lastSegment : `${lastSegment}.html`;
  }

  function pageFromLink(link) {
    if (!link) return null;
    const href = link.getAttribute("href");
    if (!href || href.startsWith("#") || href.toLowerCase().startsWith("javascript:")) {
      return null;
    }

    try {
      return pageFromPath(new URL(href, window.location.href).pathname);
    } catch {
      return null;
    }
  }

  function addMealPlannerLink(list) {
    if (!list) return;

    const hasMealPlannerLink = [...list.children].some((item) => {
      const link = item.querySelector(":scope > a[href]");
      return pageFromLink(link) === mealPlannerPage;
    });
    if (hasMealPlannerLink) return;

    const shopItem = [...list.children].find((item) =>
      pageFromLink(item.querySelector(':scope > a[href="shop.html"]')) === "shop.html",
    );
    if (!shopItem) return;

    const item = document.createElement("li");
    const link = document.createElement("a");
    link.href = mealPlannerPage;
    link.textContent = "Nấu gì hôm nay?";
    item.append(link);
    shopItem.after(item);
  }

  function markCurrentPage(list) {
    if (!list) return;

    const currentPage = pageFromPath(window.location.pathname);
    [...list.children].forEach((item) => {
      const link = item.querySelector(":scope > a[href]");
      if (!link) return;

      const isCurrentPage = pageFromLink(link) === currentPage;
      item.classList.toggle("veggie-current-page", isCurrentPage);
      link.classList.toggle("veggie-current-page-link", isCurrentPage);
      link.removeAttribute("aria-current");
      link.classList.remove("ltn__secondary-color");
      if (isCurrentPage) link.setAttribute("aria-current", "page");
    });
  }

  const navigationLists = [
    ...document.querySelectorAll(".ltn__main-menu > ul"),
    ...document.querySelectorAll(".ltn__utilize-mobile-menu .ltn__utilize-menu > ul"),
  ];

  navigationLists.forEach(addMealPlannerLink);
  navigationLists.forEach(markCurrentPage);
})();
