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
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Select Delivery Address | Khaalo</title>
    <meta name="description" content="Add or edit your delivery addresses, tag locations as Home or Work, and proceed with fast checkout.">
    <meta name="theme-color" content="#1a1a2e">

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    

    <!-- Stylesheets -->
    
    



<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
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
 * Khaalo — Mockup-aligned Address Selection Stylesheet
 * ============================================================ */

body.address-body-page {
    background-color: #F4F6F8;
    color: var(--text-primary);
    min-height: 100vh;
    padding-top: 80px;
    font-family: 'Outfit', 'Poppins', sans-serif;
}

/* === Address Header === */
.address-header {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 80px;
    background: #FFFFFF;
    border-bottom: 1px solid #E0E4E8;
    display: flex;
    align-items: center;
    padding: 0 var(--space-xl);
    gap: var(--space-lg);
    z-index: 1000;
}

.address-back-btn {
    background: none;
    border: none;
    color: #1A1D20;
    cursor: pointer;
    width: 44px;
    height: 44px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all var(--transition-fast);
}

.address-back-btn:hover {
    background: #F4F6F8;
    color: var(--primary);
}

.address-header-title h1 {
    font-size: 1.25rem;
    font-weight: 800;
    color: #1A1D20;
    margin: 0;
    line-height: 1.2;
}

.address-header-title p {
    font-size: 0.8rem;
    color: #6C757D;
    margin: 2px 0 0;
}

/* === Layout Content === */
.address-main-content {
    max-width: 1100px;
    margin: 0 auto;
    padding: var(--space-xl) var(--space-md) var(--space-2xl);
}

.address-page-layout {
    display: grid;
    grid-template-columns: 1fr 1.2fr;
    gap: var(--space-2xl);
    align-items: start;
}

.address-left-pane {
    position: sticky;
    top: 110px;
}

/* === Map Panel Container === */
.map-container {
    position: relative;
    height: 480px;
    border-radius: 20px;
    border: 1px solid #E0E4E8;
    overflow: hidden;
    background-color: #E8ECEF;
    box-shadow: 0 4px 20px rgba(0,0,0,0.05);
}

.map-viewport {
    width: 100%;
    height: 100%;
    position: relative;
}

.sim-map-layer {
    width: 100%;
    height: 100%;
    position: absolute;
    top: 0;
    left: 0;
}

/* Center Pin Marker */
.map-center-pin {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -100%);
    pointer-events: none;
    z-index: 5;
    display: flex;
    flex-direction: column;
    align-items: center;
}

.pin-marker {
    filter: drop-shadow(0 4px 6px rgba(0, 0, 0, 0.15));
    animation: pinBounce 0.3s ease-out;
}

.pin-pulse {
    width: 12px;
    height: 4px;
    background: rgba(0, 0, 0, 0.15);
    border-radius: 50%;
    position: absolute;
    bottom: -2px;
    left: 50%;
    transform: translateX(-50%);
}

.pin-pulse::after {
    content: '';
    position: absolute;
    width: 24px;
    height: 24px;
    border-radius: 50%;
    border: 2px solid var(--primary);
    top: 50%; left: 50%;
    transform: translate(-50%, -50%) scale(0.5);
    opacity: 0.8;
    animation: pinRadar 1.5s infinite ease-out;
}

@keyframes pinBounce {
    0% { transform: translateY(-20px); }
    100% { transform: translateY(0); }
}

@keyframes pinRadar {
    0% { transform: translate(-50%, -50%) scale(0.4); opacity: 0.8; }
    100% { transform: translate(-50%, -50%) scale(2.2); opacity: 0; }
}

/* === Form Cards === */
.address-right-pane {
    display: flex;
    flex-direction: column;
}

.address-form-layout {
    display: flex;
    flex-direction: column;
    gap: var(--space-xl);
}

.form-card {
    background: #FFFFFF;
    border-radius: 20px;
    padding: var(--space-xl);
    border: 1px solid #E0E4E8;
    box-shadow: 0 4px 20px rgba(0,0,0,0.02);
}

