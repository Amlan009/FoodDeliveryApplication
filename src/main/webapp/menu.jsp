<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    com.khaalo.model.User currentUser = (com.khaalo.model.User) session.getAttribute("user");
    if (currentUser != null) {
        if ("Restaurant Owner".equals(currentUser.getRole())) {
            response.sendRedirect("owner.jsp");
            return;
        } else if ("Administrator".equals(currentUser.getRole())) {
            response.sendRedirect("admin.jsp");
            return;
        } else if ("Delivery Partner".equals(currentUser.getRole())) {
            response.sendRedirect("delivery.jsp");
            return;
        }
    }
%>
<%@ page import="com.khaalo.model.Restaurant" %>
<%@ page import="com.khaalo.model.MenuCategory" %>
<%@ page import="com.khaalo.model.Dish" %>
<%@ page import="java.util.List" %>
<%@ page import="com.khaalo.model.Cart" %>
<%@ page import="com.khaalo.model.CartItem" %>
<%
    Restaurant r = (Restaurant) request.getAttribute("restaurant");
    List<MenuCategory> categories = (List<MenuCategory>) request.getAttribute("categories");
    List<Dish> allMenusByRestaurant = (List<Dish>) request.getAttribute("allMenusByRestaurant");
    
    // Safe fallbacks if page is accessed directly without the Servlet
    if (r == null) {
        String reqId = request.getParameter("id");
        if (reqId == null || reqId.trim().isEmpty()) {
            reqId = request.getParameter("restaurantId");
        }
        if (reqId != null && !reqId.trim().isEmpty()) {
            r = new com.khaalo.daoimpl.RestaurantDAOImpl().getRestaurantById(reqId);
        }
        if (r == null) {
            r = new Restaurant("restaurant1", "Spice Garden", 4.2, 120, "30-40", 600, "11:00 PM", "Indiranagar", "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=1200&h=400&fit=crop", "20% off");
        }
    }
    if (categories == null) {
        categories = new com.khaalo.daoimpl.MenuDAOImpl().getMenuByRestaurantId(r.getId());
    }
    if (allMenusByRestaurant == null) {
        allMenusByRestaurant = new com.khaalo.daoimpl.MenuDAOImpl().getAllMenusByRestaurant(r.getId());
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= r.getName() %> Menu | Khaalo</title>
    <meta name="description" content="Order food online from your favorite restaurants via Khaalo. Fast delivery and best prices.">
    <meta name="theme-color" content="#1a1a2e">

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    

    <!-- External Stylesheets (Shared root folder styles) -->
    
    



<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<!-- Khaalo Micro-Animations & JS Engines -->
<link rel="stylesheet" href="css/animations.css">
<%
    String currentMenuCartResId = (String) session.getAttribute("restaurantId");
    Cart sessionCartObjForMenu = (Cart) session.getAttribute("cart");
    if ((currentMenuCartResId == null || currentMenuCartResId.trim().isEmpty()) && sessionCartObjForMenu != null && sessionCartObjForMenu.getItems() != null && !sessionCartObjForMenu.getItems().isEmpty()) {
        try {
            int firstDishId = sessionCartObjForMenu.getItems().get(0).getDishId();
            Dish firstDish = new com.khaalo.daoimpl.MenuDAOImpl().getDishById(firstDishId);
            if (firstDish != null) {
                try (java.sql.Connection conn = com.util.connection.DBConnection.getConnection();
                     java.sql.PreparedStatement ps = conn.prepareStatement("SELECT `restaurant_id` FROM `menu_categories` WHERE `id` = ?")) {
                    ps.setInt(1, firstDish.getCategoryId());
                    try (java.sql.ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            currentMenuCartResId = rs.getString("restaurant_id");
                            session.setAttribute("restaurantId", currentMenuCartResId);
                        }
                    }
                }
            }
        } catch (Exception ignored) {}
    }
    if (currentMenuCartResId == null) currentMenuCartResId = "";
    int globalMenuCartCount = (sessionCartObjForMenu != null && sessionCartObjForMenu.getItems() != null) ? sessionCartObjForMenu.getItems().size() : 0;
%>
<script>
    window.currentCartRestaurantId = "<%= currentMenuCartResId %>";
    window.currentCartSize = <%= globalMenuCartCount %>;
    window.cartItems = [
        <%
            if (sessionCartObjForMenu != null && sessionCartObjForMenu.getItems() != null) {
                for (int i = 0; i < sessionCartObjForMenu.getItems().size(); i++) {
                    CartItem ci = sessionCartObjForMenu.getItems().get(i);
                    if (i > 0) out.print(",");
        %>
                    {"dishId": <%= ci.getDishId() %>, "quantity": <%= ci.getQuantity() %>, "price": <%= ci.getDishPrice() %>}
        <%
                }
            }
        %>
    ];
</script>
<script src="js/cart-app.js?v=<%= System.currentTimeMillis() %>" defer></script>
<script src="js/floating-cart.js?v=<%= System.currentTimeMillis() %>" defer></script>
<script src="js/live-search.js?v=<%= System.currentTimeMillis() %>" defer></script>
<style>
/* ============================================
   KHAALO - Food Delivery App Styles
   Har Bhook Ka Solution
   ============================================ */

/* === CSS Custom Properties (Design Tokens) === */
:root {
    /* Brand Colors */
    --primary: #FF6B35;
    --primary-dark: #E85D2C;
    --primary-light: #FF8A5C;
    --primary-glow: rgba(255, 107, 53, 0.35);

    --secondary: #2C1B10;
    --secondary-light: #3D291C;

    --accent: #FFB800;
    --accent-light: #FFD54F;

    /* Warm Appetite-Stimulating Neutrals */
    --bg-primary: #FFF9F2;
    --bg-secondary: #FFF3E0;
    --bg-card: #FFFFFF;
    --bg-card-hover: #FFFDF9;
    --bg-surface: #FFEEDD;
    --bg-glass: rgba(255, 255, 255, 0.88);
    --bg-glass-light: rgba(255, 107, 53, 0.06);

    --text-primary: #2C1B10;
    --text-secondary: #5C4333;
    --text-muted: #8E796A;
    --text-accent: #FF6B35;

    /* Borders */
    --border-subtle: rgba(255, 107, 53, 0.12);
    --border-active: rgba(255, 107, 53, 0.5);

    /* Shadows */
    --shadow-sm: 0 2px 8px rgba(0, 0, 0, 0.2);
    --shadow-md: 0 4px 20px rgba(0, 0, 0, 0.3);
    --shadow-lg: 0 8px 40px rgba(0, 0, 0, 0.4);
    --shadow-glow: 0 4px 30px var(--primary-glow);

    /* Spacing */
    --space-xs: 4px;
    --space-sm: 8px;
    --space-md: 16px;
    --space-lg: 24px;
    --space-xl: 32px;
    --space-2xl: 48px;

    /* Radius */
    --radius-sm: 8px;
    --radius-md: 12px;
    --radius-lg: 16px;
    --radius-xl: 24px;
    --radius-full: 9999px;

    /* Transitions */
    --transition-fast: 0.15s ease;
    --transition-base: 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    --transition-spring: 0.5s cubic-bezier(0.34, 1.56, 0.64, 1);

    /* Z-Index layers */
    --z-base: 1;
    --z-sticky: 100;
    --z-nav: 200;
    --z-overlay: 300;
    --z-modal: 400;
    --z-splash: 500;

    /* Layout */
    --nav-height: 72px;
    --header-height: 60px;
    --max-width: 1400px;
}

