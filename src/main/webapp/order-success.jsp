<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.khaalo.model.User" %>
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

    String orderId = request.getParameter("orderId");
    if (orderId == null) {
        orderId = "KH-" + (int)(Math.random() * 900000 + 100000);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Placed Successfully! | Khaalo</title>
    <meta http-equiv="refresh" content="8;url=restaurants.jsp">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #ff6b35;
            --primary-dark: #e0531c;
            --bg-body: #f8fafc;
            --bg-surface: #ffffff;
            --border-subtle: #e2e8f0;
            --text-primary: #0f172a;
            --text-secondary: #475569;
            --text-muted: #94a3b8;
            --radius-lg: 16px;
            --space-md: 16px;
        }

        body {
            font-family: 'Outfit', sans-serif;
            background-color: var(--bg-body);
            color: var(--text-primary);
            margin: 0;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
        }

        .success-card {
            background: var(--bg-surface);
            border-radius: var(--radius-lg);
            border: 1px solid var(--border-subtle);
            box-shadow: 0 24px 80px rgba(0, 0, 0, 0.05);
            padding: 48px;
            max-width: 440px;
            width: 90%;
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: var(--space-md);
        }

        .success-card h2 {
            font-size: 1.6rem;
            font-weight: 900;
            color: var(--text-primary);
            margin: 8px 0 0;
        }

        .success-order-id {
            font-size: 0.9rem;
            font-weight: 700;
            background: #f1f5f9;
            border: 1px solid var(--border-subtle);
            padding: 8px 18px;
            border-radius: 8px;
            color: var(--text-secondary);
            letter-spacing: 0.5px;
        }

        /* SVG Checkmark Draw Animation */
        .success-checkmark-wrap {
            width: 80px;
            height: 80px;
            position: relative;
        }

        .checkmark-svg {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            display: block;
            stroke-width: 3;
            stroke: #4CAF50;
            stroke-miterlimit: 10;
            box-shadow: inset 0px 0px 0px #4CAF50;
            animation: fillCheckmark .4s ease-in-out .4s forwards, scaleCheckmark .3s ease-in-out .9s forwards;
        }

        .checkmark-circle {
            stroke-dasharray: 166;
            stroke-dashoffset: 166;
            stroke-width: 3;
            stroke-linecap: round;
            stroke: #4CAF50;
            fill: none;
            animation: strokeCheckmark 0.6s cubic-bezier(0.65, 0, 0.45, 1) forwards;
        }

        .checkmark-check {
            transform-origin: 50% 50%;
            stroke-dasharray: 48;
            stroke-dashoffset: 48;
            stroke-width: 3;
            stroke-linecap: round;
            stroke: #FFFFFF;
            animation: strokeCheckmark 0.3s cubic-bezier(0.65, 0, 0.45, 1) 0.8s forwards;
        }

        @keyframes strokeCheckmark {
            100% { stroke-dashoffset: 0; }
        }

        @keyframes fillCheckmark {
            100% { box-shadow: inset 0px 0px 0px 40px #4CAF50; }
        }

        @keyframes scaleCheckmark {
            0%, 100% { transform: none; }
            50% { transform: scale3d(1.1, 1.1, 1); }
        }

        /* Delivery Bike Animation */
        .delivery-animation-box {
            position: relative;
            width: 100%;
            height: 60px;
            overflow: hidden;
            margin: 10px 0;
            background: #f8fafc;
            border-radius: 8px;
        }

        .delivery-bike-icon {
            font-size: 2.2rem;
            position: absolute;
            bottom: 8px;
            left: -50px;
            animation: driveBike 4s cubic-bezier(0.25, 0.46, 0.45, 0.94) infinite;
        }

        .delivery-road {
            position: absolute;
            bottom: 4px;
            left: 0;
            width: 100%;
            height: 3px;
            background: repeating-linear-gradient(90deg, var(--border-subtle) 0px, var(--border-subtle) 10px, transparent 10px, transparent 20px);
        }

        @keyframes driveBike {
            0% { left: -50px; }
            100% { left: 100%; }
        }

        .success-message {
            font-size: 0.92rem;
            color: var(--text-secondary);
            line-height: 1.5;
            margin: 10px 0;
        }

        .pay-submit-btn {
            width: 100%;
            padding: 16px;
            background: var(--primary);
            border: none;
            color: white;
            font-size: 1rem;
            font-weight: 800;
            border-radius: 10px;
            cursor: pointer;
            transition: background 0.2s;
            text-decoration: none;
            display: inline-block;
            box-sizing: border-box;
        }

        .pay-submit-btn:hover {
            background: var(--primary-dark);
        }

        .redirect-countdown {
            font-size: 0.8rem;
            color: var(--text-muted);
            margin-top: 10px;
        }
    </style>
</head>
<body>

    <div class="success-card">
        <div class="success-checkmark-wrap">
            <svg class="checkmark-svg" viewBox="0 0 52 52">
                <circle class="checkmark-circle" cx="26" cy="26" r="25" fill="none"/>
                <path class="checkmark-check" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>
            </svg>
        </div>
        
        <h2>Order Placed Successfully!</h2>
        <p class="success-order-id">Order ID: <%= orderId %></p>
        
        <div class="delivery-animation-box">
            <div class="delivery-bike-icon">🛵</div>
            <div class="delivery-road"></div>
        </div>
        
        <p class="success-message">Your hot meal is being prepared and will be delivered by our partner in <strong>25-35 mins</strong>.</p>
        
        <a href="restaurants.jsp" class="pay-submit-btn">Go to Homepage</a>
        
        <p class="redirect-countdown">Redirecting to Homepage in 8 seconds...</p>
    </div>
</body>
</html>
