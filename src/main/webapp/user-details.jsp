<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.khaalo.model.*" %>
<%@ page import="com.khaalo.daoimpl.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("restaurants.jsp?loginRequired=true");
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
    String userName = user.getFullName() != null ? user.getFullName() : "User";
    String userEmail = user.getEmail() != null ? user.getEmail() : "";
    String userPhone = user.getPhone() != null ? user.getPhone() : "";
    String userInitial = userName.substring(0, 1).toUpperCase();
    
    List<Order> orders = new OrderDAOImpl().getOrdersByUserId(user.getId());
    
    List<Address> addresses = Collections.emptyList();
    try {
        addresses = new AddressDAOImpl().getAddressesByUserId(user.getId());
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Details | Khaalo Profile</title>
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    
    <!-- Main Style -->
    
    <!-- User Details Style -->
    



<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<!-- Khaalo Micro-Animations & JS Engines -->
<link rel="stylesheet" href="css/animations.css">
<script src="js/cart-app.js" defer></script>
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



/* ==========================================================================
   KHAALO - User Details Profile Dashboard Stylesheet
   ========================================================================== */

.profile-page-body {
    background: linear-gradient(135deg, #FFF9F2 0%, #FFEEDD 100%);
    min-height: 100vh;
    font-family: 'Outfit', sans-serif;
    color: var(--text-primary);
    margin: 0;
    padding-bottom: var(--space-xl);
}

/* Navigation Header Styles */
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

/* Nav override title */
.nav-title {
    font-size: 1.2rem;
    font-weight: 800;
    color: var(--text-primary);
    text-transform: uppercase;
    letter-spacing: 1px;
}

/* Main Dashboard layout split */
.profile-container {
    max-width: 1200px;
    margin: var(--space-lg) auto;
    padding: 0 var(--space-md);
    display: grid;
    grid-template-columns: 280px 1fr;
    gap: var(--space-xl);
    align-items: start;
}

/* Sidebar Styling */
.profile-sidebar {
    background: var(--bg-card);
    border-radius: var(--radius-lg);
    border: 1px solid var(--border-subtle);
    box-shadow: var(--shadow-sm);
    padding: var(--space-lg) var(--space-md);
    display: flex;
    flex-direction: column;
    gap: var(--space-lg);
    position: sticky;
    top: 90px;
}

.profile-summary-card {
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: var(--space-sm);
    border-bottom: 1px solid var(--border-subtle);
    padding-bottom: var(--space-lg);
}

.profile-avatar-wrap {
    position: relative;
    width: 80px;
    height: 80px;
}

.profile-avatar {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--primary), var(--primary-dark));
    color: #fff;
    font-size: 1.8rem;
    font-weight: 800;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 8px 20px rgba(255, 107, 53, 0.3);
}

.foodie-badge-icon {
    position: absolute;
    bottom: 0;
    right: 0;
    background: #FFF;
    border: 2px solid var(--accent);
    width: 26px;
    height: 26px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.95rem;
    box-shadow: var(--shadow-sm);
}

.profile-name {
    font-size: 1.3rem;
    font-weight: 800;
    margin: 0;
}

.badge-status-pills {
    display: flex;
    gap: 6px;
    flex-wrap: wrap;
    justify-content: center;
}

.badge-status {
    font-size: 0.7rem;
    font-weight: 800;
    padding: 3px 8px;
    border-radius: var(--radius-full);
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.badge-status.verified {
    background: rgba(255, 184, 0, 0.15);
    color: #b58000;
    border: 1px solid rgba(255, 184, 0, 0.3);
}

.badge-trust-score {
    font-size: 0.7rem;
    font-weight: 800;
    padding: 3px 8px;
    border-radius: var(--radius-full);
    background: rgba(46, 125, 50, 0.1);
    color: #2E7D32;
    border: 1px solid rgba(46, 125, 50, 0.2);
}

.profile-mini-details {
    display: flex;
    flex-direction: column;
    gap: 4px;
    font-size: 0.8rem;
    color: var(--text-muted);
}

/* Sidebar Tab buttons */
.sidebar-tab-menu {
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.sidebar-tab-btn {
    display: flex;
    align-items: center;
    gap: var(--space-sm);
    width: 100%;
    padding: 12px 14px;
    border-radius: var(--radius-md);
    border: 1px solid transparent;
    background: none;
    color: var(--text-secondary);
    font-size: 0.9rem;
    font-weight: 600;
    text-align: left;
    cursor: pointer;
    transition: all var(--transition-fast);
}

.sidebar-tab-btn span {
    font-size: 1.1rem;
}

.sidebar-tab-btn:hover {
    background: var(--bg-secondary);
    color: var(--primary);
}

.sidebar-tab-btn.active {
    background: rgba(255, 107, 53, 0.08);
    border-color: var(--border-subtle);
    color: var(--primary);
    font-weight: 700;
}

/* Content Area tab pane switching */
.profile-content-area {
    display: flex;
    flex-direction: column;
    gap: var(--space-xl);
}

.profile-tab-content {
    display: none;
    animation: fadeInTab 0.4s ease;
}

.profile-tab-content.active {
    display: flex;
    flex-direction: column;
    gap: var(--space-lg);
}

@keyframes fadeInTab {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
}

.section-title-wrap h2 {
    font-size: 1.8rem;
    font-weight: 900;
    margin: 0 0 6px 0;
}

.section-title-wrap p {
    color: var(--text-muted);
    margin: 0;
}

/* Grid cards for content panels */
.details-grid-card {
    background: var(--bg-card);
    border-radius: var(--radius-lg);
    border: 1px solid var(--border-subtle);
    padding: var(--space-xl);
    box-shadow: var(--shadow-sm);
    display: flex;
    flex-direction: column;
    gap: var(--space-md);
}

.details-grid-card h3 {
    margin: 0;
    font-size: 1.25rem;
    font-weight: 800;
}

.pref-desc {
    font-size: 0.9rem;
    color: var(--text-muted);
    margin: 0;
    line-height: 1.4;
}

/* Form Styling */
.form-row {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
    gap: var(--space-md);
}

.form-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.form-group label {
    font-size: 0.85rem;
    font-weight: 700;
    color: var(--text-secondary);
}

.form-group input {
    padding: 12px;
    border: 1px solid var(--border-subtle);
    border-radius: var(--radius-md);
    background: var(--bg-primary);
    color: var(--text-primary);
    font-size: 0.95rem;
    font-family: inherit;
    transition: all var(--transition-fast);
}

.form-group input:focus {
    border-color: var(--primary);
    box-shadow: 0 0 0 3px rgba(255, 107, 53, 0.15);
    outline: none;
}

.profile-save-btn {
    background: var(--primary);
    color: #fff;
    border: none;
    padding: 12px 24px;
    font-size: 0.95rem;
    font-weight: 700;
    border-radius: var(--radius-md);
    cursor: pointer;
    transition: all var(--transition-base);
    align-self: flex-start;
}

.profile-save-btn:hover {
    background: var(--primary-dark);
    transform: translateY(-1px);
}

.action-btn-signout {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 12px 24px;
    background: var(--secondary);
    color: white;
    font-weight: 700;
    border-radius: var(--radius-md);
    font-size: 0.95rem;
    cursor: pointer;
    transition: all var(--transition-base);
    border: 1px solid transparent;
}

.action-btn-signout:hover {
    background: var(--secondary-light);
    transform: translateY(-1px);
}

.action-btn-delete {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 12px 24px;
    background: #ea4335;
    color: white;
    font-weight: 700;
    border-radius: var(--radius-md);
    font-size: 0.95rem;
    cursor: pointer;
    transition: all var(--transition-base);
    box-shadow: 0 4px 12px rgba(234, 67, 53, 0.25);
}

.action-btn-delete:hover {
    background: #c53023;
    transform: translateY(-1px);
    box-shadow: 0 6px 16px rgba(234, 67, 53, 0.4);
}

/* Dietary Toggles & Switch slider */
.preference-toggle-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: var(--space-md);
    border-radius: var(--radius-md);
    background: var(--bg-primary);
    border: 1px solid var(--border-subtle);
}

.pref-toggle-info {
    display: flex;
    align-items: center;
    gap: var(--space-md);
}

.pref-icon {
    font-size: 1.5rem;
}

.pref-text {
    display: flex;
    flex-direction: column;
}

.pref-title {
    font-weight: 750;
    font-size: 1rem;
}

.pref-subtitle {
    font-size: 0.8rem;
    color: var(--text-muted);
}

/* Toggle Switch Slider Custom */
.toggle-switch {
    position: relative;
    display: inline-block;
    width: 50px;
    height: 28px;
    flex-shrink: 0;
}

.toggle-switch input {
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
    background-color: var(--text-muted);
    transition: .3s;
}

.slider:before {
    position: absolute;
    content: "";
    height: 20px;
    width: 20px;
    left: 4px;
    bottom: 4px;
    background-color: white;
    transition: .3s;
}

input:checked + .slider {
    background-color: #2E7D32; /* Green for veg */
}

input:checked + .slider:before {
    transform: translateX(22px);
}

.slider.round {
    border-radius: 34px;
}

.slider.round:before {
    border-radius: 50%;
}

/* Allergy checkboxes grid */
.allergy-block-section {
    border-top: 1px solid var(--border-subtle);
    padding-top: var(--space-lg);
    display: flex;
    flex-direction: column;
    gap: var(--space-md);
}

.allergy-checkbox-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    gap: var(--space-sm);
}