/* === Reset & Base Styles === */
*,
*::before,
*::after {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

html {
    font-size: 16px;
    scroll-behavior: smooth;
    -webkit-tap-highlight-color: transparent;
}

body {
    font-family: 'Outfit', 'Poppins', -apple-system, BlinkMacSystemFont, sans-serif;
    background: var(--bg-primary);
    /* Warm yellow-orange appetite-inducing gradient */
    background:
        radial-gradient(ellipse at 20% 0%, rgba(255, 170, 50, 0.15) 0%, transparent 55%),
        radial-gradient(ellipse at 80% 10%, rgba(255, 120, 30, 0.1) 0%, transparent 50%),
        radial-gradient(ellipse at 50% 60%, rgba(255, 180, 50, 0.08) 0%, transparent 60%),
        radial-gradient(ellipse at 90% 90%, rgba(255, 160, 50, 0.05) 0%, transparent 50%),
        linear-gradient(175deg, #FFFDF9 0%, #FFF5E6 30%, #FFE5CC 60%, #FFD9B3 100%);
    background-attachment: fixed;
    color: var(--text-primary);
    line-height: 1.6;
    overflow-x: hidden;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
}

img {
    max-width: 100%;
    height: auto;
    display: block;
}

button {
    border: none;
    background: none;
    cursor: pointer;
    font-family: inherit;
    color: inherit;
    outline: none;
}

input {
    border: none;
    background: none;
    font-family: inherit;
    color: inherit;
    outline: none;
}

a {
    text-decoration: none;
    color: inherit;
}

/* Scrollbar Styling */
::-webkit-scrollbar {
    width: 6px;
    height: 4px;
}

::-webkit-scrollbar-track {
    background: transparent;
}

::-webkit-scrollbar-thumb {
    background: var(--bg-surface);
    border-radius: var(--radius-full);
}

::-webkit-scrollbar-thumb:hover {
    background: var(--text-muted);
}



/* ============================================================
   KHAALO - Restaurant Menu Page Styles
   ============================================================ */

/* Page Layout */
.restaurant-body {
    background:
        radial-gradient(ellipse at 20% 0%, rgba(255, 170, 50, 0.15) 0%, transparent 55%),
        radial-gradient(ellipse at 80% 10%, rgba(255, 120, 30, 0.1) 0%, transparent 50%),
        radial-gradient(ellipse at 50% 60%, rgba(255, 180, 50, 0.08) 0%, transparent 60%),
        radial-gradient(ellipse at 90% 90%, rgba(255, 160, 50, 0.05) 0%, transparent 50%),
        linear-gradient(175deg, #FFFDF9 0%, #FFF5E6 30%, #FFE5CC 60%, #FFD9B3 100%);
    background-attachment: fixed;
    color: var(--text-primary);
    font-family: 'Outfit', sans-serif;
    min-height: 100vh;
}

/* Header & Navigation override */
.restaurant-nav {
    position: sticky;
    top: 0;
    z-index: 100;
    background: var(--bg-glass);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border-bottom: 1px solid var(--border-subtle);
    padding: var(--space-md) var(--space-lg);
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.back-btn {
    display: inline-flex;
    align-items: center;
    gap: var(--space-sm);
    color: var(--text-primary);
    text-decoration: none;
    font-weight: 600;
    font-size: 0.95rem;
    transition: color var(--transition-fast);
    background: none;
    border: none;
    cursor: pointer;
}

.back-btn:hover {
    color: var(--primary);
}

.nav-search-wrapper {
    position: relative;
    flex: 1;
    max-width: 600px;
    margin: 0 var(--space-md);
}

.nav-search-wrapper .menu-search-icon {
    position: absolute;
    left: 14px;
    top: 50%;
    transform: translateY(-50%);
    color: var(--text-muted);
    pointer-events: none;
}

.nav-search-wrapper .menu-search-input {
    width: 100%;
    padding: 10px 16px 10px 42px;
    border-radius: var(--radius-full);
    border: 1px solid var(--border-subtle);
    background: var(--bg-card);
    color: var(--text-primary);
    font-family: inherit;
    font-size: 0.95rem;
    transition: all var(--transition-fast);
}

.nav-search-wrapper .menu-search-input:focus {
    border-color: var(--primary);
    box-shadow: 0 0 0 3px rgba(255, 107, 53, 0.15);
    outline: none !important;
}

/* Restaurant Header Banner */
.restaurant-header-banner {
    position: relative;
    width: 100%;
    height: 340px;
    overflow: hidden;
}

.restaurant-header-banner img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    object-position: center 20%;
}

.restaurant-header-overlay {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: linear-gradient(180deg, rgba(0,0,0,0.1) 0%, rgba(0,0,0,0.7) 100%);
}

/* Restaurant Info Section */
.restaurant-info-card {
    position: relative;
    max-width: 900px;
    margin: -60px auto 0;
    background: var(--bg-card);
    border-radius: var(--radius-lg);
    padding: var(--space-lg) var(--space-xl);
    box-shadow: var(--shadow-md);
    z-index: 10;
    border: 1px solid var(--border-subtle);
}

.restaurant-title-row {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    flex-wrap: wrap;
    gap: var(--space-md);
    margin-bottom: var(--space-sm);
}

.restaurant-name-title {
    font-size: 2.2rem;
    font-weight: 800;
    margin: 0;
    color: var(--text-primary);
}

.restaurant-rating-box {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: #25C578;
    color: #fff;
    padding: 6px 12px;
    border-radius: var(--radius-sm);
    font-weight: 700;
    font-size: 1rem;
}

.restaurant-rating-box.rating-low {
    background: var(--primary);
}

.restaurant-meta-details {
    color: var(--text-secondary);
    font-size: 0.95rem;
    margin-bottom: var(--space-md);
}

.restaurant-meta-pills {
    display: flex;
    flex-wrap: wrap;
    gap: var(--space-sm);
    border-top: 1px solid var(--border-subtle);
    padding-top: var(--space-md);
    margin-top: var(--space-md);
}

.meta-pill {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: var(--bg-secondary);
    padding: 6px 12px;
    border-radius: var(--radius-full);
    font-size: 0.85rem;
    font-weight: 600;
    color: var(--text-secondary);
    border: 1px solid var(--border-subtle);
}

.restaurant-discount-pill {
    background: rgba(255, 107, 53, 0.08);
    border: 1px dashed var(--primary);
    color: var(--primary-dark);
}

/* Sticky Filter & Search Bar */
.menu-sticky-bar {
    position: sticky;
    top: 68px; /* Below navigation */
    z-index: 90;
    background: var(--bg-glass);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border-bottom: 1px solid var(--border-subtle);
    padding: var(--space-sm) var(--space-lg);
    box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    margin-top: var(--space-lg);
}

.menu-filter-container {
    max-width: 900px;
    margin: 0 auto;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: var(--space-md);
    flex-wrap: wrap;
}

.menu-search-wrapper {
    position: relative;
    flex: 1;
    min-width: 250px;
}

.menu-search-input {
    width: 100%;
    padding: 10px 16px 10px 42px;
    border-radius: var(--radius-md);
    border: 1px solid var(--border-subtle);
    background: var(--bg-card);
    color: var(--text-primary);
    font-family: inherit;
    font-size: 0.95rem;
    transition: all var(--transition-fast);
}

.menu-search-input:focus {
    border-color: var(--primary);
    box-shadow: 0 0 0 3px rgba(255, 107, 53, 0.15);
    outline: none;
}

.menu-search-icon {
    position: absolute;
    left: 14px;
    top: 50%;
    transform: translateY(-50%);
    color: var(--text-muted);
    pointer-events: none;
}

.menu-toggles {
    display: flex;
    align-items: center;
    gap: var(--space-sm);
}

.diet-toggle {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 8px 16px;
    border-radius: var(--radius-full);
    font-size: 0.85rem;
    font-weight: 600;
    cursor: pointer;
    transition: all var(--transition-fast);
    border: 1px solid var(--border-subtle);
    background: var(--bg-card);
    user-select: none;
}

.diet-toggle.veg-toggle {
    color: #25C578;
    border-color: rgba(37, 197, 120, 0.2);
}

.diet-toggle.veg-toggle.active {
    background: rgba(37, 197, 120, 0.12);
    border-color: #25C578;
    box-shadow: 0 2px 8px rgba(37, 197, 120, 0.15);
}

.diet-toggle.nonveg-toggle {
    color: #E23744;
    border-color: rgba(226, 55, 68, 0.2);
}

.diet-toggle.nonveg-toggle.active {
    background: rgba(226, 55, 68, 0.12);
    border-color: #E23744;
    box-shadow: 0 2px 8px rgba(226, 55, 68, 0.15);
}

.diet-toggle.allergy-toggle {
    color: #c62828;
    border-color: rgba(198, 40, 40, 0.2);
}

.diet-toggle.allergy-toggle.active {
    background: rgba(198, 40, 40, 0.08);
    border-color: #c62828;
    box-shadow: 0 2px 8px rgba(198, 40, 40, 0.12);
}

.allergen-warning-badge {
    background: #FFF2F2;
    border: 1px solid #FFCDCD;
    color: #D32F2F;
    font-size: 0.72rem;
    font-weight: 700;
    padding: 4px 8px;
    border-radius: var(--radius-sm);
    width: fit-content;
    margin-top: 6px;
    display: inline-flex;
    align-items: center;
    gap: 4px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.diet-indicator-box {
    width: 14px;
    height: 14px;
    border: 1.5px solid currentColor;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 2px;
}

.diet-indicator-dot {
    width: 6px;
    height: 6px;
    background: currentColor;
    border-radius: 50%;
}

.diet-indicator-triangle {
    width: 0;
    height: 0;
    border-left: 4px solid transparent;
    border-right: 4px solid transparent;
    border-bottom: 7px solid currentColor;
}

/* Main Layout: Centered Dish List */
.menu-main-content {
    max-width: 800px;
    margin: var(--space-lg) auto;
    padding: 0 var(--space-lg) 120px;
}

.menu-diet-toggles-inline {
    display: flex;
    align-items: center;
    gap: var(--space-sm);
    padding: var(--space-md) 0;
    border-bottom: 1px solid var(--border-subtle);
    margin-bottom: var(--space-lg);
}

/* Dish Lists */
.menu-dishes-section {
    display: flex;
    flex-direction: column;
    gap: var(--space-2xl);
}

.category-block {
    scroll-margin-top: 150px;
}

.category-block-title {
    font-size: 1.5rem;
    font-weight: 800;
    margin-bottom: var(--space-lg);
    border-bottom: 2px solid var(--border-subtle);
    padding-bottom: 8px;
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.category-count-badge {
    font-size: 0.8rem;
    color: var(--text-muted);
    font-weight: 500;
}

.dish-card {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: var(--space-lg);
    padding: var(--space-lg) 0;
    border-bottom: 1px solid var(--border-subtle);
    transition: transform var(--transition-fast);
}

.dish-details {
    flex: 1;
}

.dish-diet-icon {
    display: inline-flex;
    margin-bottom: 6px;
}

.dish-name-row {
    display: flex;
    align-items: center;
    gap: var(--space-sm);
    margin-bottom: 4px;
}

.dish-name {
    font-size: 1.15rem;
    font-weight: 700;
    color: var(--text-primary);
    margin: 0;
}

.bestseller-badge {
    background: rgba(255, 184, 0, 0.15);
    border: 1px solid var(--accent);
    color: var(--text-primary);
    font-size: 0.7rem;
    font-weight: 700;
    padding: 2px 6px;
    border-radius: 4px;
    text-transform: uppercase;
}

.dish-price {
    font-size: 1.05rem;
    font-weight: 700;
    color: var(--text-primary);
    margin-bottom: 6px;
}

.dish-rating {
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 0.8rem;
    font-weight: 600;
    color: var(--text-secondary);
    margin-bottom: var(--space-sm);
}

.dish-rating svg {
    color: var(--accent);
}

.dish-reviews {
    color: var(--text-muted);
    font-weight: 400;
}

.dish-description {
    font-size: 0.88rem;
    color: var(--text-secondary);
    line-height: 1.4;
    margin: 0;
}

.dish-image-action-wrapper {
    position: relative;
    width: 120px;
    height: 120px;
    flex-shrink: 0;
}

.dish-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
    border-radius: var(--radius-md);
    border: 1px solid var(--border-subtle);
}

.dish-add-btn {
    position: absolute;
    bottom: -10px;
    left: 50%;
    transform: translateX(-50%);
    background: #fff;
    color: #25C578;
    border: 1.5px solid #25C578;
    padding: 6px 20px;
    border-radius: var(--radius-sm);
    font-weight: 700;
    font-size: 0.85rem;
    box-shadow: 0 4px 10px rgba(0,0,0,0.1);
    cursor: pointer;
    transition: all var(--transition-fast);
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.dish-add-btn:hover {
    background: #25C578;
    color: #fff;
    box-shadow: 0 4px 15px rgba(37, 197, 120, 0.3);
}

/* Menu Quantity Selector Styling */
.dish-action-container {
    position: absolute;
    bottom: -10px;
    left: 50%;
    transform: translateX(-50%);
    z-index: 10;
}

.chef-action-container {
    position: static !important;
    transform: none !important;
    width: 100%;
    margin-top: auto;
}

.menu-qty-selector {
    display: inline-flex;
    align-items: center;
    justify-content: space-between;
    background: #fff;
    border: 1.5px solid #25C578;
    border-radius: var(--radius-sm);
    padding: 0 8px;
    height: 34px;
    min-width: 80px;
    box-shadow: 0 4px 10px rgba(0,0,0,0.1);
    box-sizing: border-box;
    transition: all var(--transition-fast);
}

.chef-action-container .menu-qty-selector {
    width: 100%;
}

.menu-qty-btn {
    background: none;
    border: none;
    color: #25C578;
    font-size: 1.1rem;
    font-weight: 800;
    cursor: pointer;
    width: 20px;
    height: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: transform var(--transition-fast);
}

.menu-qty-btn:active {
    transform: scale(0.85);
}

.menu-qty-value {
    font-size: 0.85rem;
    font-weight: 800;
    color: var(--text-primary);
    min-width: 16px;
    text-align: center;
}

.customisable-tag {
    font-size: 0.65rem;
    color: var(--text-muted);
    text-align: center;
    position: absolute;
    bottom: -28px;
    width: 100%;
    left: 0;
    font-weight: 500;
}

/* Chef's Recommendation Section */
.chef-recommendation-section {
    background: linear-gradient(135deg, var(--bg-secondary), var(--bg-surface));
    border-radius: var(--radius-lg);
    padding: var(--space-xl);
    margin-top: var(--space-2xl);
    border: 1px solid var(--border-subtle);
    box-shadow: var(--shadow-sm);
}

.chef-header {
    display: flex;
    align-items: center;
    gap: var(--space-sm);
    margin-bottom: var(--space-lg);
}

.chef-header-icon {
    font-size: 2rem;
}

.chef-header-title {
    font-size: 1.6rem;
    font-weight: 800;
    margin: 0;
    color: var(--text-primary);
}

.chef-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: var(--space-lg);
}

.chef-item-card {
    background: var(--bg-card);
    border-radius: var(--radius-md);
    padding: var(--space-md);
    border: 1px solid var(--border-subtle);
    box-shadow: var(--shadow-sm);
    display: flex;
    flex-direction: column;
    height: 100%;
}

.chef-item-img {
    width: 100%;
    height: 140px;
    object-fit: cover;
    border-radius: var(--radius-sm);
    margin-bottom: var(--space-sm);
}

.chef-item-info {
    flex: 1;
    display: flex;
    flex-direction: column;
}

.chef-item-title {
    font-size: 1.05rem;
    font-weight: 700;
    margin: 4px 0;
}

.chef-item-price {
    font-size: 1rem;
    font-weight: 700;
    color: var(--primary-dark);
    margin-bottom: var(--space-sm);
}

.chef-item-desc {
    font-size: 0.8rem;
    color: var(--text-secondary);
    margin-bottom: var(--space-sm);
    line-height: 1.4;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

/* FAQ Accordion Section */
.restaurant-faq-section {
    max-width: 900px;
    margin: var(--space-2xl) auto;
    padding: 0 var(--space-md);
}

.faq-section-title {
    font-size: 1.6rem;
    font-weight: 800;
    margin-bottom: var(--space-lg);
    text-align: center;
}

.faq-list {
    display: flex;
    flex-direction: column;
    gap: var(--space-sm);
}

.faq-item {
    background: var(--bg-card);
    border: 1px solid var(--border-subtle);
    border-radius: var(--radius-md);
    overflow: hidden;
}

.faq-question-btn {
    width: 100%;
    padding: 16px 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: none;
    border: none;
    text-align: left;
    font-family: inherit;
    font-size: 1rem;
    font-weight: 700;
    color: var(--text-primary);
    cursor: pointer;
    transition: background var(--transition-fast);
}

.faq-question-btn:hover {
    background: rgba(255, 107, 53, 0.02);
}

.faq-chevron {
    transition: transform var(--transition-fast);
    color: var(--primary);
}

.faq-item.active .faq-chevron {
    transform: rotate(180deg);
}

.faq-answer {
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.3s ease-out;
    background: rgba(255, 107, 53, 0.01);
}

.faq-answer-content {
    padding: 0 20px 16px 20px;
    font-size: 0.9rem;
    color: var(--text-secondary);
    line-height: 1.5;
}

/* Floating Browse Menu Button & Sidebar overlay */
.browse-menu-btn {
    position: fixed;
    bottom: 80px;
    right: 24px;
    background: var(--text-primary);
    color: #fff;
    border: none;
    width: 52px;
    height: 52px;
    padding: 0;
    border-radius: 50%;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    box-shadow: var(--shadow-lg);
    cursor: pointer;
    z-index: 80;
    transition: all var(--transition-spring);
}

.browse-menu-btn:hover {
    transform: translateY(-4px) scale(1.1);
    background: var(--primary-dark);
    box-shadow: 0 8px 25px rgba(255, 107, 53, 0.4);
}

/* Browse Menu Sidebar Modal */
.sidebar-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.4);
    backdrop-filter: blur(4px);
    z-index: 1000;
    opacity: 0;
    pointer-events: none;
    transition: opacity 0.3s ease;
}

.sidebar-overlay:target,
.category-sidebar-modal:target ~ .sidebar-overlay {
    opacity: 1;
    pointer-events: auto;
}

.category-sidebar-modal {
    position: fixed;
    top: 0;
    left: -320px;
    width: 300px;
    height: 100%;
    background: var(--bg-card);
    box-shadow: var(--shadow-lg);
    z-index: 1001;
    transition: left 0.3s cubic-bezier(0.16, 1, 0.3, 1);
    display: flex;
    flex-direction: column;
    padding: var(--space-xl) var(--space-lg);
}

.category-sidebar-modal:target {
    left: 0;
}

.sidebar-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid var(--border-subtle);
    padding-bottom: var(--space-md);
    margin-bottom: var(--space-lg);
}

.sidebar-title {
    font-size: 1.3rem;
    font-weight: 800;
    margin: 0;
}

.sidebar-close-btn {
    background: none;
    border: none;
    font-size: 1.5rem;
    cursor: pointer;
    color: var(--text-muted);
}

.sidebar-links-list {
    display: flex;
    flex-direction: column;
    gap: var(--space-sm);
    overflow-y: auto;
    flex: 1;
}

.sidebar-link {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 16px;
    border-radius: var(--radius-md);
    color: var(--text-primary);
    text-decoration: none;
    font-weight: 600;
    transition: all var(--transition-fast);
}

.sidebar-link:hover {
    background: var(--bg-secondary);
    color: var(--primary);
}

.sidebar-link-count {
    font-size: 0.75rem;
    background: var(--bg-surface);
    color: var(--text-secondary);
    padding: 2px 8px;
    border-radius: var(--radius-full);
}

/* Empty State search */
.menu-empty-state {
    text-align: center;
    padding: var(--space-2xl) 0;
    color: var(--text-muted);
}

.menu-empty-title {
    font-size: 1.2rem;
    font-weight: 700;
    color: var(--text-secondary);
    margin-bottom: var(--space-sm);
}

/* Responsive Overrides */
@media screen and (max-width: 768px) {
    .menu-main-content {
        padding: 0 var(--space-md) 120px;
    }

    .restaurant-name-title {
        font-size: 1.6rem;
    }

    .restaurant-info-card {
        margin: -40px var(--space-md) 0;
        padding: var(--space-md);
    }

    .dish-card {
        gap: var(--space-md);
    }

    .dish-image-action-wrapper {
        width: 90px;
        height: 90px;
    }

    .dish-name {
        font-size: 1rem;
    }

    .menu-sticky-bar {
        top: 56px; /* Adjust for mobile top bar height */
        padding: var(--space-sm) var(--space-md);
    }

    .browse-menu-btn {
        bottom: 75px;
        right: 16px;
        width: 46px;
        height: 46px;
    }

    .nav-search-wrapper {
        margin: 0 var(--space-sm);
    }
}

/* === Replace Cart Confirmation Modal === */
.replace-cart-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.6);
    backdrop-filter: blur(5px);
    z-index: 2000;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: var(--space-md);
    opacity: 0;
    pointer-events: none;
    transition: opacity 0.3s ease;
}

