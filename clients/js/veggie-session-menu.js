// Các bảng trên thanh điều hướng mở riêng, đóng bằng Escape hoặc bấm bên ngoài.
(()=>{
const closeSearch=()=>document.querySelectorAll('.search-open').forEach(el=>el.classList.remove('search-open'));
const closeUsers=()=>document.querySelectorAll('.user-menu').forEach(el=>{el.classList.remove('veggie-user-open');el.querySelector(':scope > ul > li > a')?.setAttribute('aria-expanded','false');});
document.addEventListener('click',event=>{
 const search=event.target.closest('.header-search-1');if(search){closeUsers();return;}
 const trigger=event.target.closest('.user-menu > ul > li > a');if(trigger){event.preventDefault();event.stopImmediatePropagation();const menu=trigger.closest('.user-menu'),open=!menu.classList.contains('veggie-user-open');closeUsers();closeSearch();menu.classList.toggle('veggie-user-open',open);trigger.setAttribute('aria-expanded',String(open));return;}
 if(!event.target.closest('.user-menu'))closeUsers();if(!event.target.closest('.header-search-1-form'))closeSearch();
},true);
document.addEventListener('keydown',event=>{if(event.key==='Escape'){closeSearch();closeUsers();}});
})();
(async () => {
  if (!document.querySelector('script[src^="js/veggie-cart-server.js"]')) return;
  try {
    const response = await fetch("/api/account/me", { cache: "no-store" });
    if (!response.ok) return;
    const user = await response.json();
    for (const menu of document.querySelectorAll(".user-menu")) {
      const trigger = menu.querySelector(":scope > ul > li > a");
      const dropdown = menu.querySelector(":scope > ul > li > ul");
      if (trigger && typeof user.avatar === "string" &&
          /^\/product-uploads\/[a-f0-9]{32}\.(png|jpg)$/i.test(user.avatar)) {
        const photo = document.createElement("img");
        photo.className = "veggie-menu-avatar";
        photo.alt = "Tài khoản";
        photo.addEventListener("load", () => trigger.replaceChildren(photo), { once: true });
        photo.src = user.avatar;
      }
      if (!dropdown) continue;
      menu.classList.add("veggie-authenticated");
      dropdown.classList.add("veggie-session-dropdown");
      const profileEntry = document.createElement("li");
      profileEntry.className = "veggie-session-card";
      const profile = document.createElement("a");
      profile.href = "account.html";
      const badge = document.createElement("span");
      badge.className = "veggie-session-badge";
      if (typeof user.avatar === "string" && /^\/product-uploads\/[a-f0-9]{32}\.(png|jpg)$/i.test(user.avatar)) {
        const image = document.createElement("img");
        image.src = user.avatar;
        image.alt = "";
        badge.append(image);
      } else badge.textContent = user.name?.trim().charAt(0).toUpperCase() || "V";
      profile.append(badge, document.createTextNode(user.name || "Tài khoản"));
      profileEntry.append(profile);
      dropdown.prepend(profileEntry);
      if (["Admin","Staff"].includes(user.role)) {
        const adminEntry = document.createElement("li");
        const adminLink = document.createElement("a");
        adminLink.href = "/admin/dashboard";
        adminLink.textContent = "Quản trị cửa hàng";
        adminEntry.append(adminLink);
        profileEntry.after(adminEntry);
      }
      const entry = document.createElement("li");
      const button = document.createElement("button");
      button.type = "button";
      button.className = "veggie-menu-logout";
      button.innerHTML = '<span class="veggie-session-badge" aria-hidden="true"><i class="fas fa-sign-out-alt"></i></span><span>Đăng xuất</span>';
      button.addEventListener("click", async () => {
        button.disabled = true;
        try {
          const result = await fetch("/api/account/logout", { method: "POST" });
          if (!result.ok) throw new Error();
          location.href = "login.html";
        } catch {
          button.textContent = "Thử đăng xuất lại";
          button.disabled = false;
        }
      });
      entry.append(button);
      dropdown.append(entry);
    }
    for (const link of document.querySelectorAll('.user-menu a, .ltn__footer-area a')) {
      if (!/\/(login|register)\.html$/i.test(new URL(link.href).pathname)) continue;
      const item = link.closest("li") || link;
      item.style.setProperty("display", "none", "important");
      item.hidden = true;
    }
  } catch {
    // Keep guest links available if the session check fails.
  }
})();