.allergy-item {
    display: flex;
    align-items: center;
    gap: 8px;
    background: var(--bg-primary);
    border: 1px solid var(--border-subtle);
    padding: 10px 14px;
    border-radius: var(--radius-md);
    cursor: pointer;
    font-weight: 600;
    transition: all var(--transition-fast);
}

.allergy-item input {
    width: 18px;
    height: 18px;
    accent-color: var(--primary);
}

.allergy-item:hover {
    border-color: var(--primary);
    background: var(--bg-card);
}

/* Health & Nutrition summary cards */
.nutrition-summary-row {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: var(--space-md);
}

.nutri-card {
    background: var(--bg-card);
    border-radius: var(--radius-lg);
    border: 1px solid var(--border-subtle);
    padding: var(--space-lg);
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
    box-shadow: var(--shadow-sm);
    text-align: center;
}

.nutri-icon {
    font-size: 2rem;
    margin-bottom: 4px;
}

.nutri-val {
    font-size: 1.8rem;
    font-weight: 900;
    color: var(--text-primary);
}

.nutri-unit {
    font-size: 0.9rem;
    font-weight: 500;
    color: var(--text-muted);
}

.nutri-label {
    font-size: 0.85rem;
    font-weight: 700;
    color: var(--text-muted);
}

/* SVG Chart wrapper */
.chart-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.chart-toggles {
    display: flex;
    gap: 6px;
}

.chart-toggle-btn {
    background: var(--bg-primary);
    border: 1px solid var(--border-subtle);
    padding: 6px 14px;
    border-radius: var(--radius-full);
    font-size: 0.8rem;
    font-weight: 600;
    cursor: pointer;
    color: var(--text-secondary);
}

.chart-toggle-btn.active {
    background: var(--primary);
    color: #fff;
    border-color: var(--primary);
}

.chart-container {
    padding: var(--space-md) 0;
}

.calories-svg-chart {
    width: 100%;
    max-height: 180px;
    overflow: visible;
}

.chart-labels {
    display: flex;
    justify-content: space-between;
    padding: 10px 15px 0;
    font-size: 0.8rem;
    font-weight: 600;
    color: var(--text-muted);
}

/* Taste profile layout */
.taste-dashboard-row {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: var(--space-lg);
}

.pref-spec-item {
    display: flex;
    justify-content: space-between;
    padding: 10px 0;
    border-bottom: 1px dashed var(--border-subtle);
    font-size: 0.95rem;
}

.spec-label {
    font-weight: 700;
    color: var(--text-secondary);
}

.spec-val {
    font-weight: 800;
    color: var(--primary);
}

/* Trust badge & progress */
.trust-progress-container {
    display: flex;
    flex-direction: column;
    gap: var(--space-sm);
    margin-top: var(--space-sm);
}

.trust-header-info {
    display: flex;
    justify-content: space-between;
    font-weight: 750;
    font-size: 0.95rem;
}

.trust-bar-bg {
    background: var(--bg-surface);
    height: 10px;
    border-radius: var(--radius-full);
    overflow: hidden;
}

.trust-bar-fill {
    background: linear-gradient(90deg, var(--accent), var(--primary));
    height: 100%;
    border-radius: var(--radius-full);
}

.badge-status-details {
    display: flex;
    flex-direction: column;
    gap: var(--space-sm);
    border-top: 1px solid var(--border-subtle);
    padding-top: var(--space-md);
    margin-top: var(--space-sm);
}

.status-detail-item {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 0.9rem;
    font-weight: 600;
    color: var(--text-secondary);
}

.status-detail-item.unlocked-perk {
    background: rgba(255, 107, 53, 0.08);
    border: 1px dashed var(--primary);
    padding: 8px 12px;
    border-radius: var(--radius-md);
    color: var(--primary-dark);
}

/* Quiz Popup box styling */
.taste-quiz-box {
    animation: slideInDown 0.4s cubic-bezier(0.17, 0.67, 0.83, 0.67) forwards;
}

