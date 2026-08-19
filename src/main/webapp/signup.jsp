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
        } else {
            response.sendRedirect("restaurants.jsp");
            return;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up | Khaalo</title>
    <!-- Google Fonts -->
    
    <!-- Main styles for the background layout to render correctly -->
    
    <!-- Dedicated signup styles -->
    



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



/* === Khaalo Premium Dedicated Signup Style (Swiggy/Zomato Class) === */

:root {
    --primary: #FF6B35;
    --primary-dark: #E85D2C;
    --primary-glow: rgba(255, 107, 53, 0.15);
    --bg-primary: #F7F5F0;
    --bg-card: rgba(255, 255, 255, 0.88);
    --text-primary: #2C1B10;
    --text-secondary: #5C4B40;
    --text-muted: #A09085;
    --border-subtle: rgba(255, 107, 53, 0.12);
    --radius-md: 12px;
    --radius-lg: 16px;
    --radius-2xl: 24px;
    --space-xs: 8px;
    --space-sm: 12px;
    --space-md: 16px;
    --space-lg: 24px;
    --space-xl: 32px;
    --space-2xl: 40px;
    --transition-fast: 0.15s ease;
    --transition-base: 0.25s ease;
}

* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

body.signup-page-body {
    font-family: 'Outfit', 'Poppins', sans-serif;
    min-height: 100vh;
    margin: 0;
    padding: 0;
    position: relative;
    overflow: hidden;
    background-color: #0d0603;
}

/* Blurred background replica of home page */
.app-background-blur {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    width: 100%;
    height: 100%;
    z-index: 1;
    filter: blur(12px) brightness(50%);
    pointer-events: none;
    user-select: none;
    overflow: hidden;
    transform: scale(1.05); /* Prevents white edges from blur */
}

/* Modal page overlay container */
.modal-page-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    background: rgba(0, 0, 0, 0.45);
    padding: var(--space-lg);
    overflow-y: auto;
}

/* Glassmorphic Modal Card Container */
.signup-card-container {
    width: 100%;
    max-width: 440px;
    background: rgba(255, 255, 255, 0.88);
    backdrop-filter: blur(25px) saturate(190%);
    -webkit-backdrop-filter: blur(25px) saturate(190%);
    border: 1px solid rgba(255, 255, 255, 0.45);
    border-radius: var(--radius-2xl);
    box-shadow: 0 30px 80px rgba(0, 0, 0, 0.28);
    z-index: 2;
    max-height: 90vh;
    overflow-y: auto !important;
    position: relative;
    animation: modalSlideUp 0.45s cubic-bezier(0.34, 1.56, 0.64, 1);
}

