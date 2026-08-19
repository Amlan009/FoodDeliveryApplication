<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.khaalo.model.*"%>
<%@ page import="com.khaalo.daoimpl.*" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("restaurants?loginRequired=true#loginModal");
        return;
    }
    if ("Restaurant Owner".equals(user.getRole())) {
        response.sendRedirect("owner.jsp");
        return;
    } else if ("Administrator".equals(user.getRole())) {
        response.sendRedirect("admin.jsp");
        return;
    } else if ("Delivery Partner".equals(user.getRole())) {
        response.sendRedirect("delivery.jsp");
        return;
    }
    List<Restaurant> savedRestaurants = (List<Restaurant>) request.getAttribute("savedRestaurants");
    if (savedRestaurants == null) {
        savedRestaurants = new com.khaalo.daoimpl.FavoriteDAOImpl().getFavoriteRestaurants(user.getId());
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Saved Restaurants | Khaalo</title>
    <meta name="description" content="Your saved restaurants on Khaalo. Har Bhook Ka Solution.">
    <meta name="theme-color" content="#1a1a2e">

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
    /* === CSS variables definition === */
    :root {
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

        /* Border Radius */
        --radius-sm: 8px;
        --radius-md: 12px;
        --radius-lg: 18px;
        --radius-xl: 24px;
        --radius-full: 9999px;

        /* Transitions */
        --transition-fast: 0.15s ease;
        --transition-base: 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        --transition-slow: 0.5s ease;
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
    }

    body {
        font-family: 'Outfit', 'Poppins', -apple-system, BlinkMacSystemFont, sans-serif;
        background: var(--bg-primary);
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
    }

    img {
        max-width: 100%;
        height: auto;
        display: block;
    }

    a {
        text-decoration: none;
        color: inherit;
    }

    /* === Custom Styles === */
    .saved-page-body {
        background: var(--bg-surface);
        color: var(--text-primary);
        min-height: 100vh;
    }

    .saved-main-content {
        max-width: 1200px;
        margin: 0 auto;
        padding: var(--space-xl) var(--space-lg);
    }

    .saved-header-row {
        margin-bottom: var(--space-xl);
    }

    .saved-header-row h1 {
        font-size: 2rem;
        font-weight: 800;
        color: var(--text-primary);
        margin-bottom: 4px;
    }

    .saved-subtitle {
        font-size: 1rem;
        color: var(--text-muted);
    }

    /* Empty State */
    .empty-saved-state {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        text-align: center;
        padding: 80px var(--space-lg);
        background: var(--bg-card);
        border-radius: var(--radius-xl);
        border: 1px solid var(--border-subtle);
        max-width: 600px;
        margin: 40px auto;
        box-shadow: 0 10px 30px rgba(0,0,0,0.05);
    }

    .empty-icon-wrap {
        font-size: 4rem;
        margin-bottom: var(--space-lg);
        animation: heartPulse 1.5s infinite alternate ease-in-out;
    }

    @keyframes heartPulse {
        from { transform: scale(1); }
        to { transform: scale(1.15); text-shadow: 0 0 20px rgba(255, 107, 53, 0.4); }
    }

    .empty-saved-state h2 {
        font-size: 1.5rem;
        font-weight: 800;
        margin-bottom: var(--space-sm);
        color: var(--text-primary);
    }

    .empty-saved-state p {
        font-size: 0.95rem;
        color: var(--text-secondary);
        margin-bottom: var(--space-xl);
        max-width: 440px;
        line-height: 1.6;
    }

    .explore-btn {
        background: linear-gradient(135deg, var(--primary), #FF5416);
        color: white;
        padding: 12px 32px;
        border: none;
        border-radius: var(--radius-full);
        font-weight: 700;
        font-size: 0.95rem;
        cursor: pointer;
        box-shadow: 0 4px 15px rgba(255, 107, 53, 0.35);
        transition: all var(--transition-base);
    }

    .explore-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(255, 107, 53, 0.45);
    }

    /* Saved Restaurants Grid */
    .saved-restaurants-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
        gap: var(--space-xl);
    }

    .saved-res-card {
        background: var(--bg-card);
        border-radius: var(--radius-lg);
        border: 1px solid var(--border-subtle);
        overflow: hidden;
        transition: all var(--transition-base);
        position: relative;
    }

    .saved-res-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 12px 30px rgba(0, 0, 0, 0.08);
        border-color: var(--border-active);
    }

    .saved-res-img-wrap {
        position: relative;
        height: 180px;
        overflow: hidden;
    }

    .saved-res-img-wrap img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform var(--transition-slow);
    }

    .saved-res-card:hover .saved-res-img-wrap img {
        transform: scale(1.05);
    }

    .saved-res-fav-btn {
        position: absolute;
        top: 12px;
        right: 12px;
        width: 38px;
        height: 38px;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.9);
        border: none;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #FF6B35;
        cursor: pointer;
        box-shadow: 0 4px 10px rgba(0,0,0,0.15);
        transition: all var(--transition-fast);
    }

    .saved-res-fav-btn:hover {
        transform: scale(1.1);
        background: white;
    }

    .saved-res-info {
        padding: var(--space-md);
    }

    .saved-res-header-row {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: var(--space-xs);
    }

    .saved-res-header-row h3 {
        font-size: 1.1rem;
        font-weight: 700;
        color: var(--text-primary);
        margin: 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        max-width: 75%;
    }

    .saved-res-rating {
        display: flex;
        align-items: center;
        gap: 4px;
        background: #2E7D32;
        color: white;
        padding: 3px 8px;
        border-radius: 6px;
        font-size: 0.8rem;
        font-weight: 700;
    }

    .saved-res-rating svg {
        fill: white;
    }

    .saved-res-cuisine {
        font-size: 0.82rem;
        color: var(--text-secondary);
        margin-bottom: var(--space-md);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .saved-res-meta {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 0.8rem;
        color: var(--text-muted);
        border-top: 1px solid var(--border-subtle);
        padding-top: var(--space-sm);
    }

    .saved-res-meta span {
        display: flex;
        align-items: center;
        gap: 4px;
    }

    @media screen and (max-width: 768px) {
        .saved-main-content {
            padding: var(--space-md);
        }
        .saved-header-row h1 {
            font-size: 1.6rem;
        }
        .saved-restaurants-grid {
            grid-template-columns: 1fr;
            gap: var(--space-md);
        }
    }

    /* === Back Button Styling === */
    .subpage-header {
        padding: var(--space-lg) var(--space-lg) 0;
        display: flex;
        align-items: center;
        justify-content: flex-start;
        width: 100%;
    }

    .back-btn {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 44px;
        height: 44px;
        border-radius: 50%;
        background: var(--bg-card);
        color: var(--text-primary);
        box-shadow: var(--shadow-sm);
        transition: all var(--transition-fast);
        border: 1px solid var(--border-subtle);
        text-decoration: none;
    }

    .back-btn:hover {
        background: var(--primary);
        color: white;
        transform: scale(1.05);
        box-shadow: 0 4px 15px var(--primary-glow);
    }
    </style>
</head>
<body class="saved-page-body">

    <!-- Main App Container -->
    <div class="app-container visible">
        
        <!-- Top Navigation Header -->
        <header class="subpage-header">
            <a href="restaurants" class="back-btn" aria-label="Back to Home">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="19" y1="12" x2="5" y2="12"></line>
                    <polyline points="12 19 5 12 12 5"></polyline>
                </svg>
            </a>
        </header>

        <!-- Main Content -->
        <main class="saved-main-content">
            <!-- Header title -->
            <div class="saved-header-row" style="margin-bottom: var(--space-xl);">
                <h1 style="font-size: 2rem; font-weight: 800; color: var(--text-primary); margin-bottom: 4px;">My Saved Restaurants 💖</h1>
                <p class="saved-subtitle" style="font-size: 1rem; color: var(--text-muted);">Manage your favorite restaurants</p>
            </div>

            <!-- Saved Restaurants Grid -->
            <div class="saved-restaurants-container">
                <% if (savedRestaurants == null || savedRestaurants.isEmpty()) { %>
                    <!-- Empty State -->
                    <div class="empty-saved-state">
                        <div class="empty-icon-wrap">💖</div>
                        <h2>No Saved Restaurants Yet</h2>
                        <p>Tap the heart icon on any restaurant card to save it to your favorites list.</p>
                        <button class="explore-btn" onclick="window.location.href='restaurants'">Explore Restaurants</button>
                    </div>
                <% } else { %>
                    <div class="saved-restaurants-grid">
                        <% for (Restaurant restaurant : savedRestaurants) { 
                            String cuisinesStr = restaurant.getCuisines() != null ? String.join(" &middot; ", restaurant.getCuisines()) : "Multicuisine";
                        %>
                            <div class="saved-res-card">
                                <a href="menu?restaurantId=<%= restaurant.getId() %>" style="text-decoration: none; display: block; color: inherit; height: 100%;">
                                    <div class="saved-res-img-wrap">
                                        <img src="<%= restaurant.getBannerUrl() %>" alt="<%= restaurant.getName() %>" loading="lazy">
                                        <a href="SavedServlet?action=toggle&restaurantId=<%= restaurant.getId() %>" class="saved-res-fav-btn" aria-label="Remove from favorites">
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2">
                                                <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path>
                                            </svg>
                                        </a>
                                    </div>
                                    <div class="saved-res-info">
                                        <div class="saved-res-header-row">
                                            <h3><%= restaurant.getName() %></h3>
                                            <span class="saved-res-rating">
                                                <svg width="10" height="10" viewBox="0 0 24 24" fill="currentColor" style="vertical-align: middle;">
                                                    <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
                                                </svg>
                                                <%= restaurant.getRating() %>
                                            </span>
                                        </div>
                                        <p class="saved-res-cuisine"><%= cuisinesStr %></p>
                                        <div class="saved-res-meta">
                                            <span>&#128338; <%= restaurant.getDeliveryTime() %></span>
                                            <span>&#8377;<%= restaurant.getCostForTwo() %> for two</span>
                                        </div>
                                    </div>
                                </a>
                            </div>
                        <% } %>
                    </div>
                <% } %>
            </div>
        </main>

        <!-- Brand Signature Footer -->
        <footer class="bottom-brand-signature" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 8px; padding: var(--space-xl) var(--space-md); margin-top: var(--space-2xl); border-top: 1px dashed var(--border-subtle); width: 100%; text-align: center;">
            <span class="brand-logo-icon" style="font-size: 2.2rem; display: inline-block; margin-bottom: 4px; filter: drop-shadow(0 4px 6px rgba(255, 107, 53, 0.25));">🍽️</span>
            <div class="brand-logo-text" style="display: flex; flex-direction: column; align-items: center;">
                <span class="logo-name" style="font-size: 1.6rem; font-weight: 900; letter-spacing: -0.5px; color: var(--text-primary); background: linear-gradient(135deg, var(--primary), #FF5416); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;">Khaalo</span>
                <span class="logo-tagline" style="font-size: 0.75rem; color: var(--text-muted); font-weight: 600; text-transform: uppercase; letter-spacing: 1.5px; margin-top: 2px;">Har bhook ka solution</span>
            </div>
        </footer>
    </div>
</body>
</html>
