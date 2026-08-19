<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true"%>
<%@ page import="com.khaalo.model.User" %>
<%
    User deliveryUser = (User) session.getAttribute("user");
    if (deliveryUser == null || !"Delivery Partner".equals(deliveryUser.getRole())) {
        response.sendRedirect("restaurants.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khaalo Rider Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary: #FF6B35;
            --primary-light: #FF8B5C;
            --primary-dark: #E5521C;
            --secondary: #2C1B10;
            --accent: #FFB347;
            --bg-color: #F8F9FA;
            --surface: #FFFFFF;
            --text-main: #333333;
            --text-muted: #666666;
            --border-color: rgba(0, 0, 0, 0.1);
            --success: #28a745;
            --danger: #dc3545;
            --glass-bg: rgba(255, 255, 255, 0.7);
            --glass-border: rgba(255, 255, 255, 0.5);
            --shadow-sm: 0 4px 6px rgba(0, 0, 0, 0.05);
            --shadow-md: 0 10px 15px rgba(0, 0, 0, 0.05);
            --shadow-lg: 0 20px 25px rgba(0, 0, 0, 0.1);
            --transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            background-color: var(--bg-color);
            color: var(--text-main);
            display: flex;
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* Custom Scrollbar */
        ::-webkit-scrollbar {
            width: 8px;
        }
        ::-webkit-scrollbar-track {
            background: var(--bg-color);
        }
        ::-webkit-scrollbar-thumb {
            background: var(--primary-light);
            border-radius: 4px;
        }
        ::-webkit-scrollbar-thumb:hover {
            background: var(--primary);
        }

        /* Sidebar */
        .sidebar {
            width: 280px;
            background-color: var(--secondary);
            color: white;
            display: flex;
            flex-direction: column;
            position: fixed;
            height: 100vh;
            z-index: 100;
            transition: var(--transition);
        }

        .brand {
            padding: 2rem;
            text-align: center;
            font-family: 'Outfit', sans-serif;
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--primary);
            letter-spacing: 1px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }

        .nav-menu {
            flex: 1;
            padding: 1.5rem 0;
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .nav-item {
            padding: 1rem 2rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            cursor: pointer;
            transition: var(--transition);
            color: rgba(255,255,255,0.7);
            font-size: 1.05rem;
            border-left: 4px solid transparent;
        }

        .nav-item:hover, .nav-item.active {
            background-color: rgba(255, 107, 53, 0.1);
            color: white;
            border-left-color: var(--primary);
        }

        .nav-item i {
            font-size: 1.2rem;
            width: 24px;
            text-align: center;
        }

        .user-info {
            padding: 2rem;
            border-top: 1px solid rgba(255,255,255,0.1);
            text-align: center;
        }
        .user-name {
            font-family: 'Outfit', sans-serif;
            font-weight: 600;
            margin-bottom: 1rem;
            font-size: 1.1rem;
        }

        .btn-logout {
            display: inline-block;
            width: 100%;
            padding: 0.8rem;
            background-color: transparent;
            color: white;
            border: 1px solid rgba(255,255,255,0.3);
            border-radius: 8px;
            text-decoration: none;
            transition: var(--transition);
            font-weight: 500;
        }

        .btn-logout:hover {
            background-color: var(--primary);
            border-color: var(--primary);
        }

        /* Main Content */
        .main-content {
            margin-left: 280px;
            flex: 1;
            padding: 2rem;
            background-color: var(--bg-color);
            min-height: 100vh;
        }

        .tab-content {
            display: none;
            animation: fadeIn 0.4s ease-in-out;
        }
        
        .tab-content.active {
            display: block;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
        }

        .page-title {
            font-family: 'Outfit', sans-serif;
            font-size: 2rem;
            color: var(--secondary);
            font-weight: 700;
        }

        /* Glassmorphism Cards */
        .glass-card {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            border: 1px solid var(--glass-border);
            border-radius: 16px;
            padding: 1.5rem;
            box-shadow: var(--shadow-md);
            transition: var(--transition);
        }

        .glass-card:hover {
            box-shadow: var(--shadow-lg);
            transform: translateY(-2px);
        }

        /* Toggle Switch */
        .status-toggle-wrapper {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .toggle-label {
            font-weight: 600;
            font-family: 'Outfit', sans-serif;
        }

        .status-offline { color: var(--text-muted); }
        .status-online { color: var(--success); }

        .toggle-switch {
            position: relative;
            display: inline-block;
            width: 80px;
            height: 40px;
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
            transition: .4s;
            border-radius: 40px;
            box-shadow: inset 0 2px 4px rgba(0,0,0,0.2);
        }

        .slider:before {
            position: absolute;
            content: "";
            height: 32px;
            width: 32px;
            left: 4px;
            bottom: 4px;
            background-color: white;
            transition: .4s;
            border-radius: 50%;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }

        input:checked + .slider {
            background-color: var(--success);
        }

        input:checked + .slider:before {
            transform: translateX(40px);
        }

        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            display: flex;
            align-items: center;
            gap: 1.5rem;
        }

        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 1.8rem;
            color: white;
        }
        
        .bg-orange { background: linear-gradient(135deg, var(--primary), var(--accent)); }
        .bg-blue { background: linear-gradient(135deg, #4facfe, #00f2fe); }
        .bg-green { background: linear-gradient(135deg, #43e97b, #38f9d7); }
        .bg-purple { background: linear-gradient(135deg, #fa709a, #fee140); }

        .stat-info h3 {
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--secondary);
            font-family: 'Outfit', sans-serif;
            margin-bottom: 0.2rem;
        }

        .stat-info p {
            color: var(--text-muted);
            font-size: 0.9rem;
            font-weight: 500;
        }

        /* Circular Progress */
        .progress-ring-container {
            position: relative;
            width: 80px;
            height: 80px;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .progress-ring {
            transform: rotate(-90deg);
        }
        .progress-ring__circle {
            transition: stroke-dashoffset 1s ease-in-out;
        }
        .progress-ring-text {
            position: absolute;
            font-weight: 600;
            font-family: 'Outfit', sans-serif;
            color: var(--secondary);
        }

        /* Deliveries */
        .section-title {
            font-family: 'Outfit', sans-serif;
            font-size: 1.4rem;
            margin-bottom: 1rem;
            color: var(--secondary);
            font-weight: 600;
        }

        .delivery-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .delivery-card {
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }
        .delivery-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 0.5rem;
        }
        .order-id {
            font-weight: 700;
            color: var(--primary);
        }
        .status-badge {
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
        }
        .status-ready { background-color: rgba(255,179,71,0.2); color: #d97706; }
        .status-active { background-color: rgba(40,167,69,0.2); color: var(--success); }

        .btn {
            padding: 0.8rem 1.5rem;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
            text-align: center;
            font-family: 'Poppins', sans-serif;
        }
        .btn-primary {
            background-color: var(--primary);
            color: white;
        }
        .btn-primary:hover {
            background-color: var(--primary-dark);
            transform: translateY(-2px);
        }
        .btn-outline {
            background-color: transparent;
            border: 2px solid var(--primary);
            color: var(--primary);
        }
        .btn-outline:hover {
            background-color: var(--primary);
            color: white;
        }

        /* Route Map Simulator */
        .route-map {
            margin: 1.5rem 0;
            padding: 1rem;
            background: rgba(0,0,0,0.02);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: relative;
        }
        .route-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: white;
            display: flex;
            justify-content: center;
            align-items: center;
            color: var(--primary);
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            z-index: 2;
        }
        .route-path {
            flex: 1;
            height: 4px;
            background: #e2e8f0;
            margin: 0 10px;
            position: relative;
            border-radius: 2px;
            overflow: hidden;
        }
        .route-progress {
            position: absolute;
            top: 0;
            left: 0;
            height: 100%;
            background: var(--success);
            width: 0%;
            transition: width 1s ease;
        }
        .route-progress.picked-up { width: 40%; }
        .route-progress.on-the-way { width: 75%; }
        .route-progress.delivered { width: 100%; }

        /* Tables */
        .data-table {
            width: 100%;
            border-collapse: collapse;
        }
        .data-table th, .data-table td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid var(--border-color);
        }
        .data-table th {
            font-weight: 600;
            color: var(--secondary);
            background-color: rgba(0,0,0,0.02);
            font-family: 'Outfit', sans-serif;
        }
        .data-table tr:hover td {
            background-color: rgba(255,107,53,0.02);
        }

        /* Profile Form */
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
        }
        .form-group {
            margin-bottom: 1rem;
        }
        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
            color: var(--secondary);
        }
        .form-control {
            width: 100%;
            padding: 0.8rem 1rem;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            font-family: 'Poppins', sans-serif;
            background-color: rgba(255,255,255,0.8);
            transition: var(--transition);
        }
        .form-control:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(255,107,53,0.1);
        }
        
        .upload-slot {
            border: 2px dashed var(--border-color);
            padding: 1.5rem;
            text-align: center;
            border-radius: 12px;
            cursor: pointer;
            transition: var(--transition);
        }
        .upload-slot:hover {
            border-color: var(--primary);
            background-color: rgba(255,107,53,0.05);
        }

        /* Alerts/Notifications */
        .alert-item {
            display: flex;
            gap: 1rem;
            padding: 1rem;
            border-bottom: 1px solid var(--border-color);
        }
        .alert-item:last-child {
            border-bottom: none;
        }
        .alert-icon {
            font-size: 1.5rem;
        }
        .alert-content p { margin-bottom: 0.2rem; }
        .alert-time { font-size: 0.8rem; color: var(--text-muted); }

        /* Responsive */
        @media (max-width: 768px) {
            .sidebar { transform: translateX(-100%); }
            .main-content { margin-left: 0; }
            .form-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="brand">
            Khaalo Rider
        </div>
        <nav class="nav-menu">
            <div class="nav-item active" data-tab="dashboard">
                <i class="fas fa-home"></i> Dashboard
            </div>
            <div class="nav-item" data-tab="deliveries">
                <i class="fas fa-box"></i> Deliveries
            </div>
            <div class="nav-item" data-tab="earnings">
                <i class="fas fa-wallet"></i> Earnings
            </div>
            <div class="nav-item" data-tab="profile">
                <i class="fas fa-user"></i> Profile
            </div>
            <div class="nav-item" data-tab="feedback">
                <i class="fas fa-star"></i> Feedback
            </div>
            <div class="nav-item" data-tab="alerts">
                <i class="fas fa-bell"></i> Alerts
            </div>
        </nav>
        <div class="user-info">
            <div class="user-name"><%= deliveryUser.getName() %></div>
            <a href="logout" class="btn-logout">Log Out</a>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        
        <!-- Dashboard Tab -->
        <div id="dashboard" class="tab-content active">
            <div class="page-header">
                <h1 class="page-title">Dashboard</h1>
                <div class="status-toggle-wrapper glass-card" style="padding: 0.5rem 1rem;">
                    <span class="toggle-label" id="status-label">Offline</span>
                    <label class="toggle-switch">
                        <input type="checkbox" id="online-toggle" onchange="toggleOnlineStatus(this)">
                        <span class="slider"></span>
                    </label>
                </div>
            </div>

            <div class="stats-grid" id="dashboard-stats-container">
                <!-- Populated by JS -->
            </div>
        </div>

        <!-- Deliveries Tab -->
        <div id="deliveries" class="tab-content">
            <div class="page-header">
                <h1 class="page-title">Deliveries</h1>
            </div>

            <h2 class="section-title">Active Delivery</h2>
            <div id="active-delivery-container" class="glass-card" style="margin-bottom: 2rem;">
                <!-- Populated by JS -->
            </div>

            <h2 class="section-title">Available Requests</h2>
            <div class="delivery-cards" id="available-requests-container">
                <!-- Populated by JS -->
            </div>
        </div>

        <!-- Earnings Tab -->
        <div id="earnings" class="tab-content">
            <div class="page-header">
                <h1 class="page-title">Earnings</h1>
            </div>

            <div class="stats-grid">
                <div class="glass-card stat-card">
                    <div class="stat-icon bg-green"><i class="fas fa-rupee-sign"></i></div>
                    <div class="stat-info">
                        <h3 id="earn-total">₹0</h3>
                        <p>Total Earnings</p>
                    </div>
                </div>
                <div class="glass-card stat-card">
                    <div class="stat-icon bg-blue"><i class="fas fa-calendar-alt"></i></div>
                    <div class="stat-info">
                        <h3 id="earn-month">₹0</h3>
                        <p>This Month</p>
                    </div>
                </div>
                <div class="glass-card stat-card">
                    <div class="stat-icon bg-orange"><i class="fas fa-clock"></i></div>
                    <div class="stat-info">
                        <h3 id="earn-pending">₹0</h3>
                        <p>Pending Payout</p>
                    </div>
                </div>
            </div>

            <div class="glass-card" style="margin-bottom: 2rem;">
                <h3 style="margin-bottom: 1rem; color: var(--secondary);">Incentive Tracker</h3>
                <p style="margin-bottom: 0.5rem;">Complete 5 deliveries for ₹100 bonus!</p>
                <div style="width: 100%; background-color: #e2e8f0; border-radius: 10px; height: 10px; overflow: hidden;">
                    <div id="inc-bar" style="width: 0%; background-color: var(--primary); height: 100%; border-radius: 10px; transition: width 0.3s;"></div>
                </div>
                <p id="inc-text" style="text-align: right; font-size: 0.8rem; margin-top: 0.5rem;">0/5 Completed</p>
            </div>

            <div class="glass-card">
                <h2 class="section-title">Earnings History</h2>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Order ID</th>
                            <th>Amount</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody id="earnings-table-body">
                        <!-- Populated by JS -->
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Profile Tab -->
        <div id="profile" class="tab-content">
            <div class="page-header">
                <h1 class="page-title">Profile</h1>
            </div>

            <div class="glass-card">
                <form id="profile-form" onsubmit="saveProfile(event)">
                    <h2 class="section-title">Vehicle Details</h2>
                    <div class="form-grid">
                        <div class="form-group">
                            <label>Vehicle Type</label>
                            <select class="form-control" name="vehicleType">
                                <option value="Bicycle">Bicycle</option>
                                <option value="Scooter">Scooter</option>
                                <option value="Motorcycle">Motorcycle</option>
                                <option value="Car">Car</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Vehicle Number</label>
                            <input type="text" class="form-control" name="vehicleNumber" placeholder="e.g. MH 12 AB 1234">
                        </div>
                        <div class="form-group">
                            <label>License Number</label>
                            <input type="text" class="form-control" name="licenseNumber">
                        </div>
                    </div>

                    <h2 class="section-title" style="margin-top: 2rem;">Bank Details</h2>
                    <div class="form-grid">
                        <div class="form-group">
                            <label>Bank Name</label>
                            <input type="text" class="form-control" name="bankName">
                        </div>
                        <div class="form-group">
                            <label>Account Number</label>
                            <input type="text" class="form-control" name="accountNumber">
                        </div>
                        <div class="form-group">
                            <label>IFSC Code</label>
                            <input type="text" class="form-control" name="ifscCode">
                        </div>
                    </div>

                    <h2 class="section-title" style="margin-top: 2rem;">Document Upload</h2>
                    <div class="form-grid">
                        <div class="upload-slot">
                            <i class="fas fa-id-card" style="font-size: 2rem; color: var(--primary); margin-bottom: 1rem;"></i>
                            <p>Upload License</p>
                            <span class="status-badge" style="background: rgba(40,167,69,0.1); color: var(--success); margin-top: 0.5rem; display: inline-block;">Verified</span>
                        </div>
                        <div class="upload-slot">
                            <i class="fas fa-passport" style="font-size: 2rem; color: var(--primary); margin-bottom: 1rem;"></i>
                            <p>Upload ID Proof</p>
                            <span class="status-badge" style="background: rgba(40,167,69,0.1); color: var(--success); margin-top: 0.5rem; display: inline-block;">Verified</span>
                        </div>
                        <div class="upload-slot">
                            <i class="fas fa-file-contract" style="font-size: 2rem; color: var(--primary); margin-bottom: 1rem;"></i>
                            <p>Upload Insurance</p>
                            <span class="status-badge status-ready" style="margin-top: 0.5rem; display: inline-block;">Pending</span>
                        </div>
                    </div>

                    <div style="margin-top: 2rem; text-align: right;">
                        <button type="submit" class="btn btn-primary">Save Profile</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Feedback Tab -->
        <div id="feedback" class="tab-content">
            <div class="page-header">
                <h1 class="page-title">Feedback</h1>
            </div>
            <div class="glass-card" style="margin-bottom: 2rem; text-align: center;">
                <h2 style="font-size: 3rem; color: var(--primary); font-family: 'Outfit';">4.8</h2>
                <div style="color: #FFB347; font-size: 1.5rem;">
                    <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i>
                </div>
                <p style="color: var(--text-muted); margin-top: 0.5rem;">Average Rating (Based on 124 deliveries)</p>
            </div>
            <div class="glass-card">
                <h2 class="section-title">Recent Reviews</h2>
                <div id="feedback-container">
                    <!-- Populated by JS -->
                </div>
            </div>
        </div>

        <!-- Alerts Tab -->
        <div id="alerts" class="tab-content">
            <div class="page-header">
                <h1 class="page-title">Alerts</h1>
            </div>
            <div class="glass-card">
                <div id="alerts-container">
                    <!-- Populated by JS -->
                </div>
            </div>
        </div>

    </main>

    <script>
        // API Helper supporting both GET and POST requests
        const apiFetch = async (action, data = null) => {
            const url = `delivery-api?action=${action}`;
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
                return null;
            }
        };

        // Tab Switching
        document.querySelectorAll('.nav-item').forEach(item => {
            item.addEventListener('click', () => {
                document.querySelectorAll('.nav-item').forEach(nav => nav.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
                
                item.classList.add('active');
                const tabId = item.getAttribute('data-tab');
                document.getElementById(tabId).classList.add('active');

                loadTabData(tabId);
            });
        });

        // Initialize Data
        document.addEventListener('DOMContentLoaded', () => {
            loadTabData('dashboard');
        });

        const loadTabData = (tab) => {
            switch(tab) {
                case 'dashboard': loadDashboard(); break;
                case 'deliveries': loadDeliveries(); break;
                case 'earnings': loadEarnings(); break;
                case 'profile': loadProfile(); break;
                case 'feedback': loadFeedback(); break;
                case 'alerts': loadAlerts(); break;
            }
        };

        const createProgressRing = (percentage, color) => {
            const circumference = 2 * Math.PI * 36;
            const offset = circumference - (percentage / 100) * circumference;
            return `
                <div class="progress-ring-container">
                    <svg class="progress-ring" width="80" height="80">
                        <circle stroke="#e2e8f0" stroke-width="6" fill="transparent" r="36" cx="40" cy="40"/>
                        <circle class="progress-ring__circle" stroke="${color}" stroke-width="6" stroke-dasharray="${circumference} ${circumference}" stroke-dashoffset="${offset}" stroke-linecap="round" fill="transparent" r="36" cx="40" cy="40"/>
                    </svg>
                    <span class="progress-ring-text">${percentage}%</span>
                </div>
            `;
        };

        const loadDashboard = async () => {
            const response = await apiFetch('dashboard_stats');
            if (response) {
                document.getElementById('dashboard-stats-container').innerHTML = `
                    <div class="glass-card stat-card">
                        <div class="stat-icon bg-green"><i class="fas fa-rupee-sign"></i></div>
                        <div class="stat-info">
                            <h3>₹${(response.todayEarnings || 0).toFixed(2)}</h3>
                            <p>Today's Earnings</p>
                        </div>
                    </div>
                    <div class="glass-card stat-card">
                        <div class="stat-icon bg-blue"><i class="fas fa-check-circle"></i></div>
                        <div class="stat-info">
                            <h3>${response.completedDeliveries || 0}</h3>
                            <p>Deliveries</p>
                        </div>
                    </div>
                    <div class="glass-card stat-card" style="flex-direction: column; align-items: center; justify-content: center; gap: 0.5rem;">
                        <p style="margin:0; font-weight: 600;">Acceptance</p>
                        ${createProgressRing(response.acceptanceRate || 100, 'var(--primary)')}
                    </div>
                    <div class="glass-card stat-card" style="flex-direction: column; align-items: center; justify-content: center; gap: 0.5rem;">
                        <p style="margin:0; font-weight: 600;">On-Time</p>
                        ${createProgressRing(response.ontimeRate || 100, '#43e97b')}
                    </div>
                `;
                
                // Toggle status switch state
                const checkbox = document.getElementById('online-toggle');
                if (checkbox) {
                    checkbox.checked = response.isOnline;
                    const label = document.getElementById('status-label');
                    label.textContent = response.isOnline ? 'Online' : 'Offline';
                    label.className = 'toggle-label ' + (response.isOnline ? 'status-online' : 'status-offline');
                }

                // Trigger animation after render
                setTimeout(() => {
                    document.querySelectorAll('.progress-ring__circle').forEach(ring => {
                        const offset = ring.getAttribute('stroke-dashoffset');
                        ring.style.strokeDashoffset = '0'; // reset for transition
                        setTimeout(() => ring.style.strokeDashoffset = offset, 50);
                    });
                }, 100);
            }
        };

        const toggleOnlineStatus = async (checkbox) => {
            const label = document.getElementById('status-label');
            const isOnline = checkbox.checked;
            
            label.textContent = isOnline ? 'Online' : 'Offline';
            label.className = 'toggle-label ' + (isOnline ? 'status-online' : 'status-offline');

            await apiFetch('toggle_online', { isOnline: isOnline });
        };

        const loadDeliveries = async () => {
            // Get Active Delivery
            const activeRes = await apiFetch('active_delivery');
            const activeContainer = document.getElementById('active-delivery-container');
            
            if (activeRes && activeRes.activeDelivery) {
                const activeDelivery = activeRes.activeDelivery;
                let progressClass = '';
                if (activeDelivery.status === 'Picked Up') progressClass = 'picked-up';
                else if (activeDelivery.status === 'On the Way') progressClass = 'on-the-way';
                else if (activeDelivery.status === 'Delivered') progressClass = 'delivered';
                
                activeContainer.innerHTML = `
                    <div class="delivery-card">
                        <div class="delivery-header">
                            <span class="order-id">ORD-${activeDelivery.orderId}</span>
                            <span class="status-badge status-active">${activeDelivery.status}</span>
                        </div>
                        <div style="margin-bottom: 1.5rem;">
                            <p style="margin: 0.25rem 0;"><strong>Pickup:</strong> ${activeDelivery.restaurantName} (${activeDelivery.pickupLocation})</p>
                            <p style="margin: 0.25rem 0;"><strong>Deliver to:</strong> ${activeDelivery.customerName}</p>
                            <p style="color: var(--text-muted); font-size: 0.9rem; margin-top: 0.5rem; font-style: italic;">${activeDelivery.items || 'No items listed'}</p>
                            <p style="margin: 0.25rem 0; color: var(--success); font-weight: 600;">Est. Earnings: ₹${(activeDelivery.deliveryFee || 0).toFixed(2)}</p>
                        </div>
                        
                        <div class="route-map">
                            <div class="route-icon"><i class="fas fa-store"></i></div>
                            <div class="route-path">
                                <div class="route-progress ${progressClass}" id="route-prog"></div>
                            </div>
                            <div class="route-icon"><i class="fas fa-user"></i></div>
                        </div>

                        <div style="display: flex; gap: 1rem; margin-bottom: 1rem;">
                            <button class="btn btn-outline" style="flex: 1;" onclick="alert('Calling Restaurant: 555-0199')"><i class="fas fa-phone"></i> Call Restaurant</button>
                            <button class="btn btn-outline" style="flex: 1;" onclick="alert('Calling Customer: 555-0120')"><i class="fas fa-phone"></i> Call Customer</button>
                        </div>
                        
                        <div style="display: flex; gap: 0.5rem; flex-wrap: wrap;">
                            <button class="btn btn-primary btn-sm" style="flex: 1;" onclick="updateDeliveryStatus('Picked Up', ${activeDelivery.orderId})">Mark Picked Up</button>
                            <button class="btn btn-primary btn-sm" style="flex: 1;" onclick="updateDeliveryStatus('On the Way', ${activeDelivery.orderId})">Mark On the Way</button>
                            <button class="btn btn-success btn-sm" style="flex: 1;" onclick="updateDeliveryStatus('Delivered', ${activeDelivery.orderId})">Mark Delivered</button>
                        </div>
                    </div>
                `;
            } else {
                activeContainer.innerHTML = `<p style="text-align: center; color: var(--text-muted); padding: 1.5rem;">No active deliveries.</p>`;
            }

            // Get Available Requests
            const reqRes = await apiFetch('delivery_requests');
            const requestsContainer = document.getElementById('available-requests-container');
            if (reqRes && reqRes.requests && reqRes.requests.length > 0) {
                requestsContainer.innerHTML = reqRes.requests.map(req => `
                    <div class="glass-card delivery-card">
                        <div class="delivery-header">
                            <span class="order-id">ORD-${req.orderId}</span>
                            <span class="status-badge status-ready">Ready for Pickup</span>
                        </div>
                        <div style="margin-bottom: 1rem;">
                            <p><strong>From:</strong> ${req.restaurantName} (${req.pickupAddress})</p>
                            <p><strong>To:</strong> ${req.customerName}</p>
                            <p style="color: var(--success); font-weight: 600;">Est. Earnings: ₹${(req.deliveryFee || 0).toFixed(2)}</p>
                        </div>
                        <button class="btn btn-primary" onclick="acceptDelivery(${req.orderId})">Accept Delivery</button>
                    </div>
                `).join('');
            } else {
                requestsContainer.innerHTML = `<p style="text-align: center; color: var(--text-muted); width: 100%; padding: 1.5rem;">No available requests at the moment.</p>`;
            }
        };

        const acceptDelivery = async (id) => {
            const res = await apiFetch('accept_delivery', { orderId: id });
            if (res && res.success) {
                alert("Delivery Accepted!");
                loadDeliveries();
            } else {
                alert("Error accepting delivery: " + (res ? res.error : "Unknown error"));
            }
        };

        const updateDeliveryStatus = async (status, orderId) => {
            const res = await apiFetch('update_delivery_status', { status: status, orderId: orderId });
            if (res && res.success) {
                alert(`Status updated to: ${status}`);
                loadDeliveries();
            } else {
                alert("Error updating status: " + (res ? res.error : "Unknown error"));
            }
        };

        const loadEarnings = async () => {
            const response = await apiFetch('earnings_history');
            const tbody = document.getElementById('earnings-table-body');
            
            let total = 0;
            let count = 0;
            
            if (response && response.earnings && response.earnings.length > 0) {
                tbody.innerHTML = response.earnings.map(h => {
                    total += h.deliveryFee;
                    count++;
                    return `
                        <tr>
                            <td>${h.date}</td>
                            <td style="font-weight:600; color:var(--primary);">ORD-${h.orderId}</td>
                            <td>₹${h.deliveryFee.toFixed(2)}</td>
                            <td><span class="status-badge status-active">Delivered</span></td>
                        </tr>
                    `;
                }).join('');
            } else {
                tbody.innerHTML = `<tr><td colspan="4" style="text-align: center; color: var(--text-muted); padding: 1.5rem;">No earnings history found.</td></tr>`;
            }
            
            document.getElementById('earn-total').textContent = `₹${total.toFixed(2)}`;
            document.getElementById('earn-month').textContent = `₹${total.toFixed(2)}`;
            document.getElementById('earn-pending').textContent = `₹0.00`;
            
            // update incentives progress
            const incCompleted = count > 5 ? 5 : count;
            const percentage = (incCompleted / 5) * 100;
            const incText = `${incCompleted}/5 Completed`;
            
            const incBar = document.getElementById('inc-bar');
            if (incBar) {
                incBar.style.width = `${percentage}%`;
            }
            const incTextEl = document.getElementById('inc-text');
            if (incTextEl) {
                incTextEl.textContent = incText;
            }
        };

        const loadProfile = async () => {
            const response = await apiFetch('partner_profile');
            if (response && response.profile) {
                const p = response.profile;
                const form = document.getElementById('profile-form');
                if (form) {
                    form.elements['vehicleType'].value = p.vehicleType || 'Bicycle';
                    form.elements['vehicleNumber'].value = p.vehicleNumber || '';
                    form.elements['licenseNumber'].value = p.licenseNumber || '';
                    form.elements['bankName'].value = p.bankName || '';
                    form.elements['accountNumber'].value = p.accountNumber || '';
                    form.elements['ifscCode'].value = p.ifscCode || '';
                }
                
                // Update doc verification badges
                const slots = document.querySelectorAll('.upload-slot');
                if (slots.length >= 3) {
                    const statusText = p.documentStatus || 'Pending';
                    let badgeClass = 'status-ready';
                    if (statusText === 'Verified') badgeClass = 'status-active';
                    else if (statusText === 'Under Review') badgeClass = 'status-ready';
                    
                    slots.forEach(slot => {
                        const badge = slot.querySelector('.status-badge');
                        if (badge) {
                            badge.textContent = statusText;
                            badge.className = `status-badge ${badgeClass}`;
                        }
                    });
                }
            }
        };

        const saveProfile = async (e) => {
            e.preventDefault();
            const formData = new FormData(e.target);
            const data = Object.fromEntries(formData.entries());
            const res = await apiFetch('update_profile', data);
            if (res && res.success) {
                alert("Profile saved successfully!");
                loadProfile();
            } else {
                alert("Error saving profile: " + (res ? res.error : "Unknown error"));
            }
        };

        const loadFeedback = async () => {
            const response = await apiFetch('recent_feedback');
            if (response && response.feedback) {
                const container = document.getElementById('feedback-container');
                container.innerHTML = response.feedback.map(f => `
                    <div style="padding: 1rem; border-bottom: 1px solid var(--border-color);">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 0.5rem;">
                            <strong>Customer</strong>
                            <span style="color: #FFB347;">${'<i class="fas fa-star"></i>'.repeat(f.rating)}</span>
                        </div>
                        <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 0.5rem;">${f.comment}</p>
                        <small style="color: #aaa;">${f.date}</small>
                    </div>
                `).join('');
            }
        };

        const loadAlerts = async () => {
            const response = await apiFetch('notifications');
            const container = document.getElementById('alerts-container');
            if (response && response.notifications && response.notifications.length > 0) {
                container.innerHTML = response.notifications.map(n => `
                    <div class="alert-item">
                        <div class="alert-icon">📦</div>
                        <div class="alert-content">
                            <p><strong>Status Update</strong></p>
                            <p style="color: var(--text-muted); font-size: 0.9rem;">${n.message}</p>
                            <span class="alert-time">${n.date}</span>
                        </div>
                    </div>
                `).join('');
            } else {
                container.innerHTML = `<p style="text-align: center; color: var(--text-muted); padding: 1.5rem;">No alerts at this time.</p>`;
            }
        };

    </script>
</body>
</html>