.replace-cart-overlay.active {
    opacity: 1;
    pointer-events: auto;
}

.replace-cart-modal {
    background: var(--bg-card);
    border-radius: var(--radius-xl);
    padding: var(--space-xl);
    max-width: 420px;
    width: 100%;
    box-shadow: 0 15px 40px rgba(0, 0, 0, 0.3);
    text-align: center;
    transform: translateY(20px);
    transition: transform 0.3s ease;
}

.replace-cart-overlay.active .replace-cart-modal {
    transform: translateY(0);
}

.replace-cart-title {
    font-size: 1.3rem;
    font-weight: 800;
    color: var(--text-primary);
    margin-bottom: var(--space-md);
}

.replace-cart-desc {
    font-size: 0.95rem;
    color: var(--text-secondary);
    line-height: 1.5;
    margin-bottom: var(--space-xl);
}

.replace-cart-actions {
    display: flex;
    gap: var(--space-md);
    justify-content: center;
}

.replace-cart-btn {
    padding: 12px 24px;
    border-radius: var(--radius-md);
    font-size: 0.95rem;
    font-weight: 700;
    cursor: pointer;
    transition: all var(--transition-base);
}

.replace-cart-btn.cancel {
    background: var(--bg-secondary);
    color: var(--text-secondary);
    border: 1px solid var(--border-subtle);
}