@keyframes modalSlideUp {
    from { transform: translateY(40px); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
}

/* Modal header with integrated Tabs */
.modal-header-tabs {
    display: flex;
    background: rgba(0, 0, 0, 0.03);
    border-bottom: 1px solid rgba(0, 0, 0, 0.06);
    position: relative;
    height: 60px;
    align-items: stretch;
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
    text-decoration: none;
}

.modal-tab-btn:hover {
    color: var(--text-primary);
}

.modal-tab-btn.active {
    color: var(--text-primary);
    background: transparent;
    border-bottom: 3px solid var(--primary);
}

/* Modal Close Button */
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

/* Brand Display */
.brand-identity {
    text-align: center;
    padding: var(--space-lg) var(--space-xl) var(--space-xs);
}

.brand-logo-img {
    font-size: 2.2rem;
    display: inline-block;
    margin-bottom: 6px;
    filter: drop-shadow(0 4px 6px rgba(255, 107, 53, 0.25));
}

.brand-identity h1 {
    font-size: 1.6rem;
    font-weight: 800;
    color: var(--text-primary);
    letter-spacing: -0.5px;
    margin-bottom: 2px;
}

.brand-identity p {
    font-size: 0.75rem;
    color: var(--text-muted);
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 1.2px;
}

/* Forms layout */
.form-content-body {
    padding: 0 var(--space-xl) var(--space-xl);
}

.input-field-wrapper {
    display: flex;
    flex-direction: column;
    gap: 6px;
    margin-bottom: var(--space-md);
}

.input-field-wrapper label {
    font-size: 0.82rem;
    font-weight: 800;
    color: var(--text-secondary);
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.input-field-wrapper input {
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

.input-field-wrapper input:focus {
    border-color: var(--primary);
    background: white;
    box-shadow: 0 0 0 3px var(--primary-glow);
    outline: none;
}

.input-field-wrapper input::placeholder {
    color: var(--text-muted);
    opacity: 0.65;
}

/* Terms and Conditions Checkbox */
.terms-selection {
    display: flex;
    align-items: flex-start;
    gap: var(--space-xs);
    font-size: 0.8rem;
    color: var(--text-secondary);
    cursor: pointer;
    margin: var(--space-md) 0 var(--space-lg);
}

.terms-selection input {
    margin-top: 3px;
    accent-color: var(--primary);
    width: 16px;
    height: 16px;
}

.terms-selection a {
    color: var(--primary);
    font-weight: 700;
    text-decoration: none;
}

.terms-selection a:hover {
    text-decoration: underline;
}

/* Submit Action */
.action-submit-btn {
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

.action-submit-btn:hover {
    transform: translateY(-1.5px);
    box-shadow: 0 8px 24px rgba(255, 107, 53, 0.45);
}

/* Separator styling */
.connector-divider {
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

.connector-divider::before,
.connector-divider::after {
    content: '';
    flex: 1;
    height: 1px;
    background: rgba(0, 0, 0, 0.08);
}

/* Google Sign-in */
.google-brand-btn {
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

.google-brand-btn:hover {
    background: #FAF9F6;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.06);
    transform: translateY(-0.5px);
}

/* Footer switches */
.toggle-onboarding-footer {
    text-align: center;
    font-size: 0.85rem;
    color: var(--text-secondary);
    margin-top: var(--space-lg);
    font-weight: 500;
}

.toggle-onboarding-footer a {
    color: var(--primary);
    font-weight: 700;
    text-decoration: none;
    transition: color var(--transition-fast);
}

.toggle-onboarding-footer a:hover {
    text-decoration: underline;
    color: var(--primary-dark);
}

</style>
</head>
<body class="signup-page-body">

    <!-- Blurred replica of the homepage layout in the background -->
    <div class="app-background-blur">
        <!-- Top Bar -->
        <header class="top-bar">
            <div class="delivery-info">
                <span class="delivery-label">Delivery location</span>
                <div class="delivery-address">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="#FF6B35">
                        <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
                    </svg>
                    <span>Indiranagar 100 Feet Road, Bengaluru</span>
                </div>
            </div>
            <button class="profile-btn">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                    <circle cx="12" cy="7" r="4"></circle>
                </svg>
            </button>
        </header>

        <!-- Hero Section with blurred food display -->
        <section class="hero-section" style="background: url('images/hero_food_banner.png') center/cover no-repeat; min-height: 480px; position: relative;">
            <div class="hero-overlay">
                <div class="hero-left-brand">
                    <div class="brand-logo-glow">🍽️</div>
                    <span class="brand-sub">PREMIUM DELIVERY</span>
                    <h2 class="brand-title">Your Favorite Food,<br>Delivered Fast.</h2>
                </div>
            </div>
        </section>

        <!-- Bottom Navigation -->
        <nav class="bottom-nav">
            <a href="restaurants.jsp" class="nav-brand-logo" style="text-decoration: none; display: flex; align-items: center; gap: 8px; color: inherit;">
                <span class="brand-logo-icon">🍽️</span>
                <div class="brand-logo-text">
                    <span class="logo-name">Khaalo</span>
                </div>
            </a>
            <div class="nav-items-wrapper">
                <button class="nav-item active"><span>Home</span></button>
                <button class="nav-item"><span>Saved</span></button>
                <button class="nav-item"><span>Cart</span></button>
                <button class="nav-item"><span>Help</span></button>
                <button class="nav-item"><span>Sign In</span></button>
            </div>
        </nav>
    </div>

    <!-- Overlay covering the page to center the modal card -->
    <div class="modal-page-overlay">
        
        <div class="signup-card-container">
            <!-- Close Button positioned absolutely inside container -->
            <button class="modal-close-btn" onclick="window.location.href='restaurants.jsp'" aria-label="Close" style="position: absolute; top: 24px; right: 16px; width: 32px; height: 32px; border-radius: 50%; background: rgba(0, 0, 0, 0.05); border: none; font-size: 1.1rem; display: flex; align-items: center; justify-content: center; cursor: pointer; color: var(--text-secondary); transition: all 0.15s ease; z-index: 10;">✕</button>

            <!-- Brand Identity Section -->
            <div class="brand-identity">
                <span class="brand-logo-img">🍽️</span>
                <h1>Khaalo</h1>
                <p>Har bhook ka solution</p>
            </div>

            <!-- Main Form Content -->
            <div class="form-content-body">
                <%
                    String signupError = request.getParameter("error");
                    if (signupError != null && !signupError.trim().isEmpty()) {
                %>
                    <div id="signupErrorBanner" style="background: rgba(234, 67, 53, 0.15); border: 1px solid #EA4335; color: #EA4335; padding: 12px; border-radius: 12px; font-size: 0.9rem; font-weight: 600; margin-bottom: 16px; text-align: center;">
                        <%= signupError %>
                    </div>
                <%
                    }
                %>
                <form action="register" method="POST" id="onboardingForm">
                    <input type="hidden" name="source" value="standalone">
                    <!-- Full Name Field -->
                    <div class="input-field-wrapper">
                        <label for="fullName">Full Name</label>
                        <input type="text" name="fullName" id="fullName" placeholder="Enter your name" required>
                    </div>

                    <!-- Email Field -->
                    <div class="input-field-wrapper">
                        <label for="email">Email Address</label>
                        <input type="email" name="email" id="email" placeholder="name@example.com" required>
                    </div>

                    <!-- Phone Field -->
                    <div class="input-field-wrapper">
                        <label for="phone">Phone Number</label>
                        <input type="tel" name="phone" id="phone" placeholder="Enter your phone number" required>
                    </div>

                    <!-- Role Selector Field -->
                    <div class="input-field-wrapper">
                        <label for="regRole" style="font-size: 0.82rem; font-weight: 800; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px; text-align: left;">Select Your Role</label>
                        <select name="role" id="regRole" style="width: 100%; padding: 12px var(--space-md); background: rgba(0, 0, 0, 0.03); border: 1px solid rgba(0, 0, 0, 0.08); border-radius: 12px; color: var(--text-primary); font-size: 0.95rem; cursor: pointer; font-family: inherit;">
                            <option value="customer" selected>Customer</option>
                            <option value="restaurant owner">Restaurant Owner</option>
                            <option value="delivery partner">Delivery Partner</option>
                            <option value="admin">Administrator</option>
                            <option value="help and support">Help & Support Agent</option>
                        </select>
                    </div>

                    <!-- Password Field -->
                    <div class="input-field-wrapper">
                        <label for="password">Create Password</label>
                        <input type="password" name="password" id="password" placeholder="Min. 6 characters" minlength="6" required>
                    </div>

                    <!-- Terms Selection -->
                    <label class="terms-selection">
                        <input type="checkbox" id="termsCheckbox" required>
                        <span>I agree to Khaalo's <a href="#">Terms & Conditions</a></span>
                    </label>

                    <button type="submit" class="action-submit-btn">Create Account</button>
                </form>

                <div class="connector-divider">or connect with</div>
                <button class="google-brand-btn" onclick="window.location.href='google-auth.html'">
                    <svg width="20" height="20" viewBox="0 0 24 24">
                        <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 0 1-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z"/>
                        <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                        <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                        <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                    </svg>
                    Sign in with Google
                </button>

                <div class="toggle-onboarding-footer">
                    Already have an account? <a href="login.jsp">Log In</a>
                </div>
            </div>
        </div>

    </div>

</body>
</html>





