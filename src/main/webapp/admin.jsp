<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true"%>
<%@ page import="com.khaalo.model.User" %>
<%
    User adminUser = (User) session.getAttribute("user");
    if (adminUser == null || !"Administrator".equals(adminUser.getRole())) {
        response.sendRedirect("restaurants.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khaalo Admin Panel</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            /* Warm Appetite-Stimulating Neutrals & Brand Colors */
            --primary: #FF6B35;
            --primary-dark: #E85D2C;
            --primary-light: #FF8A5C;
            --primary-glow: rgba(255, 107, 53, 0.15);
            --bg-primary: #FFF9F2;
            --bg-secondary: #FFF3E0;
            --bg-card: #FFFFFF;
            --bg-card-hover: #FFFDF9;
            --text-primary: #2C1B10;
            --text-secondary: #5C4333;
            --text-muted: #8E796A;
            --border-subtle: rgba(255, 107, 53, 0.12);
            --radius-md: 12px;
            --radius-lg: 16px;
            --radius-xl: 24px;
            --sidebar-width: 260px;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            margin: 0;
            font-family: 'Outfit', 'Poppins', sans-serif;
            background: linear-gradient(175deg, #FFFDF9 0%, #FFF5E6 40%, #FFE5CC 80%, #FFD9B3 100%);
            background-attachment: fixed;
            color: var(--text-primary);
            display: flex;
            height: 100vh;
            overflow: hidden;
        }

        /* Scrollbars */
        ::-webkit-scrollbar { width: 6px; height: 6px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: #FFE0CC; border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: var(--primary-light); }

        /* Sidebar - Dark Coffee Theme */
        .sidebar {
            width: var(--sidebar-width);
            background: linear-gradient(180deg, #2C1B10 0%, #1A0F0A 100%);
            display: flex;
            flex-direction: column;
            padding: 24px 0;
            flex-shrink: 0;
            z-index: 100;
            box-shadow: 4px 0 24px rgba(44, 27, 16, 0.25);
            border-right: 1px solid rgba(255, 255, 255, 0.05);
        }

        .sidebar-header {
            padding: 0 24px 24px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .brand-logo-glow {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, #fff0eb 0%, #ffe4d6 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            box-shadow: 0 4px 12px rgba(255, 107, 53, 0.3);
            border: 2px solid #ffffff;
        }

        .brand-title {
            font-size: 1.4rem;
            font-weight: 800;
            color: #ffffff;
            letter-spacing: -0.5px;
        }

        .brand-title span {
            color: var(--primary);
        }

        .nav-item {
            padding: 14px 24px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 12px;
            color: #A09085;
            transition: all 0.25s ease;
            position: relative;
            font-weight: 600;
            font-size: 0.95rem;
        }

        .nav-item svg {
            width: 20px;
            height: 20px;
            fill: currentColor;
            transition: transform 0.25s;
        }

        .nav-item:hover {
            color: #ffffff;
            background: rgba(255, 255, 255, 0.03);
        }

        .nav-item:hover svg {
            transform: translateX(2px);
        }

        .nav-item.active {
            color: var(--primary);
            background: linear-gradient(90deg, rgba(255, 107, 53, 0.12) 0%, transparent 100%);
        }

        .nav-item.active::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 4px;
            background: var(--primary);
            box-shadow: 0 0 12px var(--primary);
            border-radius: 0 4px 4px 0;
        }

        .sidebar-footer {
            margin-top: auto;
            padding: 20px 24px 0;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 20px;
        }

        .user-avatar {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary) 0%, #ea580c 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 16px;
            color: white;
            box-shadow: 0 4px 12px rgba(255, 107, 53, 0.2);
            border: 2px solid rgba(255, 255, 255, 0.1);
        }

        .user-details {
            display: flex;
            flex-direction: column;
        }

        .user-name {
            font-weight: 700;
            font-size: 0.9rem;
            color: #ffffff;
        }

        .user-role {
            font-size: 0.75rem;
            color: #A09085;
            font-weight: 500;
        }

        .back-link {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            color: #A09085;
            text-decoration: none;
            font-size: 0.85rem;
            margin-bottom: 12px;
            font-weight: 600;
            transition: color 0.2s;
        }

        .back-link:hover { color: #ffffff; }

        .logout-btn {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 12px;
            background: rgba(239, 68, 68, 0.12);
            color: #ef4444;
            text-decoration: none;
            border-radius: 12px;
            font-weight: 700;
            font-size: 0.9rem;
            transition: all 0.2s;
            border: 1px solid rgba(239, 68, 68, 0.1);
        }

        .logout-btn:hover {
            background: #ef4444;
            color: white;
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.2);
        }

        /* Main Content Container */
        .main-content {
            flex-grow: 1;
            padding: 40px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 28px;
        }

        .header-title-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .main-content h1 {
            font-size: 2rem;
            font-weight: 800;
            color: var(--text-primary);
            letter-spacing: -0.5px;
        }

        .tab-content {
            display: none;
            animation: fadeIn 0.4s ease;
        }

        .tab-content.active {
            display: flex;
            flex-direction: column;
            gap: 28px;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Cards Grid & Styles */
        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 20px;
        }

        .metric-card {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(25px);
            -webkit-backdrop-filter: blur(25px);
            border: 1.5px solid rgba(255, 107, 53, 0.08);
            border-radius: var(--radius-lg);
            padding: 24px;
            position: relative;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(44, 27, 16, 0.04);
            transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1), box-shadow 0.3s;
        }

        .metric-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 15px 35px rgba(255, 107, 53, 0.08);
        }

        .metric-icon-bg {
            position: absolute;
            right: -10px;
            bottom: -10px;
            width: 80px;
            height: 80px;
            opacity: 0.05;
            color: var(--primary);
        }

        .metric-icon-bg svg {
            width: 100%;
            height: 100%;
        }

        .metric-value {
            font-size: 2.2rem;
            font-weight: 800;
            color: var(--text-primary);
            line-height: 1.2;
            margin-bottom: 4px;
        }

        .metric-label {
            font-size: 0.8rem;
            font-weight: 700;
            text-transform: uppercase;
            color: var(--text-muted);
            letter-spacing: 0.8px;
        }

        /* Glassmorphic White Container Cards */
        .card {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(25px);
            -webkit-backdrop-filter: blur(25px);
            border: 1.5px solid rgba(255, 107, 53, 0.08);
            border-radius: var(--radius-xl);
            padding: 28px;
            box-shadow: 0 15px 40px rgba(44, 27, 16, 0.04);
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .card h2, .card h3 {
            font-size: 1.3rem;
            font-weight: 800;
            color: var(--text-primary);
            letter-spacing: -0.3px;
        }

        .charts-row {
            display: grid;
            grid-template-columns: 1.5fr 1fr;
            gap: 24px;
        }

        .chart-container {
            position: relative;
            height: 300px;
            width: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .canvas-chart {
            width: 100%;
            height: 100%;
        }

        .lists-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
        }

        /* List styling */
        .ranked-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .list-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 14px 18px;
            background: rgba(255, 107, 53, 0.04);
            border: 1px solid rgba(255, 107, 53, 0.06);
            border-radius: var(--radius-md);
            transition: transform 0.2s, background-color 0.2s;
        }

        .list-item:hover {
            transform: translateX(4px);
            background: rgba(255, 107, 53, 0.08);
        }

        .item-main {
            font-weight: 700;
            color: var(--text-primary);
            font-size: 0.95rem;
        }

        .item-sub {
            font-size: 0.85rem;
            color: var(--text-muted);
            font-weight: 600;
        }

        /* Filter Controls */
        .controls-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
        }

        .filter-group {
            display: flex;
            gap: 12px;
            align-items: center;
        }

        input[type="text"], input[type="number"], select {
            background: white;
            border: 1.5px solid rgba(255, 107, 53, 0.12);
            color: var(--text-primary);
            padding: 11px 18px;
            border-radius: 12px;
            font-family: inherit;
            font-size: 0.9rem;
            font-weight: 500;
            outline: none;
            transition: all 0.2s;
            box-shadow: 0 2px 8px rgba(44, 27, 16, 0.02);
        }

        input[type="text"]:focus, input[type="number"]:focus, select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px var(--primary-glow);
        }

        /* Buttons styling */
        .btn {
            background: linear-gradient(135deg, var(--primary) 0%, #ea580c 100%);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 12px;
            cursor: pointer;
            font-weight: 700;
            font-size: 0.9rem;
            font-family: inherit;
            transition: all 0.25s ease;
            box-shadow: 0 6px 20px rgba(255, 107, 53, 0.25);
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn:hover {
            transform: translateY(-1.5px);
            box-shadow: 0 8px 24px rgba(255, 107, 53, 0.35);
        }

        .btn:active { transform: translateY(0); }
        .btn-danger { background: #ef4444; box-shadow: 0 6px 20px rgba(239, 68, 68, 0.2); }
        .btn-danger:hover { background: #dc2626; box-shadow: 0 8px 24px rgba(239, 68, 68, 0.3); }
        
        .btn-outline {
            background: transparent;
            border: 1.5px solid rgba(255, 107, 53, 0.2);
            color: var(--text-primary);
            box-shadow: none;
        }

        .btn-outline:hover {
            background: rgba(255, 107, 53, 0.05);
            border-color: var(--primary);
        }

        .btn-sm { padding: 8px 14px; font-size: 0.8rem; border-radius: 8px; }

        /* Responsive Table styling */
        .table-container {
            overflow-x: auto;
            border-radius: var(--radius-md);
            border: 1px solid rgba(255, 107, 53, 0.08);
            box-shadow: 0 4px 15px rgba(44, 27, 16, 0.02);
            background: white;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th, td {
            padding: 16px 20px;
            text-align: left;
            border-bottom: 1px solid rgba(255, 107, 53, 0.06);
            font-size: 0.9rem;
        }

        th {
            background: rgba(255, 107, 53, 0.03);
            color: var(--text-secondary);
            font-weight: 700;
            text-transform: uppercase;
            font-size: 0.78rem;
            letter-spacing: 0.8px;
            cursor: pointer;
            user-select: none;
            transition: background-color 0.2s;
        }

        th:hover { background: rgba(255, 107, 53, 0.06); }
        th .sort-icon { display: inline-block; margin-left: 4px; opacity: 0.6; }

        tr { transition: background-color 0.2s; }
        tr:hover { background-color: rgba(255, 107, 53, 0.02); }

        /* Color Badges */
        .badge {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 700;
            display: inline-block;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .badge.role-administrator { background: rgba(255, 107, 53, 0.12); color: var(--primary-dark); }
        .badge.role-customer { background: rgba(92, 67, 51, 0.1); color: var(--text-secondary); }
        .badge.role-restaurant-owner { background: rgba(234, 179, 8, 0.12); color: #b57a00; }
        .badge.role-delivery-partner { background: rgba(59, 130, 246, 0.12); color: #1d4ed8; }
        .badge.role-help-support-agent { background: rgba(147, 51, 234, 0.12); color: #7e22ce; }

        .badge.status-pending { background: rgba(234, 179, 8, 0.12); color: #b57a00; }
        .badge.status-confirmed { background: rgba(59, 130, 246, 0.12); color: #1d4ed8; }
        .badge.status-preparing { background: rgba(249, 115, 22, 0.12); color: #c2410c; }
        .badge.status-delivered { background: rgba(34, 197, 94, 0.12); color: #15803d; }
        .badge.status-cancelled { background: rgba(239, 68, 68, 0.12); color: #b91c1c; }

        .badge.active { background: rgba(34, 197, 94, 0.12); color: #15803d; }
        .badge.inactive { background: rgba(239, 68, 68, 0.12); color: #b91c1c; }

        .action-btns { display: flex; gap: 8px; align-items: center; }
        select.status-select { padding: 6px 12px; font-size: 0.8rem; height: auto; border-radius: 8px; }

        /* Loader */
        .loader {
            border: 3px solid rgba(255, 107, 53, 0.1);
            border-radius: 50%;
            border-top: 3px solid var(--primary);
            width: 28px;
            height: 28px;
            animation: spin 0.8s linear infinite;
            margin: 20px auto;
            display: none;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Glassmorphic Modals */
        .modal-overlay {
            position: fixed; top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(44, 27, 16, 0.55);
            backdrop-filter: blur(8px);
            display: none; justify-content: center; align-items: center;
            z-index: 1000; opacity: 0; transition: opacity 0.3s ease;
        }

        .modal-overlay.active { display: flex; opacity: 1; }

        .modal {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(25px);
            border: 1.5px solid rgba(255, 107, 53, 0.12);
            border-radius: var(--radius-xl);
            padding: 32px;
            width: 100%;
            max-width: 440px;
            box-shadow: 0 25px 60px rgba(44, 27, 16, 0.2);
            display: flex;
            flex-direction: column;
            gap: 20px;
            transform: scale(0.9);
            transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
        }

        .modal-overlay.active .modal { transform: scale(1); }

        .modal-actions {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            margin-top: 8px;
        }

        /* Form Grid Layout */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 16px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .form-group label {
            font-size: 0.8rem;
            font-weight: 700;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* Status Toast Alert */
        .toast {
            position: fixed;
            bottom: 24px;
            right: 24px;
            background: #2C1B10;
            color: white;
            padding: 16px 24px;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            z-index: 1010;
            transform: translateY(100px);
            opacity: 0;
            transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
            font-weight: 600;
            font-size: 0.9rem;
            border-left: 4px solid var(--primary);
        }

        .toast.show { transform: translateY(0); opacity: 1; }

    </style>
</head>
<body>

    <!-- Sidebar Navigation -->
    <div class="sidebar">
        <div class="sidebar-header">
            <div class="brand-logo-glow">🍽️</div>
            <div class="brand-title">Khaalo <span>Admin</span></div>
        </div>

        <div class="nav-item active" data-tab="dashboard">
            <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-2 10h-4v4h-2v-4H7v-2h4V7h2v4h4v2z"/></svg>
            Dashboard
        </div>
        <div class="nav-item" data-tab="users">
            <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5s-3 1.34-3 3 1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
            Users
        </div>
        <div class="nav-item" data-tab="restaurants">
            <svg viewBox="0 0 24 24"><path d="M20 4H4v2h16V4zm1 10v-2l-1-5H4l-1 5v2h1v6h10v-6h4v6h2v-6h1zm-9 4H6v-4h6v4z"/></svg>
            Restaurants
        </div>
        <div class="nav-item" data-tab="orders">
            <svg viewBox="0 0 24 24"><path d="M17 18c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2zM7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zm1.75-2.23l.03-.12H15.5c.75 0 1.41-.41 1.75-1.03l3.58-6.49A1.003 1.003 0 0 0 20 7H5.21l-.94-2H1v2h2l3.6 7.59-1.35 2.44C4.52 15.37 5.48 17 7 17h12v-2H7l1.75-2.23z"/></svg>
            Orders
        </div>
        <div class="nav-item" data-tab="payments">
            <svg viewBox="0 0 24 24"><path d="M21 18v1c0 1.1-.9 2-2 2H5c-1.11 0-2-.9-2-2V5c0-1.1.89-2 2-2h14c1.1 0 2 .9 2 2v1h-9c-1.11 0-2 .9-2 2v8c0 1.1.89 2 2 2h9zm-9-2h10V8H12v8zm4-2.5c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5z"/></svg>
            Payments
        </div>

        <div class="sidebar-footer">
            <div class="user-info">
                <div class="user-avatar">
                    <%= adminUser.getFullName().substring(0, 1).toUpperCase() %>
                </div>
                <div class="user-details">
                    <span class="user-name"><%= adminUser.getFullName() %></span>
                    <span class="user-role">Administrator</span>
                </div>
            </div>

            <a href="logout" class="logout-btn">
                <svg viewBox="0 0 24 24" style="width:16px; height:16px; fill:none; stroke:currentColor; stroke-width:2;"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9"/></svg>
                Log Out
            </a>
        </div>
    </div>

    <!-- Main Content Area -->
    <div class="main-content">
        
        <!-- Tab 1: Dashboard -->
        <div id="tab-dashboard" class="tab-content active">
            <div class="header-title-section">
                <h1>Dashboard Overview</h1>
            </div>

            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-icon-bg">
                        <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2z"/></svg>
                    </div>
                    <div class="metric-value" id="stat-today-orders">0</div>
                    <div class="metric-label">Today's Orders</div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon-bg">
                        <svg viewBox="0 0 24 24"><path d="M21 18v1c0 1.1-.9 2-2 2H5c-1.11 0-2-.9-2-2V5c0-1.1.89-2 2-2h14c1.1 0 2 .9 2 2v1h-9c-1.11 0-2 .9-2 2v8c0 1.1.89 2 2 2h9z"/></svg>
                    </div>
                    <div class="metric-value" id="stat-revenue">₹0</div>
                    <div class="metric-label">Total Revenue</div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon-bg">
                        <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5z"/></svg>
                    </div>
                    <div class="metric-value" id="stat-active-users">0</div>
                    <div class="metric-label">Active Users</div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon-bg">
                        <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>
                    </div>
                    <div class="metric-value" id="stat-pending-orders">0</div>
                    <div class="metric-label">Pending Orders</div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon-bg">
                        <svg viewBox="0 0 24 24"><path d="M17 18c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2z"/></svg>
                    </div>
                    <div class="metric-value" id="stat-total-orders">0</div>
                    <div class="metric-label">Total Orders</div>
                </div>
            </div>

            <div class="charts-row">
                <div class="card">
                    <h3>Order Trends (Last 30 Days)</h3>
                    <div class="chart-container">
                        <canvas id="trendChart" class="canvas-chart"></canvas>
                    </div>
                </div>
                <div class="card">
                    <h3>Peak Ordering Hours</h3>
                    <div class="chart-container">
                        <canvas id="hoursChart" class="canvas-chart"></canvas>
                    </div>
                </div>
            </div>

            <div class="lists-row">
                <div class="card">
                    <h3>Top 5 Selling Items</h3>
                    <div class="ranked-list" id="top-items-list">
                        <!-- Populated via JS -->
                    </div>
                </div>
                <div class="card">
                    <h3>Top 5 Performing Restaurants</h3>
                    <div class="ranked-list" id="top-restaurants-list">
                        <!-- Populated via JS -->
                    </div>
                </div>
            </div>
        </div>

        <!-- Tab 2: Users -->
        <div id="tab-users" class="tab-content">
            <div class="header-title-section">
                <h1>User Management</h1>
            </div>

            <div class="card">
                <div class="controls-row">
                    <div class="filter-group">
                        <input type="text" id="user-search" placeholder="Search by name, email..." oninput="filterUsers()">
                        <select id="user-role-filter" onchange="filterUsers()">
                            <option value="">All Roles</option>
                            <option value="Administrator">Administrator</option>
                            <option value="Customer">Customer</option>
                            <option value="Restaurant Owner">Restaurant Owner</option>
                            <option value="Delivery Partner">Delivery Partner</option>
                            <option value="Help & Support Agent">Help & Support Agent</option>
                        </select>
                    </div>
                </div>

                <div class="loader" id="users-loader"></div>
                
                <div class="table-container">
                    <table id="users-table">
                        <thead>
                            <tr>
                                <th onclick="sortTable('users-table', 0)">User ID <span class="sort-icon">▼</span></th>
                                <th onclick="sortTable('users-table', 1)">Name <span class="sort-icon">▼</span></th>
                                <th onclick="sortTable('users-table', 2)">Email <span class="sort-icon">▼</span></th>
                                <th onclick="sortTable('users-table', 3)">Phone <span class="sort-icon">▼</span></th>
                                <th onclick="sortTable('users-table', 4)">Role <span class="sort-icon">▼</span></th>
                                <th onclick="sortTable('users-table', 5)">Date Joined <span class="sort-icon">▼</span></th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="users-tbody">
                            <!-- Populated via JS -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Tab 3: Restaurants -->
        <div id="tab-restaurants" class="tab-content">
            <div class="header-title-section">
                <h1>Restaurant Management</h1>
            </div>

            <div class="card">
                <div class="controls-row">
                    <div class="filter-group">
                        <input type="text" id="rest-search" placeholder="Search by name, location..." oninput="filterRestaurants()">
                    </div>
                </div>

                <div class="loader" id="rest-loader"></div>

                <div class="table-container">
                    <table id="restaurants-table">
                        <thead>
                            <tr>
                                <th onclick="sortTable('restaurants-table', 0)">Restaurant Name <span class="sort-icon">▼</span></th>
                                <th onclick="sortTable('restaurants-table', 1)">Rating <span class="sort-icon">▼</span></th>
                                <th onclick="sortTable('restaurants-table', 2)">Outlet Location <span class="sort-icon">▼</span></th>
                                <th onclick="sortTable('restaurants-table', 3)">Cuisines <span class="sort-icon">▼</span></th>
                                <th onclick="sortTable('restaurants-table', 4)">Total Orders <span class="sort-icon">▼</span></th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="rest-tbody">
                            <!-- Populated via JS -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Tab 4: Orders -->
        <div id="tab-orders" class="tab-content">
            <div class="header-title-section">
                <h1>Order Management</h1>
            </div>

            <div class="card">
                <div class="controls-row">
                    <div class="filter-group">
                        <input type="text" id="order-search" placeholder="Search by customer, restaurant..." oninput="filterOrders()">
                        <select id="order-status-filter" onchange="filterOrders()">
                            <option value="">All Statuses</option>
                            <option value="Pending">Pending</option>
                            <option value="Confirmed">Confirmed</option>
                            <option value="Preparing">Preparing</option>
                            <option value="Out for Delivery">Out for Delivery</option>
                            <option value="Delivered">Delivered</option>
                            <option value="Cancelled">Cancelled</option>
                        </select>
                    </div>
                </div>

                <div class="loader" id="orders-loader"></div>

                <div class="table-container">
                    <table id="orders-table">
                        <thead>
                            <tr>
                                <th onclick="sortTable('orders-table', 0)">Order ID <span class="sort-icon">▼</span></th>
                                <th onclick="sortTable('orders-table', 1)">Customer <span class="sort-icon">▼</span></th>
                                <th onclick="sortTable('orders-table', 2)">Restaurant <span class="sort-icon">▼</span></th>
                                <th onclick="sortTable('orders-table', 3)">Total <span class="sort-icon">▼</span></th>
                                <th onclick="sortTable('orders-table', 4)">Status <span class="sort-icon">▼</span></th>
                                <th onclick="sortTable('orders-table', 5)">Date <span class="sort-icon">▼</span></th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="orders-tbody">
                            <!-- Populated via JS -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Tab 5: Payments -->
        <div id="tab-payments" class="tab-content">
            <div class="header-title-section">
                <h1>Payments & Finance</h1>
            </div>

            <div class="metrics-grid" style="grid-template-columns: repeat(4, 1fr);">
                <div class="metric-card">
                    <div class="metric-icon-bg">
                        <svg viewBox="0 0 24 24"><path d="M21 18v1c0 1.1-.9 2-2 2H5c-1.11 0-2-.9-2-2V5c0-1.1.89-2 2-2h14c1.1 0 2 .9 2 2v1h-9c-1.11 0-2 .9-2 2v8c0 1.1.89 2 2 2h9z"/></svg>
                    </div>
                    <div class="metric-value" id="pay-revenue">₹0</div>
                    <div class="metric-label">Total Revenue</div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon-bg">
                        <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>
                    </div>
                    <div class="metric-value" id="pay-refunds">₹0</div>
                    <div class="metric-label">Total Refunds</div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon-bg">
                        <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2z"/></svg>
                    </div>
                    <div class="metric-value" id="pay-avg">₹0</div>
                    <div class="metric-label">Avg Order Value</div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon-bg">
                        <svg viewBox="0 0 24 24"><path d="M17 18c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2z"/></svg>
                    </div>
                    <div class="metric-value" id="pay-txns">0</div>
                    <div class="metric-label">Total Transactions</div>
                </div>
            </div>

            <div class="card">
                <h3>Add New Coupon</h3>
                <form id="coupon-form" onsubmit="addCoupon(event)">
                    <div class="form-grid">
                        <div class="form-group">
                            <label>Coupon Code</label>
                            <input type="text" id="coupon-code" required placeholder="e.g. FESTIVE50">
                        </div>
                        <div class="form-group">
                            <label>Discount Percentage (%)</label>
                            <input type="number" id="coupon-pct" required min="1" max="100" placeholder="e.g. 20">
                        </div>
                        <div class="form-group">
                            <label>Max Discount Amount (₹)</label>
                            <input type="number" id="coupon-max" required min="1" placeholder="e.g. 150">
                        </div>
                        <div class="form-group">
                            <label>Minimum Order Value (₹)</label>
                            <input type="number" id="coupon-min" required min="0" placeholder="e.g. 400">
                        </div>
                    </div>
                    <button type="submit" class="btn" style="margin-top: 10px;">➕ Add Coupon</button>
                </form>
            </div>

            <div class="card">
                <h3>Manage Coupons</h3>
                <div class="loader" id="coupons-loader"></div>
                <div class="table-container">
                    <table id="coupons-table">
                        <thead>
                            <tr>
                                <th>Code</th>
                                <th>Discount</th>
                                <th>Max Discount</th>
                                <th>Min Order</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="coupons-tbody">
                            <!-- Populated via JS -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>

    <!-- Modals -->
    <div class="modal-overlay" id="confirm-modal">
        <div class="modal">
            <h3 id="modal-title" style="font-weight: 800; font-size: 1.3rem; color: var(--text-primary);">Confirm Action</h3>
            <p id="modal-msg" style="font-size: 0.95rem; color: var(--text-secondary); line-height: 1.5;">Are you sure you want to proceed?</p>
            <div class="modal-actions">
                <button class="btn btn-outline btn-sm" onclick="closeModal()">Cancel</button>
                <button class="btn btn-danger btn-sm" id="modal-confirm-btn">Confirm</button>
            </div>
        </div>
    </div>

    <div class="toast" id="toast">Message here</div>

    <!-- JS Logic -->
    <script>
        // API Helper
        const apiFetch = async (action, data = null) => {
            const url = `admin-api?action=${action}`;
            const options = { method: data ? 'POST' : 'GET' };
            if (data) {
                options.headers = { 'Content-Type': 'application/x-www-form-urlencoded' };
                options.body = new URLSearchParams(data).toString();
            }
            try {
                const response = await fetch(url, options);
                if (!response.ok) throw new Error('API Error');
                return await response.json();
            } catch (err) {
                console.error(err);
                showToast("An error occurred: " + err.message);
                return null;
            }
        };

        // Toast
        function showToast(msg) {
            const toast = document.getElementById('toast');
            toast.textContent = msg;
            toast.classList.add('show');
            setTimeout(() => toast.classList.remove('show'), 3000);
        }

        // Modals
        let confirmActionCb = null;
        function showConfirm(title, msg, btnText, btnClass, callback) {
            document.getElementById('modal-title').textContent = title;
            document.getElementById('modal-msg').textContent = msg;
            const btn = document.getElementById('modal-confirm-btn');
            btn.textContent = btnText;
            btn.className = `btn ${btnClass}`;
            confirmActionCb = callback;
            document.getElementById('confirm-modal').classList.add('active');
        }
        
        function closeModal() {
            document.getElementById('confirm-modal').classList.remove('active');
            confirmActionCb = null;
            document.querySelectorAll('.status-select').forEach(sel => {
                sel.value = "";
            });
        }
        
        document.getElementById('modal-confirm-btn').addEventListener('click', () => {
            if (confirmActionCb) confirmActionCb();
            closeModal();
        });

        // Tabs Switching
        document.querySelectorAll('.nav-item').forEach(item => {
            item.addEventListener('click', () => {
                document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
                
                item.classList.add('active');
                const tabId = item.getAttribute('data-tab');
                document.getElementById(`tab-${tabId}`).classList.add('active');
                
                // Load data lazily based on tab selection
                if (tabId === 'dashboard') loadDashboard();
                if (tabId === 'users') loadUsers();
                if (tabId === 'restaurants') loadRestaurants();
                if (tabId === 'orders') loadOrders();
                if (tabId === 'payments') loadPayments();
            });
        });

        // Counter Animation
        function animateCounter(el, target, isCurrency = false) {
            let current = 0;
            const duration = 500; // ms
            const steps = 20;
            const stepTime = duration / steps;
            const increment = target / steps;
            
            const timer = setInterval(() => {
                current += increment;
                if (current >= target) {
                    current = target;
                    clearInterval(timer);
                }
                if (isCurrency) {
                    el.textContent = '₹' + Math.round(current).toLocaleString('en-IN');
                } else {
                    el.textContent = Math.round(current).toLocaleString();
                }
            }, stepTime);
        }

        // Table Sorting
        let sortDirections = {};
        function sortTable(tableId, colIndex) {
            const table = document.getElementById(tableId);
            const tbody = table.tBodies[0];
            const rows = Array.from(tbody.querySelectorAll('tr'));
            
            const dir = sortDirections[tableId+colIndex] === 'asc' ? 'desc' : 'asc';
            sortDirections[tableId+colIndex] = dir;
            
            // Clear current indicator
            const headers = table.querySelectorAll('th');
            headers.forEach((th, idx) => {
                const icon = th.querySelector('.sort-icon');
                if (icon) {
                    icon.textContent = idx === colIndex ? (dir === 'asc' ? ' ▲' : ' ▼') : ' ▼';
                }
            });
            
            rows.sort((a, b) => {
                const aVal = a.cells[colIndex].textContent.trim();
                const bVal = b.cells[colIndex].textContent.trim();
                
                const aNum = parseFloat(aVal.replace(/[^0-9.-]+/g,""));
                const bNum = parseFloat(bVal.replace(/[^0-9.-]+/g,""));
                
                if (!isNaN(aNum) && !isNaN(bNum)) {
                    return dir === 'asc' ? aNum - bNum : bNum - aNum;
                }
                return dir === 'asc' ? aVal.localeCompare(bVal) : bVal.localeCompare(aVal);
            });
            
            rows.forEach(r => tbody.appendChild(r));
        }

        // Filtering
        function filterUsers() {
            const search = document.getElementById('user-search').value;
            filterTable('users-table', search, 'user-role-filter', 4);
        }

        function filterRestaurants() {
            const search = document.getElementById('rest-search').value;
            filterTable('restaurants-table', search, null, -1);
        }

        function filterOrders() {
            const search = document.getElementById('order-search').value;
            filterTable('orders-table', search, 'order-status-filter', 4);
        }

        function filterTable(tableId, searchText, selectId, selectCol) {
            const table = document.getElementById(tableId);
            const tbody = table.tBodies[0];
            const rows = tbody.querySelectorAll('tr');
            const term = searchText.toLowerCase();
            const selectVal = selectId ? document.getElementById(selectId).value.toLowerCase() : '';
            
            rows.forEach(row => {
                let textMatch = false;
                for (let j = 0; j < row.cells.length - 1; j++) {
                    if (row.cells[j].textContent.toLowerCase().includes(term)) {
                        textMatch = true;
                        break;
                    }
                }
                if (row.cells.length <= 1) textMatch = true; // handle empty row
                
                let selectMatch = true;
                if (selectVal && selectCol >= 0) {
                    selectMatch = row.cells[selectCol].textContent.toLowerCase().includes(selectVal);
                }
                row.style.display = (textMatch && selectMatch) ? '' : 'none';
            });
        }

        // Dashboard Stats Loader
        async function loadDashboard() {
            const stats = await apiFetch('dashboard_stats');
            if (stats) {
                animateCounter(document.getElementById('stat-today-orders'), stats.todayOrders);
                animateCounter(document.getElementById('stat-revenue'), stats.totalRevenue, true);
                animateCounter(document.getElementById('stat-active-users'), stats.activeUsers);
                animateCounter(document.getElementById('stat-pending-orders'), stats.pendingOrders);
                animateCounter(document.getElementById('stat-total-orders'), stats.totalOrders);
            }

            const topItems = await apiFetch('top_items');
            if (topItems) {
                const html = topItems.items.map((i, idx) => `
                    <div class="list-item">
                        <div class="item-main">${idx+1}. ${i.name}</div>
                        <div class="item-sub">${i.count} items sold • ₹${Math.round(i.revenue).toLocaleString('en-IN')}</div>
                    </div>
                `).join('');
                document.getElementById('top-items-list').innerHTML = html || '<p style="text-align:center;color:var(--text-muted);">No sales data available</p>';
            }

            const topRest = await apiFetch('top_restaurants');
            if (topRest) {
                const html = topRest.restaurants.map((r, idx) => `
                    <div class="list-item">
                        <div class="item-main">${idx+1}. ${r.name}</div>
                        <div class="item-sub">⭐ ${r.rating} • ${r.orders} orders placed</div>
                    </div>
                `).join('');
                document.getElementById('top-restaurants-list').innerHTML = html || '<p style="text-align:center;color:var(--text-muted);">No restaurant data available</p>';
            }

            drawTrendChart();
            drawHoursChart();
        }

        // Pure JS HTML5 Canvas Linear Trend Chart
        async function drawTrendChart() {
            const res = await apiFetch('order_trends');
            if (!res) return;
            const canvas = document.getElementById('trendChart');
            const ctx = canvas.getContext('2d');
            
            const w = canvas.parentElement.clientWidth;
            const h = canvas.parentElement.clientHeight;
            canvas.width = w;
            canvas.height = h;
            
            ctx.clearRect(0, 0, w, h);
            
            const data = res.data;
            if (data.length === 0) return;
            
            const maxVal = Math.max(...data, 5);
            const paddingX = 40;
            const paddingY = 30;
            
            // Draw horizontal light grid lines
            ctx.strokeStyle = 'rgba(255, 107, 53, 0.08)';
            ctx.lineWidth = 1;
            for (let i = 0; i <= 4; i++) {
                const y = paddingY + (h - paddingY * 2) * (i / 4);
                ctx.beginPath();
                ctx.moveTo(paddingX, y);
                ctx.lineTo(w - 20, y);
                ctx.stroke();
                
                // Draw y-axis labels
                ctx.fillStyle = '#8E796A';
                ctx.font = '11px Outfit, sans-serif';
                ctx.textAlign = 'right';
                ctx.fillText(Math.round(maxVal - (maxVal * (i / 4))), paddingX - 8, y + 4);
            }
            
            const chartW = w - paddingX - 20;
            const chartH = h - paddingY * 2;
            const stepX = chartW / (data.length - 1 || 1);
            
            const points = data.map((val, idx) => ({
                x: paddingX + idx * stepX,
                y: paddingY + chartH * (1 - val / maxVal)
            }));
            
            // Draw line gradient fill
            ctx.beginPath();
            ctx.moveTo(points[0].x, h - paddingY);
            points.forEach(p => ctx.lineTo(p.x, p.y));
            ctx.lineTo(points[points.length - 1].x, h - paddingY);
            ctx.closePath();
            
            const fillGrad = ctx.createLinearGradient(0, 0, 0, h);
            fillGrad.addColorStop(0, 'rgba(255, 107, 53, 0.25)');
            fillGrad.addColorStop(1, 'rgba(255, 107, 53, 0.01)');
            ctx.fillStyle = fillGrad;
            ctx.fill();
            
            // Draw trend line
            ctx.beginPath();
            ctx.strokeStyle = '#FF6B35';
            ctx.lineWidth = 3;
            ctx.lineJoin = 'round';
            points.forEach((p, idx) => {
                if (idx === 0) ctx.moveTo(p.x, p.y);
                else ctx.lineTo(p.x, p.y);
            });
            ctx.stroke();
            
            // Draw interactive point circles
            points.forEach(p => {
                ctx.beginPath();
                ctx.fillStyle = '#FFFFFF';
                ctx.strokeStyle = '#FF6B35';
                ctx.lineWidth = 2.5;
                ctx.arc(p.x, p.y, 4.5, 0, Math.PI * 2);
                ctx.fill();
                ctx.stroke();
            });
        }

        // Pure JS HTML5 Canvas Bar Peak Hours Chart
        async function drawHoursChart() {
            const res = await apiFetch('peak_hours');
            if (!res) return;
            const canvas = document.getElementById('hoursChart');
            const ctx = canvas.getContext('2d');
            
            const w = canvas.parentElement.clientWidth;
            const h = canvas.parentElement.clientHeight;
            canvas.width = w;
            canvas.height = h;
            
            ctx.clearRect(0, 0, w, h);
            
            const data = res.data;
            const maxVal = Math.max(...data, 5);
            
            const paddingX = 30;
            const paddingY = 30;
            
            const chartW = w - paddingX - 20;
            const chartH = h - paddingY * 2;
            const barW = chartW / 24 - 4;
            
            // Draw horizontal light grid lines
            ctx.strokeStyle = 'rgba(255, 107, 53, 0.08)';
            ctx.lineWidth = 1;
            for (let i = 0; i <= 4; i++) {
                const y = paddingY + chartH * (i / 4);
                ctx.beginPath();
                ctx.moveTo(paddingX, y);
                ctx.lineTo(w - 20, y);
                ctx.stroke();
            }
            
            // Draw peak hour vertical bars
            data.forEach((val, idx) => {
                const barH = chartH * (val / maxVal);
                const x = paddingX + idx * (chartW / 24) + 2;
                const y = paddingY + chartH - barH;
                
                // Highlights peak business hours
                ctx.fillStyle = val > maxVal * 0.7 ? 'linear-gradient(to top, #FF6B35, #FF8A5C)' : 'rgba(255, 107, 53, 0.4)';
                if (val > maxVal * 0.7) {
                    const gradient = ctx.createLinearGradient(0, y, 0, y + barH);
                    gradient.addColorStop(0, '#FF8A5C');
                    gradient.addColorStop(1, '#FF6B35');
                    ctx.fillStyle = gradient;
                } else {
                    ctx.fillStyle = 'rgba(255, 107, 53, 0.35)';
                }
                
                // Draw rounded top rectangles
                ctx.beginPath();
                const radius = Math.min(4, barH);
                ctx.roundRect(x, y, barW, barH, [radius, radius, 0, 0]);
                ctx.fill();
                
                // Draw hour text labels on bottom axis for every 4 hours
                if (idx % 4 === 0) {
                    ctx.fillStyle = '#8E796A';
                    ctx.font = '10px Outfit, sans-serif';
                    ctx.textAlign = 'center';
                    ctx.fillText(`${idx}h`, x + barW / 2, paddingY + chartH + 16);
                }
            });
        }

        // Users Tab Loader
        async function loadUsers() {
            document.getElementById('users-loader').style.display = 'block';
            document.getElementById('users-tbody').innerHTML = '';
            const data = await apiFetch('all_users');
            document.getElementById('users-loader').style.display = 'none';
            if (!data) return;
            
            let html = '';
            data.users.forEach(u => {
                const isBlocked = u.role.startsWith('Blocked-');
                const cleanRole = isBlocked ? u.role.substring(8) : u.role;
                const blockBtnLabel = isBlocked ? 'Unblock' : 'Block';
                const blockBtnClass = isBlocked ? 'btn-outline' : 'btn-danger';
                const roleClass = `role-${cleanRole.toLowerCase().replace(/ & /g, '-').replace(/ /g, '-')}`;
                
                html += `<tr>
                    <td>#${u.id}</td>
                    <td><strong>${u.fullName}</strong></td>
                    <td>${u.email}</td>
                    <td>${u.phone || '—'}</td>
                    <td>
                        <span class="badge ${roleClass}">${cleanRole}</span>
                        ${isBlocked ? '<span class="badge inactive" style="margin-left:4px;">Blocked</span>' : ''}
                    </td>
                    <td>${u.createdAt ? u.createdAt.substring(0, 10) : '—'}</td>
                    <td class="action-btns">
                        <button class="btn btn-sm ${blockBtnClass}" onclick="toggleBlockUser(${u.id}, ${!isBlocked})">${blockBtnLabel}</button>
                        <button class="btn btn-sm btn-outline btn-danger" onclick="deleteUser(${u.id})">Delete</button>
                    </td>
                </tr>`;
            });
            document.getElementById('users-tbody').innerHTML = html || '<tr><td colspan="7" style="text-align:center;">No users registered</td></tr>';
            filterUsers();
        }

        function toggleBlockUser(id, shouldBlock) {
            const title = shouldBlock ? 'Block User' : 'Unblock User';
            const msg = `Are you sure you want to ${shouldBlock ? 'block' : 'unblock'} this user account?`;
            showConfirm(title, msg, shouldBlock ? 'Yes, Block' : 'Yes, Unblock', shouldBlock ? 'btn-danger' : 'btn', async () => {
                const res = await apiFetch('block_user', { userId: id, blocked: shouldBlock });
                if (res) {
                    showToast(shouldBlock ? 'User blocked successfully' : 'User unblocked successfully');
                    loadUsers();
                }
            });
        }

        // Delete User Handler
        function deleteUser(id) {
            showConfirm('Delete User Account', 'This user account and all their records will be permanently deleted. Proceed?', 'Delete', 'btn-danger', async () => {
                const res = await apiFetch('delete_user', { userId: id });
                if (res) {
                    showToast('User account deleted');
                    loadUsers();
                }
            });
        }

        // Restaurants Tab Loader
        async function loadRestaurants() {
            document.getElementById('rest-loader').style.display = 'block';
            document.getElementById('rest-tbody').innerHTML = '';
            const data = await apiFetch('all_restaurants');
            document.getElementById('rest-loader').style.display = 'none';
            if (!data) return;
            
            let html = '';
            data.restaurants.forEach(r => {
                const isDisabled = r.name.startsWith('[DISABLED] ');
                const cleanName = isDisabled ? r.name.substring(11) : r.name;
                const statusBadge = !isDisabled ? '<span class="badge active">Active</span>' : '<span class="badge inactive">Disabled</span>';
                const actionLabel = !isDisabled ? 'Disable' : 'Enable';
                
                html += `<tr>
                    <td><strong>${cleanName}</strong></td>
                    <td>⭐ ${r.rating} (${r.ratingCount})</td>
                    <td>${r.outletLocation || '—'}</td>
                    <td>${r.cuisines || '—'}</td>
                    <td>${r.orderCount} orders</td>
                    <td class="action-btns">
                        ${statusBadge}
                        <button class="btn btn-sm btn-outline" onclick="toggleRestaurant('${r.id}', ${isDisabled})">${actionLabel}</button>
                    </td>
                </tr>`;
            });
            document.getElementById('rest-tbody').innerHTML = html || '<tr><td colspan="6" style="text-align:center;">No restaurants registered</td></tr>';
            filterRestaurants();
        }

        function toggleRestaurant(id, enable) {
            const title = enable ? 'Enable Restaurant' : 'Disable Restaurant';
            const msg = `Are you sure you want to ${enable ? 'enable' : 'disable'} this restaurant outlet?`;
            showConfirm(title, msg, enable ? 'Yes, Enable' : 'Yes, Disable', 'btn', async () => {
                const res = await apiFetch('toggle_restaurant', { restaurantId: id, enabled: enable });
                if (res) {
                    showToast(enable ? 'Restaurant enabled successfully' : 'Restaurant disabled successfully');
                    loadRestaurants();
                }
            });
        }

        // Orders Tab Loader
        async function loadOrders() {
            document.getElementById('orders-loader').style.display = 'block';
            document.getElementById('orders-tbody').innerHTML = '';
            const data = await apiFetch('all_orders');
            document.getElementById('orders-loader').style.display = 'none';
            if (!data) return;
            
            let html = '';
            data.orders.forEach(o => {
                const statusClass = `status-${o.orderStatus.toLowerCase().replace(/ /g, '-')}`;
                const isCancelled = o.orderStatus === 'Cancelled';
                
                html += `<tr>
                    <td><strong>#${o.id}</strong></td>
                    <td>${o.userName}</td>
                    <td>${o.restaurantName}</td>
                    <td style="font-weight:700;">₹${o.grandTotal.toFixed(2)}</td>
                    <td><span class="badge ${statusClass}">${o.orderStatus}</span></td>
                    <td>${o.createdAt ? o.createdAt.substring(0, 16).replace('T', ' ') : '—'}</td>
                    <td class="action-btns">
                        <select class="status-select" ${isCancelled ? 'disabled' : ''} onchange="updateOrderStatus(${o.id}, this.value)">
                            <option value="">Update...</option>
                            <option value="Confirmed">Confirmed</option>
                            <option value="Preparing">Preparing</option>
                            <option value="Out for Delivery">Out for Delivery</option>
                            <option value="Delivered">Delivered</option>
                        </select>
                        <button class="btn btn-sm btn-outline btn-danger" ${isCancelled ? 'disabled' : ''} title="Cancel Order" onclick="cancelOrder(${o.id})">Cancel</button>
                    </td>
                </tr>`;
            });
            document.getElementById('orders-tbody').innerHTML = html || '<tr><td colspan="7" style="text-align:center;">No orders placed yet</td></tr>';
            filterOrders();
        }

        function updateOrderStatus(id, status) {
            if (!status) return;
            showConfirm('Update Order Status', `Update order #${id} status to ${status}?`, 'Yes, Update', 'btn', async () => {
                const res = await apiFetch('update_order_status', { orderId: id, status: status });
                if (res) {
                    showToast('Order status updated');
                    loadOrders();
                }
            });
        }

        function cancelOrder(id) {
            showConfirm('Cancel Order', `Are you sure you want to cancel order #${id}? This will issue a full refund.`, 'Yes, Cancel Order', 'btn-danger', async () => {
                const res = await apiFetch('cancel_order', { orderId: id });
                if (res) {
                    showToast('Order cancelled and fully refunded');
                    loadOrders();
                }
            });
        }

        // Payments Tab Loader
        async function loadPayments() {
            const summary = await apiFetch('payment_summary');
            if (summary) {
                animateCounter(document.getElementById('pay-revenue'), summary.totalRevenue, true);
                animateCounter(document.getElementById('pay-refunds'), summary.totalRefunds, true);
                animateCounter(document.getElementById('pay-avg'), summary.avgOrderValue, true);
                animateCounter(document.getElementById('pay-txns'), summary.totalTransactions);
            }
            loadCoupons();
        }

        async function loadCoupons() {
            document.getElementById('coupons-loader').style.display = 'block';
            document.getElementById('coupons-tbody').innerHTML = '';
            const data = await apiFetch('all_coupons');
            document.getElementById('coupons-loader').style.display = 'none';
            if (!data) return;
            
            let html = '';
            data.coupons.forEach(c => {
                const isActive = c.isActive;
                const statusBadge = isActive ? '<span class="badge active">Active</span>' : '<span class="badge inactive">Inactive</span>';
                const actionLabel = isActive ? 'Deactivate' : 'Activate';
                
                html += `<tr>
                    <td><strong>${c.code}</strong></td>
                    <td>${c.discountPercent}%</td>
                    <td>₹${c.maxDiscount}</td>
                    <td>₹${c.minOrderValue}</td>
                    <td>${statusBadge}</td>
                    <td class="action-btns">
                        <button class="btn btn-sm btn-outline" onclick="toggleCoupon(${c.id}, ${!isActive})">${actionLabel}</button>
                        <button class="btn btn-sm btn-outline btn-danger" onclick="deleteCoupon(${c.id})">Delete</button>
                    </td>
                </tr>`;
            });
            document.getElementById('coupons-tbody').innerHTML = html || '<tr><td colspan="6" style="text-align:center;">No coupons registered</td></tr>';
        }

        async function addCoupon(e) {
            e.preventDefault();
            const data = {
                code: document.getElementById('coupon-code').value.toUpperCase(),
                discountPercent: document.getElementById('coupon-pct').value,
                maxDiscount: document.getElementById('coupon-max').value,
                minOrderValue: document.getElementById('coupon-min').value
            };
            const res = await apiFetch('add_coupon', data);
            if (res) {
                showToast('New coupon code added');
                document.getElementById('coupon-form').reset();
                loadCoupons();
            }
        }

        function toggleCoupon(id, active) {
            apiFetch('toggle_coupon', { couponId: id, active: active }).then(res => {
                if (res) {
                    showToast(active ? 'Coupon activated successfully' : 'Coupon deactivated successfully');
                    loadCoupons();
                }
            });
        }

        function deleteCoupon(id) {
            showConfirm('Delete Coupon Code', 'Are you sure you want to permanently delete this coupon code?', 'Delete', 'btn-danger', async () => {
                const res = await apiFetch('delete_coupon', { couponId: id });
                if (res) {
                    showToast('Coupon code deleted');
                    loadCoupons();
                }
            });
        }

        // Initialization
        window.addEventListener('DOMContentLoaded', () => {
            loadDashboard();
            
            // Handle window resizing for responsive charts redraw
            let resizeTimer;
            window.addEventListener('resize', () => {
                clearTimeout(resizeTimer);
                resizeTimer = setTimeout(() => {
                    if (document.getElementById('tab-dashboard').classList.contains('active')) {
                        drawTrendChart();
                        drawHoursChart();
                    }
                }, 250);
            });
        });
    </script>
</body>
</html>
