<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.khaalo.model.User" %>
<%@ page import="com.khaalo.model.Cart" %>
<%@ page import="com.khaalo.model.CartItem" %>
<%@ page import="com.khaalo.model.Address" %>
<%@ page import="com.khaalo.model.Restaurant" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("restaurants.jsp?loginRequired=true#signInModalOverlay");
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

    String restaurantId = request.getParameter("restaurantId");
    String subtotalStr = request.getParameter("subtotal");
    String deliveryFeeStr = request.getParameter("deliveryFee");
    String taxesStr = request.getParameter("taxes");
    String grandTotalStr = request.getParameter("grandTotal");
    String addressIdStr = request.getParameter("addressId");

    if (restaurantId == null || grandTotalStr == null || addressIdStr == null) {
        response.sendRedirect("CartServlet");
        return;
    }

    double subtotal = Double.parseDouble(subtotalStr != null ? subtotalStr : "0.0");
    double deliveryFee = Double.parseDouble(deliveryFeeStr != null ? deliveryFeeStr : "0.0");
    double taxes = Double.parseDouble(taxesStr != null ? taxesStr : "0.0");
    double grandTotal = Double.parseDouble(grandTotalStr);
    int addressId = Integer.parseInt(addressIdStr);

    Restaurant restaurant = new com.khaalo.daoimpl.RestaurantDAOImpl().getRestaurantById(restaurantId);
    Address address = new com.khaalo.daoimpl.AddressDAOImpl().getAddressById(addressId);
    Cart cart = (Cart) session.getAttribute("cart");
    List<CartItem> cartItems = (cart != null) ? cart.getItems() : new java.util.ArrayList<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secure Payment | Khaalo</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #ff6b35;
            --primary-light: rgba(255, 107, 53, 0.08);
            --primary-dark: #e0531c;
            --bg-body: #f8fafc;
            --bg-surface: #ffffff;
            --bg-card: #ffffff;
            --bg-card-hover: #fafafa;
            --border-subtle: #e2e8f0;
            --text-primary: #0f172a;
            --text-secondary: #475569;
            --text-muted: #94a3b8;
            --radius-md: 10px;
            --radius-lg: 16px;
            --space-sm: 8px;
            --space-md: 16px;
            --space-lg: 24px;
            --space-xl: 32px;
        }

        body {
            font-family: 'Outfit', sans-serif;
            background-color: var(--bg-body);
            color: var(--text-primary);
            margin: 0;
            padding: 0;
        }

        /* Top Navbar */
        .navbar {
            background: var(--bg-surface);
            border-bottom: 1px solid var(--border-subtle);
            padding: 16px var(--space-xl);
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .logo-wrap {
            display: flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
        }

        .logo-img {
            font-size: 1.8rem;
        }

        .logo-text {
            font-weight: 850;
            font-size: 1.45rem;
            color: var(--text-primary);
        }

        .logo-orange {
            color: var(--primary);
        }

        .nav-back-link {
            text-decoration: none;
            color: var(--text-secondary);
            font-weight: 700;
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            gap: 6px;
            transition: color 0.2s;
        }

        .nav-back-link:hover {
            color: var(--primary);
        }

        /* Main Grid */
        .payment-container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 var(--space-lg);
            display: grid;
            grid-template-columns: 1.7fr 1fr;
            gap: var(--space-lg);
        }

        .card {
            background: var(--bg-surface);
            border: 1px solid var(--border-subtle);
            border-radius: var(--radius-lg);
            padding: var(--space-lg);
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.02);
            margin-bottom: var(--space-lg);
        }

        .section-title {
            font-size: 1.25rem;
            font-weight: 800;
            margin-top: 0;
            margin-bottom: var(--space-md);
            color: var(--text-primary);
        }

        /* Tabs Selection Hack */
        .payment-wrapper {
            display: flex;
            border: 1px solid var(--border-subtle);
            border-radius: var(--radius-lg);
            overflow: hidden;
            background: var(--bg-surface);
            min-height: 480px;
        }

        .payment-sidebar {
            width: 35%;
            background: #f8fafc;
            border-right: 1px solid var(--border-subtle);
            display: flex;
            flex-direction: column;
        }

        .payment-tab-label {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 20px;
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--text-secondary);
            cursor: pointer;
            border-left: 4px solid transparent;
            transition: all 0.2s;
            user-select: none;
        }

        .payment-tab-label:hover {
            background: #f1f5f9;
            color: var(--text-primary);
        }

        .payment-content {
            width: 65%;
            padding: var(--space-lg);
        }

        .payment-panel {
            display: none;
        }

        /* Show panels based on selected radio */
        #tab-recommended-input:checked ~ .payment-wrapper .payment-sidebar label[for="tab-recommended-input"],
        #tab-cards-input:checked ~ .payment-wrapper .payment-sidebar label[for="tab-cards-input"],
        #tab-netbanking-input:checked ~ .payment-wrapper .payment-sidebar label[for="tab-netbanking-input"],
        #tab-wallets-input:checked ~ .payment-wrapper .payment-sidebar label[for="tab-wallets-input"],
        #tab-cod-input:checked ~ .payment-wrapper .payment-sidebar label[for="tab-cod-input"] {
            background: var(--bg-surface);
            color: var(--primary);
            border-left-color: var(--primary);
        }

        #tab-recommended-input:checked ~ .payment-wrapper .payment-content #panel-recommended,
        #tab-cards-input:checked ~ .payment-wrapper .payment-content #panel-cards,
        #tab-netbanking-input:checked ~ .payment-wrapper .payment-content #panel-netbanking,
        #tab-wallets-input:checked ~ .payment-wrapper .payment-content #panel-wallets,
        #tab-cod-input:checked ~ .payment-wrapper .payment-content #panel-cod {
            display: block;
        }

        /* Payment Content Details */
        .upi-options-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .upi-pay-submit-btn {
            display: flex;
            align-items: center;
            gap: 16px;
            width: 100%;
            padding: 16px;
            background: var(--bg-card);
            border: 1px solid var(--border-subtle);
            border-radius: var(--radius-lg);
            font-size: 0.98rem;
            font-weight: 700;
            color: var(--text-primary);
            cursor: pointer;
            transition: all 0.2s;
            text-align: left;
            font-family: inherit;
        }

        .upi-pay-submit-btn:hover {
            border-color: var(--primary);
            background: var(--bg-card-hover);
            transform: translateY(-2px);
        }

        .upi-pay-submit-btn img {
            width: 28px;
            height: 28px;
            object-fit: contain;
        }

        .upi-arrow {
            margin-left: auto;
            color: var(--text-muted);
        }

        /* Card form fields */
        .payment-field {
            margin-bottom: var(--space-md);
        }

        .payment-field input, .payment-field select {
            width: 100%;
            padding: 14px;
            border-radius: var(--radius-md);
            border: 1px solid var(--border-subtle);
            font-size: 0.95rem;
            font-family: inherit;
            box-sizing: border-box;
            background: var(--bg-surface);
            color: var(--text-primary);
        }

        .payment-row-fields {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: var(--space-md);
        }

        .pay-submit-btn {
            width: 100%;
            padding: 16px;
            background: var(--primary);
            border: none;
            color: white;
            font-size: 1rem;
            font-weight: 800;
            border-radius: var(--radius-md);
            cursor: pointer;
            transition: background 0.2s;
            font-family: inherit;
        }

        .pay-submit-btn:hover {
            background: var(--primary-dark);
        }

        /* Banks layout */
        .banks-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
            gap: 12px;
        }

        .bank-submit-btn {
            background: var(--bg-card);
            border: 1px solid var(--border-subtle);
            padding: 14px;
            border-radius: var(--radius-md);
            font-weight: 700;
            cursor: pointer;
            text-align: center;
            font-size: 0.85rem;
            transition: all 0.2s;
            font-family: inherit;
            width: 100%;
        }

        .bank-submit-btn:hover {
            border-color: var(--primary);
            background: var(--bg-card-hover);
        }

        .wallet-card {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border: 1px solid var(--border-subtle);
            border-radius: var(--radius-md);
            padding: var(--space-md);
            margin-bottom: 12px;
        }

        .wallet-name {
            font-weight: 700;
            font-size: 0.95rem;
        }

        .wallet-desc {
            font-size: 0.8rem;
            color: var(--text-muted);
        }

        /* Order Summary Panel */
        .bill-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            font-size: 0.92rem;
            color: var(--text-secondary);
        }

        .bill-divider {
            border: none;
            border-top: 1px dashed var(--border-subtle);
            margin: 16px 0;
        }

        .grand-total-row {
            font-size: 1.15rem;
            font-weight: 800;
            color: var(--text-primary);
        }

        .address-badge {
            background: #f1f5f9;
            border-radius: 10px;
            padding: 12px;
            font-size: 0.88rem;
            color: var(--text-secondary);
            line-height: 1.5;
        }
    </style>