.form-card-title {
    font-size: 1.15rem;
    font-weight: 800;
    color: #1A1D20;
    margin-bottom: var(--space-xl);
}

/* === Input Fields (Floating Labels Style) === */
.input-field-wrap {
    position: relative;
    margin-bottom: var(--space-lg);
}

.input-field-wrap input,
.input-field-wrap textarea {
    width: 100%;
    padding: 18px var(--space-lg);
    border: 1px solid #D0D5DD;
    border-radius: 16px;
    font-size: 0.95rem;
    font-weight: 500;
    color: #1A1D20;
    background: #FFFFFF;
    font-family: inherit;
    transition: all 0.25s ease;
}

.input-field-wrap textarea {
    resize: none;
}

/* Focus and Active Label styling */
.input-field-wrap input:focus,
.input-field-wrap textarea:focus {
    border-color: #FF6B35;
    box-shadow: 0 0 0 4px rgba(255, 107, 53, 0.1);
    outline: none;
}

.input-field-wrap label {
    position: absolute;
    left: var(--space-lg);
    top: 50%;
    transform: translateY(-50%);
    background: #FFFFFF;
    padding: 0 6px;
    color: #667085;
    font-size: 0.95rem;
    pointer-events: none;
    transition: all 0.2s ease;
}

.input-field-wrap textarea ~ label {
    top: 24px;
    transform: none;
}

/* When input is focused or not empty, float the label */
.input-field-wrap input:focus ~ label,
.input-field-wrap input:not(:placeholder-shown) ~ label,
.input-field-wrap textarea:focus ~ label,
.input-field-wrap textarea:not(:placeholder-shown) ~ label {
    top: 0;
    transform: translateY(-50%);
    font-size: 0.75rem;
    font-weight: 700;
    color: #FF6B35;
}

.validation-error {
    font-size: 0.75rem;
    font-weight: 600;
    color: #D32F2F;
    margin-top: 4px;
    padding-left: var(--space-md);
    display: none;
}

/* === Pill Navigation Tabs === */
.location-tabs-container {
    background: #F2F4F7;
    border-radius: 100px;
    padding: 6px;
    margin-bottom: var(--space-xl);
}

.location-tabs-row {
    display: flex;
    gap: 4px;
}

