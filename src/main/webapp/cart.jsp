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
<%@ page import="com.khaalo.model.Address" %>
<%@ page import="com.khaalo.model.Dish" %>
<%@ page import="com.khaalo.model.MenuCategory" %>
<%@ page import="com.khaalo.model.Cart" %>
<%@ page import="com.khaalo.model.CartItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
    User user = (User) session.getAttribute("user");
    Cart cart = (Cart) session.getAttribute("cart");
    if (cart == null || cart.getItems() == null || cart.getItems().isEmpty()) {
        if (user != null) {
            try {
                Cart dbCart = new com.khaalo.daoimpl.CartDAOImpl().getCartByUserId(user.getId());
                if (dbCart != null && dbCart.getItems() != null && !dbCart.getItems().isEmpty()) {
                    cart = dbCart;
                    session.setAttribute("cart", cart);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    List<CartItem> cartItems = (cart != null) ? cart.getItems() : null;
    
    double subtotal = 0.0;
    if (cartItems != null) {
        for (CartItem item : cartItems) {
            subtotal += item.getDishPrice() * item.getQuantity();
        }
    }
    
    double deliveryFee = (subtotal > 0) ? 39.0 : 0.0;
    double gst = (subtotal > 0) ? Math.round(subtotal * 0.05) : 0.0;
    
    // Apply coupon discount if any
    double discount = 0.0;
    Object couponObj = session.getAttribute("appliedCoupon");
    String couponCode = null;
    if (couponObj instanceof String) {
        couponCode = (String) couponObj;
    } else if (couponObj instanceof com.khaalo.model.Coupon) {
        couponCode = ((com.khaalo.model.Coupon) couponObj).getCode();
    }

    if (couponCode != null && subtotal > 0) {
        if ("WELCOME50".equalsIgnoreCase(couponCode)) {
            discount = Math.min(subtotal * 0.50, 100.0);
        } else if ("KHAALO200".equalsIgnoreCase(couponCode)) {
            discount = Math.min(200.0, subtotal);
        } else {
            try {
                com.khaalo.model.Coupon dbCoupon = new com.khaalo.daoimpl.CouponDAOImpl().getCouponByCode(couponCode);
                if (dbCoupon != null) {
                    double disc = subtotal * (dbCoupon.getDiscountPercent() / 100.0);
                    if (dbCoupon.getMaxDiscount() > 0) {
                        disc = Math.min(disc, dbCoupon.getMaxDiscount());
                    }
                    discount = disc;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    double grandTotal = Math.max(0.0, subtotal + deliveryFee + gst - discount);

    String restaurantId = "";
    String restaurantName = "Secure Checkout";
    String deliveryTime = "25-35";
    if (cartItems != null && !cartItems.isEmpty()) {
        CartItem firstItem = cartItems.get(0);
        try {
            com.khaalo.daoimpl.MenuDAOImpl menuDAO = new com.khaalo.daoimpl.MenuDAOImpl();
            Dish dish = menuDAO.getDishById(firstItem.getDishId());
            if (dish != null) {
                MenuCategory category = menuDAO.getMenuCategoryById(dish.getCategoryId());
                if (category != null) {
                    restaurantId = category.getRestaurantId();
                    Restaurant r = new RestaurantDAOImpl().getRestaurantById(restaurantId);
                    if (r != null) {
                        restaurantName = r.getName();
                        deliveryTime = r.getDeliveryTime();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    if (restaurantId == null || restaurantId.trim().isEmpty()) {
        String sessionResId = (String) session.getAttribute("restaurantId");
        if (sessionResId != null && !sessionResId.trim().isEmpty()) {
            restaurantId = sessionResId;
        }
    }

    String refParam = request.getParameter("ref");
    String sourcePageParam = request.getParameter("sourcePage");
    String refererHeader = request.getHeader("Referer");
    String backTarget = "restaurants.jsp";

    if ("home".equalsIgnoreCase(refParam) || "restaurants.jsp".equalsIgnoreCase(sourcePageParam)) {
        backTarget = "restaurants.jsp";
    } else if ("menu".equalsIgnoreCase(refParam)) {
        if (restaurantId != null && !restaurantId.trim().isEmpty()) {
            backTarget = "menu?restaurantId=" + restaurantId;
        } else {
            backTarget = "restaurants.jsp";
        }
    } else if (refererHeader != null && (refererHeader.contains("menu") || refererHeader.contains("restaurantId="))) {
        if (restaurantId != null && !restaurantId.trim().isEmpty()) {
            backTarget = "menu?restaurantId=" + restaurantId;
        } else {
            backTarget = "restaurants.jsp";
        }
    } else {
        backTarget = "restaurants.jsp";
    }

    // 1. Fetch all dishes from database (to be filtered in the JSP body loops)
    List<Dish> allDishes = new ArrayList<>();
    try {
        allDishes = new com.khaalo.daoimpl.MenuDAOImpl().getAllDishes();
        // Sort by rating descending to emulate ORDER BY rating DESC
        allDishes.sort((d1, d2) -> Double.compare(d2.getRating(), d1.getRating()));
    } catch (Exception e) {
        e.printStackTrace();
    }

    // 2. Build target category IDs based on current cart items and past user orders
    java.util.Set<Integer> targetCategoryIds = new java.util.HashSet<>();
    if (cartItems != null) {
        try {
            com.khaalo.daoimpl.MenuDAOImpl menuDAO = new com.khaalo.daoimpl.MenuDAOImpl();
            for (CartItem ci : cartItems) {
                Dish dish = menuDAO.getDishById(ci.getDishId());
                if (dish != null) {
                    targetCategoryIds.add(dish.getCategoryId());
                }
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
    <title>Secure Checkout & Cart | Khaalo</title>
    <meta name="description" content="Review your order, customize dishes, coordinate group orders, and proceed to payment. Fast delivery with real-time tracking.">
    <meta name="theme-color" content="#1a1a2e">

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <!-- Khaalo Micro-Animations & JS Engines -->
    <link rel="stylesheet" href="css/animations.css">
    <script src="js/cart-app.js?v=<%= System.currentTimeMillis() %>" defer></script>
    <script src="js/floating-cart.js?v=<%= System.currentTimeMillis() %>" defer></script>
    <script src="js/live-search.js?v=<%= System.currentTimeMillis() %>" defer></script>

    <!-- Inline Styles (Restaurants CSS embedded to ensure self-contained file) -->
    <style>
        /* ============================================
           KHAALO - Food Delivery App Styles
           Har Bhook Ka Solution
           ============================================ */

        :root {
            --primary: #FF6B35;
            --primary-dark: #E85D2C;
            --primary-light: #FF8A5C;
            --primary-glow: rgba(255, 107, 53, 0.35);

            --secondary: #2C1B10;
            --secondary-light: #3D291C;

            --accent: #FFB800;
            --accent-light: #FFD54F;

            --bg-primary: #FFF9F2;
            --bg-secondary: #FFF3E0;
            --bg-card: #FFFFFF;
            --bg-card-hover: #FFFDF9;
            --bg-surface: #FFEEDD;
            --bg-glass: rgba(255, 255, 255, 0.88);
            --bg-glass-light: rgba(255, 107, 53, 0.06);
            --bg-body: #FFFDFB;

            --text-primary: #2C1B10;
            --text-secondary: #5C4333;
            --text-muted: #8E796A;
            --text-accent: #FF6B35;

            --border-subtle: rgba(255, 107, 53, 0.12);
            --border-active: rgba(255, 107, 53, 0.5);

            --shadow-sm: 0 2px 8px rgba(0, 0, 0, 0.05);
            --shadow-md: 0 4px 20px rgba(0, 0, 0, 0.08);
            --shadow-lg: 0 8px 40px rgba(0, 0, 0, 0.12);
            --shadow-glow: 0 4px 30px var(--primary-glow);

            --space-xs: 4px;
            --space-sm: 8px;
            --space-md: 16px;
            --space-lg: 24px;
            --space-xl: 32px;
            --space-2xl: 48px;

            --radius-sm: 6px;
            --radius-md: 12px;
            --radius-lg: 18px;
            --radius-xl: 24px;
            --radius-full: 9999px;

            --transition-fast: 0.15s ease;
            --transition-base: 0.25s ease;
            --transition-slow: 0.4s ease;
        }

        /* Custom Zero-JS Selection styles */
        .instr-pill {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 16px;
            border: 1.5px solid var(--border-subtle);
            border-radius: 20px;
            font-size: 0.82rem;
            font-weight: 600;
            color: var(--text-secondary);
            background: #fff9e6;
            transition: all 0.2s;
            cursor: pointer;
        }
        .instr-pill-label input:checked + .instr-pill {
            background: #fff0eb !important;
            border-color: var(--primary) !important;
            color: var(--primary) !important;
            box-shadow: 0 2px 8px rgba(255, 107, 53, 0.2);
        }
        .address-option-label input:checked + .address-option-card {
            border-color: var(--primary) !important;
            background: #fff0eb !important;
            box-shadow: 0 4px 12px rgba(255, 118, 84, 0.15);
        }
        .instr-pill-label, .address-option-label {
            -webkit-tap-highlight-color: transparent;
        }
        .avail-coupon-item:hover, .address-option-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(0,0,0,0.05);
        }

        body.cart-body-page {
            background:
                radial-gradient(ellipse at 20% 0%, rgba(255, 170, 50, 0.15) 0%, transparent 55%),
                radial-gradient(ellipse at 80% 10%, rgba(255, 120, 30, 0.1) 0%, transparent 50%),
                radial-gradient(ellipse at 50% 60%, rgba(255, 180, 50, 0.08) 0%, transparent 60%),
                radial-gradient(ellipse at 90% 90%, rgba(255, 160, 50, 0.05) 0%, transparent 50%),
                linear-gradient(175deg, #FFFDF9 0%, #FFF5E6 30%, #FFE5CC 60%, #FFD9B3 100%);
            background-attachment: fixed;
            color: var(--text-primary);
            min-height: 100vh;
            padding-top: 80px;
            font-family: 'Outfit', 'Poppins', sans-serif;
            margin: 0;
        }
        
        /* === Empty Cart Page Styles === */
        .empty-cart-state {
            max-width: 500px;
            margin: 80px auto;
            text-align: center;
            padding: var(--space-xl);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            background: var(--bg-card);
            border-radius: var(--radius-xl);
            border: 1px solid var(--border-subtle);
            box-shadow: var(--shadow-md);
        }

        .empty-graphic {
            font-size: 5rem;
            margin-bottom: var(--space-md);
            filter: drop-shadow(0 8px 16px rgba(255, 107, 53, 0.15));
            animation: floatSlow 3s ease-in-out infinite;
        }

        .empty-state-btn {
            background: var(--primary);
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: white;
            border: none;
            padding: 14px 36px;
            font-weight: 800;
            font-size: 0.95rem;
            border-radius: var(--radius-md);
            cursor: pointer;
            margin-top: var(--space-md);
            box-shadow: 0 4px 15px var(--primary-glow);
            transition: all var(--transition-base);
            font-family: inherit;
        }

        .empty-state-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px var(--primary-glow);
            background: var(--primary-dark);
        }

        .empty-state-btn:active {
            transform: translateY(0);
        }

        @keyframes floatSlow {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-8px); }
        }

        .cart-header {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 70px;
            background: var(--bg-card);
            border-bottom: 1px solid var(--border-subtle);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 0;
            z-index: 1000;
            backdrop-filter: blur(8px);
        }

        .cart-header-container {
            max-width: 1200px;
            width: 100%;
            margin: 0 auto;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 var(--space-xl);
            box-sizing: border-box;
        }

        .cart-header-left {
            display: flex;
            align-items: center;
            gap: var(--space-md);
        }

        .cart-back-btn {
            background: none;
            border: none;
            color: var(--text-primary);
            cursor: pointer;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all var(--transition-fast);
        }

        .cart-back-btn:hover {
            background: var(--bg-surface);
            color: var(--primary);
        }

        .cart-res-name {
            font-size: 1.15rem;
            font-weight: 800;
            color: var(--text-primary);
            margin: 0;
            line-height: 1.2;
        }

        .cart-res-meta {
            font-size: 0.8rem;
            color: var(--text-muted);
            margin: 2px 0 0;
        }

        .secure-checkout-tag {
            font-size: 0.8rem;
            font-weight: 700;
            color: var(--text-muted);
            border: 1px dashed var(--border-subtle);
            padding: 6px 12px;
            border-radius: var(--radius-md);
            letter-spacing: 1px;
        }

        .cart-main-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: var(--space-xl) var(--space-xl) var(--space-2xl);
            box-sizing: border-box;
        }

        .cart-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: var(--space-xl);
            align-items: start;
        }

        .cart-col-left, .cart-col-right {
            display: flex;
            flex-direction: column;
            gap: var(--space-xl);
            min-width: 0;
        }

        .cart-card {
            background: var(--bg-card);
            border-radius: var(--radius-xl);
            padding: var(--space-xl);
            border: 1px solid var(--border-subtle);
            box-shadow: var(--shadow-sm);
            transition: box-shadow var(--transition-base);
            box-sizing: border-box;
        }

        .cart-card:hover {
            box-shadow: var(--shadow-md);
        }

        .cart-card-title {
            font-size: 1.15rem;
            font-weight: 800;
            color: var(--text-primary);
            margin-bottom: var(--space-lg);
            margin-top: 0;
            position: relative;
            padding-left: 12px;
        }

        .cart-card-title::before {
            content: '';
            position: absolute;
            left: 0;
            top: 3px;
            bottom: 3px;
            width: 4px;
            background: var(--primary);
            border-radius: var(--radius-full);
        }

        .cart-items-list {
            display: flex;
            flex-direction: column;
        }

        .cart-item-row {
            display: flex;
            align-items: center;
            padding: 16px 0;
            border-bottom: 1px solid var(--border-subtle);
        }

        .cart-item-row:last-child {
            border-bottom: none;
        }

        .item-diet-indicator {
            width: 14px;
            height: 14px;
            border-radius: 3px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 12px;
            flex-shrink: 0;
        }

        .item-diet-indicator.is-veg {
            border: 1.5px solid #25C578;
        }
        .item-diet-indicator.is-veg::after {
            content: '';
            width: 6px;
            height: 6px;
            background: #25C578;
            border-radius: 50%;
        }

        .item-diet-indicator.is-nonveg {
            border: 1.5px solid #E23744;
        }
        .item-diet-indicator.is-nonveg::after {
            content: '';
            width: 0;
            height: 0;
            border-left: 3.5px solid transparent;
            border-right: 3.5px solid transparent;
            border-bottom: 7px solid #E23744;
        }

        .item-details-block {
            flex-grow: 1;
            min-width: 0;
            padding-right: var(--space-md);
        }

        .cart-item-name {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--text-primary);
        }

        .item-customization-summary {
            font-size: 0.76rem;
            color: var(--text-muted);
            margin-top: 4px;
        }

        .item-action-block {
            display: flex;
            align-items: center;
            gap: var(--space-lg);
        }

        .qty-control-btn-wrap {
            display: flex;
            align-items: center;
            border: 1px solid var(--border-subtle);
            background: var(--bg-body);
            border-radius: var(--radius-md);
            padding: 2px;
        }

        .qty-btn {
            background: none;
            border: none;
            color: var(--primary);
            width: 28px;
            height: 28px;
            font-weight: 800;
            font-size: 1rem;
            cursor: pointer;
            border-radius: var(--radius-sm);
        }

        .qty-btn:hover {
            background: var(--bg-surface);
        }

        .qty-value {
            font-size: 0.9rem;
            font-weight: 700;
            width: 20px;
            text-align: center;
        }

        .item-price-block {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--text-primary);
            min-width: 60px;
            text-align: right;
        }

        .add-more-items-btn {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 100%;
            background: var(--bg-secondary);
            border: 1px dashed var(--primary);
            border-radius: var(--radius-md);
            color: var(--primary);
            padding: 12px;
            font-family: inherit;
            font-size: 0.85rem;
            font-weight: 700;
            cursor: pointer;
            margin-top: var(--space-md);
            transition: all var(--transition-fast);
        }

        .add-more-items-btn:hover {
            background: var(--bg-surface);
        }

        .collab-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .collab-subtitle {
            font-size: 0.8rem;
            color: var(--text-muted);
            margin: 2px 0 0;
        }

        .collab-action-btn {
            background: var(--primary);
            color: white;
            border: none;
            border-radius: var(--radius-md);
            padding: 8px 16px;
            font-weight: 700;
            font-size: 0.85rem;
            cursor: pointer;
        }

        .addons-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: var(--space-md);
        }

        .addon-card {
            border: 1px solid var(--border-subtle);
            border-radius: var(--radius-md);
            padding: var(--space-md);
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: var(--bg-body);
        }

        .addon-info h4 {
            margin: 0 0 4px 0;
            font-size: 0.88rem;
            font-weight: 700;
            color: var(--text-primary);
        }

        .addon-price {
            font-size: 0.82rem;
            color: var(--primary);
            font-weight: 700;
        }

        .addon-add-btn {
            background: var(--bg-card);
            border: 1px solid var(--primary);
            color: var(--primary);
            border-radius: var(--radius-sm);
            padding: 6px 14px;
            font-weight: 800;
            font-size: 0.78rem;
            cursor: pointer;
        }

        .addon-add-btn:hover {
            background: var(--primary);
            color: white;
        }

        .instruction-pills {
            display: flex;
            flex-wrap: wrap;
            gap: var(--space-sm);
            margin-bottom: var(--space-md);
        }

        .schedule-header {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .schedule-icon {
            font-size: 1.5rem;
        }

        .schedule-title {
            margin: 0;
            font-size: 0.95rem;
            font-weight: 700;
        }

        .schedule-desc {
            margin: 2px 0 0;
            font-size: 0.78rem;
            color: var(--text-muted);
        }

        .switch {
            position: relative;
            display: inline-block;
            width: 44px;
            height: 24px;
            margin-left: auto;
        }

        .switch input {
            opacity: 0;
            width: 0;
            height: 0;
        }

        .slider {
            position: absolute;
            cursor: pointer;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: var(--border-subtle);
            transition: .4s;
        }

        .slider:before {
            position: absolute;
            content: "";
            height: 16px;
            width: 16px;
            left: 4px;
            bottom: 4px;
            background-color: white;
            transition: .4s;
        }

        input:checked + .slider {
            background-color: var(--primary);
        }

        input:checked + .slider:before {
            transform: translateX(20px);
        }

        .slider.round {
            border-radius: 34px;
        }

        .slider.round:before {
            border-radius: 50%;
        }

        .bill-summary-card {
            background: var(--bg-card);
            border: 1.5px solid var(--border-subtle);
        }

        .bill-row {
            display: flex;
            justify-content: space-between;
            font-size: 0.88rem;
            color: var(--text-secondary);
            margin-bottom: var(--space-sm);
        }

        .bill-divider {
            border: none;
            border-top: 1px dashed var(--border-subtle);
            margin: var(--space-md) 0;
        }

        .grand-total-row {
            font-size: 1.05rem;
            font-weight: 800;
            color: var(--text-primary);
            margin-bottom: 0;
        }

        .checkout-btn {
            background: var(--primary);
            color: white;
            border: none;
            border-radius: var(--radius-md);
            padding: 14px;
            font-family: inherit;
            font-size: 0.95rem;
            font-weight: 800;
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: background var(--transition-fast);
        }

        .checkout-btn:hover {
            background: var(--primary-dark);
        }

        @media screen and (max-width: 992px) {
            .cart-grid {
                grid-template-columns: 1fr;
            }
            .cart-main-content {
                max-width: 680px;
                margin: 0 auto;
            }
        }

        @media screen and (max-width: 576px) {
            body.cart-body-page {
                padding-top: 70px;
            }
            .cart-header-container {
                padding: 0 var(--space-md);
            }
            .cart-main-content {
                padding: var(--space-md) var(--space-md) var(--space-2xl);
            }
            .addons-grid {
                grid-template-columns: 1fr;
            }
        }

        /* === Payment Method Grid (Warm Theme - Equal Height Boxes) === */
        .payment-methods-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 14px;
            margin-top: 14px;
            align-items: stretch;
        }

        @media (max-width: 640px) {
            .payment-methods-grid {
                grid-template-columns: 1fr;
            }
        }

        .payment-card-label {
            display: flex;
            flex-direction: column;
            cursor: pointer;
            margin: 0;
            height: 100%;
        }

        .payment-card-input {
            position: absolute;
            opacity: 0;
            width: 0;
            height: 0;
        }

        .payment-card-box {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 16px;
            background: var(--bg-surface, #ffffff);
            border: 1.5px solid var(--border-subtle, #e2e8f0);
            border-radius: 14px;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            height: 100%;
            min-height: 94px;
            box-sizing: border-box;
        }

        .payment-card-input:checked + .payment-card-box {
            border-color: var(--primary, #ff6b35);
            background: #fff8f5;
            box-shadow: 0 4px 16px rgba(255, 107, 53, 0.12);
        }

        .payment-card-box:hover {
            border-color: #cbd5e1;
            transform: translateY(-1px);
        }

        .payment-card-input:checked + .payment-card-box:hover {
            border-color: var(--primary, #ff6b35);
        }

        .payment-icon-wrap {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .payment-icon-upi {
            background: #fff0eb;
            color: var(--primary, #ff6b35);
        }

        .payment-icon-card {
            background: #eff6ff;
            color: #2563eb;
        }

        .payment-icon-cod {
            background: #ecfdf5;
            color: #059669;
        }

        .payment-icon-net {
            background: #f5f3ff;
            color: #7c3aed;
        }

        .payment-card-info {
            display: flex;
            flex-direction: column;
            flex-grow: 1;
            justify-content: center;
        }

        .payment-card-title {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--text-primary, #0f172a);
            margin-bottom: 2px;
        }

        .payment-card-desc {
            font-size: 0.78rem;
            color: var(--text-secondary, #475569);
            line-height: 1.3;
        }

        .payment-radio-indicator {
            width: 18px;
            height: 18px;
            border-radius: 50%;
            border: 2px solid #cbd5e1;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            transition: all 0.2s ease;
        }

        .payment-card-input:checked + .payment-card-box .payment-radio-indicator {
            border-color: var(--primary, #ff6b35);
            background: var(--primary, #ff6b35);
        }

        .payment-card-input:checked + .payment-card-box .payment-radio-indicator::after {
            content: '';
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: #ffffff;
        }
    </style>
</head>
<body class="cart-body-page">

    <!-- Top Navigation Header -->
    <header class="cart-header">
        <div class="cart-header-container">
            <div class="cart-header-left">
                <a href="<%= backTarget %>" class="cart-back-btn" aria-label="Back to Restaurant Menu" style="text-decoration: none; display: flex; align-items: center; justify-content: center;">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <line x1="19" y1="12" x2="5" y2="12"></line>
                        <polyline points="12 19 5 12 12 5"></polyline>
                    </svg>
                </a>
                <div class="cart-res-details" id="cartResHeaderDetails">
                    <h1 class="cart-res-name" id="headerResName"><%= restaurantName %></h1>
                    <p class="cart-res-meta" id="headerResMeta">&#9200; <%= deliveryTime %> min delivery</p>
                </div>
            </div>
            <div class="cart-header-right">
                <span class="secure-checkout-tag">🔒 SECURE CHECKOUT</span>
            </div>
        </div>
    </header>

    <% boolean isCartEmpty = (cartItems == null || cartItems.isEmpty()); %>
    <!-- Empty State -->
    <main class="empty-cart-state" id="emptyCartState" style="padding: var(--space-xl) var(--space-lg); display: <%= isCartEmpty ? "flex" : "none" %>; flex-direction: column; align-items: center;">
        <div class="empty-graphic" style="font-size: 4rem; margin-bottom: var(--space-md); filter: drop-shadow(0 4px 10px rgba(0,0,0,0.05));">🛒</div>
        <h2 style="font-size: 1.5rem; font-weight: 800; color: var(--text-primary); margin-bottom: var(--space-xs);">Your Cart is Empty</h2>
        <p style="font-size: 0.95rem; color: var(--text-secondary); margin-bottom: var(--space-xl); max-width: 320px; line-height: 1.5; text-align: center;">Looks like you haven't added anything to your cart yet. Let's find some delicious meals!</p>
        <a href="restaurants.jsp" class="empty-state-btn" style="margin-bottom: var(--space-2xl); text-decoration: none; display: inline-block;">Explore Restaurants</a>
    </main>

    <!-- Main Content Section -->
    <main class="cart-main-content" id="cartMainContent" style="display: <%= isCartEmpty ? "none" : "block" %>;">
        <div class="cart-grid">
            
            <!-- Left Column: Items and Collaborations -->
            <div class="cart-col-left">
                
                <!-- Selected Items List Card -->
                <div class="cart-card">
                    <h2 class="cart-card-title">Selected Items</h2>
                    <div class="cart-items-list" id="cartItemsList">
                        <% 
                            com.khaalo.daoimpl.MenuDAOImpl cartMenuDAO = new com.khaalo.daoimpl.MenuDAOImpl();
                            for (CartItem item : cartItems) { 
                                Dish itemDish = null;
                                try {
                                    itemDish = cartMenuDAO.getDishById(item.getDishId());
                                } catch (Exception ignored) {}
                                boolean isItemVeg = (itemDish != null) ? itemDish.isVeg() : true;
                        %>
                            <div class="cart-item-row" data-dish-id="<%= item.getDishId() %>" data-unit-price="<%= (int)item.getDishPrice() %>" style="flex-direction: column; align-items: stretch; gap: 8px;">
                                <div style="display: flex; align-items: center; width: 100%;">
                                    <div class="item-diet-indicator <%= isItemVeg ? "is-veg" : "is-nonveg" %>" title="<%= isItemVeg ? "Vegetarian" : "Non-Vegetarian" %>"></div>
                                    <div class="item-details-block">
                                        <div class="item-name-row">
                                            <span class="cart-item-name"><%= item.getDishName() %></span>
                                        </div>
                                    </div>
                                    <div class="item-action-block">
                                        <div class="qty-control-btn-wrap">
                                            <form action="CartServlet" method="POST" style="display:inline; margin:0; padding:0;">
                                                <input type="hidden" name="action" value="add">
                                                <input type="hidden" name="dishId" value="<%= item.getDishId() %>">
                                                <input type="hidden" name="quantity" value="-1">
                                                <button type="submit" class="qty-btn minus-btn">-</button>
                                            </form>
                                            <span class="qty-value"><%= item.getQuantity() %></span>
                                            <form action="CartServlet" method="POST" style="display:inline; margin:0; padding:0;">
                                                <input type="hidden" name="action" value="add">
                                                <input type="hidden" name="dishId" value="<%= item.getDishId() %>">
                                                <input type="hidden" name="quantity" value="1">
                                                <button type="submit" class="qty-btn plus-btn">+</button>
                                            </form>
                                        </div>
                                        <div class="item-price-block">
                                            ₹<%= (int)(item.getDishPrice() * item.getQuantity()) %>
                                        </div>
                                    </div>
                                </div>
                                <!-- Customize Option Below Dish Name (max 30 chars) -->
                                <div style="margin-left: 26px;">
                                    <form action="CartServlet" method="POST" style="display: flex; gap: 8px; align-items: center; margin: 0; padding: 0;">
                                        <input type="hidden" name="action" value="update">
                                        <input type="hidden" name="dishId" value="<%= item.getDishId() %>">
                                        <input type="text" name="customizations" placeholder="Customize (max 30 chars)..." maxlength="30" value="<%= (item.getCustomizations() != null) ? item.getCustomizations() : "" %>" style="padding: 4px 8px; border-radius: 6px; border: 1px solid var(--border-subtle); font-size: 0.78rem; font-family: inherit; width: 180px; box-sizing: border-box; background: var(--bg-body); color: var(--text-primary);">
                                        <button type="submit" style="padding: 4px 10px; border-radius: 6px; background: var(--primary); color: white; border: none; font-size: 0.75rem; font-weight: 700; cursor: pointer; font-family: inherit;">Save</button>
                                    </form>
                                </div>
                            </div>
                        <% } %>
                    </div>
                    <a href="<%= backTarget %>" class="add-more-items-btn" style="text-decoration: none; display: flex; align-items: center; justify-content: center;">
                        <span>➕ Add more items from menu</span>
                    </a>
                </div>

                <!-- Collaborative Cart / Split Bill Panel -->
                <div class="cart-card collab-card">
                    <div class="collab-header">
                        <div>
                            <h2 class="cart-card-title" style="margin-bottom: 4px;">Collaborative Cart</h2>
                            <p class="collab-subtitle">Let friends add items from their own phones in real-time!</p>
                        </div>
                        <button class="collab-action-btn" id="toggleCollabBtn">Start Session</button>
                    </div>

                    <!-- Collaborative Active State -->
                    <div class="collab-active-area" id="collabActiveArea" style="display: none;">
                        <div class="collab-link-row">
                            <span class="collab-link-label">Share Joint Code:</span>
                            <div class="collab-code-wrap">
                                <span class="collab-code-text" id="collabSessionCode">KHAALO-5829</span>
                                <button class="collab-copy-btn" id="copyCollabCodeBtn">Copy Link</button>
                            </div>
                        </div>

                        <!-- Active Users Grid -->
                        <div class="collab-users-grid" id="collabUsersGrid">
                            <div class="collab-user-pill host">
                                <span class="collab-avatar-dot" style="background-color: var(--primary);"></span>
                                <span class="collab-user-name">You (Host)</span>
                            </div>
                        </div>

                        <!-- Collaborative Simulator Log -->
                        <div class="collab-sim-log" id="collabSimLog">
                            <div class="collab-log-entry system">Session started. Invite friends to join.</div>
                        </div>

                        <!-- Split Bill Toggle -->
                        <div class="split-bill-section">
                            <label class="split-toggle-row">
                                <input type="checkbox" id="splitBillCheckbox">
                                <span class="split-toggle-custom"></span>
                                <div>
                                    <span class="split-toggle-title">Split Bill Proportionally</span>
                                    <span class="split-toggle-desc">Auto-calculate per-person split based on items added.</span>
                                </div>
                            </label>
                            <div class="split-breakdown-box" id="splitBreakdownBox" style="display: none;">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Suggested Add-ons Section (Recommended) -->
                <div class="cart-card">
                    <h2 class="cart-card-title">Suggested Add-ons</h2>
                    <div class="addons-grid" id="addonsGrid">
                        <%
                            int recCount = 0;
                            for (Dish dish : allDishes) {
                                boolean alreadyInCart = false;
                                if (cartItems != null) {
                                    for (CartItem ci : cartItems) {
                                        if (ci.getDishId() == dish.getId()) {
                                            alreadyInCart = true;
                                            break;
                                        }
                                    }
                                }
                                if (targetCategoryIds.contains(dish.getCategoryId()) && !alreadyInCart) {
                                    recCount++;
                                    if (recCount > 4) break;
                        %>
                                <div class="addon-card">
                                    <div class="addon-info">
                                        <h4><%= dish.getName() %></h4>
                                        <div class="addon-price">₹<%= (int)dish.getPrice() %></div>
                                    </div>
                                    <form action="CartServlet" method="POST" style="margin: 0; padding: 0;">
                                        <input type="hidden" name="action" value="add">
                                        <input type="hidden" name="dishId" value="<%= dish.getId() %>">
                                        <input type="hidden" name="quantity" value="1">
                                        <button type="submit" class="addon-add-btn">ADD</button>
                                    </form>
                                </div>
                        <%
                                }
                            }
                            if (recCount == 0) {
                        %>
                            <p style="font-size: 0.85rem; color: var(--text-secondary);">No recommended add-ons at this time.</p>
                        <%
                            }
                        %>
                    </div>
                </div>

                <!-- Frequently Ordered Dishes & Trending Searches Section (Trending Now) -->
                <div class="cart-card">
                    <h2 class="cart-card-title">Frequently Ordered & Trending</h2>
                    <p style="font-size: 0.82rem; color: var(--text-secondary); margin-bottom: var(--space-md); margin-top: -8px;">Dishes most frequently ordered with your selection</p>
                    <div class="horizontal-scroll-suggestions" id="horizontalSuggestions" style="display: flex; gap: var(--space-md); overflow-x: auto; padding-bottom: var(--space-sm); scrollbar-width: none; -ms-overflow-style: none;">
                        <%
                            int trendCount = 0;
                            for (Dish dish : allDishes) {
                                if (dish.getRating() >= 4.6) {
                                    trendCount++;
                                    if (trendCount > 10) break;

                                    String fallbackImg = dish.isVeg() ? 
                                        "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=120&h=80&fit=crop" : 
                                        "https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=120&h=80&fit=crop";
                                    String imgUrl = (dish.getImageUrl() != null && !dish.getImageUrl().trim().isEmpty()) ? dish.getImageUrl() : fallbackImg;
                        %>
                                <div class="suggestion-scroll-card" style="flex: 0 0 160px; background: var(--bg-secondary); border: 1.5px solid var(--border-subtle); border-radius: 12px; padding: var(--space-sm); text-align: center; display: flex; flex-direction: column; justify-content: space-between; align-items: center; min-height: 160px;">
                                    <img src="<%= imgUrl %>" alt="<%= dish.getName() %>" style="width: 100%; height: 80px; object-fit: cover; border-radius: 8px; margin-bottom: 8px;">
                                    <h4 style="font-size: 0.85rem; font-weight: 700; margin: 0 0 4px; color: var(--text-primary); text-overflow: ellipsis; white-space: nowrap; overflow: hidden; width: 100%;"><%= dish.getName() %></h4>
                                    <div style="display: flex; width: 100%; justify-content: space-between; align-items: center; margin-top: auto; padding-top: 4px; width: 100%;">
                                        <span style="font-size: 0.85rem; font-weight: 700; color: var(--primary);">₹<%= (int)dish.getPrice() %></span>
                                        <form action="CartServlet" method="POST" style="margin: 0; padding: 0;">
                                            <input type="hidden" name="action" value="add">
                                            <input type="hidden" name="dishId" value="<%= dish.getId() %>">
                                            <input type="hidden" name="quantity" value="1">
                                            <button type="submit" class="addon-add-btn" style="padding: 4px 10px; font-size: 0.7rem; border-radius: 6px;">ADD</button>
                                        </form>
                                    </div>
                                </div>
                        <%
                                }
                            }
                            if (trendCount == 0) {
                        %>
                            <p style="font-size: 0.85rem; color: var(--text-secondary);">No trending items at this time.</p>
                        <%
                            }
                        %>
                    </div>
                </div>

                <!-- Payment Method Selection Card (Below Frequently Ordered & Trending) -->
                <div class="cart-card">
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 4px;">
                        <span style="width: 24px; height: 24px; border-radius: 50%; background: var(--primary, #ff6b35); color: white; display: flex; align-items: center; justify-content: center; font-size: 0.8rem; font-weight: 800;">💳</span>
                        <h2 class="cart-card-title" style="margin: 0;">Payment Method</h2>
                    </div>
                    <p style="font-size: 0.82rem; color: var(--text-secondary); margin-bottom: 16px; margin-top: 2px;">Select your preferred mode of payment</p>

                    <div class="payment-methods-grid">
                        <!-- 1. UPI Payment -->
                        <label class="payment-card-label">
                            <input type="radio" name="paymentMethod" value="UPI Payment" class="payment-card-input" form="checkoutForm" checked required>
                            <div class="payment-card-box">
                                <div class="payment-icon-wrap payment-icon-upi">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                                        <rect x="5" y="2" width="14" height="20" rx="2" ry="2"></rect>
                                        <line x1="12" y1="18" x2="12.01" y2="18"></line>
                                    </svg>
                                </div>
                                <div class="payment-card-info">
                                    <span class="payment-card-title">UPI Payment</span>
                                    <span class="payment-card-desc">Google Pay, PhonePe, Paytm or other UPI apps</span>
                                </div>
                                <div class="payment-radio-indicator"></div>
                            </div>
                        </label>

                        <!-- 2. Card Payment -->
                        <label class="payment-card-label">
                            <input type="radio" name="paymentMethod" value="Card Payment" class="payment-card-input" form="checkoutForm" required>
                            <div class="payment-card-box">
                                <div class="payment-icon-wrap payment-icon-card">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                                        <rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect>
                                        <line x1="1" y1="10" x2="23" y2="10"></line>
                                    </svg>
                                </div>
                                <div class="payment-card-info">
                                    <span class="payment-card-title">Card Payment</span>
                                    <span class="payment-card-desc">Credit card or debit card</span>
                                </div>
                                <div class="payment-radio-indicator"></div>
                            </div>
                        </label>

                        <!-- 3. Cash on Delivery -->
                        <label class="payment-card-label">
                            <input type="radio" name="paymentMethod" value="Cash on Delivery" class="payment-card-input" form="checkoutForm" required>
                            <div class="payment-card-box">
                                <div class="payment-icon-wrap payment-icon-cod">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                                        <rect x="2" y="6" width="20" height="12" rx="2"></rect>
                                        <circle cx="12" cy="12" r="2"></circle>
                                        <path d="M6 12h.01M18 12h.01"></path>
                                    </svg>
                                </div>
                                <div class="payment-card-info">
                                    <span class="payment-card-title">Cash on Delivery</span>
                                    <span class="payment-card-desc">Pay when your food is delivered</span>
                                </div>
                                <div class="payment-radio-indicator"></div>
                            </div>
                        </label>

                        <!-- 4. Net Banking -->
                        <label class="payment-card-label">
                            <input type="radio" name="paymentMethod" value="Net Banking" class="payment-card-input" form="checkoutForm" required>
                            <div class="payment-card-box">
                                <div class="payment-icon-wrap payment-icon-net">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                                        <path d="M3 21h18M3 10h18M5 6l7-3 7 3M4 10v11M20 10v11M8 14v3M12 14v3M16 14v3"></path>
                                    </svg>
                                </div>
                                <div class="payment-card-info">
                                    <span class="payment-card-title">Net Banking</span>
                                    <span class="payment-card-desc">Pay directly using your bank account</span>
                                </div>
                                <div class="payment-radio-indicator"></div>
                            </div>
                        </label>
                    </div>
                </div>

            </div>

            <!-- Right Column: Coupons, Billing & Checkout -->
            <div class="cart-col-right">

                <!-- Schedule for Later Panel -->
                <div class="cart-card">
                    <div class="schedule-header">
                        <span class="schedule-icon">&#9200;</span>
                        <div>
                            <h3 class="schedule-title">Schedule Order</h3>
                            <p class="schedule-desc">Order for now or pick a custom delivery window.</p>
                        </div>
                        <label class="switch">
                            <input type="checkbox" id="scheduleToggle">
                            <span class="slider round"></span>
                        </label>
                    </div>
                    <div class="schedule-selectors" id="scheduleSelectors" style="display: none;">
                        <div class="schedule-field">
                            <label for="scheduleDate">Select Date</label>
                            <select id="scheduleDate">
                            </select>
                        </div>
                        <div class="schedule-field">
                            <label for="scheduleTime">Select Time Window</label>
                            <select id="scheduleTime">
                                <option>12:00 PM - 12:30 PM</option>
                                <option>01:00 PM - 01:30 PM</option>
                                <option>07:00 PM - 07:30 PM</option>
                                <option>08:00 PM - 08:30 PM</option>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- Delivery Instructions Panel -->
                <div class="cart-card">
                    <h2 class="cart-card-title">Delivery Instructions</h2>
                    <div class="instruction-pills">
                        <label class="instr-pill-label" style="cursor: pointer; display: inline-block;">
                            <input type="checkbox" name="instructionAvoidRinging" value="true" form="checkoutForm" style="display: none;">
                            <span class="instr-pill"><span class="instr-icon">&#128277;</span> Avoid Ringing</span>
                        </label>
                        <label class="instr-pill-label" style="cursor: pointer; display: inline-block;">
                            <input type="checkbox" name="instructionLeaveAtGate" value="true" form="checkoutForm" style="display: none;">
                            <span class="instr-pill"><span class="instr-icon">&#128682;</span> Leave at Gate</span>
                        </label>
                        <label class="instr-pill-label" style="cursor: pointer; display: inline-block;">
                            <input type="checkbox" name="instructionNoContact" value="true" form="checkoutForm" style="display: none;">
                            <span class="instr-pill"><span class="instr-icon">&#128567;</span> No-Contact</span>
                        </label>
                        <label class="instr-pill-label" style="cursor: pointer; display: inline-block;">
                            <input type="checkbox" name="instructionDoNotCall" value="true" form="checkoutForm" style="display: none;">
                            <span class="instr-pill"><span class="instr-icon">&#128263;</span> Do Not Call</span>
                        </label>
                    </div>
                    <textarea class="instr-textarea" name="deliveryNotes" form="checkoutForm" placeholder="Any specific landmarks or gate entry codes? Write here..." style="width: 100%; height: 80px; padding: 12px; border-radius: 12px; border: 1px solid var(--border-subtle); background: var(--bg-body); color: var(--text-primary); font-family: inherit; font-size: 0.88rem; resize: none; margin-top: 12px; box-sizing: border-box;"></textarea>
                </div>

                <!-- Promo Coupons Panel -->
                <div class="cart-card">
                    <h2 class="cart-card-title">Apply Coupons</h2>
                    <% if (couponCode != null && discount > 0) { %>
                        <div style="background: #e8f5e9; border: 1.5px solid #a5d6a7; border-radius: 10px; padding: 12px; margin-bottom: 14px; display: flex; justify-content: space-between; align-items: center;">
                            <div>
                                <div style="font-weight: 800; color: #2e7d32; font-size: 0.9rem;">
                                    🏷️ Coupon '<%= couponCode %>' Applied!
                                </div>
                                <div style="font-size: 0.8rem; color: #388e3c; margin-top: 2px;">
                                    You save ₹<%= (int)discount %> on this order
                                </div>
                            </div>
                            <a href="CouponServlet?action=remove" style="color: #c62828; font-weight: 700; font-size: 0.82rem; text-decoration: none; padding: 4px 10px; border: 1px solid #ef9a9a; border-radius: 6px; background: white;">Remove</a>
                        </div>
                    <% } else { %>
                        <form action="CouponServlet" method="POST" style="margin: 0 0 14px 0; padding: 0;">
                            <div class="coupon-field-wrap" style="display: flex; gap: 8px; align-items: center;">
                                <input type="text" name="code" class="coupon-input" placeholder="Enter code (e.g. WELCOME50)" style="flex: 1; padding: 10px 12px; border-radius: 8px; border: 1px solid var(--border-subtle); background: var(--bg-body); color: var(--text-primary); font-size: 0.85rem;" required>
                                <button type="submit" class="coupon-apply-btn" style="padding: 10px 18px; border-radius: 8px; background: var(--primary); color: white; border: none; font-weight: 700; cursor: pointer; font-size: 0.85rem; transition: background 0.2s;">Apply</button>
                            </div>
                        </form>
                    <% } %>

                    <%
                        String couponSuccess = request.getParameter("couponSuccess");
                        String couponError = request.getParameter("couponError");
                        String couponRemoved = request.getParameter("couponRemoved");
                        if ("true".equalsIgnoreCase(couponSuccess)) {
                    %>
                        <p style="color: #2e7d32; font-size: 0.82rem; margin: -4px 0 12px 0; font-weight: 600;">Coupon applied successfully!</p>
                    <% } else if ("true".equalsIgnoreCase(couponRemoved)) { %>
                        <p style="color: #475569; font-size: 0.82rem; margin: -4px 0 12px 0; font-weight: 600;">Coupon removed.</p>
                    <% } else if (couponError != null) { %>
                        <p style="color: #c62828; font-size: 0.82rem; margin: -4px 0 12px 0; font-weight: 600;"><%= couponError %></p>
                    <% } %>

                    <div class="available-coupons" style="display: flex; flex-direction: column; gap: 10px;">
                        <% boolean isWelcome50Applied = "WELCOME50".equalsIgnoreCase(couponCode); %>
                        <a href="CouponServlet?<%= isWelcome50Applied ? "action=remove" : "code=WELCOME50" %>" class="avail-coupon-item" style="display: block; text-decoration: none; color: inherit; padding: 12px; background: <%= isWelcome50Applied ? "#e8f5e9" : "#fff9e6" %>; border: 1.5px solid <%= isWelcome50Applied ? "#a5d6a7" : "#ffe8b3" %>; border-radius: 8px; transition: all 0.2s;">
                            <div style="display: flex; justify-content: space-between; align-items: center;">
                                <div class="avail-coupon-code" style="font-weight: 800; color: <%= isWelcome50Applied ? "#2e7d32" : "var(--primary)" %>; font-size: 0.9rem;">WELCOME50</div>
                                <% if (isWelcome50Applied) { %>
                                    <span style="font-size: 0.78rem; font-weight: 800; color: #2e7d32; background: #c8e6c9; padding: 2px 10px; border-radius: 4px; display: inline-flex; align-items: center; gap: 4px;">APPLIED ✓</span>
                                <% } else { %>
                                    <span style="font-size: 0.78rem; font-weight: 700; color: var(--primary); background: #ffeecc; padding: 2px 8px; border-radius: 4px;">APPLY</span>
                                <% } %>
                            </div>
                            <div class="avail-coupon-desc" style="font-size: 0.8rem; color: <%= isWelcome50Applied ? "#388e3c" : "var(--text-secondary)" %>; margin-top: 4px;">50% off on your first order up to ₹100</div>
                        </a>

                        <% boolean isKhaalo200Applied = "KHAALO200".equalsIgnoreCase(couponCode); %>
                        <a href="CouponServlet?<%= isKhaalo200Applied ? "action=remove" : "code=KHAALO200" %>" class="avail-coupon-item" style="display: block; text-decoration: none; color: inherit; padding: 12px; background: <%= isKhaalo200Applied ? "#e8f5e9" : "#fff9e6" %>; border: 1.5px solid <%= isKhaalo200Applied ? "#a5d6a7" : "#ffe8b3" %>; border-radius: 8px; transition: all 0.2s;">
                            <div style="display: flex; justify-content: space-between; align-items: center;">
                                <div class="avail-coupon-code" style="font-weight: 800; color: <%= isKhaalo200Applied ? "#2e7d32" : "var(--primary)" %>; font-size: 0.9rem;">KHAALO200</div>
                                <% if (isKhaalo200Applied) { %>
                                    <span style="font-size: 0.78rem; font-weight: 800; color: #2e7d32; background: #c8e6c9; padding: 2px 10px; border-radius: 4px; display: inline-flex; align-items: center; gap: 4px;">APPLIED ✓</span>
                                <% } else { %>
                                    <span style="font-size: 0.78rem; font-weight: 700; color: var(--primary); background: #ffeecc; padding: 2px 8px; border-radius: 4px;">APPLY</span>
                                <% } %>
                            </div>
                            <div class="avail-coupon-desc" style="font-size: 0.8rem; color: <%= isKhaalo200Applied ? "#388e3c" : "var(--text-secondary)" %>; margin-top: 4px;">Get a flat ₹200 discount (Referral Code)</div>
                        </a>
                    </div>
                </div>

                <!-- Delivery Address Card -->
                <div class="cart-card" id="cartAddressCard">
                    <h2 class="cart-card-title">Delivery Address</h2>
                    <div class="delivery-address-container" id="deliveryAddressContainer" style="padding-top: 4px;">
                        <%
                            List<Address> addresses = null;
                            if (user != null) {
                                addresses = new com.khaalo.daoimpl.AddressDAOImpl().getAddressesByUserId(user.getId());
                            }
                            if (user == null) {
                        %>
                            <p style="color:var(--text-secondary); margin-bottom:12px; font-size: 0.88rem;">Please log in to manage your addresses and place your order.</p>
                            <a href="#signInModalOverlay" onclick="window.openSignInModal(); return false;" class="checkout-btn" style="text-decoration: none; display: flex; justify-content: center; align-items: center; text-transform: uppercase;">
                                Log In / Sign Up to Continue
                            </a>
                        <% } else if (addresses == null || addresses.isEmpty()) { %>
                            <p style="color:var(--text-secondary); margin-bottom:12px; font-size: 0.88rem;">No address found. Please add an address to place an order.</p>
                            <a href="address.jsp?ref=cart" class="checkout-btn" style="text-decoration: none; display: flex; justify-content: center; align-items: center; text-transform: uppercase;">
                                Add Address
                            </a>
                        <% } else { %>
                            <p style="font-size:0.85rem; color:var(--text-secondary); margin-bottom:12px;">Choose a delivery address:</p>
                            <div class="address-options-list" style="display: flex; flex-direction: column; gap: 10px;">
                                <%
                                    int addrIdx = 0;
                                    for (Address addr : addresses) {
                                        addrIdx++;
                                %>
                                    <label class="address-option-label" style="display: block; cursor: pointer; margin: 0;">
                                        <input type="radio" name="addressId" value="<%= addr.getId() %>" form="checkoutForm" <%= addrIdx == 1 ? "checked" : "" %> style="display: none;" required>
                                        <div class="address-option-card" style="padding: 12px; border: 1.5px solid var(--border-subtle); border-radius: 8px; background: var(--bg-card); transition: all 0.2s;">
                                            <div style="font-weight: 700; font-size: 0.9rem; color: var(--text-primary); margin-bottom: 4px; display: flex; align-items: center; gap: 8px;">
                                                <span>&#128205;</span> <%= addr.getAddressType().toUpperCase() %>
                                            </div>
                                            <div style="font-size: 0.82rem; color: var(--text-secondary); line-height: 1.4;">
                                                <%= addr.getFlatNo() %>, <%= addr.getAreaDetails() %>, <%= addr.getCity() %> - <%= addr.getPincode() %>
                                            </div>
                                        </div>
                                    </label>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                </div>

                <!-- Bill Summary Panel -->
                <form action="OrderServlet" method="POST" id="checkoutForm">
                    <input type="hidden" name="restaurantId" value="<%= restaurantId %>">
                    <input type="hidden" name="subtotal" value="<%= subtotal %>">
                    <input type="hidden" name="deliveryFee" value="<%= deliveryFee %>">
                    <input type="hidden" name="taxes" value="<%= gst %>">
                    <input type="hidden" name="grandTotal" value="<%= grandTotal %>">

                    <div class="cart-card bill-summary-card">
                        <h2 class="cart-card-title">Bill Breakdown</h2>
                        <div class="bill-row">
                            <span>Item Total</span>
                            <span id="billItemTotal">₹<%= (int)subtotal %></span>
                        </div>
                        <div class="bill-row">
                            <span>Delivery Partner Fee</span>
                            <span id="billDeliveryFee">₹<%= (int)deliveryFee %></span>
                        </div>
                        <div class="bill-row">
                            <span>Taxes & Restaurant Charges</span>
                            <span id="billTaxes">₹<%= (int)gst %></span>
                        </div>
                        <% if (discount > 0) { %>
                            <div class="bill-row" style="color: #2e7d32; font-weight: 600;">
                                <span>Coupon Discount</span>
                                <span>-₹<%= (int)discount %></span>
                            </div>
                        <% } %>
                        <hr class="bill-divider">
                        <div class="bill-row grand-total-row">
                            <span>To Pay</span>
                            <span id="billGrandTotal">₹<%= (int)grandTotal %></span>
                        </div>

                        <% if (user == null) { %>
                            <a href="#signInModalOverlay" onclick="window.openSignInModal(); return false;" class="checkout-btn" style="text-decoration: none; display: flex; justify-content: center; align-items: center; width: 100%; box-sizing: border-box;">
                                <span>Log In / Sign Up to Continue</span>
                            </a>
                        <% } else if (addresses != null && !addresses.isEmpty()) { %>
                            <button type="submit" class="checkout-btn" style="border:none; cursor:pointer; width:100%; margin-top: var(--space-md);">
                                <span>Place Order</span>
                                <span class="btn-price-summary">₹<%= (int)grandTotal %></span>
                            </button>
                        <% } else { %>
                            <a href="address.jsp?ref=cart" class="checkout-btn checkout-btn-address" style="text-decoration: none; display: flex; justify-content: center; align-items: center; width: 100%; box-sizing: border-box;">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="flex-shrink:0;">
                                    <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
                                </svg>
                                <span>Add Address to Proceed</span>
                            </a>
                        <% } %>
                    </div>
                </form>

            </div>

        </div>
    </main>

</body>
</html>