.replace-cart-btn.cancel:hover {
    background: var(--bg-card-hover);
    color: var(--text-primary);
}

.replace-cart-btn.confirm {
    background: var(--primary);
    color: white;
    border: none;
}

.replace-cart-btn.confirm:hover {
    background: var(--primary-dark);
    transform: translateY(-1px);
}

/* === Bottom Cart Floating Popup Bar === */
.bottom-cart-bar {
    position: fixed;
    bottom: 24px;
    left: 50%;
    transform: translateX(-50%) translateY(150px);
    width: calc(100% - 32px);
    max-width: 600px;
    background: linear-gradient(135deg, #1f1a14, #120e0a);
    border: 1px solid rgba(255, 107, 53, 0.25);
    box-shadow: 0 12px 40px rgba(0, 0, 0, 0.5), 0 0 0 1px rgba(255, 107, 53, 0.1);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    padding: 14px var(--space-xl);
    border-radius: var(--radius-lg);
    display: flex;
    justify-content: space-between;
    align-items: center;
    z-index: 1000;
    transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275), opacity 0.3s ease;
    opacity: 0;
    pointer-events: none;
}

.bottom-cart-bar.active {
    transform: translateX(-50%) translateY(0);
    opacity: 1;
    pointer-events: auto;
}

.bottom-cart-info {
    display: flex;
    align-items: center;
    gap: var(--space-sm);
    color: white;
    font-weight: 700;
    font-size: 0.95rem;
}

