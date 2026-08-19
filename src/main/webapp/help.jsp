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
    <title>Help & Support | Khaalo Support Center</title>
    <meta name="description" content="Khaalo Customer Support. FAQs, Partner Onboarding, and Legal Guidelines.">
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



/* === Help & FAQs Support Page CSS === */

.help-page-body {
    background: var(--bg-surface);
    color: var(--text-primary);
    min-height: 100vh;
}

.help-main-content {
    max-width: 1200px;
    margin: 0 auto;
    padding: var(--space-xl) var(--space-lg);
}

.help-hero {
    margin-bottom: var(--space-xl);
}

.help-hero h1 {
    font-size: 2.2rem;
    font-weight: 800;
    color: var(--text-primary);
    margin-bottom: 6px;
}

.help-hero p {
    font-size: 1.05rem;
    color: var(--text-secondary);
}

/* Sidebar & Content Layout split */
.help-grid {
    display: flex;
    gap: var(--space-2xl);
    align-items: flex-start;
    margin-top: var(--space-lg);
}

/* Left Category Sidebar */
.help-sidebar {
    width: 260px;
    background: var(--bg-card);
    border-radius: var(--radius-xl);
    border: 1px solid var(--border-subtle);
    padding: var(--space-md);
    display: flex;
    flex-direction: column;
    gap: 8px;
    flex-shrink: 0;
    box-shadow: 0 4px 20px rgba(0,0,0,0.02);
}

.help-tab {
    width: 100%;
    padding: var(--space-md) var(--space-lg);
    background: none;
    border: none;
    border-left: 4px solid transparent;
    text-align: left;
    font-family: inherit;
    font-size: 0.95rem;
    font-weight: 700;
    color: var(--text-secondary);
    cursor: pointer;
    border-radius: var(--radius-sm);
    transition: all var(--transition-fast);
}

.help-tab:hover {
    background: var(--bg-surface);
    color: var(--text-primary);
}

.help-tab.active {
    background: rgba(255, 107, 53, 0.08);
    border-left-color: var(--primary);
    color: var(--primary);
}

/* Right Content Panel */
.help-panel {
    flex: 1;
    background: var(--bg-card);
    border-radius: var(--radius-xl);
    border: 1px solid var(--border-subtle);
    padding: var(--space-xl) var(--space-2xl);
    box-shadow: 0 4px 20px rgba(0,0,0,0.02);
}

.help-section {
    display: none;
}

.help-section.active {
    display: block;
    animation: fadeIn var(--transition-base);
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
}

.help-section h2 {
    font-size: 1.5rem;
    font-weight: 800;
    margin-bottom: var(--space-lg);
    color: var(--text-primary);
    border-bottom: 2px solid var(--border-subtle);
    padding-bottom: 12px;
}

/* Accordion Styles */
.accordion-list {
    display: flex;
    flex-direction: column;
}

.accordion-item {
    border-bottom: 1px solid var(--border-subtle);
}

.accordion-item:last-child {
    border-bottom: none;
}

.accordion-header {
    width: 100%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px 0;
    background: none;
    border: none;
    text-align: left;
    font-family: inherit;
    font-size: 1rem;
    font-weight: 600;
    color: var(--text-primary);
    cursor: pointer;
    transition: color var(--transition-fast);
}

.accordion-header:hover {
    color: var(--primary);
}

.accordion-header .chevron {
    font-size: 0.7rem;
    color: var(--text-muted);
    transition: transform var(--transition-base);
}

/* Collapsible Body */
.accordion-body {
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.3s cubic-bezier(0, 1, 0, 1);
}

.accordion-body p {
    padding-bottom: 20px;
    font-size: 0.92rem;
    line-height: 1.6;
    color: var(--text-secondary);
}

/* Expanded state indicators */
.accordion-item.expanded .accordion-header {
    color: var(--primary);
}

.accordion-item.expanded .chevron {
    transform: rotate(180deg);
    color: var(--primary);
}

/* Responsive */
@media screen and (max-width: 992px) {
    .help-grid {
        flex-direction: column;
        gap: var(--space-xl);
    }
    .help-sidebar {
        width: 100%;
        flex-direction: row;
        overflow-x: auto;
    }
    .help-tab {
        border-left: none;
        border-bottom: 3px solid transparent;
        text-align: center;
        white-space: nowrap;
    }
    .help-tab.active {
        border-bottom-color: var(--primary);
    }
    .help-panel {
        padding: var(--space-lg);
    }
}

