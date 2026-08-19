<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true"%>
<%@ page import="com.khaalo.model.User" %>
<%
    User ownerUser = (User) session.getAttribute("user");
    if (ownerUser == null || !"Restaurant Owner".equals(ownerUser.getRole())) {
        response.sendRedirect("restaurants.jsp");
        return;
    }
    String ownerRestaurantId = ownerUser.getRestaurantId();
    boolean needsSetup = (ownerRestaurantId == null || ownerRestaurantId.isEmpty());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khaalo Owner Panel</title>
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
            transition: transform 0.3s ease;
        }

        @media (max-width: 768px) {
            .sidebar {
                position: fixed;
                height: 100%;
                transform: translateX(-100%);
            }
            .sidebar.mobile-open {
                transform: translateX(0);
            }
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
            transition: padding 0.3s;
        }

        @media (max-width: 768px) {
            .main-content { padding: 20px; }
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
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
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
            grid-template-columns: 1fr;
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
            flex-wrap: wrap;
        }

        input[type="text"], input[type="number"], select, textarea {
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
            width: 100%;
        }

        input[type="text"]:focus, input[type="number"]:focus, select:focus, textarea:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px var(--primary-glow);
        }

        textarea { resize: vertical; min-height: 80px; }

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

        .badge.status-pending { background: rgba(234, 179, 8, 0.12); color: #b57a00; }
        .badge.status-confirmed { background: rgba(59, 130, 246, 0.12); color: #1d4ed8; }
        .badge.status-preparing { background: rgba(249, 115, 22, 0.12); color: #c2410c; }
        .badge.status-ready-for-pickup { background: rgba(147, 51, 234, 0.12); color: #7e22ce; }
        .badge.status-delivered { background: rgba(34, 197, 94, 0.12); color: #15803d; }
        .badge.status-cancelled { background: rgba(239, 68, 68, 0.12); color: #b91c1c; }

        .action-btns { display: flex; gap: 8px; align-items: center; }
        select.status-select { padding: 6px 12px; font-size: 0.8rem; height: auto; border-radius: 8px; width: auto; }

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

        @media (max-width: 600px) {
            .form-grid { grid-template-columns: 1fr; }
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        
        .form-group.full-width {
            grid-column: 1 / -1;
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
        
        /* Menu Specific Styles */
        .category-section {
            border: 1px solid var(--border-subtle);
            border-radius: var(--radius-lg);
            background: rgba(255,255,255,0.5);
            overflow: hidden;
            margin-bottom: 20px;
        }
        
        .category-header {
            padding: 16px 20px;
            background: rgba(255, 107, 53, 0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
            cursor: pointer;
            border-bottom: 1px solid var(--border-subtle);
        }
        
        .category-title {
            font-weight: 700;
            font-size: 1.1rem;
            color: var(--text-primary);
        }
        
        .dish-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
            padding: 20px;
        }
        
        .dish-card {
            background: white;
            border: 1px solid var(--border-subtle);
            border-radius: var(--radius-md);
            padding: 16px;
            box-shadow: 0 4px 12px rgba(44, 27, 16, 0.02);
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        
        .dish-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
        }
        
        .dish-name {
            font-weight: 700;
            font-size: 1.05rem;
        }
        
        .dish-price {
            font-weight: 800;
            color: var(--primary);
        }
        
        .veg-indicator {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 16px;
            height: 16px;
            border: 1px solid;
            border-radius: 3px;
        }
        .veg-indicator::after {
            content: '';
            width: 8px;
            height: 8px;
            border-radius: 50%;
        }
        .veg { border-color: #15803d; }
        .veg::after { background-color: #15803d; }
        .non-veg { border-color: #b91c1c; }
        .non-veg::after { background-color: #b91c1c; }
        
        .dish-desc {
            font-size: 0.85rem;
            color: var(--text-muted);
            line-height: 1.4;
            flex-grow: 1;
        }
        
        /* Review Card */
        .review-card {
            padding: 16px;
            background: white;
            border: 1px solid var(--border-subtle);
            border-radius: var(--radius-md);
            margin-bottom: 16px;
        }
        
        .review-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
        }
        
        .review-author { font-weight: 700; }
        .review-date { font-size: 0.8rem; color: var(--text-muted); }
        .review-stars { color: #f59e0b; margin-bottom: 8px; }
        
        /* Notification Card */
        .notif-card {
            padding: 16px;
            background: white;
            border-left: 4px solid var(--primary);
            border-radius: var(--radius-md);
            margin-bottom: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.02);
            display: flex;
            align-items: flex-start;
            gap: 12px;
        }
        .notif-icon {
            width: 32px;
            height: 32px;
            background: var(--primary-glow);
            color: var(--primary);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

    </style>
</head>
<body>

    <!-- Sidebar Navigation -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <div class="brand-logo-glow">
                <svg viewBox="0 0 24 24" width="24" height="24" fill="var(--primary)"><path d="M11 9H9V2H7v7H5V2H3v7c0 2.12 1.66 3.84 3.75 3.97V22h2.5v-9.03C11.34 12.84 13 11.12 13 9V2h-2v7zm5-3v8h2.5v8H21V2c-2.76 0-5 2.24-5 4z"/></svg>
            </div>
            <div class="brand-title">Khaalo <span>Owner</span></div>
        </div>

        <div class="nav-item active" data-tab="dashboard">
            <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-2 10h-4v4h-2v-4H7v-2h4V7h2v4h4v2z"/></svg>
            Dashboard
        </div>
        <div class="nav-item" data-tab="orders">
            <svg viewBox="0 0 24 24"><path d="M17 18c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2zM7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zm1.75-2.23l.03-.12H15.5c.75 0 1.41-.41 1.75-1.03l3.58-6.49A1.003 1.003 0 0 0 20 7H5.21l-.94-2H1v2h2l3.6 7.59-1.35 2.44C4.52 15.37 5.48 17 7 17h12v-2H7l1.75-2.23z"/></svg>
            Orders
        </div>
        <div class="nav-item" data-tab="menu">
            <svg viewBox="0 0 24 24"><path d="M18.06 22.99h1.66c.84 0 1.53-.64 1.63-1.46L23 5.05h-5V1h-1.97v4.05h-4.97l.3 2.34c1.71.47 3.31 1.32 4.27 2.26 1.44 1.42 2.43 2.89 2.43 5.29s-.99 3.87-2.43 5.29c-.96.94-2.56 1.79-4.27 2.26l1.69 1.5zm-8.62-5.46c-1.28-1.26-2.15-2.57-2.15-4.7s.87-3.44 2.15-4.7c1.37-1.35 3.58-2.36 5.53-2.74L14.7 3.05H5.05L3.18 21.53c-.1.82.59 1.46 1.43 1.46h5.81l-.98-5.46z"/></svg>
            Menu
        </div>
        <div class="nav-item" data-tab="profile">
            <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 3c1.66 0 3 1.34 3 3s-1.34 3-3 3-3-1.34-3-3 1.34-3 3-3zm0 14.2c-2.5 0-4.71-1.28-6-3.22.03-1.99 4-3.08 6-3.08 1.99 0 5.97 1.09 6 3.08-1.29 1.94-3.5 3.22-6 3.22z"/></svg>
            Profile
        </div>
        <div class="nav-item" data-tab="earnings">
            <svg viewBox="0 0 24 24"><path d="M11.8 10.9c-2.27-.59-3-1.2-3-2.15 0-1.09 1.01-1.85 2.7-1.85 1.78 0 2.44.85 2.5 2.1h2.21c-.07-1.72-1.12-3.3-3.21-3.81V3h-3v2.16c-1.94.42-3.5 1.68-3.5 3.61 0 2.31 1.91 3.46 4.7 4.13 2.5.6 3 1.48 3 2.41 0 .69-.49 1.79-2.7 1.79-2.06 0-2.87-.92-2.98-2.1h-2.2c.12 2.19 1.76 3.42 3.68 3.83V21h3v-2.15c1.95-.37 3.5-1.5 3.5-3.55 0-2.84-2.43-3.81-4.7-4.4z"/></svg>
            Earnings
        </div>
        <div class="nav-item" data-tab="reviews">
            <svg viewBox="0 0 24 24"><path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>
            Reviews
        </div>
        <div class="nav-item" data-tab="notifications">
            <svg viewBox="0 0 24 24"><path d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.9 2 2 2zm6-6v-5c0-3.07-1.63-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.64 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2zm-2 1H8v-6c0-2.48 1.51-4.5 4-4.5s4 2.02 4 4.5v6z"/></svg>
            Notifications
        </div>

        <div class="sidebar-footer">
            <div class="user-info">
                <div class="user-avatar">
                    <%= ownerUser.getFullName().substring(0, 1).toUpperCase() %>
                </div>
                <div class="user-details">
                    <span class="user-name"><%= ownerUser.getFullName() %></span>
                    <span class="user-role">Restaurant Owner</span>
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
                <h1>Owner Dashboard</h1>
            </div>

            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-icon-bg"><svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2z"/></svg></div>
                    <div class="metric-value" id="stat-today-orders">0</div>
                    <div class="metric-label">Today's Orders</div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon-bg"><svg viewBox="0 0 24 24"><path d="M21 18v1c0 1.1-.9 2-2 2H5c-1.11 0-2-.9-2-2V5c0-1.1.89-2 2-2h14c1.1 0 2 .9 2 2v1h-9c-1.11 0-2 .9-2 2v8c0 1.1.89 2 2 2h9z"/></svg></div>
                    <div class="metric-value" id="stat-revenue">₹0</div>
                    <div class="metric-label">Today's Revenue</div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon-bg"><svg viewBox="0 0 24 24"><path d="M17 18c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2z"/></svg></div>
                    <div class="metric-value" id="stat-total-orders">0</div>
                    <div class="metric-label">Total Orders</div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon-bg"><svg viewBox="0 0 24 24"><path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg></div>
                    <div class="metric-value" id="stat-avg-rating">0.0</div>
                    <div class="metric-label">Avg Rating</div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon-bg"><svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg></div>
                    <div class="metric-value" id="stat-pending-orders">0</div>
                    <div class="metric-label">Pending Orders</div>
                </div>
            </div>

            <div class="charts-row">
                <div class="card">
                    <h3>Sales Trend (Last 30 Days)</h3>
                    <div class="chart-container">
                        <canvas id="trendChart" class="canvas-chart"></canvas>
                    </div>
                </div>
            </div>

            <div class="card">
                <h3>Top 5 Selling Items</h3>
                <div class="ranked-list" id="top-items-list">
                    <!-- Populated via JS -->
                </div>
            </div>
        </div>

        <!-- Tab 2: Orders -->
        <div id="tab-orders" class="tab-content">
            <div class="header-title-section">
                <h1>Manage Orders</h1>
            </div>

            <div class="card">
                <div class="controls-row">
                    <div class="filter-group">
                        <input type="text" id="order-search" placeholder="Search orders..." oninput="filterOrders()">
                        <select id="order-status-filter" onchange="filterOrders()">
                            <option value="">All Statuses</option>
                            <option value="Pending">Pending</option>
                            <option value="Confirmed">Confirmed</option>
                            <option value="Preparing">Preparing</option>
                            <option value="Ready for Pickup">Ready for Pickup</option>
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
                                <th onclick="sortTable('orders-table', 2)">Total <span class="sort-icon">▼</span></th>
                                <th onclick="sortTable('orders-table', 3)">Status <span class="sort-icon">▼</span></th>
                                <th onclick="sortTable('orders-table', 4)">Date <span class="sort-icon">▼</span></th>
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

        <!-- Tab 3: Menu -->
        <div id="tab-menu" class="tab-content">
            <div class="header-title-section">
                <h1>Menu Management</h1>
                <button class="btn" onclick="openAddCategoryModal()">➕ Add Category</button>
            </div>
            
            <div class="loader" id="menu-loader"></div>
            
            <div id="menu-container">
                <!-- Populated via JS -->
            </div>
        </div>

        <!-- Tab 4: Profile -->
        <div id="tab-profile" class="tab-content">
            <div class="header-title-section">
                <h1>Restaurant Profile</h1>
            </div>

            <div class="card">
                <form id="profile-form" onsubmit="saveProfile(event)">
                    <div class="form-grid">
                        <div class="form-group">
                            <label>Restaurant Name</label>
                            <input type="text" id="prof-name" required>
                        </div>
                        <div class="form-group">
                            <label>Location</label>
                            <input type="text" id="prof-loc" required>
                        </div>
                        <div class="form-group">
                            <label>Closes At</label>
                            <input type="time" id="prof-close" required>
                        </div>
                        <div class="form-group">
                            <label>Cost for Two (₹)</label>
                            <input type="number" id="prof-cost" required min="1">
                        </div>
                        <div class="form-group">
                            <label>Delivery Time (mins)</label>
                            <input type="number" id="prof-time" required min="5">
                        </div>
                        <div class="form-group">
                            <label>Discount Tag (Optional)</label>
                            <input type="text" id="prof-discount" placeholder="e.g. 50% OFF up to ₹100">
                        </div>
                        <div class="form-group full-width">
                            <label>Banner Image URL</label>
                            <input type="url" id="prof-banner" placeholder="https://...">
                        </div>
                    </div>
                    <button type="submit" class="btn" style="margin-top: 20px;">Save Profile</button>
                </form>
            </div>
        </div>

        <!-- Tab 5: Earnings -->
        <div id="tab-earnings" class="tab-content">
            <div class="header-title-section">
                <h1>Earnings Summary</h1>
            </div>

            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-icon-bg"><svg viewBox="0 0 24 24"><path d="M11.8 10.9c-2.27-.59-3-1.2-3-2.15 0-1.09 1.01-1.85 2.7-1.85 1.78 0 2.44.85 2.5 2.1h2.21c-.07-1.72-1.12-3.3-3.21-3.81V3h-3v2.16c-1.94.42-3.5 1.68-3.5 3.61 0 2.31 1.91 3.46 4.7 4.13 2.5.6 3 1.48 3 2.41 0 .69-.49 1.79-2.7 1.79-2.06 0-2.87-.92-2.98-2.1h-2.2c.12 2.19 1.76 3.42 3.68 3.83V21h3v-2.15c1.95-.37 3.5-1.5 3.5-3.55 0-2.84-2.43-3.81-4.7-4.4z"/></svg></div>
                    <div class="metric-value" id="earn-gross">₹0</div>
                    <div class="metric-label">Gross Revenue</div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon-bg"><svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2z"/></svg></div>
                    <div class="metric-value" id="earn-comm">₹0</div>
                    <div class="metric-label">Platform Commission (20%)</div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon-bg"><svg viewBox="0 0 24 24"><path d="M21 18v1c0 1.1-.9 2-2 2H5c-1.11 0-2-.9-2-2V5c0-1.1.89-2 2-2h14c1.1 0 2 .9 2 2v1h-9c-1.11 0-2 .9-2 2v8c0 1.1.89 2 2 2h9z"/></svg></div>
                    <div class="metric-value" id="earn-net">₹0</div>
                    <div class="metric-label">Net Earnings</div>
                </div>
                <div class="metric-card">
                    <div class="metric-icon-bg"><svg viewBox="0 0 24 24"><path d="M17 18c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2z"/></svg></div>
                    <div class="metric-value" id="earn-orders">0</div>
                    <div class="metric-label">Total Completed Orders</div>
                </div>
            </div>
            
            <div class="card">
                <h3>Earnings Breakdown</h3>
                <p style="color: var(--text-muted);">This is a simplified summary based on your total order history. Khaalo charges a 20% platform commission on all successful orders.</p>
            </div>
        </div>

        <!-- Tab 6: Reviews -->
        <div id="tab-reviews" class="tab-content">
            <div class="header-title-section">
                <h1>Customer Reviews</h1>
            </div>
            <div class="loader" id="reviews-loader"></div>
            <div id="reviews-container">
                <!-- Populated via JS -->
            </div>
        </div>

        <!-- Tab 7: Notifications -->
        <div id="tab-notifications" class="tab-content">
            <div class="header-title-section">
                <h1>Recent Notifications</h1>
            </div>
            <div class="loader" id="notif-loader"></div>
            <div id="notif-container">
                <!-- Populated via JS -->
            </div>
        </div>
    </div>

    <!-- Modals -->
    <!-- Setup Modal (Cannot be dismissed) -->
    <div class="modal-overlay" id="setup-modal" style="<%= needsSetup ? "display: flex; opacity: 1;" : "" %>">
        <div class="modal" style="<%= needsSetup ? "transform: scale(1);" : "" %>">
            <h3 style="font-weight: 800; font-size: 1.4rem; color: var(--primary);">Link Restaurant</h3>
            <p style="font-size: 0.95rem; color: var(--text-secondary); line-height: 1.5;">Welcome to the Owner Panel! Please select your restaurant to continue.</p>
            <form id="setup-form" onsubmit="submitSetup(event)">
                <div class="form-group" style="margin-bottom: 20px;">
                    <label>Select Restaurant</label>
                    <select id="setup-restaurant" required>
                        <option value="">Loading...</option>
                    </select>
                </div>
                <button type="submit" class="btn" style="width:100%; justify-content:center;">Complete Setup</button>
            </form>
        </div>
    </div>

    <!-- Confirm Modal -->
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

    <!-- Add/Edit Dish Modal -->
    <div class="modal-overlay" id="dish-modal">
        <div class="modal">
            <h3 id="dish-modal-title" style="font-weight: 800; font-size: 1.3rem;">Add Dish</h3>
            <form id="dish-form" onsubmit="saveDish(event)">
                <input type="hidden" id="dish-id">
                <input type="hidden" id="dish-cat-id">
                <div class="form-group" style="margin-bottom:12px;">
                    <label>Dish Name</label>
                    <input type="text" id="dish-name" required>
                </div>
                <div class="form-grid" style="margin-bottom:12px;">
                    <div class="form-group">
                        <label>Price (₹)</label>
                        <input type="number" id="dish-price" required min="1">
                    </div>
                    <div class="form-group" style="justify-content: center;">
                        <label style="display:flex; align-items:center; gap:8px; cursor:pointer;">
                            <input type="checkbox" id="dish-veg" style="width:18px; height:18px;">
                            Is Vegetarian?
                        </label>
                    </div>
                </div>
                <div class="form-group" style="margin-bottom:12px;">
                    <label>Description</label>
                    <textarea id="dish-desc"></textarea>
                </div>
                <div class="form-group" style="margin-bottom:20px;">
                    <label>Image URL</label>
                    <input type="url" id="dish-img" placeholder="https://...">
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn btn-outline btn-sm" onclick="closeDishModal()">Cancel</button>
                    <button type="submit" class="btn btn-sm">Save Dish</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Add Category Modal -->
    <div class="modal-overlay" id="category-modal">
        <div class="modal">
            <h3 style="font-weight: 800; font-size: 1.3rem;">Add Category</h3>
            <form id="category-form" onsubmit="saveCategory(event)">
                <div class="form-group" style="margin-bottom:20px;">
                    <label>Category Name</label>
                    <input type="text" id="cat-name" required placeholder="e.g. Starters">
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn btn-outline btn-sm" onclick="closeCategoryModal()">Cancel</button>
                    <button type="submit" class="btn btn-sm">Add Category</button>
                </div>
            </form>
        </div>
    </div>

    <div class="toast" id="toast">Message here</div>

    <!-- JS Logic -->
    <script>
        const needsSetup = <%= needsSetup %>;

        // API Helper
        const apiFetch = async (action, data = null) => {
            const url = `owner-api?action=${action}`;
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
        
        function openAddCategoryModal() { document.getElementById('category-modal').classList.add('active'); }
        function closeCategoryModal() { document.getElementById('category-modal').classList.remove('active'); document.getElementById('category-form').reset(); }
        
        function openDishModal(catId, dish = null) {
            document.getElementById('dish-cat-id').value = catId;
            if (dish) {
                document.getElementById('dish-modal-title').textContent = 'Edit Dish';
                document.getElementById('dish-id').value = dish.id;
                document.getElementById('dish-name').value = dish.name;
                document.getElementById('dish-price').value = dish.price;
                document.getElementById('dish-veg').checked = dish.isVeg;
                document.getElementById('dish-desc').value = dish.description || '';
                document.getElementById('dish-img').value = dish.imageUrl || '';
            } else {
                document.getElementById('dish-modal-title').textContent = 'Add Dish';
                document.getElementById('dish-form').reset();
                document.getElementById('dish-id').value = '';
            }
            document.getElementById('dish-modal').classList.add('active');
        }
        function closeDishModal() { document.getElementById('dish-modal').classList.remove('active'); document.getElementById('dish-form').reset(); }

        // Tabs Switching
        document.querySelectorAll('.nav-item').forEach(item => {
            item.addEventListener('click', () => {
                document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
                
                item.classList.add('active');
                const tabId = item.getAttribute('data-tab');
                document.getElementById(`tab-${tabId}`).classList.add('active');
                
                if (tabId === 'dashboard') loadDashboard();
                if (tabId === 'orders') loadOrders();
                if (tabId === 'menu') loadMenu();
                if (tabId === 'profile') loadProfile();
                if (tabId === 'earnings') loadEarnings();
                if (tabId === 'reviews') loadReviews();
                if (tabId === 'notifications') loadNotifications();
            });
        });

        // Counter Animation
        function animateCounter(el, target, isCurrency = false) {
            let current = 0;
            const duration = 500;
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
                } else if(el.id === 'stat-avg-rating') {
                    el.textContent = current.toFixed(1) + ' ⭐';
                } else {
                    el.textContent = Math.round(current).toLocaleString();
                }
            }, stepTime);
        }

        // Table Sorting & Filtering
        let sortDirections = {};
        function sortTable(tableId, colIndex) {
            const table = document.getElementById(tableId);
            const tbody = table.tBodies[0];
            const rows = Array.from(tbody.querySelectorAll('tr'));
            
            const dir = sortDirections[tableId+colIndex] === 'asc' ? 'desc' : 'asc';
            sortDirections[tableId+colIndex] = dir;
            
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

        function filterOrders() {
            const search = document.getElementById('order-search').value.toLowerCase();
            const status = document.getElementById('order-status-filter').value.toLowerCase();
            const tbody = document.getElementById('orders-tbody');
            const rows = tbody.querySelectorAll('tr:not(.no-matches-row)');
            
            // Remove any existing no-matches row
            const existingNoMatches = tbody.querySelector('.no-matches-row');
            if (existingNoMatches) existingNoMatches.remove();
            
            let visibleCount = 0;
            rows.forEach(row => {
                if (row.cells.length <= 1) return;
                let textMatch = false;
                for (let j = 0; j < 3; j++) {
                    if (row.cells[j].textContent.toLowerCase().includes(search)) textMatch = true;
                }
                const statusMatch = status ? row.cells[3].textContent.toLowerCase().includes(status) : true;
                if (textMatch && statusMatch) {
                    row.style.display = '';
                    visibleCount++;
                } else {
                    row.style.display = 'none';
                }
            });
            
            if (visibleCount === 0 && rows.length > 0) {
                const tr = document.createElement('tr');
                tr.className = 'no-matches-row';
                tr.innerHTML = '<td colspan="6" style="text-align:center; color:var(--text-muted); padding:30px 20px;">No orders match the selected search or filter criteria.</td>';
                tbody.appendChild(tr);
            }
        }

        // Setup Flow
        async function loadSetup() {
            const res = await apiFetch('available_restaurants');
            if (res) {
                const sel = document.getElementById('setup-restaurant');
                sel.innerHTML = '<option value="">Select a restaurant...</option>' + 
                    res.restaurants.map(r => `<option value="${r.id}">${r.name} - ${r.location}</option>`).join('');
            }
        }

        async function submitSetup(e) {
            e.preventDefault();
            const restId = document.getElementById('setup-restaurant').value;
            if (!restId) return;
            const res = await apiFetch('select_restaurant', { restaurantId: restId });
            if (res) {
                window.location.reload();
            }
        }

        // Dashboard Tab
        async function loadDashboard() {
            const stats = await apiFetch('dashboard_stats');
            if (stats) {
                animateCounter(document.getElementById('stat-today-orders'), stats.todayOrders);
                animateCounter(document.getElementById('stat-revenue'), stats.todayRevenue, true);
                animateCounter(document.getElementById('stat-total-orders'), stats.totalOrders);
                animateCounter(document.getElementById('stat-avg-rating'), stats.avgRating);
                animateCounter(document.getElementById('stat-pending-orders'), stats.pendingOrders);
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

            drawTrendChart();
        }

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
            if (!data || data.length === 0) return;
            
            const maxVal = Math.max(...data, 5);
            const paddingX = 40;
            const paddingY = 30;
            
            ctx.strokeStyle = 'rgba(255, 107, 53, 0.08)';
            ctx.lineWidth = 1;
            for (let i = 0; i <= 4; i++) {
                const y = paddingY + (h - paddingY * 2) * (i / 4);
                ctx.beginPath();
                ctx.moveTo(paddingX, y);
                ctx.lineTo(w - 20, y);
                ctx.stroke();
                
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
            
            ctx.beginPath();
            ctx.strokeStyle = '#FF6B35';
            ctx.lineWidth = 3;
            ctx.lineJoin = 'round';
            points.forEach((p, idx) => {
                if (idx === 0) ctx.moveTo(p.x, p.y);
                else ctx.lineTo(p.x, p.y);
            });
            ctx.stroke();
            
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

        // Orders Tab
        async function loadOrders() {
            document.getElementById('orders-loader').style.display = 'block';
            document.getElementById('orders-tbody').innerHTML = '';
            const data = await apiFetch('all_orders');
            document.getElementById('orders-loader').style.display = 'none';
            if (!data) return;
            
            let html = '';
            data.orders.forEach(o => {
                const statusClass = `status-${o.orderStatus.toLowerCase().replace(/ /g, '-')}`;
                
                html += `<tr>
                    <td><strong>#${o.id}</strong></td>
                    <td>${o.userName}</td>
                    <td style="font-weight:700;">₹${o.grandTotal.toFixed(2)}</td>
                    <td><span class="badge ${statusClass}">${o.orderStatus}</span></td>
                    <td>${o.createdAt ? o.createdAt.substring(0, 16).replace('T', ' ') : '—'}</td>
                    <td class="action-btns">
                        <select class="status-select" onchange="updateOrderStatus(${o.id}, this.value)">
                            <option value="">Update...</option>
                            <option value="Confirmed">Confirmed</option>
                            <option value="Preparing">Preparing</option>
                            <option value="Ready for Pickup">Ready for Pickup</option>
                        </select>
                    </td>
                </tr>`;
            });
            document.getElementById('orders-tbody').innerHTML = html || '<tr><td colspan="6" style="text-align:center;">No orders yet</td></tr>';
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

        // Menu Tab
        let menuData = [];
        async function loadMenu() {
            document.getElementById('menu-loader').style.display = 'block';
            const data = await apiFetch('menu_data');
            document.getElementById('menu-loader').style.display = 'none';
            if (!data) return;
            
            menuData = data.categories;
            renderMenu();
        }

        function renderMenu() {
            const container = document.getElementById('menu-container');
            if (menuData.length === 0) {
                container.innerHTML = '<p style="text-align:center; color:var(--text-muted); margin-top:20px;">No menu categories added yet.</p>';
                return;
            }
            
            let html = '';
            menuData.forEach(cat => {
                html += `
                <div class="category-section">
                    <div class="category-header">
                        <div class="category-title">${cat.name} (${cat.dishes.length})</div>
                        <div style="display:flex; gap:10px;">
                            <button class="btn btn-sm btn-outline" onclick="openDishModal(${cat.id})">➕ Add Dish</button>
                            <button class="btn btn-sm btn-outline btn-danger" onclick="deleteCategory(${cat.id})">Delete</button>
                        </div>
                    </div>
                    <div class="dish-grid">`;
                
                cat.dishes.forEach(dish => {
                    const dishObjStr = JSON.stringify(dish).replace(/"/g, '&quot;');
                    html += `
                        <div class="dish-card">
                            <div class="dish-header">
                                <div style="display:flex; align-items:center; gap:8px;">
                                    <div class="veg-indicator ${dish.isVeg ? 'veg' : 'non-veg'}"></div>
                                    <span class="dish-name">${dish.name}</span>
                                </div>
                                <span class="dish-price">₹${dish.price}</span>
                            </div>
                            <div class="dish-desc">${dish.description || ''}</div>
                            <div style="display:flex; justify-content:flex-end; gap:8px; margin-top:8px;">
                                <button class="btn btn-sm btn-outline" onclick="openDishModal(${cat.id}, ${dishObjStr})">Edit</button>
                                <button class="btn btn-sm btn-outline btn-danger" onclick="deleteDish(${dish.id})">Delete</button>
                            </div>
                        </div>`;
                });
                
                if (cat.dishes.length === 0) {
                    html += `<div style="grid-column:1/-1; text-align:center; color:var(--text-muted); padding:20px;">No dishes in this category</div>`;
                }
                
                html += `</div></div>`;
            });
            container.innerHTML = html;
        }

        async function saveCategory(e) {
            e.preventDefault();
            const name = document.getElementById('cat-name').value;
            const res = await apiFetch('add_category', { name });
            if (res) {
                showToast('Category added');
                closeCategoryModal();
                loadMenu();
            }
        }

        function deleteCategory(id) {
            showConfirm('Delete Category', 'Are you sure you want to delete this category and all its dishes?', 'Delete', 'btn-danger', async () => {
                const res = await apiFetch('delete_category', { categoryId: id });
                if (res) {
                    showToast('Category deleted');
                    loadMenu();
                }
            });
        }

        async function saveDish(e) {
            e.preventDefault();
            const data = {
                id: document.getElementById('dish-id').value,
                categoryId: document.getElementById('dish-cat-id').value,
                name: document.getElementById('dish-name').value,
                price: document.getElementById('dish-price').value,
                isVeg: document.getElementById('dish-veg').checked,
                description: document.getElementById('dish-desc').value,
                imageUrl: document.getElementById('dish-img').value
            };
            const action = data.id ? 'update_dish' : 'add_dish';
            const res = await apiFetch(action, data);
            if (res) {
                showToast(data.id ? 'Dish updated' : 'Dish added');
                closeDishModal();
                loadMenu();
            }
        }

        function deleteDish(id) {
            showConfirm('Delete Dish', 'Are you sure you want to delete this dish?', 'Delete', 'btn-danger', async () => {
                const res = await apiFetch('delete_dish', { dishId: id });
                if (res) {
                    showToast('Dish deleted');
                    loadMenu();
                }
            });
        }

        // Profile Tab
        async function loadProfile() {
            const data = await apiFetch('restaurant_profile');
            if (data) {
                document.getElementById('prof-name').value = data.name || '';
                document.getElementById('prof-loc').value = data.location || '';
                document.getElementById('prof-close').value = data.closesAt || '';
                document.getElementById('prof-cost').value = data.costForTwo || '';
                document.getElementById('prof-time').value = data.deliveryTime || '';
                document.getElementById('prof-discount').value = data.discountTag || '';
                document.getElementById('prof-banner').value = data.bannerUrl || '';
            }
        }

        async function saveProfile(e) {
            e.preventDefault();
            const data = {
                name: document.getElementById('prof-name').value,
                location: document.getElementById('prof-loc').value,
                closesAt: document.getElementById('prof-close').value,
                costForTwo: document.getElementById('prof-cost').value,
                deliveryTime: document.getElementById('prof-time').value,
                discountTag: document.getElementById('prof-discount').value,
                bannerUrl: document.getElementById('prof-banner').value
            };
            const res = await apiFetch('update_restaurant_profile', data);
            if (res) {
                showToast('Profile updated successfully');
            }
        }

        // Earnings Tab
        async function loadEarnings() {
            const data = await apiFetch('earnings_summary');
            if (data) {
                animateCounter(document.getElementById('earn-gross'), data.grossRevenue, true);
                animateCounter(document.getElementById('earn-comm'), data.commission, true);
                animateCounter(document.getElementById('earn-net'), data.netEarnings, true);
                animateCounter(document.getElementById('earn-orders'), data.totalOrders);
            }
        }

        // Reviews Tab
        async function loadReviews() {
            document.getElementById('reviews-loader').style.display = 'block';
            const data = await apiFetch('recent_reviews');
            document.getElementById('reviews-loader').style.display = 'none';
            if (!data) return;
            
            let html = '';
            data.reviews.forEach(r => {
                const stars = '⭐'.repeat(r.rating);
                html += `
                <div class="review-card">
                    <div class="review-header">
                        <span class="review-author">${r.customerName}</span>
                        <span class="review-date">${r.date}</span>
                    </div>
                    <div class="review-stars">${stars}</div>
                    <p style="color:var(--text-secondary); font-size:0.95rem; line-height:1.4;">${r.reviewText || '<em>No written review</em>'}</p>
                </div>`;
            });
            document.getElementById('reviews-container').innerHTML = html || '<p style="text-align:center; color:var(--text-muted); margin-top:20px;">No reviews yet.</p>';
        }

        // Notifications Tab
        async function loadNotifications() {
            document.getElementById('notif-loader').style.display = 'block';
            const data = await apiFetch('notifications');
            document.getElementById('notif-loader').style.display = 'none';
            if (!data) return;
            
            let html = '';
            data.notifications.forEach(n => {
                let icon = '🔔';
                if (n.message.includes('New order')) icon = '📦';
                if (n.message.includes('delivered')) icon = '✅';
                if (n.message.includes('cancelled')) icon = '❌';
                
                html += `
                <div class="notif-card">
                    <div class="notif-icon">${icon}</div>
                    <div>
                        <div style="font-weight:600; color:var(--text-primary); margin-bottom:4px;">${n.message}</div>
                        <div style="font-size:0.8rem; color:var(--text-muted);">${n.date}</div>
                    </div>
                </div>`;
            });
            document.getElementById('notif-container').innerHTML = html || '<p style="text-align:center; color:var(--text-muted); margin-top:20px;">No recent notifications.</p>';
        }

        // Initialization
        window.addEventListener('DOMContentLoaded', () => {
            if (needsSetup) {
                loadSetup();
            } else {
                loadDashboard();
            }
        });
    </script>
</body>
</html>