.bottom-cart-separator {
    color: rgba(255, 255, 255, 0.3);
}

.bottom-cart-total {
    color: var(--primary);
    font-size: 1.05rem;
}

.bottom-cart-action-btn {
    background: linear-gradient(135deg, #FF6B35, #E85D2C);
    color: white;
    border: none;
    padding: 10px 24px;
    border-radius: var(--radius-md);
    font-weight: 700;
    font-size: 0.95rem;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 8px;
    transition: all var(--transition-base);
    box-shadow: 0 4px 15px rgba(255, 107, 53, 0.3);
}

.bottom-cart-action-btn:hover {
    transform: translateY(-1px);
    box-shadow: 0 6px 20px rgba(255, 107, 53, 0.4);
}

.bottom-cart-action-btn:active {
    transform: translateY(1px);
}

/* Hide the old menu cart button */
.menu-cart-btn {
    display: none !important;
}

/* Conflict Modal Styles */
.modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.45);
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    pointer-events: none;
    transition: all 0.3s cubic-bezier(0.25, 1, 0.5, 1);
    backdrop-filter: blur(10px);
    z-index: 9999;
}
.modal-overlay:target {
    opacity: 1;
    pointer-events: auto;
}
.modal-container {
    transform: scale(0.92);
    transition: all 0.3s cubic-bezier(0.25, 1, 0.5, 1);
    background: var(--bg-surface, #ffffff);
    border-radius: var(--radius-lg, 16px);
    padding: 24px;
    max-width: 440px;
    width: 90%;
    box-shadow: 0 20px 50px rgba(0, 0, 0, 0.15);
}
/* === Footer Styles === */
.app-footer {
    background: var(--bg-secondary);
    border-top: 1px solid var(--border-subtle);
    padding: var(--space-2xl) 0;
    margin-top: var(--space-2xl);
    width: 100%;
}
.footer-container {
    max-width: var(--max-width);
    margin: 0 auto;
    padding: 0 var(--space-xl);
}
.footer-brand-row {
    margin-bottom: var(--space-xl);
    display: flex;
    justify-content: flex-start;
    align-items: center;
}
.footer-logo {
    display: flex;
    align-items: center;
    gap: var(--space-sm);
}
.footer-logo .logo-icon {
    font-size: 2rem;
}
.footer-logo .logo-name {
    font-size: 1.8rem;
    font-weight: 800;
    color: var(--text-primary);
    background: linear-gradient(135deg, var(--primary), var(--accent));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}
.footer-links-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: var(--space-xl);
    margin-bottom: var(--space-2xl);
    border-bottom: 1px solid var(--border-subtle);
    padding-bottom: var(--space-2xl);
}
.footer-column h3 {
    font-size: 0.85rem;
    font-weight: 700;
    color: var(--text-primary);
    letter-spacing: 1.5px;
    margin-bottom: var(--space-lg);
    text-transform: uppercase;
}
.footer-column ul {
    list-style: none;
    padding: 0;
}
.footer-column ul li {
    margin-bottom: var(--space-sm);
}
.footer-column ul li a {
    font-size: 0.9rem;
    color: var(--text-secondary);
    transition: all var(--transition-fast);
}
.footer-column ul li a:hover {
    color: var(--primary);
    padding-left: 2px;
}
.social-column {
    display: flex;
    flex-direction: column;
}
.social-icons {
    display: flex;
    gap: var(--space-sm);
    margin-bottom: var(--space-lg);
}
.social-icon {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background: var(--text-primary);
    color: var(--bg-secondary);
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all var(--transition-base);
}
.social-icon:hover {
    background: var(--primary);
    color: white;
    transform: translateY(-2px);
}
.app-download-badges {
    display: flex;
    flex-direction: column;
    gap: var(--space-sm);
    max-width: 160px;
}
.download-badge {
    background: #0F0906;
    border: 1px solid #231710;
    border-radius: var(--radius-sm);
    padding: 6px 12px;
    color: white;
    display: flex;
    align-items: center;
    transition: all var(--transition-base);
}
.download-badge:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-sm);
    border-color: var(--border-active);
}
.download-badge .badge-content {
    display: flex;
    align-items: center;
    gap: var(--space-sm);
    width: 100%;
}
.download-badge svg {
    color: white;
    flex-shrink: 0;
}
.badge-text {
    display: flex;
    flex-direction: column;
    line-height: 1.1;
}
.download-subText {
    font-size: 0.55rem;
    text-transform: uppercase;
    color: #8C7560;
}
.download-mainText {
    font-size: 0.8rem;
    font-weight: 700;
}
.footer-bottom {
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.footer-bottom .copyright {
    font-size: 0.8rem;
    color: var(--text-muted);
    line-height: 1.5;
}
@media screen and (max-width: 768px) {
    .footer-links-grid {
        grid-template-columns: repeat(2, 1fr);
        gap: var(--space-lg);
    }
}
</style>
</head>
<body class="restaurant-body">

    <!-- Top Bar / Navigation -->
    <nav class="restaurant-nav">
        <a class="back-btn" href="restaurants" aria-label="Back to Home">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <line x1="19" y1="12" x2="5" y2="12"></line>
                <polyline points="12 19 5 12 12 5"></polyline>
            </svg>
        </a>
        <div class="nav-search-wrapper">
            <svg class="menu-search-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="11" cy="11" r="8"></circle>
                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
            </svg>
            <input type="text" class="menu-search-input" id="menuSearchInput" placeholder="Search for dishes within the menu...">
        </div>
        <a href="cart.jsp?ref=menu&restaurantId=<%= r.getId() %>" class="menu-cart-btn" aria-label="Cart" style="position: relative; background: none; border: none; color: var(--text-primary); cursor: pointer; display: flex; align-items: center; justify-content: center; width: 40px; height: 40px; border-radius: 50%; transition: all var(--transition-fast); text-decoration: none;">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="9" cy="21" r="1"></circle>
                <circle cx="20" cy="21" r="1"></circle>
                <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path>
            </svg>
            <span class="cart-badge menu-cart-badge" style="position: absolute; top: 0; right: 0; background: var(--primary); color: white; font-size: 0.75rem; font-weight: 700; min-width: 18px; height: 18px; border-radius: 50%; display: flex; align-items: center; justify-content: center; border: 2px solid var(--bg-card); display: none;">0</span>
        </a>
    </nav>

    <!-- Main Container -->
    <div id="restaurantViewContainer">
        <!-- Banner Image -->
        <div class="restaurant-header-banner">
            <img src="<%= r.getBannerUrl() %>" alt="<%= r.getName() %>">
            <div class="restaurant-header-overlay"></div>
        </div>

        <!-- Info Card -->
        <div class="restaurant-info-card">
            <div class="restaurant-title-row">
                <h1 class="restaurant-name-title"><%= r.getName() %></h1>
                <div class="restaurant-rating-box">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                        <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
                    </svg>
                    <span><%= r.getRating() %></span>
                </div>
            </div>
            <div class="restaurant-meta-details">
                Cost for two: &#8377;<%= r.getCostForTwo() %>
            </div>
            <div class="restaurant-meta-pills">
                <span class="meta-pill">&#128337; <%= r.getDeliveryTime() %> mins</span>
                <span class="meta-pill">&#9200; Closes at <%= r.getClosesAt() %></span>
                <span class="meta-pill">&#128205; <%= r.getOutletLocation() %></span>
                <% 
                    String discountTag = r.getDiscountTag();
                    if (discountTag != null && !discountTag.trim().isEmpty()) {
                        discountTag = discountTag.replace("₹", "&#8377;").replace("â,¹", "&#8377;").replace("â‚¹", "&#8377;").replace("?", "&#8377;");
                %>
                <span class="meta-pill restaurant-discount-pill">&#127991; <%= discountTag %></span>
                <% } %>
            </div>
        </div>

        <!-- Main Section -->
        <div class="menu-main-content">
            <%
                String currentDiet = request.getParameter("diet");
                if (currentDiet == null) currentDiet = "all";

                String vegUrl = "menu?restaurantId=" + r.getId() + ("veg".equalsIgnoreCase(currentDiet) ? "" : "&diet=veg");
                String nonVegUrl = "menu?restaurantId=" + r.getId() + ("non-veg".equalsIgnoreCase(currentDiet) ? "" : "&diet=non-veg");
            %>
            <!-- Veg / Non-Veg Toggles -->
            <div class="menu-diet-toggles-inline" id="menuDietToggles">
                <a href="<%= vegUrl %>" class="diet-toggle veg-toggle <%= "veg".equalsIgnoreCase(currentDiet) ? "active" : "" %>" style="text-decoration: none; color: inherit; display: inline-flex; align-items: center;">
                    <span class="diet-indicator-box">
                        <span class="diet-indicator-dot"></span>
                    </span>
                    Veg Only
                </a>
                <a href="<%= nonVegUrl %>" class="diet-toggle nonveg-toggle <%= "non-veg".equalsIgnoreCase(currentDiet) ? "active" : "" %>" style="text-decoration: none; color: inherit; display: inline-flex; align-items: center;">
                    <span class="diet-indicator-box">
                        <span class="diet-indicator-triangle"></span>
                    </span>
                    Non-Veg
                </a>
            </div>

            <!-- Dishes Sections Grouped dynamically by Categories -->
            <main class="menu-dishes-section" id="dishesSectionsContainer">
                <%
                    if (categories != null && !categories.isEmpty()) {
                        for (MenuCategory c : categories) {
                            String categoryId = c.getCategoryName().replaceAll("\\s+", "-").toLowerCase();
                %>
                            <section class="category-block" id="<%= categoryId %>">
                                <h2 class="category-block-title">
                                    <%= c.getCategoryName() %>
                                </h2>
                                <div class="dish-list-container">
                                    <%
                                        boolean hasDishes = false;
                                        if (allMenusByRestaurant != null && !allMenusByRestaurant.isEmpty()) {
                                            for (Dish dish : allMenusByRestaurant) {
                                                if (dish.getCategoryId() == c.getId()) {
                                                    if ("veg".equalsIgnoreCase(currentDiet) && !dish.isVeg()) continue;
                                                    if ("non-veg".equalsIgnoreCase(currentDiet) && dish.isVeg()) continue;
                                                    hasDishes = true;
                                                    String dietIconHtml = dish.isVeg() ? 
                                                        "<span class=\"dish-diet-icon\" style=\"color: #25C578;\" title=\"Veg Only\"><span class=\"diet-indicator-box\"><span class=\"diet-indicator-dot\"></span></span></span>" : 
                                                        "<span class=\"dish-diet-icon\" style=\"color: #E23744;\" title=\"Non-Veg\"><span class=\"diet-indicator-box\"><span class=\"diet-indicator-triangle\"></span></span></span>";
                                                    String fallbackImg = dish.isVeg() ? 
                                                        "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=120&h=120&fit=crop" : 
                                                        "https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=120&h=120&fit=crop";
                                                    String dishImg = (dish.getImageUrl() != null && !dish.getImageUrl().trim().isEmpty()) ? dish.getImageUrl() : fallbackImg;
                                    %>
                                                    <!-- menu-card: Teacher's exact CSS class; dish-card: styled premium CSS class -->
                                                    <div class="menu-card dish-card" data-diet="<%= dish.isVeg() ? "veg" : "non-veg" %>" data-price="<%= dish.getPrice() %>" data-name="<%= dish.getName() %>">
                                                        <!-- image-container: Teacher's exact CSS class; dish-image-action-wrapper: styled premium CSS class -->
                                                        <div class="image-container dish-image-action-wrapper">
                                                            <img src="<%= dishImg %>" alt="<%= dish.getName() %>" class="dish-image" loading="lazy">
                                                             <div class="dish-action-container" data-dish-id="<%= dish.getId() %>" data-res-id="<%= r.getId() %>">
                                                                 <%
                                                                     int inCartQty = 0;
                                                                     if (sessionCartObjForMenu != null && sessionCartObjForMenu.getItems() != null) {
                                                                         for (CartItem item : sessionCartObjForMenu.getItems()) {
                                                                             if (item.getDishId() == dish.getId()) {
                                                                                 inCartQty = item.getQuantity();
                                                                                 break;
                                                                             }
                                                                         }
                                                                     }
                                                                     if (inCartQty > 0) {
                                                                 %>
                                                                     <div style="display: flex; align-items: center; gap: 4px; background: #25C578; color: white; padding: 2px 8px; border-radius: var(--radius-sm); font-weight: 700; font-size: 0.75rem;">
                                                                         <form action="cart" method="POST" style="margin: 0; padding: 0; display: inline;">
                                                                             <input type="hidden" name="action" value="add">
                                                                             <input type="hidden" name="dishId" value="<%= dish.getId() %>">
                                                                             <input type="hidden" name="restaurantId" value="<%= r.getId() %>">
                                                                             <input type="hidden" name="quantity" value="-1">
                                                                             <input type="hidden" name="sourcePage" value="menu.jsp">
                                                                             <button type="submit" style="background: none; border: none; color: white; font-weight: 800; cursor: pointer; font-size: 0.85rem; padding: 0 4px;">-</button>
                                                                         </form>
                                                                         <span><%= inCartQty %></span>
                                                                         <form action="cart" method="POST" style="margin: 0; padding: 0; display: inline;">
                                                                             <input type="hidden" name="action" value="add">
                                                                             <input type="hidden" name="dishId" value="<%= dish.getId() %>">
                                                                             <input type="hidden" name="restaurantId" value="<%= r.getId() %>">
                                                                             <input type="hidden" name="quantity" value="1">
                                                                             <input type="hidden" name="sourcePage" value="menu.jsp">
                                                                             <button type="submit" style="background: none; border: none; color: white; font-weight: 800; cursor: pointer; font-size: 0.85rem; padding: 0 4px;">+</button>
                                                                         </form>
                                                                     </div>
                                                                 <% } else { %>
                                                                     <form action="cart" method="POST" style="margin:0; padding:0; display:block; width:100%;">
                                                                         <input type="hidden" name="action" value="add">
                                                                         <input type="hidden" name="dishId" value="<%= dish.getId() %>">
                                                                         <input type="hidden" name="restaurantId" value="<%= r.getId() %>">
                                                                         <input type="hidden" name="quantity" value="1">
                                                                         <input type="hidden" name="sourcePage" value="menu.jsp">
                                                                         <button type="submit" class="dish-add-btn add-btn" style="border:none; cursor:pointer; width:100%; position:static; transform:none; display:block; margin:0 auto;">ADD</button>
                                                                     </form>
                                                                 <% } %>
                                                             </div>
                                                            <span class="customisable-tag">customisable</span>
                                                        </div>
                                                        
                                                        <!-- menu-info: Teacher's exact CSS class; dish-details: styled premium CSS class -->
                                                        <div class="menu-info dish-details">
                                                            <%= dietIconHtml %>
                                                            <div class="dish-name-row">
                                                                <h2 class="dish-name"><%= dish.getName() %></h2>
                                                                <% if (dish.isBestseller()) { %>
                                                                <span class="bestseller-badge">&#11088; Bestseller</span>
                                                                <% } %>
                                                            </div>
                                                            
                                                            <p class="description dish-description">
                                                                <%= dish.getDescription() != null ? dish.getDescription() : "Prepared with fresh ingredients and signature spices." %>
                                                            </p>
                                                            
                                                            <div class="price-section dish-price">
                                                                <span class="price">₹<%= (int)dish.getPrice() %></span>
                                                            </div>
                                                        </div>
                                                    </div>
                                    <%
                                                }
                                            }
                                        }
                                        if (!hasDishes) {
                                    %>
                                        <p class="menu-empty-state">No items available in this category.</p>
                                    <%
                                        }
                                    %>
                                </div>
                            </section>
                <%
                        }
                    } else {
                %>
                    <div class="menu-empty-state" style="padding: 100px 0;">
                        <p>No categories or menu items available for this restaurant.</p>
                    </div>
                <%
                    }
                %>
            </main>
        </div>
    </div>

    <!-- Floating Browse Menu Link (Zero-JS) -->
    <a href="#categorySidebarModal" class="browse-menu-btn" style="text-decoration:none; display:inline-flex; align-items:center; justify-content:center;" aria-label="Browse Menu">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
            <line x1="4" y1="21" x2="4" y2="14"></line>
            <line x1="4" y1="10" x2="4" y2="3"></line>
            <line x1="12" y1="21" x2="12" y2="12"></line>
            <line x1="12" y1="8" x2="12" y2="3"></line>
            <line x1="20" y1="21" x2="20" y2="16"></line>
            <line x1="20" y1="12" x2="20" y2="3"></line>
            <line x1="2" y1="14" x2="6" y2="14"></line>
            <line x1="10" y1="8" x2="14" y2="8"></line>
            <line x1="18" y1="16" x2="22" y2="16"></line>
        </svg>
    </a>

    <!-- Sidebar Modal (Zero-JS) -->
    <div class="category-sidebar-modal" id="categorySidebarModal">
        <div class="sidebar-header">
            <h3 class="sidebar-title">Menu Categories</h3>
            <a href="#" class="sidebar-close-btn" style="text-decoration: none;">&times;</a>
        </div>
        <div class="sidebar-links-list" id="sidebarLinksList">
            <%
                if (categories != null) {
                    for (MenuCategory c : categories) {
                        String categoryId = c.getCategoryName().replaceAll("\\s+", "-").toLowerCase();
            %>
                        <a href="#<%= categoryId %>" class="sidebar-link"><%= c.getCategoryName() %></a>
            <%
                    }
                }
            %>
        </div>
    </div>
    <a href="#" class="sidebar-overlay" id="sidebarOverlay"></a>

    <!-- Footer -->
    <footer class="app-footer">
        <div class="footer-container">
            <div class="footer-brand-row">
                <a href="restaurants.jsp" class="footer-logo" style="text-decoration: none; display: flex; align-items: center; gap: 8px; color: inherit;">
                    <span class="logo-icon">🍽️</span>
                    <span class="logo-name">Khaalo</span>
                </a>
            </div>
            
            <div class="footer-links-grid">
                <div class="footer-column">
                    <h3>ABOUT KHAALO</h3>
                    <ul>
                        <li><a href="#who-we-are">Who We Are</a></li>
                        <li><a href="#blog">Blog</a></li>
                        <li><a href="#work-with-us">Work With Us</a></li>
                        <li><a href="#investor-relations">Investor Relations</a></li>
                        <li><a href="#report-fraud">Report Fraud</a></li>
                        <li><a href="#press-kit">Press Kit</a></li>
                        <li><a href="#contact-us">Contact Us</a></li>
                    </ul>
                </div>
                
                <div class="footer-column">
                    <h3>FOR RESTAURANTS</h3>
                    <ul>
                        <li><a href="#partner-with-us">Partner With Us</a></li>
                        <li><a href="#apps-for-you">Apps For You</a></li>
                    </ul>
                </div>
                
                <div class="footer-column">
                    <h3>LEARN MORE</h3>
                    <ul>
                        <li><a href="#privacy">Privacy</a></li>
                        <li><a href="#security">Security</a></li>
                        <li><a href="#terms">Terms</a></li>
                    </ul>
                </div>
                
                <div class="footer-column social-column">
                    <h3>SOCIAL LINKS</h3>
                    <div class="social-icons">
                        <a href="#linkedin" class="social-icon" aria-label="LinkedIn">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.779-1.75-1.75s.784-1.75 1.75-1.75 1.75.779 1.75 1.75-.784 1.75-1.75 1.75zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z"/>
                            </svg>
                        </a>
                        <a href="#instagram" class="social-icon" aria-label="Instagram">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="2" y="2" width="20" height="20" rx="5" ry="5"></rect>
                                <path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"></path>
                                <line x1="17.5" y1="6.5" x2="17.51" y2="6.5"></line>
                            </svg>
                        </a>
                        <a href="#twitter" class="social-icon" aria-label="Twitter">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
                            </svg>
                        </a>
                        <a href="#youtube" class="social-icon" aria-label="YouTube">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M23.498 6.163a3.003 3.003 0 0 0-2.11-2.108C19.524 3.545 12 3.545 12 3.545s-7.525 0-9.388.51a3.004 3.004 0 0 0-2.11 2.108C0 8.028 0 12 0 12s0 3.972.502 5.837a3.003 3.003 0 0 0 2.11 2.108C4.475 20.455 12 20.455 12 20.455s7.524 0 9.388-.51a3.003 3.003 0 0 0 2.11-2.108C24 15.972 24 12 24 12s0-3.972-.502-5.837zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/>
                            </svg>
                        </a>
                        <a href="#facebook" class="social-icon" aria-label="Facebook">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                            </svg>
                        </a>
                    </div>
                    
                    <div class="app-download-badges">
                        <a href="#appstore" class="download-badge" aria-label="Download on the App Store">
                            <div class="badge-content">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                                    <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 4.17c.66-.81 1.11-1.93.99-3.06-1 .04-2.21.67-2.93 1.49-.62.69-1.16 1.84-1.01 2.96 1.12.09 2.27-.58 2.95-1.39z"/>
                                </svg>
                                <div class="badge-text">
                                    <span class="download-subText">Download on the</span>
                                    <span class="download-mainText">App Store</span>
                                </div>
                            </div>
                        </a>
                        <a href="#googleplay" class="download-badge" aria-label="Get it on Google Play">
                            <div class="badge-content">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                                    <path d="M5.25 3.5c-.22 0-.44.06-.62.19l10.22 10.22 2.69-2.69L5.88 3.69c-.19-.13-.41-.19-.63-.19M4 4.84v14.32c0 .34.16.63.44.81l7.81-7.81L4.44 4.03c-.28.19-.44.47-.44.81m12.44 7.16l2.94 2.94c.31-.19.5-.53.5-.94 0-.41-.19-.75-.5-.94l-2.94-1.06m-4.22.94l-7.81 7.81c.19.13.41.19.62.19.22 0 .44-.06.63-.19l11.66-7.56-5.1-2.94"/>
                                </svg>
                                <div class="badge-text">
                                    <span class="download-subText">GET IT ON</span>
                                    <span class="download-mainText">Google Play</span>
                                </div>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
            
            <div class="footer-bottom">
                <p class="copyright">By continuing past this page, you agree to our Terms of Service, Cookie Policy, Privacy Policy and Content Policies. All trademarks are properties of their respective owners. 2026 © Khaalo™ Ltd. All rights reserved.</p>
            </div>
        </div>
    </footer>


    <!-- Cart Conflict Modal Overlay (Always available in DOM) -->
    <%
        String cartConflict = request.getParameter("cartConflict");
        String newDishIdStr = request.getParameter("newDishId");
        String newRestaurantIdStr = request.getParameter("newRestaurantId");
        boolean showModalServer = "true".equalsIgnoreCase(cartConflict) && newDishIdStr != null;
        Dish initialNewDish = null;
        if (showModalServer) {
            try {
                initialNewDish = new com.khaalo.daoimpl.MenuDAOImpl().getDishById(Integer.parseInt(newDishIdStr));
            } catch(Exception ignored){}
        }
        Cart sessionCartObj = (Cart) session.getAttribute("cart");
    %>
    <div class="modal-overlay <%= showModalServer ? "active" : "" %>" id="cartConflictModalOverlay" style="position: fixed; inset: 0; background: rgba(0,0,0,0.65); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); display: <%= showModalServer ? "flex" : "none" %>; align-items: center; justify-content: center; z-index: 999999; padding: 16px; opacity: 1; visibility: visible;">
        <div class="modal-container" style="max-width: 440px; width: 100%; background: #ffffff; border-radius: 20px; padding: 24px 28px; text-align: center; font-family: Outfit, Poppins, sans-serif; box-shadow: 0 20px 40px rgba(0,0,0,0.3); transform: none;">
            <div style="font-size: 2.5rem; margin-bottom: 8px;">🥣</div>
            <h3 style="font-size: 1.2rem; font-weight: 800; color: #1e293b; margin-bottom: 8px;">Replace Cart Items?</h3>
            <p style="font-size: 0.85rem; color: #64748b; line-height: 1.5; margin-bottom: 16px;">
                Your cart contains items from another restaurant. Do you want to discard your previous order and start a new cart?
            </p>
            
            <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 12px 16px; text-align: left; margin-bottom: 20px;">
                <div style="font-size: 0.75rem; font-weight: 700; color: #94a3b8; text-transform: uppercase; margin-bottom: 4px;">Your current cart contains items from another restaurant.</div>
                <div style="font-size: 0.75rem; font-weight: 700; color: #94a3b8; text-transform: uppercase; margin-top: 8px; margin-bottom: 4px;">You are replacing it with:</div>
                <div id="conflictNewDishName" style="font-size: 0.85rem; font-weight: 700; color: #ff6b35;">
                    <%= initialNewDish != null ? initialNewDish.getName() : "Selected Dish" %>
                </div>
            </div>
            
            <div style="display: flex; gap: 10px; justify-content: center;">
                <button type="button" onclick="document.getElementById('cartConflictModalOverlay').style.display='none'; document.getElementById('cartConflictModalOverlay').classList.remove('active'); history.replaceState(null,null,window.location.pathname+window.location.search); return false;" style="text-decoration: none; padding: 10px 20px; border-radius: 10px; font-weight: 700; border: 1px solid #cbd5e1; color: #475569; background: #f1f5f9; cursor: pointer; font-size: 0.85rem; display: inline-block; transition: all 0.2s;">
                    Keep Existing
                </button>
                <form action="CartServlet" method="POST" id="conflictConfirmForm" style="margin: 0; padding: 0; display: inline-block;">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="dishId" id="confirmReplaceDishId" value="<%= initialNewDish != null ? initialNewDish.getId() : "" %>">
                    <input type="hidden" name="restaurantId" id="confirmReplaceRestaurantId" value="<%= newRestaurantIdStr != null ? newRestaurantIdStr : "" %>">
                    <input type="hidden" name="confirmReplace" value="true">
                    <input type="hidden" name="quantity" value="1">
                    <input type="hidden" name="sourcePage" id="confirmReplaceSourcePage" value="menu.jsp">
                    <button type="submit" style="padding: 10px 20px; border-radius: 10px; font-weight: 700; border: none; color: white; background: #ff6b35; cursor: pointer; font-size: 0.85rem; box-shadow: 0 4px 12px rgba(255,107,53,0.3); transition: all 0.2s;">
                        Replace & Add
                    </button>
                </form>
            </div>
        </div>
    </div>
</body>