.loc-tab-btn {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 12px var(--space-md);
    border: none;
    border-radius: 100px;
    background: transparent;
    color: #475467;
    font-size: 0.9rem;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

.loc-tab-btn .tab-icon {
    stroke: #475467;
    transition: stroke 0.25s ease;
}

.loc-tab-btn.active {
    background: #0C111D;
    color: #FFFFFF;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}

.loc-tab-btn.active .tab-icon {
    stroke: #FFFFFF;
}

/* === Area Picker Card === */
.area-picker-card {
    border: 1px solid #D0D5DD;
    border-radius: 16px;
    padding: var(--space-md) var(--space-lg);
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: var(--space-lg);
    margin-bottom: var(--space-lg);
    background: #FFFFFF;
    position: relative;
}

.area-picker-info {
    flex: 1;
}

.area-picker-label {
    position: absolute;
    left: var(--space-lg);
    top: 0;
    transform: translateY(-50%);
    background: #FFFFFF;
    padding: 0 6px;
    font-size: 0.75rem;
    font-weight: 700;
    color: #667085;
}

.area-picker-value {
    font-size: 0.85rem;
    font-weight: 500;
    color: #475467;
    line-height: 1.45;
}

/* Thumbnail Map Change Button */
.area-change-btn {
    background: none;
    border: none;
    cursor: pointer;
    padding: 0;
}

.area-mini-map {
    width: 72px;
    height: 72px;
    border: 1px solid #EAECF0;
    border-radius: 12px;
    background: #F9FAFB;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 2px;
    transition: all 0.2s ease;
}

.area-mini-map svg {
    filter: drop-shadow(0 2px 4px rgba(255, 107, 53, 0.15));
}

.area-mini-map span {
    font-size: 0.7rem;
    font-weight: 700;
    color: #FF6B35;
}

.area-change-btn:hover .area-mini-map {
    border-color: #FF6B35;
    background: rgba(255, 107, 53, 0.02);
    transform: scale(1.02);
}

/* === Save Address Save Button === */
.save-address-btn {
    width: 100%;
    padding: 18px;
    background: linear-gradient(135deg, #FF6B35, #E85D2C);
    color: #FFFFFF;
    border: none;
    border-radius: 16px;
    font-size: 1rem;
    font-weight: 700;
    cursor: pointer;
    box-shadow: 0 4px 20px rgba(255, 107, 53, 0.3);
    transition: all 0.25s ease;
}

.save-address-btn:hover {
    transform: translateY(-1px);
    box-shadow: 0 6px 25px rgba(255, 107, 53, 0.4);
}

/* === Map Search Search Modal === */
.modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(12, 17, 29, 0.65);
    backdrop-filter: blur(4px);
    z-index: 2000;
    display: none;
    align-items: center;
    justify-content: center;
    padding: var(--space-lg);
}

.modal-overlay.active {
    display: flex;
}

.map-search-modal {
    max-width: 480px;
    width: 100%;
    background: #FFFFFF;
    border-radius: 20px;
    box-shadow: 0 20px 60px rgba(0,0,0,0.15);
    overflow: hidden;
    animation: modalScaleUp 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

@keyframes modalScaleUp {
    from { transform: scale(0.9) translateY(20px); opacity: 0; }
    to { transform: scale(1) translateY(0); opacity: 1; }
}

.map-modal-body {
    padding: var(--space-xl);
    display: flex;
    flex-direction: column;
    gap: var(--space-md);
}

.map-modal-search-box {
    position: relative;
}

.map-modal-search-box input {
    width: 100%;
    padding: 14px 44px 14px 16px;
    border: 1px solid #D0D5DD;
    border-radius: 12px;
    font-size: 0.9rem;
    color: #1A1D20;
}

.map-modal-search-box input:focus {
    border-color: #FF6B35;
    outline: none;
}

.modal-search-clear-btn {
    position: absolute;
    right: 14px;
    top: 50%;
    transform: translateY(-50%);
    background: none;
    border: none;
    font-size: 0.95rem;
    color: #98A2B3;
    cursor: pointer;
}

.map-suggestions {
    display: flex;
    flex-direction: column;
    max-height: 200px;
    overflow-y: auto;
    border: 1px solid #EAECF0;
    border-radius: 12px;
}

.suggest-item {
    padding: 12px var(--space-md);
    text-align: left;
    background: none;
    border: none;
    border-bottom: 1px solid #F2F4F7;
    font-size: 0.85rem;
    font-weight: 500;
    color: #475467;
    cursor: pointer;
    transition: background 0.15s ease;
}

.suggest-item:hover {
    background: #F9FAFB;
    color: #FF6B35;
}

.modal-gps-btn {
    width: 100%;
    padding: 12px;
    background: #FFFFFF;
    border: 1px solid #FF6B35;
    color: #FF6B35;
    border-radius: 12px;
    font-size: 0.85rem;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.2s ease;
}

.modal-gps-btn:hover {
    background: rgba(255, 107, 53, 0.04);
}

/* === Responsive Overrides === */
@media screen and (max-width: 868px) {
    .address-page-layout {
        grid-template-columns: 1fr;
        gap: var(--space-xl);
    }
    .address-left-pane {
        position: static;
    }
    .map-container {
        height: 280px;
    }
}

</style>
</head>
<body class="address-body-page">

    <!-- Header -->
    <header class="address-header">
        <button class="address-back-btn" id="addressBackBtn" aria-label="Go Back">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <line x1="19" y1="12" x2="5" y2="12"></line>
                <polyline points="12 19 5 12 12 5"></polyline>
            </svg>
        </button>
        <div class="address-header-title">
            <h1>Select Delivery Address</h1>
            <p>Specify a precise location for seamless delivery.</p>
        </div>
    </header>

    <!-- Main Content -->
    <main class="address-main-content">
        <div class="address-page-layout">
            
            <!-- Left Column: Map Simulator (Stays sticky on desktop) -->
            <div class="address-left-pane">
                <div class="map-container">
                    <!-- Map Viewport -->
                    <div class="map-viewport" id="mapViewport">
                        <div class="sim-map-layer">
                            <svg width="100%" height="100%" xmlns="http://www.w3.org/2000/svg">
                                <defs>
                                    <pattern id="roadGrid" width="120" height="120" patternUnits="userSpaceOnUse">
                                        <rect width="120" height="120" fill="#EAEFF2" />
                                        <line x1="0" y1="60" x2="120" y2="60" stroke="#FFFFFF" stroke-width="18" />
                                        <line x1="60" y1="0" x2="60" y2="120" stroke="#FFFFFF" stroke-width="18" />
                                        <circle cx="60" cy="60" r="18" fill="#FFFFFF" />
                                    </pattern>
                                </defs>
                                <rect width="100%" height="100%" fill="url(#roadGrid)" />
                                <rect x="90" y="30" width="120" height="90" rx="12" fill="#D4EDDA" />
                                <rect x="300" y="200" width="150" height="110" rx="12" fill="#D4EDDA" />
                                <rect x="30" y="210" width="60" height="60" rx="6" fill="#ECEFF1"/>
                                <rect x="240" y="40" width="90" height="50" rx="6" fill="#ECEFF1"/>
                            </svg>
                        </div>
                        <!-- Center Pin Marker -->
                        <div class="map-center-pin">
                            <div class="pin-marker">
                                <svg width="42" height="42" viewBox="0 0 24 24" fill="#FF6B35">
                                    <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
                                </svg>
                            </div>
                            <div class="pin-pulse"></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Column: Address Form Details -->
            <div class="address-right-pane">
                <form class="address-form-layout" id="addressForm" action="AddressServlet" method="POST">
                    
                    <!-- Card 1: Receiver Details -->
                    <div class="form-card receiver-details-card">
                        <h2 class="form-card-title">Receiver Details</h2>
                        
                        <div class="input-field-wrap">
                            <input type="text" id="contactName" placeholder=" " required>
                            <label for="contactName">Receiver's Name *</label>
                            <div class="validation-error" id="contactNameError">Please enter the receiver's name.</div>
                        </div>

                        <div class="input-field-wrap">
                            <input type="tel" id="contactPhone" placeholder=" " required>
                            <label for="contactPhone">Receiver's Phone Number *</label>
                            <div class="validation-error" id="contactPhoneError">Please enter a valid 10-digit phone number.</div>
                        </div>
                    </div>

                    <!-- Card 2: Location Details -->
                    <div class="form-card location-details-card">
                        <h2 class="form-card-title">Location Details</h2>
                        
                        <!-- Tabs Row -->
                        <div class="location-tabs-container">
                            <div class="location-tabs-row">
                                <button type="button" class="loc-tab-btn active" data-tab="House">
                                    <svg class="tab-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                                        <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
                                        <polyline points="9 22 9 12 15 12 15 22"></polyline>
                                    </svg>
                                    <span>House</span>
                                </button>
                                <button type="button" class="loc-tab-btn" data-tab="Office">
                                    <svg class="tab-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                                        <rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect>
                                        <path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path>
                                    </svg>
                                    <span>Office</span>
                                </button>
                                <button type="button" class="loc-tab-btn" data-tab="Other">
                                    <svg class="tab-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                                        <line x1="22" y1="2" x2="11" y2="13"></line>
                                        <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
                                    </svg>
                                    <span>Other</span>
                                </button>
                            </div>
                        </div>

                        <!-- Dynamic Inputs Container -->
                        <div class="dynamic-inputs-group">
                            <!-- Input 1: House/Office/Building Name -->
                            <div class="input-field-wrap">
                                <input type="text" id="primaryAddressDetail" name="flatNo" placeholder=" " required>
                                <label for="primaryAddressDetail" id="primaryFieldLabel">House / Flat / Floor *</label>
                                <div class="validation-error" id="primaryDetailError">Please fill out this field.</div>
                            </div>

                            <!-- Input 2: Building / Street (Recommended) -->
                            <div class="input-field-wrap">
                                <input type="text" id="secondaryAddressDetail" name="areaDetails" placeholder=" ">
                                <label for="secondaryAddressDetail" id="secondaryFieldLabel">Building / Street (Recommended)</label>
                            </div>

                            <!-- Area Card Block -->
                            <div class="area-picker-card">
                                <div class="area-picker-info">
                                    <span class="area-picker-label">Area</span>
                                    <p class="area-picker-value" id="selectedAreaText">Jay Bheema Nagar, 1st Stage, BTM 1st Stage, Bengaluru, Karnataka, India. (Rahmat Manzil)</p>
                                </div>
                                <button type="button" class="area-change-btn" id="triggerAreaChangeBtn">
                                    <div class="area-mini-map">
                                        <svg width="24" height="24" viewBox="0 0 24 24" fill="#FF6B35">
                                            <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
                                        </svg>
                                        <span>Change</span>
                                    </div>
                                </button>
                            </div>

                            <!-- Input 3: Save address as * -->
                            <div class="input-field-wrap">
                                <input type="text" id="saveAddressAs" name="addressType" placeholder=" " value="Home" required>
                                <label for="saveAddressAs">Save address as *</label>
                                <div class="validation-error" id="saveAddressAsError">Please specify a tag name.</div>
                            </div>
                        </div>

                        <!-- Instructions Field -->
                        <div class="input-field-wrap reach-instructions-wrap">
                            <textarea id="reachInstruction" name="landmark" placeholder=" " rows="2"></textarea>
                            <label for="reachInstruction">Instruction to reach location</label>
                        </div>
                    </div>

                    <!-- Save Address Button -->
                    <input type="hidden" name="city" value="Bangalore">
                    <input type="hidden" name="pincode" value="560000">
                    <button type="submit" class="save-address-btn" id="saveAddressBtn">
                        Save Address & Proceed
                    </button>

                </form>
            </div>

        </div>
    </main>

    <!-- Map Search Modal Overlay -->
    <div class="modal-overlay" id="mapSearchModalOverlay">
        <div class="modal-container map-search-modal">
            <div class="modal-header">
                <h2>Search Location</h2>
                <button class="modal-close" id="mapSearchModalClose">✕</button>
            </div>
            <div class="map-modal-body">
                <div class="map-modal-search-box">
                    <input type="text" id="modalMapSearchInput" placeholder="Search for area, street name...">
                    <button class="modal-search-clear-btn" id="modalMapSearchClearBtn">✕</button>
                </div>
                <div class="map-suggestions" id="mapSuggestionsContainer">
                    <!-- Suggestions loaded here -->
                </div>
                <button class="modal-gps-btn" id="modalGpsLocateBtn">
                    🎯 Locate Me via GPS
                </button>
            </div>
        </div>
    </div>

    <!-- Inline JS for location tabs -->
    <script>
        document.querySelectorAll('.loc-tab-btn').forEach(function(btn) {
            btn.addEventListener('click', function() {
                document.querySelectorAll('.loc-tab-btn').forEach(function(b) { b.classList.remove('active'); });
                btn.classList.add('active');
                var tag = btn.getAttribute('data-tab');
                var saveAsField = document.getElementById('saveAddressAs');
                if (saveAsField && tag) saveAsField.value = tag;
            });
        });
    </script>
</body>
</html>