@keyframes slideInDown {
    from { opacity: 0; transform: translateY(-20px); }
    to { opacity: 1; transform: translateY(0); }
}

.quiz-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.quiz-close-btn {
    background: none;
    border: none;
    font-size: 1.2rem;
    cursor: pointer;
    color: var(--text-muted);
}

.quiz-q {
    font-size: 1.1rem;
    font-weight: 800;
    margin-bottom: var(--space-md);
}

.quiz-options {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: var(--space-sm);
}

.quiz-opt-btn {
    background: var(--bg-primary);
    border: 1px solid var(--border-subtle);
    padding: var(--space-md);
    border-radius: var(--radius-md);
    font-weight: 700;
    cursor: pointer;
    transition: all var(--transition-fast);
}

.quiz-opt-btn:hover {
    border-color: var(--primary);
    background: rgba(255, 107, 53, 0.04);
}

.quiz-options-checkbox {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
    gap: var(--space-sm);
    margin-bottom: var(--space-md);
}

.quiz-check {
    display: flex;
    align-items: center;
    gap: var(--space-xs);
    font-weight: 600;
    cursor: pointer;
}

.quiz-check input {
    width: 18px;
    height: 18px;
    accent-color: var(--primary);
}

.quiz-next-btn {
    background: var(--text-primary);
    color: #fff;
    border: none;
    padding: 10px 24px;
    font-weight: 750;
    border-radius: var(--radius-md);
    cursor: pointer;
}

/* Order cards history */
.order-history-list {
    display: flex;
    flex-direction: column;
    gap: var(--space-md);
}

.order-history-card {
    background: var(--bg-card);
    border-radius: var(--radius-lg);
    border: 1px solid var(--border-subtle);
    padding: var(--space-lg);
    box-shadow: var(--shadow-sm);
    display: flex;
    flex-direction: column;
    gap: var(--space-sm);
}

.order-card-header {
    display: flex;
    justify-content: space-between;
    align-items: start;
    border-bottom: 1px solid var(--border-subtle);
    padding-bottom: var(--space-sm);
}

.order-restaurant-name {
    margin: 0;
    font-size: 1.1rem;
    font-weight: 850;
}

.order-date {
    font-size: 0.8rem;
    color: var(--text-muted);
}

.order-status {
    font-size: 0.75rem;
    font-weight: 800;
    padding: 4px 10px;
    border-radius: var(--radius-full);
}

.order-status.delivered {
    background: rgba(46, 125, 50, 0.1);
    color: #2E7D32;
}

.order-items-summary {
    font-size: 0.9rem;
    color: var(--text-secondary);
}

.order-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-top: 1px solid var(--border-subtle);
    padding-top: var(--space-sm);
}

.order-total {
    font-weight: 800;
    font-size: 1rem;
}

.order-actions {
    display: flex;
    gap: 6px;
}

.order-action-btn {
    padding: 8px 16px;
    font-size: 0.85rem;
    font-weight: 700;
    border-radius: var(--radius-md);
    cursor: pointer;
    border: none;
    background: var(--primary);
    color: #fff;
}

.order-action-btn.secondary {
    background: var(--bg-primary);
    border: 1px solid var(--border-subtle);
    color: var(--text-secondary);
}

/* Address grid cards */
.addresses-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
    gap: var(--space-md);
}

.address-card {
    background: var(--bg-card);
    border-radius: var(--radius-lg);
    border: 1px solid var(--border-subtle);
    padding: var(--space-lg);
    display: flex;
    flex-direction: column;
    gap: var(--space-md);
    box-shadow: var(--shadow-sm);
}

.address-icon-type {
    font-weight: 800;
    font-size: 1rem;
}

.address-text {
    font-size: 0.85rem;
    color: var(--text-secondary);
    line-height: 1.4;
    margin: 0;
    flex-grow: 1;
}

.address-actions {
    display: flex;
    gap: var(--space-sm);
}

.address-edit-btn,
.address-delete-btn {
    background: none;
    border: none;
    font-size: 0.8rem;
    font-weight: 700;
    cursor: pointer;
    color: var(--text-muted);
}

.address-edit-btn:hover {
    color: var(--primary);
}

.address-delete-btn:hover {
    color: #c62828;
}

.add-new-address-card {
    border: 2px dashed var(--border-subtle);
    background: transparent;
    cursor: pointer;
    align-items: center;
    justify-content: center;
    text-align: center;
    font-weight: 750;
    color: var(--text-muted);
}

.add-address-plus {
    font-size: 2rem;
    margin-bottom: var(--space-xs);
}

/* Payment Dashboard styles */
.payments-dashboard {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: var(--space-lg);
}

.wallet-balance-wrap {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: var(--space-sm);
}

.wallet-amount {
    font-size: 2.2rem;
    font-weight: 900;
    color: var(--primary-dark);
}

.add-money-btn {
    background: var(--text-primary);
    color: #fff;
    border: none;
    padding: 10px 20px;
    border-radius: var(--radius-md);
    font-weight: 700;
    cursor: pointer;
}

.saved-cards-row {
    display: flex;
    flex-direction: column;
    gap: var(--space-sm);
}

.credit-card-item {
    padding: var(--space-md);
    border-radius: var(--radius-md);
    color: #fff;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    height: 140px;
    box-shadow: var(--shadow-sm);
}

