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
<%@ page import="com.khaalo.dao.RestaurantDAO" %>
<%@ page import="com.khaalo.daoimpl.RestaurantDAOImpl" %>
<%@ page import="com.khaalo.model.Restaurant" %>
<%@ page import="com.khaalo.model.User" %>
<%@ page import="com.khaalo.daoimpl.FavoriteDAOImpl" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="com.khaalo.model.Dish" %>
<%@ page import="com.khaalo.model.Cart" %>
<%@ page import="com.khaalo.model.CartItem" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%
    User user = (User) session.getAttribute("user");
    Set<String> favoritedIds = new HashSet<>();
    if (user != null) {
        favoritedIds = new FavoriteDAOImpl().getFavoriteRestaurantIds(user.getId());
    }

    // 1. Fetch all dishes from database (to be filtered in the JSP body loops)
    String dietFilter = request.getParameter("diet");
    if (dietFilter == null) dietFilter = "all";

    List<Dish> homepageDishes = new ArrayList<>();
    try (Connection conn = com.util.connection.DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement("SELECT * FROM `dishes` ORDER BY `rating` DESC");
         ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            Dish dish = new Dish();
            dish.setId(rs.getInt("id"));
            dish.setCategoryId(rs.getInt("category_id"));
            dish.setName(rs.getString("name"));
            dish.setPrice(rs.getDouble("price"));
            dish.setVeg(rs.getBoolean("is_veg"));
            dish.setBestseller(rs.getBoolean("is_bestseller"));
            dish.setChefPick(false);
            dish.setRatingCount(120);
            dish.setRating(rs.getDouble("rating"));
            dish.setImageUrl(rs.getString("image_url"));
            dish.setDescription(rs.getString("description"));
            homepageDishes.add(dish);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    // 2. Build target category IDs based on current cart items and past user orders
    Set<Integer> homepageTargetCategoryIds = new HashSet<>();
    Cart homepageCart = (Cart) session.getAttribute("cart");
    List<CartItem> homepageCartItems = (homepageCart != null) ? homepageCart.getItems() : new ArrayList<>();
    for (CartItem item : homepageCartItems) {
        try (Connection conn = com.util.connection.DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT `category_id` FROM `dishes` WHERE `id` = ?")) {
            ps.setInt(1, item.getDishId());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    homepageTargetCategoryIds.add(rs.getInt("category_id"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    if (user != null) {
        // Query categories of items previously ordered by the user
        String pastCategoriesQuery = "SELECT DISTINCT d.`category_id` FROM `order_items` oi " +
                                     "JOIN `orders` o ON oi.`order_id` = o.`id` " +
                                     "JOIN `dishes` d ON oi.`dish_id` = d.`id` " +
                                     "WHERE o.`user_id` = ?";
        try (Connection conn = com.util.connection.DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(pastCategoriesQuery)) {
            ps.setInt(1, user.getId());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    homepageTargetCategoryIds.add(rs.getInt("category_id"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Fallback if no category found (e.g. guest or new user with empty cart)
    if (homepageTargetCategoryIds.isEmpty()) {
        try (Connection conn = com.util.connection.DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT DISTINCT `category_id` FROM `dishes` LIMIT 4");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                homepageTargetCategoryIds.add(rs.getInt("category_id"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khaalo - Har Bhook Ka Solution | Food Delivery App</title>
    <meta name="description" content="Khaalo - Har Bhook Ka Solution. Order food from the best restaurants near you. Fast delivery, exclusive discounts, and a wide variety of cuisines.">
    <meta name="keywords" content="food delivery, khaalo, order food online, restaurant delivery, fast food delivery">
    <meta name="theme-color" content="#1a1a2e">

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <!-- Khaalo Micro-Animations & JS Engines -->
    <link rel="stylesheet" href="css/animations.css">
    <%
        String currentCartResId = (String) session.getAttribute("restaurantId");
        Cart sessionCartObjForRes = (Cart) session.getAttribute("cart");
        if ((currentCartResId == null || currentCartResId.trim().isEmpty()) && sessionCartObjForRes != null && sessionCartObjForRes.getItems() != null && !sessionCartObjForRes.getItems().isEmpty()) {
            try {
                int firstDishId = sessionCartObjForRes.getItems().get(0).getDishId();
                Dish firstDish = new com.khaalo.daoimpl.MenuDAOImpl().getDishById(firstDishId);
                if (firstDish != null) {
                    try (java.sql.Connection conn = com.util.connection.DBConnection.getConnection();
                         java.sql.PreparedStatement ps = conn.prepareStatement("SELECT `restaurant_id` FROM `menu_categories` WHERE `id` = ?")) {
                        ps.setInt(1, firstDish.getCategoryId());
                        try (java.sql.ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                currentCartResId = rs.getString("restaurant_id");
                                session.setAttribute("restaurantId", currentCartResId);
                            }
                        }
                    }
                }
            } catch (Exception ignored) {}
        }
        if (currentCartResId == null) currentCartResId = "";
        int globalCartCount = (sessionCartObjForRes != null && sessionCartObjForRes.getItems() != null) ? sessionCartObjForRes.getItems().size() : 0;
    %>
    <script>
        window.currentCartRestaurantId = "<%= currentCartResId %>";
        window.currentCartSize = <%= globalCartCount %>;
        window.cartItems = [
            <%
                if (sessionCartObjForRes != null && sessionCartObjForRes.getItems() != null) {
                    for (int i = 0; i < sessionCartObjForRes.getItems().size(); i++) {
                        CartItem ci = sessionCartObjForRes.getItems().get(i);
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

    <!-- Stylesheet -->
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

/* === Splash Screen === */
.splash-loader {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: var(--bg-primary);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: var(--z-splash);
    animation: fadeOutSplash 0.6s cubic-bezier(0.25, 1, 0.5, 1) forwards;
    animation-delay: 1.2s;
    pointer-events: none;
}

@keyframes fadeOutSplash {
    to {
        opacity: 0;
        visibility: hidden;
    }
}

.splash-loader.hidden {
    opacity: 0;
    visibility: hidden;
    pointer-events: none;
}

.splash-content {
    text-align: center;
    position: relative;
}

.splash-phase {
    display: none;
    flex-direction: column;
    align-items: center;
    animation: splashFadeIn 0.5s ease forwards;
}

.splash-phase.active {
    display: flex;
}

.splash-logo {
    margin-bottom: var(--space-xl);
}

.splash-icon {
    font-size: 4rem;
    display: block;
    margin-bottom: var(--space-md);
    animation: splashBounce 1.2s ease-in-out infinite;
}

.splash-title {
    font-family: 'Outfit', sans-serif;
    font-size: 3.5rem;
    font-weight: 900;
    background: linear-gradient(135deg, var(--primary), var(--accent));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    letter-spacing: -1px;
}

.splash-tagline {
    font-family: 'Poppins', sans-serif;
    font-size: 1.1rem;
    color: var(--text-secondary);
    font-weight: 400;
    margin-top: var(--space-xs);
    letter-spacing: 2px;
    text-transform: uppercase;
}

.splash-spinner {
    display: flex;
    justify-content: center;
}

.spinner-ring {
    width: 40px;
    height: 40px;
    border: 3px solid var(--border-subtle);
    border-top-color: var(--primary);
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
}

/* Splash Location Phase */
.splash-location-pin {
    position: relative;
    width: 80px;
    height: 80px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: var(--space-lg);
}

.splash-location-pin svg {
    filter: drop-shadow(0 4px 12px rgba(255, 107, 53, 0.35));
    animation: splashPinBob 1s ease-in-out infinite;
}

@keyframes splashPinBob {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-8px); }
}

.splash-loc-pulse {
    position: absolute;
    width: 60px;
    height: 60px;
    border-radius: 50%;
    border: 2px solid var(--primary);
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%) scale(0.5);
    animation: splashLocPulse 1.5s infinite ease-out;
    pointer-events: none;
}

@keyframes splashLocPulse {
    0% { transform: translate(-50%, -50%) scale(0.5); opacity: 0.7; }
    100% { transform: translate(-50%, -50%) scale(2.2); opacity: 0; }
}

.splash-loc-status {
    font-family: 'Outfit', sans-serif;
    font-size: 1.1rem;
    font-weight: 600;
    color: var(--text-secondary);
    margin-bottom: var(--space-sm);
}

.splash-loc-address {
    font-family: 'Poppins', sans-serif;
    font-size: 0.9rem;
    font-weight: 500;
    color: var(--text-primary);
    max-width: 320px;
    line-height: 1.4;
    opacity: 0;
    transition: opacity 0.4s ease;
}

.splash-loc-address.visible {
    opacity: 1;
}

@keyframes splashFadeIn {
    from {
        opacity: 0;
        transform: translateY(20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@keyframes splashBounce {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-12px); }
}

@keyframes spin {
    to { transform: rotate(360deg); }
}

/* === App Container === */
.app-container {
    width: 100%;
    max-width: var(--max-width);
    margin: 0 auto;
    min-height: 100vh;
    opacity: 1;
    transition: opacity 0.5s ease;
}

.app-container.visible {
    opacity: 1;
}

/* === Top Bar / Header === */
.top-bar {
    position: sticky;
    top: 0;
    z-index: var(--z-sticky);
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: var(--space-md) var(--space-lg);
    background: var(--bg-glass);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border-bottom: 1px solid var(--border-subtle);
    transition: all var(--transition-base);
    height: var(--header-height);
}

.top-bar.scrolled {
    background: var(--bg-glass);
    box-shadow: var(--shadow-md);
}

.menu-btn {
    width: 44px;
    height: 44px;
    border-radius: var(--radius-md);
    display: flex;
    align-items: center;
    justify-content: center;
    background: var(--bg-glass-light);
    color: var(--text-primary);
    transition: all var(--transition-base);
}

.menu-btn:hover {
    background: var(--bg-surface);
    transform: scale(1.05);
}

.menu-btn:active {
    transform: scale(0.95);
}

.delivery-info {
    text-align: left;
    flex: 1;
    padding-right: var(--space-md);
}

.delivery-label {
    font-size: 0.7rem;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 1.5px;
    font-weight: 500;
}

.delivery-address {
    display: flex;
    align-items: center;
    justify-content: flex-start;
    gap: var(--space-xs);
    margin-top: 2px;
}

.delivery-address span {
    font-size: 0.85rem;
    font-weight: 600;
    color: var(--text-primary);
}

.notification-btn {
    width: 44px;
    height: 44px;
    border-radius: var(--radius-md);
    display: flex;
    align-items: center;
    justify-content: center;
    background: var(--bg-glass-light);
    color: var(--text-primary);
    position: relative;
    transition: all var(--transition-base);
}

.notification-btn:hover {
    background: var(--bg-surface);
    transform: scale(1.05);
}

.notification-btn:active {
    transform: scale(0.95);
}

.profile-btn {
    width: 44px;
    height: 44px;
    border-radius: var(--radius-md);
    display: flex;
    align-items: center;
    justify-content: center;
    background: var(--bg-glass-light);
    color: var(--text-primary);
    transition: all var(--transition-base);
}

.profile-btn:hover {
    background: var(--bg-surface);
    transform: scale(1.05);
}

.profile-btn:active {
    transform: scale(0.95);
}

.notif-dot {
    position: absolute;
    top: 10px;
    right: 10px;
    width: 8px;
    height: 8px;
    background: var(--primary);
    border-radius: 50%;
    border: 2px solid var(--bg-primary);
    animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
    0%, 100% { opacity: 1; transform: scale(1); }
    50% { opacity: 0.7; transform: scale(1.2); }
}

/* === Hero Section === */
.hero-section {
    position: relative;
    width: auto;
    margin-bottom: var(--space-lg);
    overflow: hidden;
    border-radius: 0 0 var(--radius-xl) var(--radius-xl);
    background: #000;
}

.hero-video-container {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    overflow: hidden;
    z-index: 0;
}

.hero-video-container video {
    width: 100%;
    height: 100%;
    display: block;
    object-fit: cover;
}

.hero-overlay {
    position: relative;
    width: 100%;
    background: linear-gradient(
        135deg,
        rgba(0, 0, 0, 0.45) 0%,
        rgba(0, 0, 0, 0.65) 50%,
        rgba(0, 0, 0, 0.85) 100%
    );
    z-index: 1;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: var(--space-2xl);
    gap: var(--space-2xl);
    min-height: 480px;
}

/* Left Brand Column */
.hero-left-brand {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: var(--space-md);
    max-width: 45%;
    animation: slideInLeft 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}

.brand-logo-glow {
    font-size: 3rem;
    animation: floatGlow 3s ease-in-out infinite;
    filter: drop-shadow(0 0 10px var(--primary-glow));
}

@keyframes floatGlow {
    0%, 100% { transform: translateY(0); filter: drop-shadow(0 0 10px rgba(255, 107, 53, 0.4)); }
    50% { transform: translateY(-6px); filter: drop-shadow(0 0 20px rgba(255, 107, 53, 0.7)); }
}

.brand-sub {
    font-size: 0.8rem;
    font-weight: 800;
    color: var(--primary-light);
    letter-spacing: 3px;
    text-transform: uppercase;
}

.brand-title {
    font-family: 'Outfit', sans-serif;
    font-size: 3rem;
    font-weight: 900;
    line-height: 1.15;
    color: #fff;
    margin: 0;
}

/* Right Side Card (Inspired by reference image layout) */
.hero-right-card {
    background: rgba(28, 20, 15, 0.55);
    border: 1px solid rgba(255, 255, 255, 0.12);
    border-radius: var(--radius-xl);
    max-width: 680px;
    width: 60%;
    display: flex;
    overflow: hidden;
    box-shadow: 0 30px 60px rgba(0, 0, 0, 0.5),
                inset 0 1px 0 rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(24px) saturate(180%);
    -webkit-backdrop-filter: blur(24px) saturate(180%);
    animation: fadeInUp 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.2s both;
    flex-shrink: 0;
}

.hero-card-content {
    flex: 1.2;
    padding: var(--space-xl);
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    justify-content: center;
    color: #fff;
    text-align: left;
}

.promo-pill-light {
    display: inline-flex;
    align-items: center;
    background: rgba(255, 107, 53, 0.15);
    border: 1px solid rgba(255, 107, 53, 0.3);
    padding: 6px 12px;
    border-radius: var(--radius-full);
    font-size: 0.7rem;
    font-weight: 700;
    color: #ff9d73;
    margin-bottom: var(--space-md);
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.hero-card-slogan {
    font-family: 'Outfit', sans-serif;
    font-size: 2.4rem;
    font-weight: 900;
    line-height: 1.1;
    margin: 0 0 var(--space-sm) 0;
    color: #fff;
}

.slogan-highlight {
    background: linear-gradient(135deg, #ffb088, var(--primary));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

.hero-card-desc {
    font-size: 0.9rem;
    color: rgba(255, 255, 255, 0.8);
    line-height: 1.4;
    margin: 0 0 var(--space-md) 0;
}

.hero-card-promo-badge {
    display: flex;
    align-items: center;
    gap: var(--space-sm);
    margin-bottom: var(--space-lg);
    background: rgba(255, 255, 255, 0.05);
    padding: 8px 16px;
    border-radius: var(--radius-md);
    border: 1px solid rgba(255, 255, 255, 0.08);
}

.promo-percent-bold {
    font-family: 'Outfit', sans-serif;
    font-weight: 900;
    font-size: 1.2rem;
    color: var(--primary-light);
}

.promo-code-pill {
    font-size: 0.75rem;
    font-weight: 700;
    color: #fff;
    background: var(--primary);
    padding: 2px 8px;
    border-radius: 4px;
    letter-spacing: 0.5px;
}

.promo-cta-new {
    display: inline-flex;
    align-items: center;
    gap: var(--space-sm);
    background: linear-gradient(135deg, var(--primary), var(--primary-dark));
    color: white;
    padding: 12px 28px;
    border-radius: var(--radius-full);
    font-weight: 700;
    font-size: 0.95rem;
    cursor: pointer;
    transition: all var(--transition-base);
    box-shadow: 0 4px 15px rgba(255, 107, 53, 0.3);
    border: none;
}

.promo-cta-new:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(255, 107, 53, 0.45);
}

.hero-card-image-wrap {
    flex: 1;
    overflow: hidden;
    position: relative;
}

.hero-card-img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform var(--transition-slow);
}

.hero-right-card:hover .hero-card-img {
    transform: scale(1.05);
}


/* Floating food emojis */
.floating-food {
    position: absolute;
    z-index: 2;
    font-size: 2rem;
    opacity: 0.4;
    animation: floatAround 8s ease-in-out infinite;
    pointer-events: none;
}

.food-1 {
    top: 15%;
    right: 10%;
    animation-delay: 0s;
}

.food-2 {
    top: 60%;
    right: 5%;
    animation-delay: 2s;
    font-size: 1.5rem;
}

.food-3 {
    bottom: 20%;
    right: 20%;
    animation-delay: 4s;
    font-size: 1.8rem;
}

.food-4 {
    top: 30%;
    right: 25%;
    animation-delay: 6s;
    font-size: 1.3rem;
}

@keyframes floatAround {
    0%, 100% {
        transform: translateY(0) rotate(0deg);
    }
    25% {
        transform: translateY(-15px) rotate(10deg);
    }
    50% {
        transform: translateY(-5px) rotate(-5deg);
    }
    75% {
        transform: translateY(-20px) rotate(5deg);
    }
}

@keyframes slideInLeft {
    from {
        opacity: 0;
        transform: translateX(-30px);
    }
    to {
        opacity: 1;
        transform: translateX(0);
    }
}

/* === Search Section === */
.search-section {
    padding: 0 var(--space-lg);
    margin-bottom: var(--space-lg);
    margin-top: calc(-1 * var(--space-md));
    position: relative;
    z-index: 3;
}

.search-wrapper {
    display: flex;
    gap: var(--space-sm);
    align-items: center;
}

.search-bar {
    flex: 1;
    display: flex;
    align-items: center;
    gap: var(--space-sm);
    background: var(--bg-card);
    border: 1px solid var(--border-subtle);
    border-radius: var(--radius-xl);
    padding: var(--space-md) var(--space-lg);
    transition: all var(--transition-base);
    box-shadow: var(--shadow-sm);
}

.search-bar:focus-within {
    border-color: var(--border-active);
    box-shadow: 0 0 0 3px var(--primary-glow), var(--shadow-md);
    background: var(--bg-card-hover);
}

.search-icon {
    color: var(--text-muted);
    flex-shrink: 0;
}

.search-bar input,
#searchInput {
    flex: 1;
    font-size: 0.9rem;
    color: var(--text-primary);
    border: none !important;
    outline: none !important;
    box-shadow: none !important;
    background: transparent !important;
}

.search-bar input:focus,
.search-bar input:focus-visible,
.search-bar input:active,
#searchInput:focus,
#searchInput:focus-visible,
#searchInput:active {
    border: none !important;
    outline: none !important;
    box-shadow: none !important;
    background: transparent !important;
}

.search-bar input::placeholder {
    color: var(--text-muted);
    font-weight: 400;
}

.filter-btn {
    width: 52px;
    height: 52px;
    border-radius: var(--radius-lg);
    background: linear-gradient(135deg, var(--primary), var(--primary-dark));
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: var(--shadow-glow);
    transition: all var(--transition-spring);
    flex-shrink: 0;
}

.filter-btn:hover {
    transform: scale(1.08);
    box-shadow: 0 4px 25px var(--primary-glow);
}

.filter-btn:active {
    transform: scale(0.95);
}

/* === Section Headers === */
.section-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 var(--space-lg);
    margin-bottom: var(--space-md);
}

.section-header h2 {
    font-family: 'Outfit', sans-serif;
    font-size: 1.3rem;
    font-weight: 700;
    color: var(--text-primary);
}

.see-all-btn {
    display: flex;
    align-items: center;
    gap: 4px;
    color: var(--primary);
    font-size: 0.85rem;
    font-weight: 600;
    transition: all var(--transition-base);
}

.see-all-btn:hover {
    color: var(--primary-light);
    gap: 8px;
}

.arrow-btn {
    width: 36px;
    height: 36px;
    border-radius: var(--radius-md);
    background: var(--bg-glass-light);
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--primary);
    transition: all var(--transition-base);
}

.arrow-btn:hover {
    background: var(--primary);
    color: white;
    transform: scale(1.1);
}

/* Mobile See All Button & Desktop Hiding */
.mobile-see-all-container {
    display: none;
    justify-content: center;
    margin: var(--space-md) 0 var(--space-xl);
}

.mobile-see-all-btn {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: var(--bg-card);
    border: 2px solid var(--primary);
    color: var(--primary);
    padding: 10px 24px;
    border-radius: var(--radius-full);
    font-weight: 700;
    font-size: 0.9rem;
    font-family: inherit;
    cursor: pointer;
    transition: all var(--transition-base);
    box-shadow: var(--shadow-sm);
}

.mobile-see-all-btn:hover {
    background: var(--primary);
    color: white;
    box-shadow: 0 4px 15px rgba(255, 107, 53, 0.2);
    transform: translateY(-1px);
}

.mobile-see-all-btn svg {
    transition: transform var(--transition-base);
}

.mobile-see-all-btn:hover svg {
    transform: translateY(2px);
}


/* Show mobile see-all button container for mobile/tablet */
@media screen and (max-width: 768px) {
    .mobile-see-all-container {
        display: flex;
    }
}

/* === Categories Section === */
.categories-section {
    margin-bottom: var(--space-xl);
}

.categories-scroll {
    display: flex;
    gap: var(--space-lg);
    padding: var(--space-sm) var(--space-lg);
    overflow-x: auto;
    scroll-snap-type: x mandatory;
    -webkit-overflow-scrolling: touch;
    scrollbar-width: none;
}

.categories-scroll::-webkit-scrollbar {
    display: none;
}

.category-card {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: var(--space-sm);
    min-width: 100px;
    scroll-snap-align: start;
    cursor: pointer;
    transition: all var(--transition-spring);
}

.category-card:hover {
    transform: translateY(-4px);
}

.category-card:active {
    transform: scale(0.95);
}

.category-card.active .category-img-wrap {
    border-color: var(--primary);
    box-shadow: 0 0 0 3px var(--primary-glow);
}

.category-card.active .category-name {
    color: var(--primary);
    font-weight: 700;
}

.category-img-wrap {
    width: 90px;
    height: 90px;
    border-radius: 50%;
    overflow: hidden;
    border: 2px solid var(--border-subtle);
    padding: 4px;
    background: var(--bg-card);
    transition: all var(--transition-base);
    display: flex;
    align-items: center;
    justify-content: center;
}

.category-img-wrap img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    border-radius: 50%;
}

.category-img-wrap.biryani-emoji span,
.category-img-wrap.chinese-emoji span,
.category-img-wrap.thali-emoji span,
.category-img-wrap.category-emoji span {
    font-size: 2rem;
}

.category-name {
    font-size: 0.85rem;
    font-weight: 500;
    color: var(--text-secondary);
    text-align: center;
    white-space: nowrap;
    transition: all var(--transition-base);
}

/* === Popular Restaurants Section === */
.popular-section {
    margin-bottom: var(--space-xl);
}

.restaurants-grid {
    display: grid;
    grid-template-columns: 1fr;
    gap: var(--space-md);
    padding: 0 var(--space-lg);
}
.restaurants-grid .top-restaurant-card {
    min-width: 0;
}

.restaurant-card {
    background: var(--bg-card);
    border-radius: var(--radius-lg);
    overflow: hidden;
    border: 1px solid var(--border-subtle);
    transition: all var(--transition-base);
    cursor: pointer;
    animation: fadeInUp 0.5s ease both;
    text-decoration: none;
    color: inherit;
    display: block;
}

.restaurant-card:nth-child(1) { animation-delay: 0.1s; }
.restaurant-card:nth-child(2) { animation-delay: 0.2s; }
.restaurant-card:nth-child(3) { animation-delay: 0.3s; }
.restaurant-card:nth-child(4) { animation-delay: 0.4s; }

.restaurant-card:hover {
    transform: translateY(-4px);
    box-shadow: var(--shadow-lg);
    border-color: var(--border-active);
}

.restaurant-card:active {
    transform: scale(0.98);
}

.restaurant-img-wrap {
    position: relative;
    width: 100%;
    height: 180px;
    overflow: hidden;
}

.restaurant-img-wrap img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.5s ease;
}

.restaurant-card:hover .restaurant-img-wrap img {
    transform: scale(1.05);
}

.restaurant-badge {
    position: absolute;
    top: var(--space-sm);
    left: var(--space-sm);
}

.badge-discount {
    display: inline-flex;
    align-items: center;
    gap: var(--space-xs);
    background: linear-gradient(135deg, rgba(255, 107, 53, 0.95), rgba(232, 93, 44, 0.95));
    color: white;
    padding: 6px 12px;
    border-radius: var(--radius-sm);
    font-size: 0.72rem;
    font-weight: 700;
    backdrop-filter: blur(4px);
    letter-spacing: 0.3px;
}

.fav-btn {
    position: absolute;
    top: var(--space-sm);
    right: var(--space-sm);
    width: 36px;
    height: 36px;
    border-radius: 50%;
    background: rgba(26, 16, 8, 0.6);
    backdrop-filter: blur(8px);
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    transition: all var(--transition-spring);
}

.fav-btn:hover {
    background: var(--primary);
    transform: scale(1.15);
}

.fav-btn.liked {
    background: var(--primary);
}

.fav-btn.liked svg {
    fill: white;
    animation: heartBeat 0.4s ease;
}

@keyframes heartBeat {
    0% { transform: scale(1); }
    30% { transform: scale(1.3); }
    60% { transform: scale(0.9); }
    100% { transform: scale(1); }
}

.restaurant-info {
    padding: var(--space-md);
}

.restaurant-name-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: var(--space-xs);
}

.restaurant-name-row h3 {
    font-family: 'Outfit', sans-serif;
    font-size: 1.05rem;
    font-weight: 700;
    color: var(--text-primary);
}

.restaurant-rating {
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 0.85rem;
    font-weight: 600;
    color: var(--text-primary);
}

.rating-count {
    color: var(--text-muted);
    font-weight: 400;
    font-size: 0.75rem;
}

.restaurant-meta {
    font-size: 0.8rem;
    color: var(--text-secondary);
    margin-bottom: var(--space-sm);
}

.restaurant-tags {
    display: flex;
    gap: var(--space-sm);
    flex-wrap: wrap;
}

.tag {
    font-size: 0.72rem;
    color: var(--text-secondary);
    background: var(--bg-glass-light);
    padding: 4px 10px;
    border-radius: var(--radius-full);
    font-weight: 500;
    border: 1px solid var(--border-subtle);
}

/* === Trending Section === */
.trending-section {
    margin-bottom: var(--space-xl);
}

.trending-scroll {
    display: flex;
    gap: var(--space-md);
    padding: var(--space-sm) var(--space-lg);
    overflow-x: auto;
    scroll-snap-type: x mandatory;
    -webkit-overflow-scrolling: touch;
    scrollbar-width: none;
}

.trending-scroll::-webkit-scrollbar {
    display: none;
}

.trending-card,
.recommended-card {
    min-width: 220px;
    border-radius: var(--radius-lg);
    overflow: hidden;
    background: var(--bg-card);
    border: 1px solid var(--border-subtle);
    scroll-snap-align: start;
    cursor: pointer;
    transition: all var(--transition-base);
}

.trending-card:hover,
.recommended-card:hover {
    transform: translateY(-4px);
    box-shadow: var(--shadow-md);
    border-color: var(--border-active);
}

.trending-img,
.recommended-img {
    position: relative;
    width: 100%;
    height: 140px;
    overflow: hidden;
}

.trending-img img,
.recommended-img img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.5s ease;
}

.trending-card:hover .trending-img img,
.recommended-card:hover .recommended-img img {
    transform: scale(1.1);
}

.trending-info,
.recommended-info {
    padding: var(--space-sm) var(--space-md);
}

.trending-info h4,
.recommended-info h4 {
    font-size: 0.95rem;
    font-weight: 700;
    color: var(--text-primary);
    margin-bottom: var(--space-xs);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.trending-price-row,
.recommended-price-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: var(--space-xs);
}

.trending-price-row .price,
.recommended-price-row .price {
    font-size: 1rem;
    font-weight: 800;
    color: var(--primary);
}

.original-price {
    color: var(--text-muted);
    text-decoration: line-through;
    font-weight: 400;
    font-size: 0.75rem;
    margin-left: 4px;
}

/* === Recommended Section === */
.recommended-section {
    margin-bottom: var(--space-xl);
}

.recommended-scroll {
    display: flex;
    gap: var(--space-md);
    padding: var(--space-sm) var(--space-lg);
    overflow-x: auto;
    scroll-snap-type: x mandatory;
    -webkit-overflow-scrolling: touch;
    scrollbar-width: none;
}

.recommended-scroll::-webkit-scrollbar {
    display: none;
}

.recommended-card .rating-badge {
    position: absolute;
    top: var(--space-sm);
    left: var(--space-sm);
    background: rgba(255, 255, 255, 0.95);
    color: #2C1B10;
    padding: 3px 8px;
    border-radius: var(--radius-sm);
    font-size: 0.75rem;
    font-weight: 700;
    box-shadow: var(--shadow-sm);
}

.recommended-price-row .add-to-cart-btn {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background: var(--primary);
    color: white;
    font-size: 1.2rem;
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all var(--transition-fast);
}

.recommended-price-row .add-to-cart-btn:hover {
    background: var(--primary-dark);
    transform: scale(1.1);
}

/* === Top Restaurants Section === */
.top-restaurants-section {
    margin-bottom: var(--space-xl);
}

.top-restaurants-scroll {
    display: flex;
    gap: var(--space-md);
    padding: var(--space-sm) var(--space-lg);
    overflow-x: auto;
    scroll-snap-type: x mandatory;
    -webkit-overflow-scrolling: touch;
    scrollbar-width: none;
}

.top-restaurants-scroll::-webkit-scrollbar {
    display: none;
}

.top-restaurant-card {
    min-width: 280px;
    border-radius: var(--radius-lg);
    overflow: hidden;
    background: var(--bg-card);
    border: 1px solid var(--border-subtle);
    scroll-snap-align: start;
    cursor: pointer;
    transition: all var(--transition-base);
    text-decoration: none;
    color: inherit;
    display: block;
    scroll-margin-top: 100px;
}

.top-restaurant-card:hover {
    transform: translateY(-4px);
    box-shadow: var(--shadow-md);
    border-color: var(--border-active);
}

.top-restaurant-img {
    position: relative;
    width: 100%;
    height: 160px;
    overflow: hidden;
}

.top-restaurant-img img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.5s ease;
}

.top-restaurant-card:hover .top-restaurant-img img {
    transform: scale(1.1);
}

.top-restaurant-card .promo-badge {
    position: absolute;
    top: var(--space-sm);
    left: var(--space-sm);
    background: var(--primary);
    color: white;
    padding: 4px 10px;
    border-radius: var(--radius-sm);
    font-size: 0.75rem;
    font-weight: 700;
    box-shadow: var(--shadow-sm);
}

.top-restaurant-info {
    padding: var(--space-md);
}

.top-restaurant-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2px;
}

.top-restaurant-header h3 {
    font-size: 1.05rem;
    font-weight: 800;
    color: var(--text-primary);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.top-restaurant-header .rating {
    font-size: 0.9rem;
    font-weight: 700;
    color: #FFA000;
    background: rgba(255, 160, 0, 0.1);
    padding: 2px 6px;
    border-radius: var(--radius-sm);
}

.top-restaurant-info .cuisine {
    font-size: 0.85rem;
    color: var(--text-secondary);
    margin-bottom: var(--space-sm);
}

.top-restaurant-info .meta-row {
    display: flex;
    gap: var(--space-md);
    font-size: 0.8rem;
    color: var(--text-muted);
}

/* === FAQ Section === */
.faq-section {
    max-width: 800px;
    margin: var(--space-2xl) auto;
    padding: 0 var(--space-lg);
}

.faq-accordion {
    display: flex;
    flex-direction: column;
    gap: var(--space-md);
}

.faq-item {
    background: var(--bg-card);
    border: 1px solid var(--border-subtle);
    border-radius: var(--radius-lg);
    overflow: hidden;
    transition: all var(--transition-base);
}

.faq-item:hover {
    border-color: var(--border-active);
    box-shadow: var(--shadow-sm);
}

.faq-question {
    width: 100%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: var(--space-md) var(--space-lg);
    text-align: left;
    font-size: 1.05rem;
    font-weight: 700;
    color: var(--text-primary);
    background: none;
    transition: color var(--transition-fast);
}

.faq-question:hover {
    color: var(--primary);
}

.faq-question .chevron-icon {
    color: var(--text-muted);
    transition: transform var(--transition-base);
}

/* Accordion Active States */
.faq-item.active {
    border-color: var(--primary);
    box-shadow: var(--shadow-md);
}

.faq-item.active .faq-question {
    color: var(--primary);
}

.faq-item.active .chevron-icon {
    transform: rotate(180deg);
    color: var(--primary);
}

.faq-answer {
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.3s ease-out;
}

.faq-answer-content {
    padding: 0 var(--space-lg) var(--space-md);
    color: var(--text-secondary);
    font-size: 0.92rem;
    line-height: 1.6;
}

/* === Bottom Spacer === */
.bottom-spacer {
    height: calc(var(--nav-height) + var(--space-lg));
}

/* === Bottom Navigation === */
.bottom-nav {
    position: fixed;
    bottom: 0;
    left: 50%;
    transform: translateX(-50%);
    width: 100%;
    max-width: var(--max-width);
    height: var(--nav-height);
    background: var(--bg-glass);
    backdrop-filter: blur(24px);
    -webkit-backdrop-filter: blur(24px);
    border-top: 1px solid var(--border-subtle);
    display: flex;
    align-items: center;
    justify-content: space-around;
    padding: 0 var(--space-sm);
    z-index: var(--z-nav);
    transition: transform 0.3s ease;
}

.bottom-nav.hidden {
    transform: translateX(-50%) translateY(100%);
}

.nav-brand-logo {
    display: none;
}

.nav-items-wrapper {
    display: flex;
    width: 100%;
    justify-content: space-around;
    align-items: center;
}

.nav-desktop-actions {
    display: none;
}

.nav-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 2px;
    padding: var(--space-sm);
    border-radius: var(--radius-md);
    color: var(--text-muted);
    font-size: 0.65rem;
    font-weight: 500;
    transition: all var(--transition-base);
    position: relative;
    min-width: 56px;
}

.nav-item:hover {
    color: var(--text-secondary);
}

.nav-item.active {
    color: var(--primary);
}

.nav-item.active::before {
    content: '';
    position: absolute;
    top: -1px;
    left: 50%;
    transform: translateX(-50%);
    width: 24px;
    height: 3px;
    background: var(--primary);
    border-radius: 0 0 var(--radius-sm) var(--radius-sm);
}

.nav-item span {
    letter-spacing: 0.3px;
}

.cart-nav {
    position: relative;
}

.cart-icon-wrap {
    position: relative;
    width: 50px;
    height: 50px;
    background: linear-gradient(135deg, var(--primary), var(--primary-dark));
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-top: -20px;
    box-shadow: var(--shadow-glow);
    transition: all var(--transition-spring);
    color: white;
}

.cart-nav:hover .cart-icon-wrap {
    transform: scale(1.1);
    box-shadow: 0 6px 30px var(--primary-glow);
}

.cart-badge {
    position: absolute;
    top: -2px;
    right: -2px;
    width: 18px;
    height: 18px;
    background: var(--accent);
    color: var(--secondary);
    font-size: 0.65rem;
    font-weight: 800;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 2px solid var(--bg-primary);
}

/* === Animations === */
@keyframes fadeInUp {
    from {
        opacity: 0;
        transform: translateY(30px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

/* === Scroll reveal animations === */
.reveal {
    opacity: 0;
    transform: translateY(30px);
    transition: opacity 0.6s ease, transform 0.6s ease;
}

.reveal.visible {
    opacity: 1;
    transform: translateY(0);
}

/* ============================================
   RESPONSIVE DESIGN
   ============================================ */

/* === Mobile (320px - 480px) === */
@media screen and (max-width: 480px) {
    :root {
        --space-lg: 16px;
        --space-xl: 24px;
        --space-2xl: 32px;
        --nav-height: 64px;
    }

    .hero-overlay {
        flex-direction: column;
        justify-content: center;
        align-items: center;
        padding: var(--space-xl) var(--space-md);
        gap: var(--space-md);
        min-height: unset;
    }

    .hero-left-brand {
        max-width: 100%;
        text-align: center;
        align-items: center;
        gap: var(--space-xs);
    }

    .brand-title {
        font-size: 1.6rem;
    }

    .hero-right-card {
        width: 100%;
        max-width: 100%;
        flex-direction: column;
    }

    .hero-card-content {
        padding: var(--space-md);
    }

    .hero-card-slogan {
        font-size: 1.6rem;
    }

    .hero-card-image-wrap {
        display: none;
    }

    .category-img-wrap {
        width: 75px;
        height: 75px;
    }

    .categories-scroll {
        gap: var(--space-md);
    }

    .category-name {
        font-size: 0.8rem;
    }

    .restaurant-img-wrap {
        height: 150px;
    }

    .section-header h2 {
        font-size: 1.15rem;
    }

    .trending-card,
    .recommended-card {
        min-width: 170px;
    }

    .trending-img,
    .recommended-img {
        height: 110px;
    }

    .floating-food {
        font-size: 1.5rem;
    }

    .floating-food.food-2,
    .floating-food.food-4 {
        display: none;
    }
}

/* === Tablet Portrait (481px - 768px) === */
@media screen and (min-width: 481px) and (max-width: 768px) {
    .hero-overlay {
        flex-direction: column;
        padding: var(--space-xl) var(--space-lg);
        gap: var(--space-lg);
        min-height: unset;
    }

    .hero-left-brand {
        max-width: 100%;
        text-align: center;
        align-items: center;
        gap: var(--space-xs);
    }

    .brand-title {
        font-size: 2rem;
    }

    .hero-right-card {
        width: 100%;
        max-width: 580px;
        flex-direction: row;
    }

    .hero-card-content {
        padding: var(--space-lg);
    }

    .hero-card-slogan {
        font-size: 1.8rem;
    }

    .restaurants-grid {
        grid-template-columns: repeat(2, 1fr);
    }

    .discount-percent {
        font-size: 4.5rem;
    }

    .extra,
    .discount-label {
        font-size: 1.5rem;
    }

    .category-img-wrap {
        width: 90px;
        height: 90px;
    }

    .category-name {
        font-size: 0.85rem;
    }

    .trending-card,
    .recommended-card {
        min-width: 220px;
    }
}

/* === Tablet Landscape / Small Laptop (769px - 1024px) === */
@media screen and (min-width: 769px) and (max-width: 1024px) {
    :root {
        --space-lg: 28px;
        --space-xl: 40px;
    }

    .hero-section {
        margin: var(--space-md) var(--space-xl) var(--space-xl);
        border-radius: var(--radius-xl);
    }
    .hero-left-brand {
        max-width: 38%;
    }
    .hero-right-card {
        max-width: 600px;
        width: 58%;
        flex-shrink: 1;
    }
    .brand-title {
        font-size: 2.2rem;
    }
    .hero-card-slogan {
        font-size: 1.8rem;
    }

    .restaurants-grid {
        grid-template-columns: repeat(2, 1fr);
        gap: var(--space-lg);
    }

    .restaurant-img-wrap {
        height: 200px;
    }

    .category-img-wrap {
        width: 100px;
        height: 100px;
    }

    .category-name {
        font-size: 0.9rem;
    }

    .categories-scroll {
        gap: var(--space-xl);
    }

    .trending-card,
    .recommended-card {
        min-width: 240px;
    }

    .trending-img,
    .recommended-img {
        height: 150px;
    }

    .search-bar {
        padding: 14px var(--space-lg);
    }
}

/* === Desktop / Large Laptop (1025px+) === */
@media screen and (min-width: 1025px) {
    :root {
        --space-lg: 32px;
        --space-xl: 48px;
        --space-2xl: 64px;
        --header-height: 68px;
        --nav-height: 78px;
    }

    .app-container {
        padding: var(--header-height) var(--space-md) 0;
    }

    .top-bar {
        border-radius: 0 0 var(--radius-lg) var(--radius-lg);
        padding: var(--space-md) var(--space-xl);
    }

    .hero-section {
        margin: var(--space-md) var(--space-xl) var(--space-xl);
        border-radius: var(--radius-xl);
    }
    .hero-left-brand {
        max-width: 38%;
    }
    .hero-right-card {
        max-width: 680px;
        width: 58%;
        flex-shrink: 1;
    }

    .search-section {
        padding: 0 var(--space-xl);
        margin-top: 0;
    }

    .search-bar {
        padding: 16px var(--space-xl);
        border-radius: var(--radius-xl);
    }

    .search-bar input {
        font-size: 1rem;
    }

    .filter-btn {
        width: 56px;
        height: 56px;
    }

    .section-header {
        padding: 0 var(--space-xl);
    }

    .section-header h2 {
        font-size: 1.5rem;
    }

    .categories-scroll {
        padding: var(--space-sm) var(--space-xl);
        gap: var(--space-xl);
        justify-content: flex-start;
    }

    .category-card {
        min-width: 125px;
    }

    .category-img-wrap {
        width: 115px;
        height: 115px;
    }

    .category-name {
        font-size: 0.95rem;
    }

    .restaurants-grid {
        grid-template-columns: repeat(4, 1fr);
        gap: var(--space-lg);
        padding: 0 var(--space-xl);
    }

    .restaurant-img-wrap {
        height: 200px;
    }

    .trending-scroll {
        padding: var(--space-sm) var(--space-xl);
        gap: var(--space-lg);
    }

    .trending-card,
    .recommended-card {
        min-width: 260px;
    }

    .trending-img,
    .recommended-img {
        height: 160px;
    }

    .top-bar {
        display: none;
    }

    .bottom-nav {
        position: fixed;
        top: 0;
        bottom: auto;
        left: 50%;
        transform: translateX(-50%) !important;
        width: 100%;
        max-width: var(--max-width);
        height: var(--header-height);
        background: var(--bg-glass);
        backdrop-filter: blur(24px);
        -webkit-backdrop-filter: blur(24px);
        border-top: none;
        border-bottom: 1px solid var(--border-subtle);
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 0 var(--space-xl);
        border-radius: 0;
        z-index: var(--z-sticky);
    }

    .bottom-nav.hidden {
        transform: translateX(-50%) translateY(-100%) !important;
    }

    .nav-brand-logo {
        display: flex;
        align-items: center;
        gap: var(--space-sm);
        cursor: pointer;
    }

    .brand-logo-icon {
        font-size: 1.8rem;
    }

    .brand-logo-text {
        display: flex;
        flex-direction: column;
        line-height: 1.1;
    }

    .logo-name {
        font-size: 1.3rem;
        font-weight: 800;
        color: var(--text-primary);
        background: linear-gradient(135deg, var(--primary), var(--accent));
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
    }

    .logo-tagline {
        font-size: 0.65rem;
        color: var(--text-muted);
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .nav-items-wrapper {
        display: flex;
        width: auto;
        gap: var(--space-md);
        justify-content: center;
        align-items: center;
    }

    .nav-item {
        flex-direction: row;
        gap: var(--space-sm);
        padding: var(--space-sm) var(--space-md);
        border-radius: var(--radius-full);
        font-size: 0.85rem;
        font-weight: 600;
        color: var(--text-secondary);
        min-width: auto;
        transition: all var(--transition-base);
    }

    .nav-item:hover {
        background: rgba(255, 255, 255, 0.03);
        color: var(--text-primary);
    }

    .nav-item.active {
        background: rgba(255, 107, 53, 0.1);
        color: var(--primary);
    }

    .nav-item.active::before {
        display: none;
    }

    .cart-icon-wrap {
        width: auto;
        height: auto;
        background: none;
        border-radius: 0;
        margin-top: 0;
        box-shadow: none;
        color: inherit;
        display: inline-flex;
    }

    .cart-nav:hover .cart-icon-wrap {
        transform: none;
        box-shadow: none;
    }

    .cart-badge {
        top: -8px;
        right: -8px;
        border-color: var(--bg-card);
    }

    .nav-desktop-actions {
        display: flex;
        align-items: center;
        gap: var(--space-lg);
    }

    #navProfile {
        display: none;
    }

    .desktop-delivery-info {
        display: flex;
        flex-direction: column;
        align-items: flex-end;
    }

    .desktop-delivery-info .delivery-label {
        font-size: 0.65rem;
        color: var(--text-muted);
        text-transform: uppercase;
        letter-spacing: 1px;
    }

    .desktop-delivery-info .delivery-address {
        display: flex;
        align-items: center;
        gap: var(--space-xs);
        margin-top: 2px;
        font-size: 0.8rem;
        font-weight: 600;
        color: var(--text-primary);
    }

    .desktop-profile-btn {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        background: var(--bg-glass-light);
        color: var(--text-primary);
        position: relative;
        border: 1px solid var(--border-subtle);
        transition: all var(--transition-base);
        cursor: pointer;
    }

    .desktop-profile-btn:hover {
        background: var(--bg-surface);
        transform: scale(1.05);
        border-color: var(--primary);
        color: var(--primary);
    }

    .bottom-spacer {
        display: none;
    }

    .floating-food {
        font-size: 2.5rem;
    }
}

/* === Ultra Wide (1440px+) === */
@media screen and (min-width: 1440px) {


    .hero-content {
        max-width: 50%;
    }

    .discount-percent {
        font-size: 7rem;
    }

    .restaurants-grid {
        grid-template-columns: repeat(4, 1fr);
    }
}

/* === Landscape Mobile === */
@media screen and (max-height: 500px) and (orientation: landscape) {


    .hero-content {
        padding: var(--space-md);
    }

    .discount-percent {
        font-size: 2.5rem;
    }

    .extra,
    .discount-label {
        font-size: 1rem;
    }

    .bottom-nav {
        height: 56px;
    }

    .nav-item span {
        display: none;
    }

    .cart-icon-wrap {
        width: 40px;
        height: 40px;
        margin-top: -10px;
    }

    .bottom-spacer {
        height: 72px;
    }
}

/* === Prefers Reduced Motion === */
@media (prefers-reduced-motion: reduce) {
    *,
    *::before,
    *::after {
        animation-duration: 0.01ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.01ms !important;
    }

    .floating-food {
        display: none;
    }
}

/* === Dark mode scrollbar for Firefox === */
@supports (scrollbar-color: auto) {
    * {
        scrollbar-color: var(--bg-surface) transparent;
        scrollbar-width: thin;
    }
}

/* === iOS Safari bottom safe area === */
@supports (padding-bottom: env(safe-area-inset-bottom)) {
    .bottom-nav {
        padding-bottom: env(safe-area-inset-bottom);
        height: calc(var(--nav-height) + env(safe-area-inset-bottom));
    }

    .bottom-spacer {
        height: calc(var(--nav-height) + env(safe-area-inset-bottom) + var(--space-lg));
    }
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
    background: #0F0906; /* dark app store pill */
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

/* Responsive Footer overrides */
@media screen and (max-width: 768px) {
    .footer-links-grid {
        grid-template-columns: repeat(2, 1fr);
        gap: var(--space-lg);
    }
}

@media screen and (max-width: 480px) {
    .footer-links-grid {
        grid-template-columns: 1fr;
        gap: var(--space-lg);
    }
    
    .app-download-badges {
        flex-direction: row;
        max-width: 100%;
    }
    
    .download-badge {
        flex: 1;
    }
}

/* === Veg/Non-Veg Toggle === */
.veg-toggle-group {
    display: flex;
    gap: 6px;
    flex-shrink: 0;
}

.veg-toggle-btn {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 8px 16px;
    border-radius: var(--radius-full);
    font-size: 0.85rem;
    font-weight: 700;
    color: var(--text-secondary);
    background: var(--bg-card);
    border: 1px solid var(--border-subtle);
    transition: all var(--transition-base);
    white-space: nowrap;
    box-shadow: var(--shadow-sm);
}

.veg-toggle-btn.active {
    border-color: #2E7D32;
    color: #2E7D32;
    background: rgba(46, 125, 50, 0.08);
}

.veg-toggle-btn#vegToggleAll.active {
    border-color: var(--primary);
    color: var(--primary);
    background: rgba(255, 107, 53, 0.08);
}

.veg-dot {
    width: 14px;
    height: 14px;
    border-radius: 3px;
    border: 2px solid;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    position: relative;
}

.veg-dot::after {
    content: '';
    width: 6px;
    height: 6px;
    border-radius: 50%;
    display: block;
}

.veg-dot-red {
    border-color: #C62828;
}

.veg-dot-red::after {
    background: #C62828;
}

.veg-dot-green {
    border-color: #2E7D32;
}

.veg-dot-green::after {
    background: #2E7D32;
}

body.modal-open {
    overflow: hidden;
}

/* === Modal Styles === */
body.modal-open {
    overflow: hidden !important;
    touch-action: none;
}

.modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(15, 23, 42, 0.75);
    backdrop-filter: blur(16px) saturate(180%);
    -webkit-backdrop-filter: blur(16px) saturate(180%);
    z-index: 9999999;
    display: none;
    align-items: center;
    justify-content: center;
    padding: var(--space-md);
    opacity: 0;
    visibility: hidden;
    pointer-events: none;
    overscroll-behavior: contain !important;
    transition: opacity 0.25s ease, visibility 0.25s ease;
}

.modal-overlay.active,
.modal-overlay:target {
    display: flex !important;
    opacity: 1 !important;
    visibility: visible !important;
    pointer-events: auto !important;
}

.modal-container {
    background: var(--bg-card);
    border-radius: var(--radius-xl);
    width: 100%;
    max-height: calc(100dvh - 32px);
    max-height: calc(100vh - 32px);
    overflow-y: auto !important;
    overscroll-behavior: contain !important;
    -webkit-overflow-scrolling: touch;
    box-shadow: 0 24px 80px rgba(0, 0, 0, 0.25);
    border: 1px solid var(--border-subtle);
    transform: translateY(20px);
    transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
    scrollbar-width: thin;
    scrollbar-color: rgba(255, 107, 53, 0.4) transparent;
}

.modal-overlay.active .modal-container,
.modal-overlay:target .modal-container {
    transform: translateY(0);
}

.filter-modal {
    max-width: 650px;
}

.signin-modal {
    max-width: 440px;
    background: rgba(255, 255, 255, 0.88);
    backdrop-filter: blur(25px) saturate(190%);
    -webkit-backdrop-filter: blur(25px) saturate(190%);
    border: 1px solid rgba(255, 255, 255, 0.45);
    border-radius: 24px;
    box-shadow: 0 30px 80px rgba(0, 0, 0, 0.28);
    max-height: 90vh;
    display: flex;
    flex-direction: column;
    overflow-y: auto !important; /* Allow scrollbars on small screens */
}

.modal-header-tabs {
    display: flex;
    background: rgba(0, 0, 0, 0.03);
    border-bottom: 1px solid rgba(0, 0, 0, 0.06);
    height: 60px;
    align-items: stretch;
    position: relative;
}

.modal-tab-btn {
    flex: 1;
    border: none;
    background: none;
    font-size: 0.95rem;
    font-weight: 700;
    color: var(--text-muted);
    cursor: pointer;
    transition: all var(--transition-fast);
    display: flex;
    align-items: center;
    justify-content: center;
    font-family: inherit;
}

.modal-tab-btn:hover {
    color: var(--text-primary);
}

.modal-tab-btn.active {
    color: var(--text-primary);
    background: transparent;
    border-bottom: 3px solid var(--primary);
}

.modal-close-btn {
    position: absolute;
    top: 50%;
    right: 16px;
    transform: translateY(-50%);
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background: rgba(0, 0, 0, 0.05);
    border: none;
    font-size: 1.1rem;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    color: var(--text-secondary);
    transition: all var(--transition-fast);
    z-index: 5;
}

.modal-close-btn:hover {
    background: rgba(0, 0, 0, 0.1);
    color: var(--text-primary);
}

/* Filter Modal Body */
.filter-body {
    display: flex;
    min-height: 320px;
}

.filter-sidebar {
    width: 190px;
    border-right: 1px solid var(--border-subtle);
    background: var(--bg-secondary);
    flex-shrink: 0;
}

.filter-tab {
    display: flex;
    flex-direction: column;
    width: 100%;
    padding: var(--space-md) var(--space-lg);
    text-align: left;
    font-size: 0.95rem;
    font-weight: 700;
    color: var(--text-secondary);
    border-left: 4px solid transparent;
    background: none;
    transition: all var(--transition-fast);
}

.filter-tab:hover {
    background: var(--bg-card-hover);
}

.filter-tab.active {
    color: var(--text-primary);
    border-left-color: var(--primary);
    background: var(--bg-card);
}

.filter-tab-value {
    font-size: 0.75rem;
    font-weight: 500;
    color: var(--primary);
    margin-top: 2px;
}

.filter-content {
    flex: 1;
    padding: var(--space-lg) var(--space-xl);
    overflow-y: auto;
    background: var(--bg-card);
}

.filter-panel {
    display: none;
    flex-direction: column;
    gap: var(--space-md);
}

.filter-panel.active {
    display: flex;
}

.filter-radio,
.filter-checkbox {
    display: flex;
    align-items: center;
    gap: var(--space-md);
    cursor: pointer;
    font-size: 0.95rem;
    color: var(--text-primary);
    padding: var(--space-xs) 0;
}

.filter-radio input,
.filter-checkbox input {
    display: none;
}

.radio-custom {
    width: 20px;
    height: 20px;
    border-radius: 50%;
    border: 2px solid var(--text-muted);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    transition: all var(--transition-fast);
}

.filter-radio input:checked + .radio-custom {
    border-color: var(--primary);
}

.filter-radio input:checked + .radio-custom::after {
    content: '';
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: var(--primary);
}

.checkbox-custom {
    width: 20px;
    height: 20px;
    border-radius: 4px;
    border: 2px solid var(--text-muted);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    transition: all var(--transition-fast);
}

.filter-checkbox input:checked + .checkbox-custom {
    background: var(--primary);
    border-color: var(--primary);
}

.filter-checkbox input:checked + .checkbox-custom::after {
    content: '✓';
    color: white;
    font-size: 0.8rem;
    font-weight: 900;
}

.modal-footer {
    display: flex;
    justify-content: flex-end;
    gap: var(--space-md);
    padding: var(--space-md) var(--space-xl);
    border-top: 1px solid var(--border-subtle);
    background: var(--bg-card);
}

.modal-btn-secondary {
    padding: 10px 24px;
    border-radius: var(--radius-md);
    font-size: 0.95rem;
    font-weight: 600;
    color: var(--text-secondary);
    background: none;
    transition: all var(--transition-fast);
}

.modal-btn-secondary:hover {
    color: var(--text-primary);
}

.modal-btn-primary {
    padding: 10px 32px;
    border-radius: var(--radius-md);
    background: var(--primary);
    color: white;
    font-size: 0.95rem;
    font-weight: 700;
    transition: all var(--transition-base);
    box-shadow: var(--shadow-sm);
}

.modal-btn-primary:hover {
    background: var(--primary-dark);
    transform: translateY(-1px);
    box-shadow: var(--shadow-md);
}

/* Sign In Modal Body */
.signin-body {
    padding: var(--space-xl);
    display: flex;
    flex-direction: column;
    gap: var(--space-lg);
}

.signin-field input {
    width: 100%;
    padding: 14px var(--space-lg);
    border: 1px solid var(--border-subtle);
    border-radius: var(--radius-md);
    font-size: 1rem;
    color: var(--text-primary);
    background: var(--bg-card);
    transition: border-color var(--transition-fast);
}

.signin-field input:focus {
    border-color: var(--border-active);
    box-shadow: 0 0 0 3px var(--primary-glow);
}

.signin-field input::placeholder {
    color: var(--text-muted);
}

.signin-terms {
    display: flex;
    align-items: flex-start;
    gap: var(--space-sm);
    font-size: 0.85rem;
    color: var(--text-secondary);
    cursor: pointer;
}

.signin-terms input[type="checkbox"] {
    width: 18px;
    height: 18px;
    margin-top: 2px;
    accent-color: var(--primary);
    flex-shrink: 0;
}

.signin-terms a {
    color: var(--primary);
    font-weight: 600;
}

.signin-submit {
    width: 100%;
    padding: 14px;
    border-radius: var(--radius-md);
    background: var(--bg-surface);
    color: var(--text-muted);
    font-size: 1rem;
    font-weight: 700;
    transition: all var(--transition-base);
    border: 1px solid var(--border-subtle);
}

.signin-submit.enabled {
    background: var(--primary);
    color: white;
    cursor: pointer;
    box-shadow: var(--shadow-sm);
}

.signin-submit.enabled:hover {
    background: var(--primary-dark);
    box-shadow: var(--shadow-md);
}

.signin-divider {
    display: flex;
    align-items: center;
    gap: var(--space-md);
    color: var(--text-muted);
    font-size: 0.85rem;
}

.signin-divider::before,
.signin-divider::after {
    content: '';
    flex: 1;
    height: 1px;
    background: var(--border-subtle);
}

.signin-google {
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: var(--space-sm);
    padding: 12px;
    border: 1px solid var(--border-subtle);
    border-radius: var(--radius-md);
    font-size: 0.95rem;
    font-weight: 600;
    color: var(--text-primary);
    background: var(--bg-card);
    transition: all var(--transition-fast);
}

.signin-google:hover {
    border-color: var(--border-active);
    background: var(--bg-card-hover);
}

.signin-google svg {
    flex-shrink: 0;
}

.signin-footer-text {
    text-align: center;
    font-size: 0.9rem;
    color: var(--text-secondary);
}

.signin-footer-text .login-link {
    color: var(--primary);
    font-weight: 700;
}

@media screen and (max-width: 580px) {
    .filter-body {
        flex-direction: column;
        min-height: auto;
    }
    .filter-sidebar {
        width: 100%;
        display: flex;
        overflow-x: auto;
        border-right: none;
        border-bottom: 1px solid var(--border-subtle);
    }
    .filter-tab {
        padding: var(--space-sm) var(--space-md);
        border-left: none;
        border-bottom: 3px solid transparent;
        white-space: nowrap;
        width: auto;
        align-items: center;
    }
    .filter-tab.active {
        border-bottom-color: var(--primary);
    }
    .veg-toggle-group {
        display: none;
    }
}

/* === Focus visible for keyboard navigation === */
button:focus-visible,
input:focus-visible {
    outline: 2px solid var(--primary);
    outline-offset: 2px;
}

/* === Print styles === */
@media print {
    .bottom-nav,
    .splash-loader,
    .hero-video-container video {
        display: none !important;
    }

    body {
        background: white;
        color: black;
    }
}

/* === Food Detail Modal Styling === */
.food-detail-modal {
    max-width: 500px;
    border-radius: var(--radius-lg);
    overflow: hidden;
}

.food-detail-body {
    padding: var(--space-xl);
    max-height: calc(85vh - 70px);
    overflow-y: auto;
}

.food-detail-img-container {
    width: 100%;
    height: 240px;
    border-radius: var(--radius-md);
    overflow: hidden;
    margin-bottom: var(--space-lg);
    border: 1px solid var(--border-subtle);
    box-shadow: var(--shadow-sm);
}

.food-detail-img-container img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.food-detail-content {
    display: flex;
    flex-direction: column;
    gap: var(--space-md);
}

.food-detail-price-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.food-detail-price {
    font-size: 1.4rem;
    font-weight: 800;
    color: var(--primary);
}

.food-detail-desc {
    font-size: 0.95rem;
    color: var(--text-secondary);
    line-height: 1.6;
}

.food-detail-ingredients-section h3 {
    font-size: 1rem;
    font-weight: 700;
    margin-bottom: var(--space-sm);
    color: var(--text-primary);
}

.ingredients-list {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
}

.ingredient-pill {
    background: var(--bg-surface);
    border: 1px solid var(--border-subtle);
    color: var(--text-secondary);
    padding: 6px 12px;
    border-radius: var(--radius-pill);
    font-size: 0.8rem;
    font-weight: 500;
    transition: all var(--transition-fast);
}

.ingredient-pill:hover {
    background: var(--primary-light);
    border-color: var(--primary);
    color: var(--primary);
    transform: translateY(-1px);
}

/* Menu Quantity Selector & ADD button styling for Homepage Modal */
.modal-action-container .dish-add-btn {
    position: static;
    transform: none;
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
    display: inline-flex;
    align-items: center;
    justify-content: center;
}

.modal-action-container .dish-add-btn:hover {
    background: #25C578;
    color: #fff;
    box-shadow: 0 4px 15px rgba(37, 197, 120, 0.3);
}

.modal-action-container .menu-qty-selector {
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

.modal-action-container .menu-qty-btn {
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

.modal-action-container .menu-qty-btn:active {
    transform: scale(0.85);
}

.modal-action-container .menu-qty-value {
    font-size: 0.85rem;
    font-weight: 800;
    color: var(--text-primary);
    min-width: 16px;
    text-align: center;
}

/* Homepage Cards Quantity Selector Style overrides */
.homepage-qty-container .dish-add-btn {
    position: static;
    transform: none;
    background: #fff;
    color: #25C578;
    border: 1.5px solid #25C578;
    padding: 4px 14px;
    border-radius: var(--radius-sm);
    font-weight: 700;
    font-size: 0.75rem;
    box-shadow: 0 2px 6px rgba(0,0,0,0.08);
    cursor: pointer;
    transition: all var(--transition-fast);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
}

.homepage-qty-container .dish-add-btn:hover {
    background: #25C578;
    color: #fff;
    box-shadow: 0 4px 10px rgba(37, 197, 120, 0.2);
}

.homepage-qty-container .menu-qty-selector {
    display: inline-flex;
    align-items: center;
    justify-content: space-between;
    background: #fff;
    border: 1.5px solid #25C578;
    border-radius: var(--radius-sm);
    padding: 0 6px;
    height: 28px;
    min-width: 70px;
    box-shadow: 0 2px 6px rgba(0,0,0,0.08);
    box-sizing: border-box;
    transition: all var(--transition-fast);
}

.homepage-qty-container .menu-qty-btn {
    background: none;
    border: none;
    color: #25C578;
    font-size: 1rem;
    font-weight: 800;
    cursor: pointer;
    width: 18px;
    height: 18px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: transform var(--transition-fast);
}

.homepage-qty-container .menu-qty-btn:active {
    transform: scale(0.85);
}

.homepage-qty-container .menu-qty-value {
    font-size: 0.75rem;
    font-weight: 800;
    color: var(--text-primary);
    min-width: 12px;
    text-align: center;
}

/* === Autocomplete Search Suggestions Dropdown === */
.search-suggest-dropdown {
    position: absolute;
    top: calc(100% + 8px);
    left: 0;
    width: 100%;
    background: var(--bg-card);
    border: 1px solid var(--border-subtle);
    border-radius: var(--radius-lg);
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
    z-index: 200;
    max-height: 350px;
    overflow-y: auto;
    display: none;
    flex-direction: column;
    padding: var(--space-sm) 0;
}

.search-suggest-dropdown.active {
    display: flex;
}

.suggest-item {
    display: flex;
    align-items: center;
    gap: var(--space-md);
    padding: var(--space-md) var(--space-lg);
    cursor: pointer;
    transition: background var(--transition-fast);
    text-align: left;
    width: 100%;
    background: none;
    border: none;
    font-family: inherit;
    color: var(--text-primary);
}

.suggest-item:hover {
    background: var(--bg-card-hover);
}

.suggest-img {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    object-fit: cover;
    flex-shrink: 0;
}

.suggest-info {
    display: flex;
    flex-direction: column;
    flex: 1;
}

.suggest-title {
    font-size: 0.95rem;
    font-weight: 600;
    color: var(--text-primary);
}

.suggest-subtitle {
    font-size: 0.75rem;
    color: var(--text-muted);
}

/* === Search Results Overlay === */
.search-results-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: var(--bg-surface);
    z-index: 450;
    display: none;
    opacity: 0;
    transition: opacity 0.3s ease;
    overflow-y: auto;
}

.search-results-overlay.active {
    display: block;
    opacity: 1;
}

.search-results-container {
    max-width: 800px;
    margin: 0 auto;
    padding: var(--space-md);
    box-sizing: border-box;
}

.search-results-header {
    display: flex;
    align-items: center;
    gap: var(--space-md);
    padding: var(--space-md) 0;
    border-bottom: 1px solid var(--border-subtle);
}

.search-results-back-btn {
    background: none;
    border: none;
    color: var(--text-primary);
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: var(--space-sm);
    border-radius: 50%;
    transition: background var(--transition-fast);
}

.search-results-back-btn:hover {
    background: var(--bg-card-hover);
}

.search-results-title {
    display: flex;
    flex-direction: column;
    text-align: left;
}

.search-results-title span {
    font-size: 0.75rem;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.search-results-title strong {
    font-size: 1.15rem;
    font-weight: 800;
    color: var(--text-primary);
}

/* Search Tabs */
.search-results-tabs {
    display: flex;
    border-bottom: 1px solid var(--border-subtle);
    margin-bottom: var(--space-lg);
}

.search-results-tab {
    flex: 1;
    background: none;
    border: none;
    padding: var(--space-md) 0;
    font-size: 0.95rem;
    font-weight: 600;
    color: var(--text-muted);
    cursor: pointer;
    position: relative;
    transition: color var(--transition-fast);
}

.search-results-tab.active {
    color: var(--text-primary);
    font-weight: 700;
}

.search-results-tab.active::after {
    content: '';
    position: absolute;
    bottom: -1px;
    left: 0;
    width: 100%;
    height: 3px;
    background: var(--primary);
}

/* Tab Panels */
.search-results-panel {
    display: none;
    flex-direction: column;
    gap: var(--space-lg);
    padding-bottom: var(--space-2xl);
}

.search-results-panel.active {
    display: flex;
}

/* --- Tab: Restaurants Results Layout (Image 2) --- */
.search-res-card {
    display: flex;
    background: var(--bg-card);
    border-radius: var(--radius-xl);
    border: 1px solid var(--border-subtle);
    overflow: hidden;
    box-shadow: var(--shadow-sm);
    transition: all var(--transition-base);
}

.search-res-card:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
}

.search-res-img-wrap {
    width: 180px;
    height: 140px;
    position: relative;
    overflow: hidden;
    flex-shrink: 0;
}

.search-res-img-wrap img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.search-res-offer-tag {
    position: absolute;
    bottom: 0;
    left: 0;
    width: 100%;
    padding: 20px 8px 6px;
    font-size: 0.85rem;
    font-weight: 900;
    color: #fff;
    background: linear-gradient(0deg, rgba(0,0,0,0.9) 0%, transparent 100%);
    box-sizing: border-box;
}

.search-res-info {
    padding: var(--space-md) var(--space-lg);
    display: flex;
    flex-direction: column;
    justify-content: center;
    flex: 1;
    text-align: left;
}

.search-res-info h3 {
    font-size: 1.15rem;
    font-weight: 800;
    margin: 0 0 var(--space-xs) 0;
}

.search-res-rating-row {
    display: flex;
    align-items: center;
    gap: var(--space-sm);
    font-size: 0.85rem;
    font-weight: 700;
    margin-bottom: var(--space-xs);
}

.search-res-rating-row .star-badge {
    background: #2E7D32;
    color: white;
    padding: 2px 6px;
    border-radius: 4px;
    display: inline-flex;
    align-items: center;
    gap: 2px;
}

.search-res-meta {
    font-size: 0.8rem;
    color: var(--text-muted);
}

/* --- Tab: Dishes Results Layout (Image 1) --- */
.search-dish-restaurant-group {
    background: var(--bg-card);
    border-radius: var(--radius-xl);
    border: 1px solid var(--border-subtle);
    padding: var(--space-lg);
    display: flex;
    flex-direction: column;
    gap: var(--space-md);
    box-shadow: var(--shadow-sm);
    text-align: left;
}

.search-dish-group-header {
    border-bottom: 1px dashed var(--border-subtle);
    padding-bottom: var(--space-sm);
}

.search-dish-group-header h3 {
    font-size: 1.2rem;
    font-weight: 800;
    margin: 0;
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.search-dish-group-rating {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 0.85rem;
    font-weight: 600;
    color: var(--text-secondary);
    margin-top: 4px;
}

.search-dish-group-rating .star {
    color: #2E7D32;
    font-weight: 700;
}

.search-dish-group-offer {
    font-size: 0.8rem;
    font-weight: 700;
    color: var(--primary);
    margin-top: 4px;
}

.search-dish-list-scroll {
    display: flex;
    gap: var(--space-md);
    overflow-x: auto;
    padding: var(--space-xs) 0 var(--space-md);
    scrollbar-width: none;
}

.search-dish-list-scroll::-webkit-scrollbar {
    display: none;
}

.search-dish-result-card {
    border: 1px solid var(--border-subtle);
    border-radius: var(--radius-lg);
    background: var(--bg-surface);
    padding: var(--space-md);
    width: 250px;
    flex-shrink: 0;
    display: flex;
    align-items: center;
    justify-content: space-between;
    position: relative;
    box-sizing: border-box;
    gap: var(--space-md);
}

.search-dish-details {
    display: flex;
    flex-direction: column;
    flex: 1;
}

.search-dish-diet-icon {
    width: 14px;
    height: 14px;
    border: 1.5px solid;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    border-radius: 2px;
}

.search-dish-diet-icon::after {
    content: '';
    width: 6px;
    height: 6px;
    border-radius: 50%;
}

.search-dish-diet-icon.veg {
    border-color: #2E7D32;
}

.search-dish-diet-icon.veg::after {
    background: #2E7D32;
}

.search-dish-diet-icon.nonveg {
    border-color: #C62828;
}

.search-dish-diet-icon.nonveg::after {
    background: #C62828;
}

.search-dish-result-card h4 {
    font-size: 0.95rem;
    font-weight: 700;
    margin: var(--space-xs) 0 4px;
}

.search-dish-rating {
    font-size: 0.75rem;
    font-weight: 700;
    color: #2E7D32;
    display: flex;
    align-items: center;
    gap: 2px;
    margin-bottom: var(--space-sm);
}

.search-dish-price {
    font-size: 1rem;
    font-weight: 700;
    color: var(--text-primary);
}

.search-dish-img {
    width: 85px;
    height: 85px;
    border-radius: var(--radius-md);
    object-fit: cover;
    flex-shrink: 0;
}

/* === Veg/Non-Veg Dietary Indicators (Swiggy/Zomato Style) === */
.dish-diet-icon {
    display: inline-flex;
    margin-bottom: 6px;
    vertical-align: middle;
}

.diet-indicator-box {
    width: 15px;
    height: 15px;
    border: 2px solid currentColor;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 3px;
    background: transparent;
    padding: 2px;
}

/* Green dot for Veg */
.dish-diet-icon[title="Veg Only"] .diet-indicator-box {
    color: #0F8A5F !important; /* Swiggy green */
}
.dish-diet-icon[title="Veg Only"] .diet-indicator-dot {
    width: 7px;
    height: 7px;
    background-color: #0F8A5F;
    border-radius: 50%;
    display: block;
}

/* Red triangle for Non-Veg */
.dish-diet-icon[title="Non-Veg"] .diet-indicator-box {
    color: #E23744 !important; /* Swiggy non-veg red */
}
.dish-diet-icon[title="Non-Veg"] .diet-indicator-triangle {
    width: 0;
    height: 0;
    border-left: 4px solid transparent;
    border-right: 4px solid transparent;
    border-bottom: 8px solid #E23744;
    display: block;
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

.replace-cart-buttons {
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

/* === Veg/Non-Veg Diet Indicators & Badges === */
.diet-indicator {
    display: inline-flex;
    width: 14px;
    height: 14px;
    border: 1.5px solid currentColor;
    border-radius: 3px;
    align-items: center;
    justify-content: center;
    padding: 2px;
    box-sizing: border-box;
    margin-bottom: var(--space-xs);
    flex-shrink: 0;
}

.diet-indicator.veg {
    color: #0F8A5F;
}

.diet-indicator.veg .diet-dot {
    width: 6px;
    height: 6px;
    background-color: #0F8A5F;
    border-radius: 50%;
    display: block;
}

.diet-indicator.non-veg {
    color: #E23744;
}

.diet-indicator.non-veg .diet-dot {
    width: 0;
    height: 0;
    border-left: 3.5px solid transparent;
    border-right: 3.5px solid transparent;
    border-bottom: 7px solid #E23744;
    display: block;
}

/* Pure Veg Tag for Restaurants */
.pure-veg-tag {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    color: #0F8A5F;
    font-size: 0.72rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    margin-bottom: 6px;
    padding: 2px 0;
}

.pure-veg-dot {
    width: 12px;
    height: 12px;
    border: 1.5px solid #0F8A5F;
    border-radius: 2px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    box-sizing: border-box;
    flex-shrink: 0;
}

.pure-veg-dot::after {
    content: '';
    width: 5px;
    height: 5px;
    background-color: #0F8A5F;
    border-radius: 50%;
    display: block;
}

/* === Swiggy/Zomato Sign-in Modal Inner Fields === */
.signin-modal .brand-identity {
    text-align: center;
    padding: var(--space-lg) var(--space-xl) var(--space-xs);
}

.signin-modal .brand-logo-img {
    font-size: 2.2rem;
    display: inline-block;
    margin-bottom: 6px;
    filter: drop-shadow(0 4px 6px rgba(255, 107, 53, 0.25));
}

.signin-modal .brand-identity h1 {
    font-size: 1.6rem;
    font-weight: 800;
    color: var(--text-primary);
    letter-spacing: -0.5px;
    margin-bottom: 2px;
}

.signin-modal .brand-identity p {
    font-size: 0.75rem;
    color: var(--text-muted);
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 1.2px;
}

.signin-modal .form-content-body {
    padding: 0 var(--space-xl) var(--space-xl);
}

.signin-modal .input-field-wrapper {
    display: flex;
    flex-direction: column;
    gap: 6px;
    margin-bottom: var(--space-md);
}

.signin-modal .input-field-wrapper label {
    font-size: 0.82rem;
    font-weight: 800;
    color: var(--text-secondary);
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.signin-modal .input-field-wrapper input {
    width: 100%;
    padding: 12px var(--space-md);
    background: rgba(0, 0, 0, 0.03);
    border: 1px solid rgba(0, 0, 0, 0.08);
    border-radius: var(--radius-md);
    color: var(--text-primary);
    font-size: 0.95rem;
    font-family: inherit;
    transition: all var(--transition-fast);
}

.signin-modal .input-field-wrapper input:focus {
    border-color: var(--primary);
    background: white;
    box-shadow: 0 0 0 3px var(--primary-glow);
    outline: none;
}

.signin-modal .input-field-wrapper input::placeholder {
    color: var(--text-muted);
    opacity: 0.65;
}

.signin-modal .terms-selection {
    display: flex;
    align-items: flex-start;
    gap: var(--space-xs);
    font-size: 0.8rem;
    color: var(--text-secondary);
    cursor: pointer;
    margin: var(--space-md) 0 var(--space-lg);
}

.signin-modal .terms-selection input {
    margin-top: 3px;
    accent-color: var(--primary);
    width: 16px;
    height: 16px;
}

.signin-modal .terms-selection a {
    color: var(--primary);
    font-weight: 700;
    text-decoration: none;
}

.signin-modal .terms-selection a:hover {
    text-decoration: underline;
}

.signin-modal .action-submit-btn {
    width: 100%;
    padding: 14px;
    background: linear-gradient(135deg, var(--primary), #FF5416);
    color: white;
    font-size: 1rem;
    font-weight: 700;
    border: none;
    border-radius: var(--radius-md);
    cursor: pointer;
    box-shadow: 0 6px 20px rgba(255, 107, 53, 0.35);
    transition: all var(--transition-base);
    margin-top: var(--space-sm);
}

.signin-modal .action-submit-btn:hover {
    transform: translateY(-1.5px);
    box-shadow: 0 8px 24px rgba(255, 107, 53, 0.45);
}

.signin-modal .connector-divider {
    display: flex;
    align-items: center;
    gap: var(--space-md);
    color: var(--text-muted);
    font-size: 0.78rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin: var(--space-lg) 0;
}

.signin-modal .connector-divider::before,
.signin-modal .connector-divider::after {
    content: '';
    flex: 1;
    height: 1px;
    background: rgba(0, 0, 0, 0.08);
}

.signin-modal .google-brand-btn {
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    padding: 12px;
    background: white;
    border: 1px solid rgba(0, 0, 0, 0.08);
    border-radius: var(--radius-md);
    color: var(--text-primary);
    font-size: 0.92rem;
    font-weight: 700;
    cursor: pointer;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.03);
    transition: all var(--transition-fast);
    font-family: inherit;
}

.signin-modal .google-brand-btn:hover {
    background: #FAF9F6;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.06);
    transform: translateY(-0.5px);
}

.signin-modal .toggle-onboarding-footer {
    text-align: center;
    font-size: 0.85rem;
    color: var(--text-secondary);
    margin-top: var(--space-lg);
    font-weight: 500;
}

.signin-modal .toggle-onboarding-footer a {
    color: var(--primary);
    font-weight: 700;
    text-decoration: none;
    transition: color var(--transition-fast);
}

.signin-modal .toggle-onboarding-footer a:hover {
    text-decoration: underline;
    color: var(--primary-dark);
}

/* Teacher's Card Layout Styles */
.details {
    display: flex;
    gap: 12px;
    align-items: center;
    margin: 8px 0;
    font-size: 0.9rem;
}
.details .rating {
    background: #4caf50;
    color: white;
    padding: 2px 6px;
    border-radius: var(--radius-sm);
    font-weight: bold;
}
.details .time {
    color: var(--text-secondary);
}
.cuisine {
    font-size: 0.95rem;
    color: var(--text-secondary);
    margin-bottom: 6px;
    font-weight: 500;
}
.address {
    font-size: 0.9rem;
    color: var(--text-muted);
    margin-bottom: 6px;
}
.description {
    font-size: 0.85rem;
    color: var(--text-muted);
    line-height: 1.4;
    margin-bottom: 12px;
}
.order-btn {
    display: inline-block;
    background: var(--primary);
    color: white;
    padding: 8px 16px;
    border-radius: var(--radius-md);
    font-weight: 600;
    text-decoration: none;
    text-align: center;
    transition: var(--transition-fast);
}
.order-btn:hover {
    background: var(--primary-dark);
}

/* === Premium Top Navigation Header === */
.app-top-header {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 72px;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border-bottom: 1px solid rgba(255, 107, 53, 0.15);
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.06);
    z-index: 1000;
    display: flex;
    align-items: center;
    justify-content: center;
}

.header-container {
    width: 100%;
    max-width: 1400px;
    padding: 0 24px;
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.header-brand {
    display: flex;
    align-items: center;
    gap: 10px;
    text-decoration: none;
}

.header-brand .brand-icon {
    font-size: 1.8rem;
}

.header-brand .brand-text {
    display: flex;
    flex-direction: column;
    line-height: 1.1;
}

.header-brand .brand-name {
    font-size: 1.4rem;
    font-weight: 800;
    background: linear-gradient(135deg, #FF6B35, #FFB800);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

.header-brand .brand-tagline {
    font-size: 0.65rem;
    color: #8E796A;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.header-location {
    display: flex;
    align-items: center;
    gap: 8px;
    background: rgba(255, 107, 53, 0.08);
    padding: 8px 16px;
    border-radius: 9999px;
    border: 1px solid rgba(255, 107, 53, 0.18);
}

.location-details {
    display: flex;
    flex-direction: column;
    line-height: 1.1;
}

.location-label {
    font-size: 0.62rem;
    font-weight: 700;
    color: #8E796A;
    text-transform: uppercase;
}

.location-value {
    font-size: 0.85rem;
    font-weight: 700;
    color: #2C1B10;
}

.header-nav-links {
    display: flex;
    align-items: center;
    gap: 12px;
}

.nav-link {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 16px;
    border-radius: 9999px;
    font-size: 0.9rem;
    font-weight: 600;
    color: #5C4333;
    text-decoration: none;
    transition: all 0.2s ease;
}

.nav-link:hover, .nav-link.active {
    background: rgba(255, 107, 53, 0.12);
    color: #FF6B35;
}

.nav-link.profile-link, .nav-link.signin-link {
    background: linear-gradient(135deg, #FF6B35, #FF5416);
    color: white !important;
    box-shadow: 0 4px 12px rgba(255, 107, 53, 0.3);
}

.nav-link.profile-link:hover, .nav-link.signin-link:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 16px rgba(255, 107, 53, 0.4);
}

.app-container {
    padding-top: 84px !important;
}

@media (max-width: 768px) {
    .header-location {
        display: none;
    }
    .header-nav-links .nav-link span {
        display: none;
    }
    .header-nav-links .nav-link {
        padding: 8px 10px;
    }
}
</style>
</head>
<body>
    <!-- Premium Top Navigation Header -->
    <header class="app-top-header" id="appTopHeader">
        <div class="header-container">
            <!-- Brand Logo -->
            <a href="restaurants" class="header-brand">
                <span class="brand-icon">🍽️</span>
                <div class="brand-text">
                    <span class="brand-name">Khaalo</span>
                    <span class="brand-tagline">Har Bhook Ka Solution</span>
                </div>
            </a>

            <!-- Location Selector -->
            <div class="header-location">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="#FF6B35">
                    <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
                </svg>
                <div class="location-details">
                    <span class="location-label">Delivery Location</span>
                    <span class="location-value" id="headerLocationText">Select Location</span>
                </div>
            </div>

            <!-- Header Navigation Links -->
            <nav class="header-nav-links">
                <a href="restaurants" class="nav-link active">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/>
                    </svg>
                    <span>Home</span>
                </a>
                <a href="saved" class="nav-link">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path>
                    </svg>
                    <span>Saved</span>
                </a>
                <a href="cart.jsp?ref=home" class="nav-link cart-link">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z"/>
                    </svg>
                    <span>Cart</span>
                </a>
                <a href="help.jsp" class="nav-link">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="12" cy="12" r="10"></circle>
                        <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"></path>
                        <line x1="12" y1="17" x2="12.01" y2="17"></line>
                    </svg>
                    <span>Help</span>
                </a>
                <% if (user != null) { %>
                <a href="user-details.jsp" class="nav-link profile-link">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                        <circle cx="12" cy="7" r="4"></circle>
                    </svg>
                    <span><%= user.getFullName() %></span>
                </a>
                <% } else { %>
                <a href="#signInModalOverlay" class="nav-link signin-link" onclick="window.openSignInModal(); return false;">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"></path>
                        <polyline points="10 17 15 12 10 7"></polyline>
                        <line x1="15" y1="12" x2="3" y2="12"></line>
                    </svg>
                    <span>Sign In</span>
                </a>
                <% } %>
            </nav>
        </div>
    </header>

    <!-- Main App Container -->
    <div class="app-container" id="appContainer">

        <!-- Hero Section with Video and Promo Overlay -->
        <section class="hero-section" id="heroSection">
            <div class="hero-video-container">
                <video autoplay muted loop playsinline preload="auto" id="heroVideo">
                    <source src="videos/hero_banner.mp4" type="video/mp4">
                </video>
            </div>
            <div class="hero-overlay">
                <!-- Left Side: Brand & Quick Title (minimalist) -->
                <div class="hero-left-brand">
                    <div class="brand-logo-glow">🍽️</div>
                    <span class="brand-sub">PREMIUM DELIVERY</span>
                    <h2 class="brand-title">Your Favorite Food,<br>Delivered Fast.</h2>
                </div>

                <!-- Right Side: Large Featured Card (Teal/Dark styled glass card) -->
                <div class="hero-right-card">
                    <div class="hero-card-content">
                        <span class="promo-pill-light">🔥 Limited Time Offer</span>
                        <h1 class="hero-card-slogan">Har Bhook<br>Ka <span class="slogan-highlight">Solution</span></h1>
                        <p class="hero-card-desc">Freshly prepared meals from top rated local restaurants delivered straight to your door.</p>
                        
                        <div class="hero-card-promo-badge">
                            <span class="promo-percent-bold">15% OFF</span>
                            <span class="promo-code-pill">CODE: KHAALO15</span>
                        </div>

                        <button class="promo-cta-new" onclick="document.getElementById('searchSection').scrollIntoView({behavior: 'smooth'})">
                            Explore Menu
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                                <line x1="5" y1="12" x2="19" y2="12"></line>
                                <polyline points="12 5 19 12 12 19"></polyline>
                            </svg>
                        </button>
                    </div>
                    <div class="hero-card-image-wrap">
                        <img src="https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&auto=format&fit=crop&q=80" alt="Delicious Food Gourmet Spread" class="hero-card-img">
                    </div>
                </div>
            </div>
        </section>

        <!-- Search Bar & Diet Filters -->
        <section class="search-section" id="searchSection">
            <div class="search-wrapper" style="position: relative;">
                <div class="search-bar" id="searchBar">
                    <svg class="search-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="11" cy="11" r="8"></circle>
                        <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                    </svg>
                    <input type="text" placeholder="Search by name & restaurant" id="searchInput" aria-label="Search for food or restaurants" autocomplete="off" style="border: none !important; outline: none !important; box-shadow: none !important; background: transparent !important;">
                </div>
                <div class="veg-toggle-group">
                    <a href="restaurants.jsp?diet=<%= "veg".equalsIgnoreCase(dietFilter) ? "all" : "veg" %>#recommendedSection" class="veg-toggle-btn <%= "veg".equalsIgnoreCase(dietFilter) ? "active" : "" %>" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center; color: inherit;">
                        <span class="veg-dot veg-dot-green"></span> Veg
                    </a>
                    <a href="restaurants.jsp?diet=<%= "non-veg".equalsIgnoreCase(dietFilter) ? "all" : "non-veg" %>#recommendedSection" class="veg-toggle-btn <%= "non-veg".equalsIgnoreCase(dietFilter) ? "active" : "" %>" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center; color: inherit;">
                        <span class="veg-dot veg-dot-red"></span> Non-Veg
                    </a>
                </div>
                <!-- Search Suggestions Dropdown -->
                <div class="search-suggest-dropdown" id="searchSuggestDropdown"></div>
            </div>
        </section>

        <!-- Categories Section -->
        <section class="categories-section" id="categoriesSection">
            <div class="section-header">
                <h2>Categories</h2>
                <button class="see-all-btn" id="seeAllCategoriesBtn">
                    See All
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                        <polyline points="9 18 15 12 9 6"></polyline>
                    </svg>
                </button>
            </div>
            <div class="categories-scroll" id="categoriesScroll">
                <div class="category-card" data-category="burger">
                    <div class="category-img-wrap">
                        <img src="images/burger.png" alt="Burger" loading="lazy">
                    </div>
                    <span class="category-name">Burger</span>
                </div>
                <div class="category-card" data-category="chicken">
                    <div class="category-img-wrap">
                        <img src="images/grilled_chicken.png" alt="Grilled Chicken" loading="lazy">
                    </div>
                    <span class="category-name">Grilled Chicken</span>
                </div>
                <div class="category-card" data-category="south-indian">
                    <div class="category-img-wrap">
                        <img src="images/south_indian.png" alt="South Indian" loading="lazy">
                    </div>
                    <span class="category-name">South Indian</span>
                </div>
                <div class="category-card" data-category="idli">
                    <div class="category-img-wrap">
                        <img src="images/idli.png" alt="Idli" loading="lazy">
                    </div>
                    <span class="category-name">Idli</span>
                </div>
                <div class="category-card" data-category="dosa">
                    <div class="category-img-wrap">
                        <img src="https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=150&h=150&fit=crop&q=80" alt="Dosa" loading="lazy">
                    </div>
                    <span class="category-name">Dosa</span>
                </div>
                <div class="category-card" data-category="vada">
                    <div class="category-img-wrap">
                        <img src="images/vada.png" alt="Vada" loading="lazy">
                    </div>
                    <span class="category-name">Vada</span>
                </div>
                <div class="category-card" data-category="pongal">
                    <div class="category-img-wrap">
                        <img src="images/pongal.png" alt="Pongal" loading="lazy">
                    </div>
                    <span class="category-name">Pongal</span>
                </div>
                <div class="category-card" data-category="upma">
                    <div class="category-img-wrap">
                        <img src="images/upma.png" alt="Upma" loading="lazy">
                    </div>
                    <span class="category-name">Upma</span>
                </div>
                <div class="category-card" data-category="salad">
                    <div class="category-img-wrap">
                        <img src="images/salad.png" alt="Salad" loading="lazy">
                    </div>
                    <span class="category-name">Salad</span>
                </div>
                <div class="category-card" data-category="juice">
                    <div class="category-img-wrap">
                        <img src="images/juice.png" alt="Juice" loading="lazy">
                    </div>
                    <span class="category-name">Juice</span>
                </div>
                <div class="category-card" data-category="desserts">
                    <div class="category-img-wrap">
                        <img src="images/desserts.png" alt="Dessert" loading="lazy">
                    </div>
                    <span class="category-name">Dessert</span>
                </div>
                <div class="category-card" data-category="sandwich">
                    <div class="category-img-wrap">
                        <img src="images/sandwich.png" alt="Sandwich" loading="lazy">
                    </div>
                    <span class="category-name">Sandwich</span>
                </div>
                <div class="category-card" data-category="coffee">
                    <div class="category-img-wrap">
                        <img src="images/coffee.png" alt="Coffee" loading="lazy">
                    </div>
                    <span class="category-name">Coffee</span>
                </div>
                <div class="category-card" data-category="poori">
                    <div class="category-img-wrap">
                        <img src="images/poori.png" alt="Poori" loading="lazy">
                    </div>
                    <span class="category-name">Poori</span>
                </div>
                <div class="category-card" data-category="biryani">
                    <div class="category-img-wrap">
                        <img src="images/biriyani.png" alt="Biryani" loading="lazy">
                    </div>
                    <span class="category-name">Biryani</span>
                </div>
                <div class="category-card" data-category="cakes">
                    <div class="category-img-wrap">
                        <img src="images/cake.png" alt="Cakes" loading="lazy">
                    </div>
                    <span class="category-name">Cakes</span>
                </div>
                <div class="category-card" data-category="poha">
                    <div class="category-img-wrap">
                        <img src="images/poha.png" alt="Poha" loading="lazy">
                    </div>
                    <span class="category-name">Poha</span>
                </div>
                <div class="category-card" data-category="paratha">
                    <div class="category-img-wrap">
                        <img src="images/paratha.png" alt="Paratha" loading="lazy">
                    </div>
                    <span class="category-name">Paratha</span>
                </div>
                <div class="category-card" data-category="pizza">
                    <div class="category-img-wrap">
                        <img src="images/pizza.png" alt="Pizza" loading="lazy">
                    </div>
                    <span class="category-name">Pizza</span>
                </div>
                <div class="category-card" data-category="seafood">
                    <div class="category-img-wrap">
                        <img src="images/seafood.png" alt="Sea Food" loading="lazy">
                    </div>
                    <span class="category-name">Sea Food</span>
                </div>
                <div class="category-card" data-category="chinese">
                    <div class="category-img-wrap">
                        <img src="images/chinese.png" alt="Chinese" loading="lazy">
                    </div>
                    <span class="category-name">Chinese</span>
                </div>
                <div class="category-card" data-category="thali">
                    <div class="category-img-wrap">
                        <img src="images/thali.png" alt="Thali" loading="lazy">
                    </div>
                    <span class="category-name">Thali</span>
                </div>
            </div>
        </section>

                        <!-- Recommended Section -->
        <section class="recommended-section" id="recommendedSection">
            <div class="section-header">
                <div>
                    <h2>Recommended for You</h2>
                </div>
            </div>
            <div class="recommended-scroll" id="recommendedScroll" style="display: flex; gap: var(--space-md); overflow-x: auto; padding-bottom: var(--space-sm); scrollbar-width: none; -ms-overflow-style: none;">
                <%
                    java.util.Map<Integer, String> catResMap = new java.util.HashMap<>();
                    try (java.sql.Connection conn = com.util.connection.DBConnection.getConnection();
                         java.sql.PreparedStatement ps = conn.prepareStatement("SELECT `id`, `restaurant_id` FROM `menu_categories`")) {
                        try (java.sql.ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                                catResMap.put(rs.getInt("id"), rs.getString("restaurant_id"));
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    int recCount = 0;
                    for (Dish dish : homepageDishes) {
                        // Check if this dish is in target recommended category
                        if (homepageTargetCategoryIds.contains(dish.getCategoryId())) {
                            if ("veg".equalsIgnoreCase(dietFilter) && !dish.isVeg()) continue;
                            if ("non-veg".equalsIgnoreCase(dietFilter) && dish.isVeg()) continue;
                            recCount++;
                            if (recCount > 8) break; // Limit to 8 items

                            String dishResId = catResMap.getOrDefault(dish.getCategoryId(), "restaurant1");

                            String cleanId = "rec-" + dish.getName().replace(" ", "-");
                            String dietClass = dish.isVeg() ? "veg" : "non-veg";
                            String fallbackImg = dish.isVeg() ? "images/Crunchy_veg_buger.png" : "images/spicy_zinger_burger.png";
                            String imgUrl = (dish.getImageUrl() != null && !dish.getImageUrl().trim().isEmpty()) ? dish.getImageUrl() : fallbackImg;
                %>
                            <div class="recommended-card" id="<%= cleanId %>" data-name="<%= dish.getName() %>" data-price="<%= (int)dish.getPrice() %>" data-resid="<%= dishResId %>" data-diet="<%= dietClass %>" data-rating="<%= dish.getRating() %>" style="min-width: 220px; border-radius: var(--radius-lg); overflow: hidden; background: var(--bg-card); border: 1px solid var(--border-subtle); display: flex; flex-direction: column; justify-content: space-between;">
                                <a href="menu?restaurantId=<%= dishResId %>" class="recommended-img" style="display: block; height: 140px; overflow: hidden; text-decoration: none;">
                                    <img src="<%= imgUrl %>" alt="<%= dish.getName() %>" loading="lazy" style="width:100%; height:100%; object-fit:cover;">
                                </a>
                                <a href="menu?restaurantId=<%= dishResId %>" class="recommended-info" style="display: block; text-decoration: none; color: inherit; padding: 10px 14px 4px 14px;">
                                    <div class="diet-indicator <%= dietClass %>" aria-label="<%= dietClass %>" style="margin-bottom: 4px;">
                                        <span class="diet-dot"></span>
                                    </div>
                                    <h4 style="font-size: 0.95rem; font-weight: 700; color: var(--text-primary); margin: 0 0 4px 0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><%= dish.getName() %></h4>
                                    <div class="food-rating" style="display: flex; align-items: center; gap: 4px; font-size: 0.85rem; color: var(--text-secondary);">
                                        <svg width="12" height="12" viewBox="0 0 24 24" fill="#FFB800">
                                            <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
                                        </svg>
                                        <span><%= dish.getRating() %></span>
                                        <span class="rating-count">(<%= dish.getRatingCount() %>+)</span>
                                    </div>
                                </a>
                                <div class="recommended-info" style="padding: 0 14px 12px 14px;">
                                    <div class="recommended-price-row" style="display: flex; justify-content: space-between; align-items: center; margin-top: 4px;">
                                        <span class="price" style="font-size: 1rem; font-weight: 800; color: var(--primary);">&#8377;<%= (int)dish.getPrice() %></span>
                                        <div class="homepage-qty-container" data-dish-id="<%= dish.getId() %>" data-res-id="<%= dishResId %>" style="display: inline-flex; align-items: center; justify-content: center;">
                                            <%
                                                int inCartQty = 0;
                                                Cart currentSessionCart = (Cart) session.getAttribute("cart");
                                                if (currentSessionCart != null && currentSessionCart.getItems() != null) {
                                                    for (CartItem item : currentSessionCart.getItems()) {
                                                        if (item.getDishId() == dish.getId()) {
                                                            inCartQty = item.getQuantity();
                                                            break;
                                                        }
                                                    }
                                                }
                                                if (inCartQty > 0) {
                                            %>
                                                <div style="display: flex; align-items: center; gap: 4px; background: #25C578; color: white; padding: 2px 8px; border-radius: var(--radius-sm); font-weight: 700; font-size: 0.75rem;">
                                                    <form action="CartServlet" method="POST" style="margin: 0; padding: 0; display: inline;">
                                                        <input type="hidden" name="action" value="add">
                                                        <input type="hidden" name="dishId" value="<%= dish.getId() %>">
                                                        <input type="hidden" name="restaurantId" value="<%= dishResId %>">
                                                        <input type="hidden" name="quantity" value="-1">
                                                        <input type="hidden" name="sourcePage" value="restaurants.jsp">
                                                        <button type="submit" style="background: none; border: none; color: white; font-weight: 800; cursor: pointer; font-size: 0.85rem; padding: 0 4px;">-</button>
                                                    </form>
                                                    <span><%= inCartQty %></span>
                                                    <form action="CartServlet" method="POST" style="margin: 0; padding: 0; display: inline;">
                                                        <input type="hidden" name="action" value="add">
                                                        <input type="hidden" name="dishId" value="<%= dish.getId() %>">
                                                        <input type="hidden" name="restaurantId" value="<%= dishResId %>">
                                                        <input type="hidden" name="quantity" value="1">
                                                        <input type="hidden" name="sourcePage" value="restaurants.jsp">
                                                        <button type="submit" style="background: none; border: none; color: white; font-weight: 800; cursor: pointer; font-size: 0.85rem; padding: 0 4px;">+</button>
                                                    </form>
                                                </div>
                                            <% } else { %>
                                                <form action="CartServlet" method="POST" style="margin: 0; padding: 0; display: inline;">
                                                    <input type="hidden" name="action" value="add">
                                                    <input type="hidden" name="dishId" value="<%= dish.getId() %>">
                                                    <input type="hidden" name="restaurantId" value="<%= dishResId %>">
                                                    <input type="hidden" name="quantity" value="1">
                                                    <input type="hidden" name="sourcePage" value="restaurants.jsp">
                                                    <button type="submit" class="dish-add-btn" style="background: #fff; color: #25C578; border: 1.5px solid #25C578; padding: 4px 14px; border-radius: var(--radius-sm); font-weight: 700; font-size: 0.75rem; box-shadow: 0 2px 6px rgba(0,0,0,0.08); cursor: pointer; text-transform: uppercase; letter-spacing: 0.5px; transition: all 0.2s;">ADD</button>
                                                </form>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>
                            </div>
                <%
                        }
                    }
                    if (recCount == 0) {
                %>
                    <p style="padding: 20px; color: var(--text-secondary);">No recommendations currently available.</p>
                <%
                    }
                %>
            </div>
        </section>

                        <!-- Trending Section -->
        <section class="trending-section" id="trendingSection">
            <div class="section-header">
                <h2>&#128293; Trending Now</h2>
            </div>
            <div class="trending-scroll" id="trendingScroll" style="display: flex; gap: var(--space-md); overflow-x: auto; padding-bottom: var(--space-sm); scrollbar-width: none; -ms-overflow-style: none;">
                <%
                    int trendCount = 0;
                    for (Dish dish : homepageDishes) {
                        // If dish rating is more than 4.6 show them in trending now
                        if (dish.getRating() >= 4.6) {
                            if ("veg".equalsIgnoreCase(dietFilter) && !dish.isVeg()) continue;
                            if ("non-veg".equalsIgnoreCase(dietFilter) && dish.isVeg()) continue;
                            trendCount++;
                            if (trendCount > 10) break; // Limit to 10 items

                            String dishResId = catResMap.getOrDefault(dish.getCategoryId(), "restaurant1");

                            String cleanId = "trend-" + dish.getName().replace(" ", "-");
                            String dietClass = dish.isVeg() ? "veg" : "non-veg";
                            String fallbackImg = dish.isVeg() ? "images/Crunchy_veg_buger.png" : "images/spicy_zinger_burger.png";
                            String imgUrl = (dish.getImageUrl() != null && !dish.getImageUrl().trim().isEmpty()) ? dish.getImageUrl() : fallbackImg;
                %>
                            <div class="trending-card" id="<%= cleanId %>" data-name="<%= dish.getName() %>" data-price="<%= (int)dish.getPrice() %>" data-resid="<%= dishResId %>" data-diet="<%= dietClass %>" data-rating="<%= dish.getRating() %>" style="min-width: 220px; border-radius: var(--radius-lg); overflow: hidden; background: var(--bg-card); border: 1px solid var(--border-subtle); display: flex; flex-direction: column; justify-content: space-between;">
                                <a href="menu?restaurantId=<%= dishResId %>" class="trending-img" style="display: block; height: 140px; overflow: hidden; text-decoration: none;">
                                    <img src="<%= imgUrl %>" alt="<%= dish.getName() %>" loading="lazy" style="width:100%; height:100%; object-fit:cover;">
                                </a>
                                <a href="menu?restaurantId=<%= dishResId %>" class="trending-info" style="display: block; text-decoration: none; color: inherit; padding: 10px 14px 4px 14px;">
                                    <div class="diet-indicator <%= dietClass %>" aria-label="<%= dietClass %>" style="margin-bottom: 4px;">
                                        <span class="diet-dot"></span>
                                    </div>
                                    <h4 style="font-size: 0.95rem; font-weight: 700; color: var(--text-primary); margin: 0 0 4px 0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><%= dish.getName() %></h4>
                                    <div class="food-rating" style="display: flex; align-items: center; gap: 4px; font-size: 0.85rem; color: var(--text-secondary);">
                                        <svg width="12" height="12" viewBox="0 0 24 24" fill="#FFB800">
                                            <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
                                        </svg>
                                        <span><%= dish.getRating() %></span>
                                        <span class="rating-count">(<%= dish.getRatingCount() %>+)</span>
                                    </div>
                                </a>
                                <div class="trending-info" style="padding: 0 14px 12px 14px;">
                                    <div class="trending-price-row" style="display: flex; justify-content: space-between; align-items: center; margin-top: 4px;">
                                        <span class="price" style="font-size: 1rem; font-weight: 800; color: var(--primary);">&#8377;<%= (int)dish.getPrice() %></span>
                                        <div class="homepage-qty-container" data-dish-id="<%= dish.getId() %>" data-res-id="<%= dishResId %>" style="display: inline-flex; align-items: center; justify-content: center;">
                                            <%
                                                int inCartQtyTrend = 0;
                                                Cart currentSessionCartTrend = (Cart) session.getAttribute("cart");
                                                if (currentSessionCartTrend != null && currentSessionCartTrend.getItems() != null) {
                                                    for (CartItem item : currentSessionCartTrend.getItems()) {
                                                        if (item.getDishId() == dish.getId()) {
                                                            inCartQtyTrend = item.getQuantity();
                                                            break;
                                                        }
                                                    }
                                                }
                                                if (inCartQtyTrend > 0) {
                                            %>
                                                <div style="display: flex; align-items: center; gap: 4px; background: #25C578; color: white; padding: 2px 8px; border-radius: var(--radius-sm); font-weight: 700; font-size: 0.75rem;">
                                                    <form action="CartServlet" method="POST" style="margin: 0; padding: 0; display: inline;">
                                                        <input type="hidden" name="action" value="add">
                                                        <input type="hidden" name="dishId" value="<%= dish.getId() %>">
                                                        <input type="hidden" name="restaurantId" value="<%= dishResId %>">
                                                        <input type="hidden" name="quantity" value="-1">
                                                        <input type="hidden" name="sourcePage" value="restaurants.jsp">
                                                        <button type="submit" style="background: none; border: none; color: white; font-weight: 800; cursor: pointer; font-size: 0.85rem; padding: 0 4px;">-</button>
                                                    </form>
                                                    <span><%= inCartQtyTrend %></span>
                                                    <form action="CartServlet" method="POST" style="margin: 0; padding: 0; display: inline;">
                                                        <input type="hidden" name="action" value="add">
                                                        <input type="hidden" name="dishId" value="<%= dish.getId() %>">
                                                        <input type="hidden" name="restaurantId" value="<%= dishResId %>">
                                                        <input type="hidden" name="quantity" value="1">
                                                        <input type="hidden" name="sourcePage" value="restaurants.jsp">
                                                        <button type="submit" style="background: none; border: none; color: white; font-weight: 800; cursor: pointer; font-size: 0.85rem; padding: 0 4px;">+</button>
                                                    </form>
                                                </div>
                                            <% } else { %>
                                                <form action="CartServlet" method="POST" style="margin: 0; padding: 0; display: inline;">
                                                    <input type="hidden" name="action" value="add">
                                                    <input type="hidden" name="dishId" value="<%= dish.getId() %>">
                                                    <input type="hidden" name="restaurantId" value="<%= dishResId %>">
                                                    <input type="hidden" name="quantity" value="1">
                                                    <input type="hidden" name="sourcePage" value="restaurants.jsp">
                                                    <button type="submit" class="dish-add-btn" style="background: #fff; color: #25C578; border: 1.5px solid #25C578; padding: 4px 14px; border-radius: var(--radius-sm); font-weight: 700; font-size: 0.75rem; box-shadow: 0 2px 6px rgba(0,0,0,0.08); cursor: pointer; text-transform: uppercase; letter-spacing: 0.5px; transition: all 0.2s;">ADD</button>
                                                </form>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>
                            </div>
                <%
                        }
                    }
                    if (trendCount == 0) {
                %>
                    <p style="padding: 20px; color: var(--text-secondary);">No trending items currently available.</p>
                <%
                    }
                %>
            </div>
        </section>

        <!-- Popular Restaurants Section -->
        <section class="popular-section" id="popularSection">
            <div class="section-header">
                <h2>Popular Restaurants</h2>
            </div>
            <div class="restaurants-grid" id="restaurantsGrid">
<%
    List<Restaurant> restaurantList = (List<Restaurant>) request.getAttribute("restaurantList");
		RestaurantDAOImpl restaurants = new RestaurantDAOImpl();
    if (restaurantList == null) {
        restaurantList = restaurants.getAllRestaurants();
    }
    if (restaurantList != null) {
        for(Restaurant restaurant : restaurantList){
            String cuisinesStr = restaurant.getCuisines() != null ? String.join(", ", restaurant.getCuisines()) : "";
%>  
                <div class="top-restaurant-card" id="<%= restaurant.getId() %>">
                <a href="menu?restaurantId=<%= restaurant.getId() %>" style="display: block; color: inherit; text-decoration: none;">
                    <div class="top-restaurant-img">
                        <img src="<%= restaurant.getBannerUrl() %>" alt="<%= restaurant.getName() %>" loading="lazy">
                        <% 
                            String discountTag = restaurant.getDiscountTag();
                            if (discountTag != null && !discountTag.trim().isEmpty()) {
                                discountTag = discountTag.replace("₹", "&#8377;").replace("â,¹", "&#8377;").replace("â‚¹", "&#8377;").replace("Ã¢,Â¹", "&#8377;").replace("Ã¢â€šÂ¹", "&#8377;").replace("?", "&#8377;");
                        %>
                        <span class="promo-badge"><%= discountTag %></span>
                        <% } %>
                    </div>
                </a>
                <a href="SavedServlet?restaurantId=<%= restaurant.getId() %>" class="fav-btn <%= (user != null && favoritedIds.contains(restaurant.getId())) ? "liked" : "" %>" data-id="<%= restaurant.getId() %>" aria-label="Save to favorites">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="<%= (user != null && favoritedIds.contains(restaurant.getId())) ? "currentColor" : "none" %>" stroke="currentColor" stroke-width="2">
                        <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path>
                    </svg>
                </a>
                <a href="menu?restaurantId=<%= restaurant.getId() %>" style="display: block; color: inherit; text-decoration: none;">
                    <div class="top-restaurant-info">
                        <div class="top-restaurant-header">
                            <h3><%= restaurant.getName() %></h3>
                            <div class="restaurant-rating">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="#FFB800">
                                    <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
                                </svg>
                                <span><%= restaurant.getRating() %></span>
                                <span class="rating-count">(<%= restaurant.getRatingCount() %>+)</span>
                            </div>
                        </div>
                        <p class="cuisine">
                            <%= cuisinesStr.isEmpty() ? "Multicuisine &middot; Fast Food" : cuisinesStr %>
                        </p>
                        <div class="meta-row">
                            <span>&#128338; <%= restaurant.getDeliveryTime() %></span>
                            <span>&#8377;<%= restaurant.getCostForTwo() %> for two</span>
                        </div>
                    </div>
                </a>
            </div>
            
<%

        }
    }
%>
            </div>
            <!-- Mobile/Tablet See All Button -->
            <div class="mobile-see-all-container" id="mobileSeeAllContainer" style="display: none;">
                <button class="mobile-see-all-btn" id="mobileSeeAllBtn">
                    <span>See All Restaurants</span>
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                        <polyline points="6 9 12 15 18 9"></polyline>
                    </svg>
                </button>
            </div>
        </section>

        <!-- FAQ Section -->
        <section class="faq-section" id="faqSection">
            <div class="section-header">
                <h2>Frequently Asked Questions</h2>
            </div>
            <div class="faq-accordion">
                <div class="faq-item">
                    <button class="faq-question" aria-expanded="false">
                        <span>How fast is Khaalo's delivery?</span>
                        <svg class="chevron-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                            <polyline points="6 9 12 15 18 9"></polyline>
                        </svg>
                    </button>
                    <div class="faq-answer">
                        <div class="faq-answer-content">
                            <p>Khaalo delivers appetite-inducing hot food within 25 to 35 minutes depending on the location of your chosen restaurant. You can check the estimated delivery time for each restaurant in their profile card.</p>
                        </div>
                    </div>
                </div>
                <div class="faq-item">
                    <button class="faq-question" aria-expanded="false">
                        <span>How can I track my order?</span>
                        <svg class="chevron-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                            <polyline points="6 9 12 15 18 9"></polyline>
                        </svg>
                    </button>
                    <div class="faq-answer">
                        <div class="faq-answer-content">
                            <p>Once you place your order, you will receive a tracking link in the Orders tab and via SMS. This lets you track your delivery driver from the kitchen to your doorstep in real-time.</p>
                        </div>
                    </div>
                </div>
                <div class="faq-item">
                    <button class="faq-question" aria-expanded="false">
                        <span>Is there a minimum order value?</span>
                        <svg class="chevron-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                            <polyline points="6 9 12 15 18 9"></polyline>
                        </svg>
                    </button>
                    <div class="faq-answer">
                        <div class="faq-answer-content">
                            <p>No, there is no minimum order value for ordering on Khaalo. However, orders under ₹150 may carry a small delivery fee to support our delivery partners.</p>
                        </div>
                    </div>
                </div>
                <div class="faq-item">
                    <button class="faq-question" aria-expanded="false">
                        <span>Can I pay cash on delivery (COD)?</span>
                        <svg class="chevron-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                            <polyline points="6 9 12 15 18 9"></polyline>
                        </svg>
                    </button>
                    <div class="faq-answer">
                        <div class="faq-answer-content">
                            <p>Yes, we accept Cash on Delivery (COD) as well as all major credit/debit cards, UPI, Google Pay, Net Banking, and popular digital wallets.</p>
                        </div>
                    </div>
                </div>
                <div class="faq-item">
                    <button class="faq-question" aria-expanded="false">
                        <span>How do I contact customer support?</span>
                        <svg class="chevron-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                            <polyline points="6 9 12 15 18 9"></polyline>
                        </svg>
                    </button>
                    <div class="faq-answer">
                        <div class="faq-answer-content">
                            <p>You can tap on the "Help" option in the navigation bar to chat instantly with our 24/7 customer support team or request a call back.</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

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

        <!-- Filter Modal -->
        <div class="modal-overlay" id="filterModalOverlay">
            <div class="modal-container filter-modal">
                <div class="modal-header">
                    <h2>Filters</h2>
                    <button class="modal-close" id="filterModalClose" aria-label="Close">&times;</button>
                </div>
                <div class="filter-body">
                    <div class="filter-sidebar">
                        <button class="filter-tab active" data-filter-tab="sort">Sort by<span class="filter-tab-value" id="activeSortValue">Popularity</span></button>
                        <button class="filter-tab" data-filter-tab="cuisines">Cuisines</button>
                        <button class="filter-tab" data-filter-tab="rating">Rating</button>
                        <button class="filter-tab" data-filter-tab="cost">Cost per person</button>
                    </div>
                    <div class="filter-content">
                        <div class="filter-panel active" data-filter-panel="sort">
                            <label class="filter-radio"><input type="radio" name="sort" value="popularity" checked><span class="radio-custom"></span>Popularity</label>
                            <label class="filter-radio"><input type="radio" name="sort" value="rating-htl"><span class="radio-custom"></span>Rating: High to Low</label>
                            <label class="filter-radio"><input type="radio" name="sort" value="cost-lth"><span class="radio-custom"></span>Cost: Low to High</label>
                            <label class="filter-radio"><input type="radio" name="sort" value="cost-htl"><span class="radio-custom"></span>Cost: High to Low</label>
                        </div>
                        <div class="filter-panel" data-filter-panel="cuisines">
                            <label class="filter-checkbox"><input type="checkbox" value="north-indian"><span class="checkbox-custom"></span>North Indian</label>
                            <label class="filter-checkbox"><input type="checkbox" value="south-indian"><span class="checkbox-custom"></span>South Indian</label>
                            <label class="filter-checkbox"><input type="checkbox" value="chinese"><span class="checkbox-custom"></span>Chinese</label>
                            <label class="filter-checkbox"><input type="checkbox" value="italian"><span class="checkbox-custom"></span>Italian</label>
                            <label class="filter-checkbox"><input type="checkbox" value="desserts"><span class="checkbox-custom"></span>Desserts</label>
                        </div>
                        <div class="filter-panel" data-filter-panel="rating">
                            <label class="filter-radio"><input type="radio" name="rating" value="4.5"><span class="radio-custom"></span>4.5 and above</label>
                            <label class="filter-radio"><input type="radio" name="rating" value="4.0"><span class="radio-custom"></span>4.0 and above</label>
                            <label class="filter-radio"><input type="radio" name="rating" value="3.5"><span class="radio-custom"></span>3.5 and above</label>
                        </div>
                        <div class="filter-panel" data-filter-panel="cost">
                            <label class="filter-radio"><input type="radio" name="cost" value="300"><span class="radio-custom"></span>Under ₹300</label>
                            <label class="filter-radio"><input type="radio" name="cost" value="500"><span class="radio-custom"></span>₹300 - ₹500</label>
                            <label class="filter-radio"><input type="radio" name="cost" value="1000"><span class="radio-custom"></span>₹500 - ₹1000</label>
                            <label class="filter-radio"><input type="radio" name="cost" value="1000+"><span class="radio-custom"></span>Above ₹1000</label>
                        </div>
                        </svg>
                    </button>
                    <div class="faq-answer">
                        <div class="faq-answer-content">
                            <p>Once you place your order, you will receive a tracking link in the Orders tab and via SMS. This lets you track your delivery driver from the kitchen to your doorstep in real-time.</p>
                        </div>
                    </div>
                </div>
                <div class="faq-item">
                    <button class="faq-question" aria-expanded="false">
                        <span>Is there a minimum order value?</span>
                        <svg class="chevron-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                            <polyline points="6 9 12 15 18 9"></polyline>
                        </svg>
                    </button>
                    <div class="faq-answer">
                        <div class="faq-answer-content">
                            <p>No, there is no minimum order value for ordering on Khaalo. However, orders under ₹150 may carry a small delivery fee to support our delivery partners.</p>
                        </div>
                    </div>
                </div>
                <div class="faq-item">
                    <button class="faq-question" aria-expanded="false">
                        <span>Can I pay cash on delivery (COD)?</span>
                        <svg class="chevron-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                            <polyline points="6 9 12 15 18 9"></polyline>
                        </svg>
                    </button>
                    <div class="faq-answer">
                        <div class="faq-answer-content">
                            <p>Yes, we accept Cash on Delivery (COD) as well as all major credit/debit cards, UPI, Google Pay, Net Banking, and popular digital wallets.</p>
                        </div>
                    </div>
                </div>
                <div class="faq-item">
                    <button class="faq-question" aria-expanded="false">
                        <span>How do I contact customer support?</span>
                        <svg class="chevron-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                            <polyline points="6 9 12 15 18 9"></polyline>
                        </svg>
                    </button>
                    <div class="faq-answer">
                        <div class="faq-answer-content">
                            <p>You can tap on the "Help" option in the navigation bar to chat instantly with our 24/7 customer support team or request a call back.</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

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

        <!-- Filter Modal -->
        <div class="modal-overlay" id="filterModalOverlay">
            <div class="modal-container filter-modal">
                <div class="modal-header">
                    <h2>Filters</h2>
                    <button class="modal-close" id="filterModalClose" aria-label="Close">&times;</button>
                </div>
                <div class="filter-body">
                    <div class="filter-sidebar">
                        <button class="filter-tab active" data-filter-tab="sort">Sort by<span class="filter-tab-value" id="activeSortValue">Popularity</span></button>
                        <button class="filter-tab" data-filter-tab="cuisines">Cuisines</button>
                        <button class="filter-tab" data-filter-tab="rating">Rating</button>
                        <button class="filter-tab" data-filter-tab="cost">Cost per person</button>
                    </div>
                    <div class="filter-content">
                        <div class="filter-panel active" data-filter-panel="sort">
                            <label class="filter-radio"><input type="radio" name="sort" value="popularity" checked><span class="radio-custom"></span>Popularity</label>
                            <label class="filter-radio"><input type="radio" name="sort" value="rating-htl"><span class="radio-custom"></span>Rating: High to Low</label>
                            <label class="filter-radio"><input type="radio" name="sort" value="cost-lth"><span class="radio-custom"></span>Cost: Low to High</label>
                            <label class="filter-radio"><input type="radio" name="sort" value="cost-htl"><span class="radio-custom"></span>Cost: High to Low</label>
                        </div>
                        <div class="filter-panel" data-filter-panel="cuisines">
                            <label class="filter-checkbox"><input type="checkbox" value="north-indian"><span class="checkbox-custom"></span>North Indian</label>
                            <label class="filter-checkbox"><input type="checkbox" value="south-indian"><span class="checkbox-custom"></span>South Indian</label>
                            <label class="filter-checkbox"><input type="checkbox" value="chinese"><span class="checkbox-custom"></span>Chinese</label>
                            <label class="filter-checkbox"><input type="checkbox" value="italian"><span class="checkbox-custom"></span>Italian</label>
                            <label class="filter-checkbox"><input type="checkbox" value="desserts"><span class="checkbox-custom"></span>Desserts</label>
                        </div>
                        <div class="filter-panel" data-filter-panel="rating">
                            <label class="filter-radio"><input type="radio" name="rating" value="4.5"><span class="radio-custom"></span>4.5 and above</label>
                            <label class="filter-radio"><input type="radio" name="rating" value="4.0"><span class="radio-custom"></span>4.0 and above</label>
                            <label class="filter-radio"><input type="radio" name="rating" value="3.5"><span class="radio-custom"></span>3.5 and above</label>
                        </div>
                        <div class="filter-panel" data-filter-panel="cost">
                            <label class="filter-radio"><input type="radio" name="cost" value="300"><span class="radio-custom"></span>Under ₹300</label>
                            <label class="filter-radio"><input type="radio" name="cost" value="500"><span class="radio-custom"></span>₹300 - ₹500</label>
                            <label class="filter-radio"><input type="radio" name="cost" value="1000"><span class="radio-custom"></span>₹500 - ₹1000</label>
                            <label class="filter-radio"><input type="radio" name="cost" value="1000+"><span class="radio-custom"></span>Above ₹1000</label>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button class="modal-btn-secondary" id="filterClearBtn">Clear all</button>
                    <button class="modal-btn-primary" id="filterApplyBtn">Apply</button>
                </div>
            </div>
        </div>

        <!-- Food Detail Modal -->
        <div class="modal-overlay" id="foodDetailModalOverlay">
            <div class="modal-container food-detail-modal">
                <div class="modal-header">
                    <h2 id="modalFoodName">Dish Details</h2>
                    <button class="modal-close" id="foodDetailModalClose" aria-label="Close">&times;</button>
                </div>
                <div class="food-detail-body">
                    <div class="food-detail-img-container">
                        <img id="modalFoodImg" src="" alt="Dish Image">
                    </div>
                    <div class="food-detail-content">
                        <div class="food-detail-price-row">
                            <span class="food-detail-price" id="modalFoodPrice">₹0</span>
                            <div class="food-rating" id="modalFoodRating" style="margin: 0; display: flex; align-items: center; gap: 4px;">
                            </div>
                        </div>
                        <p class="food-detail-desc" id="modalFoodDesc">Delicious food item prepared fresh.</p>
                        
                        <div class="food-detail-action-wrapper" style="display: flex; justify-content: flex-end; margin-top: 10px;">
                            <div class="dish-action-container modal-action-container" id="modalFoodAction" data-dish-name="" style="position: static; transform: none; margin: 0;">
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Search Results Overlay -->
        <div class="search-results-overlay" id="searchResultsOverlay">
            <div class="search-results-container">
                <div class="search-results-header">
                    <button class="search-results-back-btn" id="searchResultsBackBtn" aria-label="Back">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <line x1="19" y1="12" x2="5" y2="12"></line>
                            <polyline points="12 19 5 12 12 5"></polyline>
                        </svg>
                    </button>
                    <div class="search-results-title">
                        <span id="resultsSubtitleText">Showing results in Food</span>
                        <strong><span id="resultsTitleText">Noodles</span></strong>
                    </div>
                </div>
                
                <div class="search-results-tabs">
                    <button class="search-results-tab active" data-search-tab="restaurants">Restaurants</button>
                    <button class="search-results-tab" data-search-tab="dishes">Dishes</button>
                </div>
                
                <div class="search-results-content">
                    <div class="search-results-panel active" id="searchPanelRestaurants"></div>
                    <div class="search-results-panel" id="searchPanelDishes"></div>
                </div>
            </div>
        </div>

        <!-- Sign Up Modal -->
        <div class="modal-overlay" id="signUpModalOverlay" style="position: fixed; inset: 0; background: rgba(15, 23, 42, 0.75); backdrop-filter: blur(16px) saturate(180%); -webkit-backdrop-filter: blur(16px) saturate(180%); z-index: 9999999; display: none; align-items: center; justify-content: center; padding: 16px;">
            <div class="modal-container signup-modal" style="background: rgba(255, 255, 255, 0.88); backdrop-filter: blur(30px); -webkit-backdrop-filter: blur(30px); border-radius: 28px; max-width: 440px; width: 90%; padding: 32px 28px; position: relative; box-shadow: 0 30px 60px -12px rgba(0,0,0,0.35), inset 0 1px 0 rgba(255,255,255,0.9), 0 0 40px rgba(255,107,53,0.15); border: 1px solid rgba(255, 255, 255, 0.8);">
                <button type="button" class="modal-close-btn" id="signUpModalClose" onclick="window.closeSignUpModal(); return false;" style="position: absolute; top: 20px; right: 20px; width: 36px; height: 36px; border-radius: 50%; background: rgba(0, 0, 0, 0.05); border: 1px solid rgba(0, 0, 0, 0.08); font-size: 1.1rem; color: #475569; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.2s;">✕</button>
                <div class="brand-identity" style="text-align: center; margin-bottom: 20px;">
                    <div style="width: 64px; height: 64px; background: linear-gradient(135deg, #fff0eb 0%, #ffe4d6 100%); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 12px auto; font-size: 2.2rem; box-shadow: 0 8px 24px rgba(255, 107, 53, 0.2); border: 2px solid #ffffff;">
                        🍽️
                    </div>
                    <h2 style="font-size: 1.5rem; font-weight: 800; color: #0f172a; margin: 0 0 4px 0; letter-spacing: -0.5px;">Create Account</h2>
                    <p style="font-size: 0.82rem; color: #64748b; margin: 0;">Join Khaalo to order your favorite meals</p>
                </div>
                <%
                    String regError = request.getParameter("error");
                    if ("signup".equals(regError)) {
                %>
                <div style="background: rgba(239, 68, 68, 0.12); border: 1px solid rgba(239, 68, 68, 0.3); color: #dc2626; padding: 12px; border-radius: 14px; font-size: 0.85rem; font-weight: 700; margin-bottom: 16px; text-align: center; backdrop-filter: blur(10px);">
                    ⚠️ Registration failed. Email might already be registered.
                </div>
                <%
                    } else if ("admin_blocked".equals(regError)) {
                %>
                <div style="background: rgba(239, 68, 68, 0.12); border: 1px solid rgba(239, 68, 68, 0.3); color: #dc2626; padding: 12px; border-radius: 14px; font-size: 0.85rem; font-weight: 700; margin-bottom: 16px; text-align: center; backdrop-filter: blur(10px);">
                    🚫 This email is already registered with a different role. Admins must use a fresh email.
                </div>
                <%
                    }
                %>
                <form action="register" method="POST" id="signupForm" style="display: flex; flex-direction: column; gap: 14px;">
                    <input type="text" name="fullName" placeholder="Enter your full name" required style="padding: 13px 16px; border-radius: 14px; border: 1.5px solid rgba(203, 213, 225, 0.8); background: rgba(248, 250, 252, 0.8); font-family: inherit; font-size: 0.9rem; color: #0f172a; outline: none; transition: all 0.2s;">
                    <input type="email" name="email" placeholder="name@example.com" required style="padding: 13px 16px; border-radius: 14px; border: 1.5px solid rgba(203, 213, 225, 0.8); background: rgba(248, 250, 252, 0.8); font-family: inherit; font-size: 0.9rem; color: #0f172a; outline: none; transition: all 0.2s;">
                    <input type="tel" name="phone" placeholder="Enter your phone number" required style="padding: 13px 16px; border-radius: 14px; border: 1.5px solid rgba(203, 213, 225, 0.8); background: rgba(248, 250, 252, 0.8); font-family: inherit; font-size: 0.9rem; color: #0f172a; outline: none; transition: all 0.2s;">
                    <select name="role" style="padding: 13px 16px; border-radius: 14px; border: 1.5px solid rgba(203, 213, 225, 0.8); background: rgba(248, 250, 252, 0.8); font-family: inherit; font-size: 0.9rem; color: #0f172a; outline: none; transition: all 0.2s;">
                        <option value="customer" selected>Customer</option>
                        <option value="restaurant owner">Restaurant Owner</option>
                        <option value="delivery partner">Delivery Partner</option>
                        <option value="admin">Administrator</option>
                        <option value="help and support">Help & Support Agent</option>
                    </select>
                    <input type="password" name="password" placeholder="Min. 6 characters" required style="padding: 13px 16px; border-radius: 14px; border: 1.5px solid rgba(203, 213, 225, 0.8); background: rgba(248, 250, 252, 0.8); font-family: inherit; font-size: 0.9rem; color: #0f172a; outline: none; transition: all 0.2s;">
                    <div style="display: flex; align-items: flex-start; gap: 10px; margin: 4px 0; text-align: left;">
                        <input type="checkbox" id="agreeTerms" required style="width: 18px; height: 18px; accent-color: #ff6b35; cursor: pointer; border-radius: 4px; margin-top: 2px;">
                        <label for="agreeTerms" style="font-size: 0.82rem; color: #64748b; line-height: 1.4; cursor: pointer; user-select: none;">
                            I agree to the <a href="#" onclick="alert('Terms & Conditions coming soon!'); return false;" style="color: #ff6b35; text-decoration: none; font-weight: 600;">Terms of Service</a> &amp; <a href="#" onclick="alert('Privacy Policy coming soon!'); return false;" style="color: #ff6b35; text-decoration: none; font-weight: 600;">Privacy Policy</a>.
                        </label>
                    </div>
                    <button type="submit" style="padding: 14px; background: linear-gradient(135deg, #ff6b35 0%, #ea580c 100%); color: white; border: none; border-radius: 14px; font-weight: 800; font-size: 0.95rem; cursor: pointer; box-shadow: 0 8px 24px rgba(255, 107, 53, 0.4); transition: all 0.2s ease; margin-top: 4px;">Create Account</button>
                </form>
                <div style="text-align: center; margin-top: 18px; font-size: 0.88rem; color: #64748b;">
                    Already have an account? <a href="#signInModalOverlay" onclick="window.openSignInModal(); return false;" style="color: #ff6b35; font-weight: 800; text-decoration: none;">Log In</a>
                </div>
            </div>
        </div>

        <!-- Log In Modal -->
        <div class="modal-overlay" id="signInModalOverlay" style="position: fixed; inset: 0; background: rgba(15, 23, 42, 0.75); backdrop-filter: blur(16px) saturate(180%); -webkit-backdrop-filter: blur(16px) saturate(180%); z-index: 9999999; display: none; align-items: center; justify-content: center; padding: 16px;">
            <div class="modal-container signin-modal" style="background: rgba(255, 255, 255, 0.88); backdrop-filter: blur(30px); -webkit-backdrop-filter: blur(30px); border-radius: 28px; max-width: 440px; width: 90%; padding: 32px 28px; position: relative; box-shadow: 0 30px 60px -12px rgba(0,0,0,0.35), inset 0 1px 0 rgba(255,255,255,0.9), 0 0 40px rgba(255,107,53,0.15); border: 1px solid rgba(255, 255, 255, 0.8);">
                <button type="button" class="modal-close-btn" id="signInModalClose" onclick="window.closeSignInModal(); return false;" style="position: absolute; top: 20px; right: 20px; width: 36px; height: 36px; border-radius: 50%; background: rgba(0, 0, 0, 0.05); border: 1px solid rgba(0, 0, 0, 0.08); font-size: 1.1rem; color: #475569; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.2s;">✕</button>
                <div class="brand-identity" style="text-align: center; margin-bottom: 20px;">
                    <div style="width: 64px; height: 64px; background: linear-gradient(135deg, #fff0eb 0%, #ffe4d6 100%); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 12px auto; font-size: 2.2rem; box-shadow: 0 8px 24px rgba(255, 107, 53, 0.2); border: 2px solid #ffffff;">
                        🍽️
                    </div>
                    <h2 style="font-size: 1.5rem; font-weight: 800; color: #0f172a; margin: 0 0 4px 0; letter-spacing: -0.5px;">Welcome Back</h2>
                    <p style="font-size: 0.82rem; color: #64748b; margin: 0;">Log in to continue your food journey</p>
                </div>
                <%
                    String logError = request.getParameter("error");
                    if (logError != null && !"signup".equals(logError)) {
                %>
                <div style="background: rgba(239, 68, 68, 0.12); border: 1px solid rgba(239, 68, 68, 0.3); color: #dc2626; padding: 12px; border-radius: 14px; font-size: 0.85rem; font-weight: 700; margin-bottom: 16px; text-align: center; backdrop-filter: blur(10px);">
                    ⚠️ Invalid login credentials. Please try again.
                </div>
                <%
                    }
                %>
                <form action="login" method="POST" id="loginForm" style="display: flex; flex-direction: column; gap: 14px;">
                    <input type="email" name="email" placeholder="Enter your email" required style="padding: 13px 16px; border-radius: 14px; border: 1.5px solid rgba(203, 213, 225, 0.8); background: rgba(248, 250, 252, 0.8); font-family: inherit; font-size: 0.9rem; color: #0f172a; outline: none; transition: all 0.2s;">
                    <input type="password" name="password" placeholder="Enter your password" required style="padding: 13px 16px; border-radius: 14px; border: 1.5px solid rgba(203, 213, 225, 0.8); background: rgba(248, 250, 252, 0.8); font-family: inherit; font-size: 0.9rem; color: #0f172a; outline: none; transition: all 0.2s;">
                    <button type="submit" style="padding: 14px; background: linear-gradient(135deg, #ff6b35 0%, #ea580c 100%); color: white; border: none; border-radius: 14px; font-weight: 800; font-size: 0.95rem; cursor: pointer; box-shadow: 0 8px 24px rgba(255, 107, 53, 0.4); transition: all 0.2s ease; margin-top: 4px;">Log In</button>
                </form>
                <div style="text-align: center; margin-top: 18px; font-size: 0.88rem; color: #64748b;">
                    Don't have an account? <a href="#signUpModalOverlay" onclick="window.openSignUpModal(); return false;" style="color: #ff6b35; font-weight: 800; text-decoration: none;">Sign Up</a>
                </div>
            </div>
        </div>

        <!-- Spacer for bottom nav -->
        <div class="bottom-spacer"></div>

        <!-- Bottom Navigation -->
        <nav class="bottom-nav" id="bottomNav">
            <a href="restaurants.jsp" class="nav-brand-logo" style="text-decoration: none; display: flex; align-items: center; gap: 8px; color: inherit;">
                <span class="brand-logo-icon">🍽️</span>
                <div class="brand-logo-text">
                    <span class="logo-name">Khaalo</span>
                    <span class="logo-tagline">Har bhook ka solution</span>
                </div>
            </a>
            <div class="nav-items-wrapper">
                <a href="restaurants" class="nav-item active" id="navHome" aria-label="Home">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/>
                    </svg>
                    <span>Home</span>
                </a>
                <a href="saved" class="nav-item" id="navSaved" aria-label="Saved">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path>
                    </svg>
                    <span>Saved</span>
                </a>
                <a href="cart.jsp?ref=home" class="nav-item cart-nav" id="navCart" aria-label="Cart">
                    <div class="cart-icon-wrap">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z"/>
                        </svg>
                        <span class="cart-badge" style="display: none;">0</span>
                    </div>
                    <span>Cart</span>
                </a>
                <a href="help.jsp" class="nav-item" id="navHelp" aria-label="Help">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="12" cy="12" r="10"></circle>
                        <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"></path>
                        <line x1="12" y1="17" x2="12.01" y2="17"></line>
                    </svg>
                    <span>Help</span>
                </a>
                <% if (user != null) { %>
                <a href="user-details.jsp" class="nav-item" id="navProfile" aria-label="Profile">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                        <circle cx="12" cy="7" r="4"></circle>
                    </svg>
                    <span>Profile</span>
                </a>
                <% } else { %>
                <a href="#signUpModalOverlay" class="nav-item" id="navSignIn" aria-label="Sign In">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"></path>
                        <polyline points="10 17 15 12 10 7"></polyline>
                        <line x1="15" y1="12" x2="3" y2="12"></line>
                    </svg>
                    <span>Sign In</span>
                </a>
                <% } %>
            </div>

            <div class="nav-desktop-actions">
                <div class="desktop-delivery-info">
                    <span class="delivery-label" id="desktopDeliveryLabel">Delivery location</span>
                    <div class="delivery-address">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="#FF6B35">
                            <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
                        </svg>
                        <span id="desktopDeliveryAddressText">Select your location</span>
                    </div>
                </div>
                <a href="<%= (user != null) ? "user-details.jsp" : "#signUpModalOverlay" %>" class="desktop-profile-btn" id="desktopProfileBtn" aria-label="Profile">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                        <circle cx="12" cy="7" r="4"></circle>
                    </svg>
                </a>
            </div>
        </nav>

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
                <button type="button" onclick="const m=document.getElementById('cartConflictModalOverlay'); if(m){m.style.display='none'; m.classList.remove('active');} return false;" style="text-decoration: none; padding: 10px 20px; border-radius: 10px; font-weight: 700; border: 1px solid #cbd5e1; color: #475569; background: #f1f5f9; cursor: pointer; font-size: 0.85rem; display: inline-block; transition: all 0.2s;">
                    Keep Existing
                </button>
                <form action="CartServlet" method="POST" id="conflictConfirmForm" style="margin: 0; padding: 0; display: inline-block;">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="dishId" id="confirmReplaceDishId" value="<%= initialNewDish != null ? initialNewDish.getId() : "" %>">
                    <input type="hidden" name="restaurantId" id="confirmReplaceRestaurantId" value="<%= newRestaurantIdStr != null ? newRestaurantIdStr : "" %>">
                    <input type="hidden" name="confirmReplace" value="true">
                    <input type="hidden" name="quantity" value="1">
                    <input type="hidden" name="sourcePage" id="confirmReplaceSourcePage" value="restaurants.jsp">
                    <button type="submit" style="padding: 10px 20px; border-radius: 10px; font-weight: 700; border: none; color: white; background: #ff6b35; cursor: pointer; font-size: 0.85rem; box-shadow: 0 4px 12px rgba(255,107,53,0.3); transition: all 0.2s;">
                        Replace & Add
                    </button>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