</head>
<body>

    <!-- Header Navbar -->
    <nav class="navbar">
        <a href="restaurants.jsp" class="logo-wrap">
            <span class="logo-img">🥣</span>
            <span class="logo-text">Khaalo<span class="logo-orange">.</span></span>
        </a>
        <a href="CartServlet" class="nav-back-link">
            ← Back to Cart
        </a>
    </nav>

    <!-- Radios for zero-js tabs switching -->
    <input type="radio" id="tab-recommended-input" name="payment-tabs" checked style="display:none;">
    <input type="radio" id="tab-cards-input" name="payment-tabs" style="display:none;">
    <input type="radio" id="tab-netbanking-input" name="payment-tabs" style="display:none;">
    <input type="radio" id="tab-wallets-input" name="payment-tabs" style="display:none;">
    <input type="radio" id="tab-cod-input" name="payment-tabs" style="display:none;">

    <!-- Grid Container -->
    <main class="payment-container">
        
        <!-- Left Side: Tabs Selection -->
        <div class="payment-wrapper">
            <div class="payment-sidebar">
                <label for="tab-recommended-input" class="payment-tab-label">🌟 Recommended</label>
                <label for="tab-cards-input" class="payment-tab-label">💳 Cards</label>
                <label for="tab-netbanking-input" class="payment-tab-label">🏦 Net Banking</label>
                <label for="tab-wallets-input" class="payment-tab-label">👛 Wallets</label>
                <label for="tab-cod-input" class="payment-tab-label">💵 Cash on Delivery</label>
            </div>

            <div class="payment-content">
                
                <!-- 1. Recommended UPI Tab -->
                <div class="payment-panel" id="panel-recommended">
                    <h3 class="section-title">Recommended UPI Options</h3>
                    <div class="upi-options-list">
                        <form action="OrderServlet" method="POST">
                            <input type="hidden" name="restaurantId" value="<%= restaurantId %>">
                            <input type="hidden" name="subtotal" value="<%= subtotal %>">
                            <input type="hidden" name="deliveryFee" value="<%= deliveryFee %>">
                            <input type="hidden" name="taxes" value="<%= taxes %>">
                            <input type="hidden" name="grandTotal" value="<%= grandTotal %>">
                            <input type="hidden" name="addressId" value="<%= addressId %>">
                            <input type="hidden" name="paymentMethod" value="PhonePe UPI">
                            <button type="submit" class="upi-pay-submit-btn">
                                <img src="https://img.icons8.com/color/48/phonepe.png" alt="PhonePe">
                                <span>PhonePe UPI</span>
                                <span class="upi-arrow">→</span>
                            </button>
                        </form>
                        <form action="OrderServlet" method="POST">
                            <input type="hidden" name="restaurantId" value="<%= restaurantId %>">
                            <input type="hidden" name="subtotal" value="<%= subtotal %>">
                            <input type="hidden" name="deliveryFee" value="<%= deliveryFee %>">
                            <input type="hidden" name="taxes" value="<%= taxes %>">
                            <input type="hidden" name="grandTotal" value="<%= grandTotal %>">
                            <input type="hidden" name="addressId" value="<%= addressId %>">
                            <input type="hidden" name="paymentMethod" value="Google Pay UPI">
                            <button type="submit" class="upi-pay-submit-btn">
                                <img src="https://img.icons8.com/color/48/google-pay.png" alt="Google Pay">
                                <span>Google Pay UPI</span>
                                <span class="upi-arrow">→</span>
                            </button>
                        </form>
                        <form action="OrderServlet" method="POST">
                            <input type="hidden" name="restaurantId" value="<%= restaurantId %>">
                            <input type="hidden" name="subtotal" value="<%= subtotal %>">
                            <input type="hidden" name="deliveryFee" value="<%= deliveryFee %>">
                            <input type="hidden" name="taxes" value="<%= taxes %>">
                            <input type="hidden" name="grandTotal" value="<%= grandTotal %>">
                            <input type="hidden" name="addressId" value="<%= addressId %>">
                            <input type="hidden" name="paymentMethod" value="Amazon Pay UPI">
                            <button type="submit" class="upi-pay-submit-btn">
                                <img src="https://img.icons8.com/color/48/amazon-pay.png" alt="Amazon Pay">
                                <span>Amazon Pay UPI</span>
                                <span class="upi-arrow">→</span>
                            </button>
                        </form>
                    </div>
                </div>

                <!-- 2. Cards Tab -->
                <div class="payment-panel" id="panel-cards">
                    <h3 class="section-title">Pay via Credit / Debit Card</h3>
                    <form action="OrderServlet" method="POST">
                        <input type="hidden" name="restaurantId" value="<%= restaurantId %>">
                        <input type="hidden" name="subtotal" value="<%= subtotal %>">
                        <input type="hidden" name="deliveryFee" value="<%= deliveryFee %>">
                        <input type="hidden" name="taxes" value="<%= taxes %>">
                        <input type="hidden" name="grandTotal" value="<%= grandTotal %>">
                        <input type="hidden" name="addressId" value="<%= addressId %>">
                        <input type="hidden" name="paymentMethod" value="Credit/Debit Card">
                        
                        <div class="payment-field">
                            <input type="text" placeholder="Card Number" required pattern="\d{16}" title="16-digit card number">
                        </div>
                        <div class="payment-row-fields">
                            <div class="payment-field">
                                <input type="text" placeholder="MM/YY" required pattern="\d{2}/\d{2}">
                            </div>
                            <div class="payment-field">
                                <input type="password" placeholder="CVV" required pattern="\d{3}">
                            </div>
                        </div>
                        <div class="payment-field">
                            <input type="text" placeholder="Cardholder Name" required>
                        </div>
                        <button type="submit" class="pay-submit-btn">Pay Securely ₹<%= (int)grandTotal %></button>
                    </form>
                </div>

                <!-- 3. Net Banking Tab -->
                <div class="payment-panel" id="panel-netbanking">
                    <h3 class="section-title">Select Bank</h3>
                    <div class="banks-grid">
                        <form action="OrderServlet" method="POST">
                            <input type="hidden" name="restaurantId" value="<%= restaurantId %>">
                            <input type="hidden" name="subtotal" value="<%= subtotal %>">
                            <input type="hidden" name="deliveryFee" value="<%= deliveryFee %>">
                            <input type="hidden" name="taxes" value="<%= taxes %>">
                            <input type="hidden" name="grandTotal" value="<%= grandTotal %>">
                            <input type="hidden" name="addressId" value="<%= addressId %>">
                            <input type="hidden" name="paymentMethod" value="SBI Net Banking">
                            <button type="submit" class="bank-submit-btn">SBI</button>
                        </form>
                        <form action="OrderServlet" method="POST">
                            <input type="hidden" name="restaurantId" value="<%= restaurantId %>">
                            <input type="hidden" name="subtotal" value="<%= subtotal %>">
                            <input type="hidden" name="deliveryFee" value="<%= deliveryFee %>">
                            <input type="hidden" name="taxes" value="<%= taxes %>">
                            <input type="hidden" name="grandTotal" value="<%= grandTotal %>">
                            <input type="hidden" name="addressId" value="<%= addressId %>">
                            <input type="hidden" name="paymentMethod" value="HDFC Net Banking">
                            <button type="submit" class="bank-submit-btn">HDFC</button>
                        </form>
                        <form action="OrderServlet" method="POST">
                            <input type="hidden" name="restaurantId" value="<%= restaurantId %>">
                            <input type="hidden" name="subtotal" value="<%= subtotal %>">
                            <input type="hidden" name="deliveryFee" value="<%= deliveryFee %>">
                            <input type="hidden" name="taxes" value="<%= taxes %>">
                            <input type="hidden" name="grandTotal" value="<%= grandTotal %>">
                            <input type="hidden" name="addressId" value="<%= addressId %>">
                            <input type="hidden" name="paymentMethod" value="ICICI Net Banking">
                            <button type="submit" class="bank-submit-btn">ICICI</button>
                        </form>
                        <form action="OrderServlet" method="POST">
                            <input type="hidden" name="restaurantId" value="<%= restaurantId %>">
                            <input type="hidden" name="subtotal" value="<%= subtotal %>">
                            <input type="hidden" name="deliveryFee" value="<%= deliveryFee %>">
                            <input type="hidden" name="taxes" value="<%= taxes %>">
                            <input type="hidden" name="grandTotal" value="<%= grandTotal %>">
                            <input type="hidden" name="addressId" value="<%= addressId %>">
                            <input type="hidden" name="paymentMethod" value="Axis Net Banking">
                            <button type="submit" class="bank-submit-btn">Axis</button>
                        </form>
                    </div>
                </div>

                <!-- 4. Wallets Tab -->
                <div class="payment-panel" id="panel-wallets">
                    <h3 class="section-title">Wallets</h3>
                    <div class="wallets-list">
                        <div class="wallet-card">
                            <div>
                                <span class="wallet-name">Khaalo Wallet</span>
                                <span class="wallet-desc" style="display:block;">Balance: ₹450.00</span>
                            </div>
                            <form action="OrderServlet" method="POST">
                                <input type="hidden" name="restaurantId" value="<%= restaurantId %>">
                                <input type="hidden" name="subtotal" value="<%= subtotal %>">
                                <input type="hidden" name="deliveryFee" value="<%= deliveryFee %>">
                                <input type="hidden" name="taxes" value="<%= taxes %>">
                                <input type="hidden" name="grandTotal" value="<%= grandTotal %>">
                                <input type="hidden" name="addressId" value="<%= addressId %>">
                                <input type="hidden" name="paymentMethod" value="Khaalo Wallet">
                                <button type="submit" class="pay-submit-btn" style="padding: 10px 20px; font-size:0.85rem;">Pay Now</button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- 5. COD Tab -->
                <div class="payment-panel" id="panel-cod">
                    <h3 class="section-title">Cash on Delivery</h3>
                    <div style="margin-bottom: var(--space-lg); line-height: 1.5; color: var(--text-secondary);">
                        💳 Pay with Cash, Card, or UPI at your doorstep when the delivery partner arrives.
                    </div>
                    <form action="OrderServlet" method="POST">
                        <input type="hidden" name="restaurantId" value="<%= restaurantId %>">
                        <input type="hidden" name="subtotal" value="<%= subtotal %>">
                        <input type="hidden" name="deliveryFee" value="<%= deliveryFee %>">
                        <input type="hidden" name="taxes" value="<%= taxes %>">
                        <input type="hidden" name="grandTotal" value="<%= grandTotal %>">
                        <input type="hidden" name="addressId" value="<%= addressId %>">
                        <input type="hidden" name="paymentMethod" value="COD">
                        <button type="submit" class="pay-submit-btn">Place Order (COD)</button>
                    </form>
                </div>

            </div>
        </div>

        <!-- Right Side: Order Summary -->
        <div class="payment-summary">
            
            <div class="card">
                <h3 class="section-title" style="font-size: 1.1rem; border-bottom: 1px solid var(--border-subtle); padding-bottom: 10px; margin-bottom: 12px;">Order Summary</h3>
                <div style="font-size:0.9rem; font-weight:700; color:var(--primary); margin-bottom: 10px;">
                    <%= restaurant != null ? restaurant.getName() : "Secure Checkout" %>
                </div>
                <div style="max-height: 160px; overflow-y: auto; margin-bottom: var(--space-md);">
                    <%
                        for (CartItem item : cartItems) {
                    %>
                        <div style="display:flex; justify-content:space-between; font-size:0.85rem; margin-bottom:6px; color:var(--text-secondary);">
                            <span><%= item.getDishName() %> (x<%= item.getQuantity() %>)</span>
                            <span>₹<%= (int)(item.getDishPrice() * item.getQuantity()) %></span>
                        </div>
                    <%
                        }
                    %>
                </div>

                <hr class="bill-divider">

                <div class="bill-row">
                    <span>Subtotal</span>
                    <span>₹<%= (int)subtotal %></span>
                </div>
                <div class="bill-row">
                    <span>Delivery Fee</span>
                    <span>₹<%= (int)deliveryFee %></span>
                </div>
                <div class="bill-row">
                    <span>Taxes</span>
                    <span>₹<%= (int)taxes %></span>
                </div>

                <hr class="bill-divider">

                <div class="bill-row grand-total-row">
                    <span>To Pay</span>
                    <span>₹<%= (int)grandTotal %></span>
                </div>
            </div>

            <div class="card">
                <h3 class="section-title" style="font-size: 1.1rem; border-bottom: 1px solid var(--border-subtle); padding-bottom: 10px; margin-bottom: 12px;">Delivering To</h3>
                <div class="address-badge">
                    <% if (address != null) { %>
                        <strong><%= address.getAddressType().toUpperCase() %></strong><br>
                        <%= address.getFlatNo() %>, <%= address.getAreaDetails() %><br>
                        <%= address.getCity() %> - <%= address.getPincode() %>
                    <% } else { %>
                        Address not specified.
                    <% } %>
                </div>
            </div>

        </div>

    </main>

</body>
</html>