.credit-card-item.visa {
    background: linear-gradient(135deg, #1565C0, #1E88E5);
}

.credit-card-item.mastercard {
    background: linear-gradient(135deg, #37474F, #455A64);
}

.card-brand {
    font-weight: 800;
    font-style: italic;
    font-size: 1.2rem;
    align-self: flex-end;
}

.card-number {
    font-size: 1.1rem;
    font-weight: 600;
    letter-spacing: 2px;
}

.card-footer-info {
    display: flex;
    justify-content: space-between;
    font-size: 0.8rem;
    font-weight: 500;
    opacity: 0.9;
}

/* Referral banner styles */
.referral-banner-card {
    background: linear-gradient(135deg, #2C1B10 0%, #3D291C 100%);
    border-radius: var(--radius-lg);
    padding: var(--space-2xl);
    color: #fff;
}

.referral-content-left {
    max-width: 480px;
    display: flex;
    flex-direction: column;
    gap: var(--space-md);
}

.referral-gift-icon {
    font-size: 3rem;
}

.referral-content-left h3 {
    font-size: 1.8rem;
    margin: 0;
}

.copy-code-container {
    display: flex;
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: var(--radius-md);
    overflow: hidden;
    padding: 4px;
}

.copy-code-container input {
    background: transparent;
    border: none;
    padding: 10px 14px;
    color: #fff;
    font-family: inherit;
    font-size: 1.1rem;
    font-weight: 800;
    letter-spacing: 1px;
    width: 100%;
}

.copy-code-container input:focus {
    outline: none;
}

.copy-ref-btn {
    background: var(--primary);
    color: #fff;
    border: none;
    padding: 10px 20px;
    font-weight: 800;
    border-radius: var(--radius-md);
    cursor: pointer;
    transition: background var(--transition-fast);
}

.copy-ref-btn:hover {
    background: var(--primary-dark);
}

/* Support centre FAQ accordion */
.help-section-row {
    display: grid;
    grid-template-columns: 1.5fr 1fr;
    gap: var(--space-lg);
}

.support-faq-item {
    border: 1px solid var(--border-subtle);
    border-radius: var(--radius-md);
    background: var(--bg-primary);
    overflow: hidden;
}

.faq-q-row {
    display: flex;
    justify-content: space-between;
    padding: 14px var(--space-md);
    font-weight: 750;
    font-size: 0.95rem;
    cursor: pointer;
    user-select: none;
}

.faq-icon {
    font-size: 0.8rem;
    transition: transform var(--transition-base);
}

.support-faq-item.active .faq-icon {
    transform: rotate(180deg);
}

.faq-answer-content {
    display: none;
    padding: var(--space-md);
    background: var(--bg-card);
    border-top: 1px solid var(--border-subtle);
    font-size: 0.85rem;
    color: var(--text-secondary);
    line-height: 1.4;
}

.support-faq-item.active .faq-answer-content {
    display: block;
}

.helpline-section {
    display: flex;
    flex-direction: column;
    gap: var(--space-md);
    justify-content: center;
}

.support-action-btn {
    width: 100%;
    padding: 14px;
    font-size: 0.95rem;
    font-weight: 750;
    border-radius: var(--radius-md);
    cursor: pointer;
    border: none;
    transition: all var(--transition-base);
}

.support-action-btn.primary {
    background: var(--primary);
    color: #fff;
}

.support-action-btn.secondary {
    background: var(--bg-primary);
    border: 1px solid var(--border-subtle);
    color: var(--text-secondary);
}

.support-action-btn:hover {
    transform: translateY(-1px);
}

/* Toast alert overlay */
.toast-notification {
    position: fixed;
    bottom: 24px;
    left: 50%;
    transform: translateX(-50%) translateY(40px);
    background: var(--text-primary);
    color: #fff;
    padding: 12px 24px;
    border-radius: var(--radius-full);
    font-weight: 700;
    font-size: 0.9rem;
    z-index: 10000;
    box-shadow: var(--shadow-lg);
    opacity: 0;
    transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    pointer-events: none;
}

.toast-notification.active {
    transform: translateX(-50%) translateY(0);
    opacity: 1;
}

/* ==========================================================================
   Responsive Overrides
   ========================================================================== */
@media screen and (max-width: 768px) {
    .profile-container {
        grid-template-columns: 1fr;
    }

    .profile-sidebar {
        position: static;
        padding: var(--space-md);
    }

    .sidebar-tab-menu {
        flex-direction: row;
        overflow-x: auto;
        padding-bottom: 8px;
        gap: 6px;
    }

    .sidebar-tab-btn {
        flex-shrink: 0;
        width: auto;
        padding: 8px 12px;
        font-size: 0.8rem;
    }

    .help-section-row {
        grid-template-columns: 1fr;
    }
}

</style>
</head>
<body class="profile-page-body">

    <!-- Header Navigation -->
    <nav class="restaurant-nav">
        <button class="back-btn" onclick="window.location.href='restaurants.jsp'" aria-label="Back to Home">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <line x1="19" y1="12" x2="5" y2="12"></line>
                <polyline points="12 19 5 12 12 5"></polyline>
            </svg>
        </button>
    </nav>

    <!-- Main Container -->
    <div class="profile-container">
        <!-- Sidebar -->
        <aside class="profile-sidebar">
            <!-- Profile Summary Card -->
            <div class="profile-summary-card">
                <div class="profile-avatar-wrap">
                    <div class="profile-avatar"><%= userInitial %></div>
                    <span class="foodie-badge-icon" title="Verified Foodie">🏆</span>
                </div>
                <h2 class="profile-name"><%= userName %></h2>
                <div class="badge-status-pills">
                    <span class="badge-status verified" id="badgeStatus">Verified Foodie</span>
                    <span class="badge-trust-score" id="trustScoreLabel">Trust: 96%</span>
                </div>
                <div class="profile-mini-details">
                    <span>📱 <%= userPhone %></span>
                    <span>✉️ <%= userEmail %></span>
                </div>
            </div>

            <%
                String activeTab = request.getParameter("tab");
                if (activeTab == null || activeTab.trim().isEmpty()) {
                    activeTab = "personal-info";
                }
                String savedAction = request.getParameter("saved");
                String chartType = request.getParameter("chart");
                String quizState = request.getParameter("quiz");
                String addedMoney = request.getParameter("added");
                String copiedCode = request.getParameter("copied");
            %>
            <!-- Tab Menu -->
            <nav class="sidebar-tab-menu">
                <a href="user-details.jsp?tab=personal-info" class="sidebar-tab-btn <%= "personal-info".equalsIgnoreCase(activeTab) ? "active" : "" %>" style="text-decoration: none; display: flex; align-items: center; gap: 8px;">
                    <span>👤</span> Personal Info & Diet
                </a>
                <a href="user-details.jsp?tab=health-dashboard" class="sidebar-tab-btn <%= "health-dashboard".equalsIgnoreCase(activeTab) ? "active" : "" %>" style="text-decoration: none; display: flex; align-items: center; gap: 8px;">
                    <span>🏥</span> Health & Nutrition
                </a>
                <a href="user-details.jsp?tab=taste-profile" class="sidebar-tab-btn <%= "taste-profile".equalsIgnoreCase(activeTab) ? "active" : "" %>" style="text-decoration: none; display: flex; align-items: center; gap: 8px;">
                    <span>🌶️</span> Taste Profile Builder
                </a>
                <a href="user-details.jsp?tab=order-history" class="sidebar-tab-btn <%= "order-history".equalsIgnoreCase(activeTab) ? "active" : "" %>" style="text-decoration: none; display: flex; align-items: center; gap: 8px;">
                    <span>📜</span> Order History
                </a>
                <a href="user-details.jsp?tab=saved-addresses" class="sidebar-tab-btn <%= "saved-addresses".equalsIgnoreCase(activeTab) ? "active" : "" %>" style="text-decoration: none; display: flex; align-items: center; gap: 8px;">
                    <span>📍</span> Saved Addresses
                </a>
                <a href="user-details.jsp?tab=payment-methods" class="sidebar-tab-btn <%= "payment-methods".equalsIgnoreCase(activeTab) ? "active" : "" %>" style="text-decoration: none; display: flex; align-items: center; gap: 8px;">
                    <span>💳</span> Payment Methods
                </a>
                <a href="user-details.jsp?tab=referral-program" class="sidebar-tab-btn <%= "referral-program".equalsIgnoreCase(activeTab) ? "active" : "" %>" style="text-decoration: none; display: flex; align-items: center; gap: 8px;">
                    <span>🎁</span> Refer & Earn
                </a>
                <a href="user-details.jsp?tab=help-support" class="sidebar-tab-btn <%= "help-support".equalsIgnoreCase(activeTab) ? "active" : "" %>" style="text-decoration: none; display: flex; align-items: center; gap: 8px;">
                    <span>🛠️</span> Help & Support
                </a>
            </nav>
        </aside>

        <!-- Main Content Area -->
        <main class="profile-content-area">
            
            <!-- Tab 1: Personal Info -->
            <section class="profile-tab-content <%= "personal-info".equalsIgnoreCase(activeTab) ? "active" : "" %>" id="personal-info">
                <div class="section-title-wrap">
                    <h2>Personal Information & Preferences</h2>
                    <p>Manage your details, diet mode, and food allergies.</p>
                </div>

                <% if ("contact".equalsIgnoreCase(savedAction)) { %>
                    <div style="background: #e8f5e9; border: 1px solid #a5d6a7; color: #2e7d32; padding: 12px; border-radius: 8px; font-weight: 700; margin-bottom: 16px;">
                        ✓ Contact details saved successfully!
                    </div>
                <% } else if ("allergy".equalsIgnoreCase(savedAction)) { %>
                    <div style="background: #e8f5e9; border: 1px solid #a5d6a7; color: #2e7d32; padding: 12px; border-radius: 8px; font-weight: 700; margin-bottom: 16px;">
                        ✓ Allergy preferences updated successfully!
                    </div>
                <% } %>
                
                <form action="user-details.jsp?tab=personal-info&saved=contact" method="POST">
                    <div class="details-grid-card">
                        <h3>Contact Information</h3>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="profName">Full Name</label>
                                <input type="text" id="profName" name="fullName" value="<%= userName %>">
                            </div>
                            <div class="form-group">
                                <label for="profPhone">Phone Number</label>
                                <input type="text" id="profPhone" name="phone" value="<%= userPhone %>">
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="profEmail">Email Address</label>
                                <input type="email" id="profEmail" name="email" value="<%= userEmail %>">
                            </div>
                        </div>
                        <button type="submit" class="profile-save-btn" style="border:none; cursor:pointer;">Save Contact Details</button>
                    </div>
                </form>

                <form action="user-details.jsp?tab=personal-info&saved=allergy" method="POST">
                    <div class="details-grid-card dietary-prefs-card" style="margin-top: 20px;">
                        <h3>Dietary Preference Settings</h3>
                        <p class="pref-desc">Personalize what items are recommended or shown to you automatically.</p>
                        
                        <div class="preference-toggle-item">
                            <div class="pref-toggle-info">
                                <span class="pref-icon">🟢</span>
                                <div class="pref-text">
                                    <span class="pref-title">Strict Veg Mode Only</span>
                                    <span class="pref-subtitle">Automatically hides all non-vegetarian dishes across index and restaurant pages.</span>
                                </div>
                            </div>
                            <label class="toggle-switch">
                                <input type="checkbox" id="vegOnlyPreference" name="vegOnly">
                                <span class="slider round"></span>
                            </label>
                        </div>

                        <div class="allergy-block-section">
                            <h4>⚠️ Allergy Blocker Settings</h4>
                            <p class="pref-desc">Select any ingredients you are allergic to. We will tag, flag, or hide these dishes to protect your health.</p>
                            
                            <div class="allergy-checkbox-grid">
                                <label class="allergy-item">
                                    <input type="checkbox" name="allergies" value="peanuts" class="allergy-checkbox">
                                    <span>🥜 Peanuts</span>
                                </label>
                                <label class="allergy-item">
                                    <input type="checkbox" name="allergies" value="dairy" class="allergy-checkbox">
                                    <span>🥛 Dairy / Milk</span>
                                </label>
                                <label class="allergy-item">
                                    <input type="checkbox" name="allergies" value="gluten" class="allergy-checkbox">
                                    <span>🌾 Gluten</span>
                                </label>
                                <label class="allergy-item">
                                    <input type="checkbox" name="allergies" value="seafood" class="allergy-checkbox">
                                    <span>🐟 Seafood / Fish</span>
                                </label>
                                <label class="allergy-item">
                                    <input type="checkbox" name="allergies" value="soy" class="allergy-checkbox">
                                    <span>🫘 Soy Products</span>
                                </label>
                                <label class="allergy-item">
                                    <input type="checkbox" name="allergies" value="eggs" class="allergy-checkbox">
                                    <span>🥚 Eggs</span>
                                </label>
                            </div>
                            <button type="submit" class="profile-save-btn" style="border:none; cursor:pointer;">Save Allergy Preferences</button>
                        </div>
                    </div>
                </form>

                <div class="details-grid-card account-actions-card" style="border: 1px solid rgba(234, 67, 53, 0.2); background: rgba(255, 245, 245, 0.6); padding: var(--space-xl); border-radius: var(--radius-lg); margin-top: var(--space-lg);">
                    <h3 style="color: #ea4335; display: flex; align-items: center; gap: 8px; margin-bottom: 8px;">
                        <span>⚙️</span> Account Actions
                    </h3>
                    <p style="font-size: 0.9rem; color: var(--text-muted); margin: 0 0 var(--space-md); line-height: 1.5;">
                        Log out of your current session or permanently remove your account and all associated data from the Khaalo platform.
                    </p>
                    <div class="account-actions-buttons" style="display: flex; gap: var(--space-md); flex-wrap: wrap;">
                        <a href="logout" class="action-btn-signout" style="text-decoration: none; display: inline-flex; align-items: center; gap: 6px;">
                            <span>🚪</span> Sign Out
                        </a>
                        <form action="delete-account" method="POST" style="display: inline-block; margin: 0;">
                            <button type="submit" class="action-btn-delete" style="border:none; cursor:pointer;">
                                <span>🗑️</span> Delete Account
                            </button>
                        </form>
                    </div>
                </div>
            </section>

            <!-- Tab 2: Health & Nutrition Dashboard -->
            <section class="profile-tab-content <%= "health-dashboard".equalsIgnoreCase(activeTab) ? "active" : "" %>" id="health-dashboard">
                <div class="section-title-wrap">
                    <h2>Health & Nutrition Dashboard</h2>
                    <p>Track your calories, protein, carbs, and sugar intake based on your orders.</p>
                </div>

                <div class="nutrition-summary-row">
                    <div class="nutri-card calorie-card">
                        <span class="nutri-icon">🔥</span>
                        <div class="nutri-val">680 <span class="nutri-unit">kcal</span></div>
                        <div class="nutri-label">Avg Daily Calories</div>
                    </div>
                    <div class="nutri-card protein-card">
                        <span class="nutri-icon">🥩</span>
                        <div class="nutri-val">42 <span class="nutri-unit">g</span></div>
                        <div class="nutri-label">Avg Daily Protein</div>
                    </div>
                    <div class="nutri-card sugar-card">
                        <span class="nutri-icon">🍬</span>
                        <div class="nutri-val">18 <span class="nutri-unit">g</span></div>
                        <div class="nutri-label">Avg Sugar Intake</div>
                    </div>
                    <div class="nutri-card carbs-card">
                        <span class="nutri-icon">🍞</span>
                        <div class="nutri-val">75 <span class="nutri-unit">g</span></div>
                        <div class="nutri-label">Avg Carbohydrates</div>
                    </div>
                </div>

                <!-- Graphic Chart Section -->
                <div class="details-grid-card">
                    <div class="chart-header">
                        <h3><%= "monthly".equalsIgnoreCase(chartType) ? "Monthly" : "Weekly" %> Intake Tracking</h3>
                        <div class="chart-toggles">
                            <a href="user-details.jsp?tab=health-dashboard&chart=weekly" class="chart-toggle-btn <%= !"monthly".equalsIgnoreCase(chartType) ? "active" : "" %>" style="text-decoration: none; display: inline-block;">Weekly</a>
                            <a href="user-details.jsp?tab=health-dashboard&chart=monthly" class="chart-toggle-btn <%= "monthly".equalsIgnoreCase(chartType) ? "active" : "" %>" style="text-decoration: none; display: inline-block;">Monthly</a>
                        </div>
                    </div>
                    <div class="chart-container">
                        <% if ("monthly".equalsIgnoreCase(chartType)) { %>
                            <div class="svg-chart-wrap" id="chartMonthly">
                                <svg viewBox="0 0 500 200" class="calories-svg-chart">
                                    <polyline fill="url(#chartGradient)" stroke="#FFB800" stroke-width="3" 
                                        points="20,180 100,120 180,80 260,140 340,90 420,60 480,180" />
                                    <circle cx="100" cy="120" r="5" fill="#FFB800"></circle>
                                    <circle cx="180" cy="80" r="5" fill="#FFB800"></circle>
                                    <circle cx="260" cy="140" r="5" fill="#FFB800"></circle>
                                    <circle cx="340" cy="90" r="5" fill="#FFB800"></circle>
                                    <circle cx="420" cy="60" r="5" fill="#FFB800"></circle>
                                </svg>
                                <div class="chart-labels">
                                    <span>Week 1</span>
                                    <span>Week 2</span>
                                    <span>Week 3</span>
                                    <span>Week 4</span>
                                    <span>Week 5</span>
                                </div>
                            </div>
                        <% } else { %>
                            <div class="svg-chart-wrap" id="chartWeekly">
                                <svg viewBox="0 0 500 200" class="calories-svg-chart">
                                    <defs>
                                        <linearGradient id="chartGradient" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="0%" stop-color="#FF6B35" stop-opacity="0.8"></stop>
                                            <stop offset="100%" stop-color="#FF6B35" stop-opacity="0.1"></stop>
                                        </linearGradient>
                                    </defs>
                                    <polyline fill="url(#chartGradient)" stroke="#FF6B35" stroke-width="3" 
                                        points="20,180 80,140 140,160 200,90 260,110 320,70 380,85 440,105 480,180" />
                                    <circle cx="80" cy="140" r="5" fill="#FF6B35"></circle>
                                    <circle cx="140" cy="160" r="5" fill="#FF6B35"></circle>
                                    <circle cx="200" cy="90" r="5" fill="#FF6B35"></circle>
                                    <circle cx="260" cy="110" r="5" fill="#FF6B35"></circle>
                                    <circle cx="320" cy="70" r="5" fill="#FF6B35"></circle>
                                    <circle cx="380" cy="85" r="5" fill="#FF6B35"></circle>
                                    <circle cx="440" cy="105" r="5" fill="#FF6B35"></circle>
                                </svg>
                                <div class="chart-labels">
                                    <span>Mon</span>
                                    <span>Tue</span>
                                    <span>Wed</span>
                                    <span>Thu</span>
                                    <span>Fri</span>
                                    <span>Sat</span>
                                    <span>Sun</span>
                                </div>
                            </div>
                        <% } %>
                    </div>
                </div>
            </section>

            <!-- Tab 3: Taste Profile Builder -->
            <section class="profile-tab-content <%= "taste-profile".equalsIgnoreCase(activeTab) ? "active" : "" %>" id="taste-profile">
                <div class="section-title-wrap">
                    <h2>Personalized Taste Profile Builder</h2>
                    <p>Fine-tune recommendation algorithms by directly editing your preferences quiz.</p>
                </div>

                <div class="taste-dashboard-row">
                    <div class="details-grid-card taste-current-settings">
                        <h3>Your Profile Preferences</h3>
                        <p class="pref-desc">These settings drive the automated restaurant recommendations transparently.</p>
                        
                        <div class="pref-spec-item">
                            <span class="spec-label">Spice Tolerance:</span>
                            <span class="spec-val" id="tasteSpiceVal">🔥 Medium (Balanced)</span>
                        </div>
                        <div class="pref-spec-item">
                            <span class="spec-label">Cuisine Preferences:</span>
                            <span class="spec-val" id="tasteCuisineVal">North Indian, Italian, Desserts</span>
                        </div>
                        <div class="pref-spec-item">
                            <span class="spec-label">Portion Size Preference:</span>
                            <span class="spec-val" id="tastePortionVal">Normal Size Meals</span>
                        </div>

                        <a href="user-details.jsp?tab=taste-profile&quiz=open#tasteQuizBox" class="profile-save-btn" style="margin-top:var(--space-lg); text-decoration: none; display: inline-block;">
                            Take Personalization Quiz
                        </a>
                    </div>

                    <!-- Verified Foodie Badges & Trust Score Info -->
                    <div class="details-grid-card foodie-trust-score-card">
                        <h3>🏆 Trust Score & Badge Builder</h3>
                        <p class="pref-desc">Write genuine food reviews and rate dishes to increase your score and unlock exclusive rewards.</p>
                        
                        <div class="trust-progress-container">
                            <div class="trust-header-info">
                                <span class="score-label">Trust Score</span>
                                <span class="score-value">96 / 100</span>
                            </div>
                            <div class="trust-bar-bg">
                                <div class="trust-bar-fill" style="width: 96%;"></div>
                            </div>
                        </div>

                        <div class="badge-status-details">
                            <div class="status-detail-item">
                                <span class="status-detail-icon">✔️</span>
                                <span>Review Authenticity verified</span>
                            </div>
                            <div class="status-detail-item">
                                <span class="status-detail-icon">✔️</span>
                                <span>Genuine Review History (14 reviews)</span>
                            </div>
                            <div class="status-detail-item unlocked-perk">
                                <span class="status-detail-icon">🚀</span>
                                <strong>Early Access to New Launches: UNLOCKED!</strong>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Personalization Quiz Box -->
                <% if ("open".equalsIgnoreCase(quizState)) { %>
                    <div class="details-grid-card taste-quiz-box" id="tasteQuizBox" style="display:block; margin-top: 20px;">
                        <div class="quiz-header" style="display: flex; justify-content: space-between; align-items: center;">
                            <h3>Taste Profile Quiz</h3>
                            <a href="user-details.jsp?tab=taste-profile" class="quiz-close-btn" style="text-decoration: none; font-weight: 700;">✕</a>
                        </div>
                        <form action="user-details.jsp?tab=taste-profile&saved=quiz" method="POST" class="quiz-content">
                            <div class="quiz-step active" id="quizStep1">
                                <p class="quiz-q">1. What is your preferred spice level?</p>
                                <div class="quiz-options" style="display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 16px;">
                                    <label style="padding: 8px 14px; background: var(--bg-surface); border-radius: 8px; cursor: pointer;">
                                        <input type="radio" name="spice" value="Mild" checked> Mild (No Spice)
                                    </label>
                                    <label style="padding: 8px 14px; background: var(--bg-surface); border-radius: 8px; cursor: pointer;">
                                        <input type="radio" name="spice" value="Medium"> Medium (Balanced)
                                    </label>
                                    <label style="padding: 8px 14px; background: var(--bg-surface); border-radius: 8px; cursor: pointer;">
                                        <input type="radio" name="spice" value="Hot"> Hot (Spicy Kick)
                                    </label>
                                </div>
                            </div>
                            <button type="submit" class="profile-save-btn" style="border:none; cursor:pointer;">Save Quiz Answers</button>
                        </form>
                    </div>
                <% } %>
            </section>

            <!-- Tab 4: Order History -->
            <section class="profile-tab-content <%= "order-history".equalsIgnoreCase(activeTab) ? "active" : "" %>" id="order-history">
                <div class="section-title-wrap">
                    <h2>Your Order History</h2>
                    <p>View your past orders, status, and track historical orders.</p>
                </div>

                <div class="order-history-list">
                    <% if (orders == null || orders.isEmpty()) { %>
                        <div style="text-align: center; padding: 40px 20px; color: var(--text-secondary);">
                            <div style="font-size: 3rem; margin-bottom: 12px;">📦</div>
                            <h3 style="margin: 0 0 8px; color: var(--text-primary);">No Orders Yet</h3>
                            <p>Your order history will appear here once you place your first order.</p>
                            <a href="restaurants.jsp" class="profile-save-btn" style="text-decoration: none; display: inline-block; margin-top: 16px;">Explore Restaurants</a>
                        </div>
                    <% } else {
                        OrderItemDAOImpl oiDAO = new OrderItemDAOImpl();
                        RestaurantDAOImpl rDAO = new RestaurantDAOImpl();
                        for (Order ord : orders) {
                            List<OrderItem> items = oiDAO.getOrderItemsByOrderId(ord.getId());
                            StringBuilder itemsStr = new StringBuilder();
                            if (items != null) {
                                for (int i = 0; i < items.size(); i++) {
                                    OrderItem oi = items.get(i);
                                    itemsStr.append(oi.getQuantity()).append("x ").append(oi.getDishName());
                                    if (i < items.size() - 1) itemsStr.append(", ");
                                }
                            }
                            Restaurant rest = rDAO.getRestaurantById(ord.getRestaurantId());
                            String rName = (rest != null) ? rest.getName() : "Khaalo Partner";
                            String dStr = ord.getCreatedAt() != null ? new java.text.SimpleDateFormat("MMM dd, yyyy").format(ord.getCreatedAt()) : "Recent";
                    %>
                    <div class="order-history-card">
                        <div class="order-card-header">
                            <div>
                                <h4 class="order-restaurant-name"><%= rName %></h4>
                                <span class="order-date"><%= dStr %></span>
                            </div>
                            <span class="order-status delivered"><%= ord.getOrderStatus() %></span>
                        </div>
                        <div class="order-items-summary">
                            <%= itemsStr.toString() %>
                        </div>
                        <div class="order-footer">
                            <span class="order-total">Total: ₹<%= (int)ord.getGrandTotal() %></span>
                            <div class="order-actions">
                                <a href="help.jsp" class="order-action-btn secondary" style="text-decoration: none; display: inline-block;">Need Help?</a>
                            </div>
                        </div>
                    </div>
                    <% } } %>
                </div>
            </section>

            <!-- Tab 5: Saved Addresses -->
            <section class="profile-tab-content <%= "saved-addresses".equalsIgnoreCase(activeTab) ? "active" : "" %>" id="saved-addresses">
                <div class="section-title-wrap">
                    <h2>Saved Delivery Addresses</h2>
                    <p>Manage your primary addresses for fast checkout.</p>
                </div>

                <div class="addresses-grid">
                    <% if (addresses == null || addresses.isEmpty()) { %>
                        <div style="text-align: center; padding: 40px 20px; color: var(--text-secondary);">
                            <div style="font-size: 3rem; margin-bottom: 12px;">📍</div>
                            <h3 style="margin: 0 0 8px; color: var(--text-primary);">No Saved Addresses</h3>
                            <p>Add a delivery address for faster checkout.</p>
                        </div>
                    <% } else {
                        for (Address addr : addresses) {
                    %>
                        <div class="details-grid-card" style="margin-bottom: 12px;">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                <strong style="text-transform: uppercase; color: var(--primary); font-size: 0.85rem;"><%= addr.getAddressType() %></strong>
                                <form action="AddressServlet" method="POST" style="margin:0; padding:0;">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<%= addr.getId() %>">
                                    <button type="submit" style="background: none; border: none; color: #C62828; font-weight: 700; cursor: pointer; font-size: 0.8rem;">Delete</button>
                                </form>
                            </div>
                            <p style="font-size: 0.92rem; color: var(--text-primary); margin: 0 0 4px;"><%= addr.getFlatNo() %>, <%= addr.getAreaDetails() %></p>
                            <% if (addr.getLandmark() != null && !addr.getLandmark().isEmpty()) { %>
                                <p style="font-size: 0.85rem; color: var(--text-secondary); margin: 0 0 4px;">Landmark: <%= addr.getLandmark() %></p>
                            <% } %>
                            <p style="font-size: 0.85rem; color: var(--text-secondary); margin: 0;"><%= addr.getCity() %> - <%= addr.getPincode() %></p>
                        </div>
                    <% } } %>
                </div>

                <div style="margin-top: 20px; text-align: center;">
                    <a href="address.jsp" class="profile-save-btn" style="text-decoration: none; display: inline-block;">Add New Address</a>
                </div>
            </section>

            <!-- Tab 6: Payment Methods -->
            <section class="profile-tab-content <%= "payment-methods".equalsIgnoreCase(activeTab) ? "active" : "" %>" id="payment-methods">
                <div class="section-title-wrap">
                    <h2>Payment Methods</h2>
                    <p>Manage your saved cards, UPI credentials, and wallets.</p>
                </div>

                <% if ("money".equalsIgnoreCase(addedMoney)) { %>
                    <div style="background: #e8f5e9; border: 1px solid #a5d6a7; color: #2e7d32; padding: 12px; border-radius: 8px; font-weight: 700; margin-bottom: 16px;">
                        ✓ ₹500 added to Khaalo Wallet!
                    </div>
                <% } %>

                <div class="payments-dashboard">
                    <div class="details-grid-card wallet-card">
                        <h3>Khaalo Wallet</h3>
                        <div class="wallet-balance-wrap">
                            <span class="wallet-amount" id="walletBalanceVal">₹<%= "money".equalsIgnoreCase(addedMoney) ? "950.00" : "450.00" %></span>
                            <a href="user-details.jsp?tab=payment-methods&added=money" class="add-money-btn" style="text-decoration: none; display: inline-block;">Add Money</a>
                        </div>
                    </div>

                    <div class="details-grid-card cards-section">
                        <h3>Saved Credit & Debit Cards</h3>
                        <div class="saved-cards-row" id="savedCardsRow">
                            <div class="credit-card-item visa">
                                <span class="card-brand">VISA</span>
                                <span class="card-number">•••• •••• •••• 4296</span>
                                <div class="card-footer-info">
                                    <span class="card-holder"><%= userName %></span>
                                    <span class="card-expiry">12/29</span>
                                </div>
                            </div>
                            <div class="credit-card-item mastercard">
                                <span class="card-brand">MasterCard</span>
                                <span class="card-number">•••• •••• •••• 8105</span>
                                <div class="card-footer-info">
                                    <span class="card-holder"><%= userName %></span>
                                    <span class="card-expiry">08/30</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Tab 7: Referral Program -->
            <section class="profile-tab-content <%= "referral-program".equalsIgnoreCase(activeTab) ? "active" : "" %>" id="referral-program">
                <div class="section-title-wrap">
                    <h2>Refer & Earn program</h2>
                    <p>Invite friends and earn ₹200 for every referral coupon.</p>
                </div>

                <% if ("true".equalsIgnoreCase(copiedCode)) { %>
                    <div style="background: #e8f5e9; border: 1px solid #a5d6a7; color: #2e7d32; padding: 12px; border-radius: 8px; font-weight: 700; margin-bottom: 16px;">
                        ✓ Code KHAALO200AML copied! Share with friends to earn ₹200.
                    </div>
                <% } %>

                <div class="referral-banner-card">
                    <div class="referral-content-left">
                        <span class="referral-gift-icon">🎁</span>
                        <h3>Earn ₹200 Free!</h3>
                        <p>Share your code with friends. When they place their first order above ₹300, both of you get ₹200 credited to your Khaalo wallets instantly.</p>
                        
                        <div class="copy-code-container" style="display: flex; gap: 8px; align-items: center; margin-top: 14px;">
                            <input type="text" id="refCodeInput" value="KHAALO200AML" readonly style="background: #fff; padding: 10px; border-radius: 6px; font-weight: 800; border: 1px solid #ccc;">
                            <a href="user-details.jsp?tab=referral-program&copied=true" class="copy-ref-btn" style="text-decoration: none; padding: 10px 16px; background: var(--primary); color: white; border-radius: 6px; font-weight: 700;">Copy Code</a>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Tab 8: Help & Support -->
            <section class="profile-tab-content <%= "help-support".equalsIgnoreCase(activeTab) ? "active" : "" %>" id="help-support">
                <div class="section-title-wrap">
                    <h2>Help & Support Centre</h2>
                    <p>Facing issues? Read FAQs or chat with customer support directly.</p>
                </div>

                <div class="help-section-row">
                    <div class="details-grid-card faq-section">
                        <h3>Frequently Asked Questions</h3>
                        
                        <details class="support-faq-item" style="cursor: pointer; padding: 12px 0; border-bottom: 1px solid var(--border-subtle);">
                            <summary style="font-weight: 700; font-size: 0.95rem; color: var(--text-primary); outline: none;">How do I cancel my order?</summary>
                            <div class="faq-answer-content" style="padding-top: 8px;">
                                <p style="font-size: 0.88rem; color: var(--text-secondary);">Orders can be cancelled within 1 minute of confirmation. Simply navigate to the Order History tab and press "Cancel Order". After that, cancellation fees apply depending on preparation stage.</p>
                            </div>
                        </details>

                        <details class="support-faq-item" style="cursor: pointer; padding: 12px 0; border-bottom: 1px solid var(--border-subtle);">
                            <summary style="font-weight: 700; font-size: 0.95rem; color: var(--text-primary); outline: none;">My payment failed, but money was deducted.</summary>
                            <div class="faq-answer-content" style="padding-top: 8px;">
                                <p style="font-size: 0.88rem; color: var(--text-secondary);">Failed payments are automatically reversed by banks within 3-5 business days. You can check the transaction ID under Payment Methods.</p>
                            </div>
                        </details>
                    </div>

                    <div class="details-grid-card helpline-section">
                        <h3>Connect Instantly</h3>
                        <p class="pref-desc">Our support agents are available 24/7 to solve your queries.</p>
                        
                        <div style="display: flex; flex-direction: column; gap: 10px; margin-top: 14px;">
                            <a href="help.jsp" class="support-action-btn primary" style="text-decoration: none; text-align: center; display: block;">Chat with Support</a>
                            <a href="tel:1800542256" class="support-action-btn secondary" style="text-decoration: none; text-align: center; display: block;">Call 1800-KHAALO</a>
                        </div>
                    </div>
                </div>
            </section>

        </main>
    </div>
</body>
</html>
</html>