@media screen and (max-width: 480px) {
    .help-hero h1 {
        font-size: 1.8rem;
    }
    .help-hero p {
        font-size: 0.95rem;
    }
    .accordion-header {
        font-size: 0.92rem;
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
    transition: all var(--transition-base);
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
<body class="help-page-body">

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
        <main class="help-main-content">
            
            <!-- Page Title -->
            <div class="help-hero">
                <h1>Help & Support</h1>
                <p>Let's take care of your queries, issues, or onboarding requirements.</p>
            </div>

            <!-- Layout Split Grid -->
            <div class="help-grid">
                
                <!-- Left Sidebar Categories -->
                <aside class="help-sidebar">
                    <button class="help-tab active" data-tab="faqs">FAQs</button>
                    <button class="help-tab" data-tab="partner">Partner Onboarding</button>
                    <button class="help-tab" data-tab="legal">Legal</button>
                </aside>

                <!-- Right Accordions Panel -->
                <section class="help-panel">
                    
                    <!-- 1. FAQs Panel -->
                    <div class="help-section active" id="section-faqs">
                        <h2>FAQs</h2>
                        <div class="accordion-list">
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>What is Khaalo Customer Care Number?</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>We provide 24/7 in-app support chat to handle all your queries. You can also reach our care executive directly at +91 98765 43210 or email us at support@khaalo.com.</p>
                                </div>
                            </div>
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>I want to explore career opportunities with Khaalo</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>We are constantly growing! Check out our careers portal at careers.khaalo.com to view open openings in engineering, operations, logistics, marketing, and customer success.</p>
                                </div>
                            </div>
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>I want to provide feedback</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>We appreciate your feedback! You can rate the dishes and restaurant partners directly in the order history section of your profile or send your suggestions to feedback@khaalo.com.</p>
                                </div>
                            </div>
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>Can I edit my order?</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>Orders can only be modified (adding items, changing address details) before the restaurant partner accepts and starts preparing your food. Please contact our support chat immediately to request edits.</p>
                                </div>
                            </div>
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>I want to cancel my order</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>Cancellations can be made within 60 seconds of order placement for a full refund. After this window, restaurant partners start preparing food and a cancellation fee matching the order total is applied to cover their cost.</p>
                                </div>
                            </div>
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>Will Khaalo be accountable for quality/quantity?</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>While the respective restaurant is responsible for preparation, packaging, and portion sizing, Khaalo takes full accountability for your delivery satisfaction. We will issue refunds, coupon codes, or replacements if you receive incorrect or sub-standard orders.</p>
                                </div>
                            </div>
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>Is there a minimum order value?</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>No! There is no minimum order value. You are welcome to order a single beverage or dessert. However, orders below ₹149 may carry a small cart value surcharge.</p>
                                </div>
                            </div>
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>Do you charge for delivery?</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>Delivery charges depend on distance, local traffic, weather conditions, and peak demand hours. Khaalo Gold subscribers receive Free Delivery on all orders above ₹199 from partners within a 10km radius.</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 2. Partner Onboarding Panel -->
                    <div class="help-section" id="section-partner">
                        <h2>Partner Onboarding</h2>
                        <div class="accordion-list">
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>I want to partner my restaurant with Khaalo</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>To list your restaurant on Khaalo, navigate to partner.khaalo.com and fill in the merchant registration form. Enter your shop details, upload legal documents, list your menu, and submit for verification.</p>
                                </div>
                            </div>
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>What are the mandatory documents needed to list my restaurant?</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>You need: 1. FSSAI Registration License. 2. GSTIN Certificate. 3. PAN Card of the proprietor/business entity. 4. Bank account statement/cancelled cheque for vendor weekly settlements.</p>
                                </div>
                            </div>
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>I want to opt-out from Google reserve</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>Google Reserve allows customers to discover and order from your kitchen directly from Google Search/Maps. You can opt-out of this integration at any time in your Partner Portal under Integrations & API settings.</p>
                                </div>
                            </div>
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>After I submit all documents, how long will it take to go live?</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>It takes 24 to 48 business hours for our regional operations team to audit your documentation, set up your restaurant profile, and activate your listing on the customer application.</p>
                                </div>
                            </div>
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>What is this one-time Onboarding fee? Do I have to pay it while registering?</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>Registration is completely free! We charge a nominal one-time onboarding fee to set up your tablets, packaging materials, and listing photography. This fee is automatically deducted from your first week's settlement, so you do not have to pay anything upfront.</p>
                                </div>
                            </div>
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>Who should I contact if I need help & support in getting onboarded?</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>We are here to help! You can reach our dedicated onboarding assistance team at onboarding@khaalo.com or call our merchant helpline at 1800-KHAALO-PARTNER (Mon-Sat, 9 AM - 6 PM).</p>
                                </div>
                            </div>
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>How much commission will I be charged by Khaalo?</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>Our standard commission rates range from 15% to 22% on total order volume, depending on whether you utilize our delivery fleet (Khaalo Delivered) or fulfill orders using your own staff (Self Delivered).</p>
                                </div>
                            </div>
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>I don't have an FSSAI licence for my restaurant. Can it still be onboarded?</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>No. FSSAI registration/license is a mandatory legal compliance required by food safety regulations in India. We cannot list any restaurant, cloud kitchen, or home chef on our platform without a valid FSSAI license number.</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 3. Legal Panel -->
                    <div class="help-section" id="section-legal">
                        <h2>Legal</h2>
                        <div class="accordion-list">
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>Terms of Use</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>These terms of use govern your license and usage of the Khaalo mobile application, web ordering portals, API endpoints, and delivery services. By accessing or using our services, you agree to comply with our code of conduct, payment rules, and fair usage guidelines.</p>
                                </div>
                            </div>
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>Privacy Policy</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>We prioritize your privacy. This policy describes how we collect, store, and utilize your personal information (location, device ID, contact details, payment history) to improve your experience. We do not sell your personal data to third parties, and all payment transactions are fully encrypted.</p>
                                </div>
                            </div>
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>Cancellations and Refunds</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>As a general rule, buyer is not entitled to cancel order once placed. However, a refund may be issued if: 1. The restaurant rejects the order due to item stockout. 2. The order is cancelled within the 60-second window. 3. Our delivery partner is unable to contact you after reaching the location.</p>
                                </div>
                            </div>
                            <div class="accordion-item">
                                <button class="accordion-header">
                                    <span>Terms of Use for Khaalo ON-TIME / Assured</span>
                                    <span class="chevron">▼</span>
                                </button>
                                <div class="accordion-body">
                                    <p>Our Khaalo Assured program guarantees delivery within the estimated duration shown at checkout. If the order is delayed by more than 10 minutes (excluding severe weather and traffic emergencies), we will credit a cashback voucher worth 50% of your order value to your wallet balance.</p>
                                </div>
                            </div>
                        </div>
                    </div>

                </section>
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

    <!-- Scripts -->
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            // Accordion toggles
            const accordionHeaders = document.querySelectorAll('.accordion-header');
            accordionHeaders.forEach(header => {
                header.addEventListener('click', () => {
                    const currentItem = header.closest('.accordion-item');
                    const isExpanded = currentItem.classList.contains('expanded');

                    // Close all accordion items in current section
                    const parentSection = currentItem.closest('.help-section');
                    if (parentSection) {
                        parentSection.querySelectorAll('.accordion-item').forEach(item => {
                            item.classList.remove('expanded');
                            const b = item.querySelector('.accordion-body');
                            if (b) b.style.maxHeight = null;
                        });
                    }

                    // Toggle current item if it wasn't expanded
                    if (!isExpanded) {
                        currentItem.classList.add('expanded');
                        const body = currentItem.querySelector('.accordion-body');
                        if (body) {
                            body.style.maxHeight = body.scrollHeight + 'px';
                        }
                    }
                });
            });

            // Tab Switching (FAQs / Partner Onboarding / Legal)
            const tabs = document.querySelectorAll('.help-tab');
            const sections = document.querySelectorAll('.help-section');

            tabs.forEach(tab => {
                tab.addEventListener('click', () => {
                    const tabId = tab.getAttribute('data-tab');
                    
                    tabs.forEach(t => t.classList.remove('active'));
                    sections.forEach(s => s.classList.remove('active'));

                    tab.classList.add('active');
                    const targetSection = document.getElementById('section-' + tabId);
                    if (targetSection) {
                        targetSection.classList.add('active');
                    }
                });
            });
        });
    </script>
</body>
</html>





