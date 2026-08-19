package com.khaalo.servlets;

import com.khaalo.daoimpl.*;
import com.khaalo.model.*;
import com.util.connection.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.List;
import java.util.Map;

@WebServlet({"/admin-api", "/AdminServlet"})
public class AdminServlet extends HttpServlet {

    private final UserDAOImpl userDAO = new UserDAOImpl();
    private final OrderDAOImpl orderDAO = new OrderDAOImpl();
    private final RestaurantDAOImpl restaurantDAO = new RestaurantDAOImpl();
    private final CouponDAOImpl couponDAO = new CouponDAOImpl();

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        User user = (User) session.getAttribute("user");
        if (user == null) return false;
        return "Administrator".equals(user.getRole());
    }

    private void sendJson(HttpServletResponse response, String json) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print(json);
        out.flush();
    }

    private void sendError(HttpServletResponse response, int code, String msg) throws IOException {
        response.setStatus(code);
        sendJson(response, "{\"error\":\"" + escapeJson(msg) + "\"}");
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!isAdmin(request)) {
            sendError(response, 403, "Access denied");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            sendError(response, 400, "Missing action parameter");
            return;
        }

        try {
            switch (action) {
                case "dashboard_stats":
                    handleDashboardStats(response);
                    break;
                case "order_trends":
                    handleOrderTrends(response);
                    break;
                case "peak_hours":
                    handlePeakHours(response);
                    break;
                case "top_items":
                    handleTopItems(response);
                    break;
                case "top_restaurants":
                    handleTopRestaurants(response);
                    break;
                case "all_users":
                    handleAllUsers(response);
                    break;
                case "all_restaurants":
                    handleAllRestaurants(response);
                    break;
                case "all_orders":
                    handleAllOrders(response);
                    break;
                case "all_coupons":
                    handleAllCoupons(response);
                    break;
                case "payment_summary":
                    handlePaymentSummary(response);
                    break;
                default:
                    sendError(response, 400, "Unknown action: " + action);
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, 500, "Server error: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!isAdmin(request)) {
            sendError(response, 403, "Access denied");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            sendError(response, 400, "Missing action parameter");
            return;
        }

        try {
            switch (action) {
                case "block_user":
                    handleBlockUser(request, response);
                    break;
                case "delete_user":
                    handleDeleteUser(request, response);
                    break;
                case "update_order_status":
                    handleUpdateOrderStatus(request, response);
                    break;
                case "cancel_order":
                    handleCancelOrder(request, response);
                    break;
                case "add_coupon":
                    handleAddCoupon(request, response);
                    break;
                case "toggle_coupon":
                    handleToggleCoupon(request, response);
                    break;
                case "delete_coupon":
                    handleDeleteCoupon(request, response);
                    break;
                case "toggle_restaurant":
                    handleToggleRestaurant(request, response);
                    break;
                default:
                    sendError(response, 400, "Unknown action: " + action);
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, 500, "Server error: " + e.getMessage());
        }
    }

    // ==================== GET Handlers ====================

    private void handleDashboardStats(HttpServletResponse response) throws IOException {
        int totalOrders = orderDAO.getTotalOrderCount();
        double totalRevenue = orderDAO.getTotalRevenue();
        int activeUsers = userDAO.getTotalUserCount();
        int pendingOrders = orderDAO.getPendingOrderCount();
        int todayOrders = orderDAO.getOrderCountToday();

        String json = String.format(
            "{\"totalOrders\":%d,\"totalRevenue\":%.2f,\"activeUsers\":%d,\"pendingOrders\":%d,\"todayOrders\":%d}",
            totalOrders, totalRevenue, activeUsers, pendingOrders, todayOrders
        );
        sendJson(response, json);
    }

    private void handleOrderTrends(HttpServletResponse response) throws IOException {
        Map<String, Integer> trends = orderDAO.getOrderCountByDate(30);
        StringBuilder labels = new StringBuilder("[");
        StringBuilder data = new StringBuilder("[");
        boolean first = true;
        for (Map.Entry<String, Integer> entry : trends.entrySet()) {
            if (!first) { labels.append(","); data.append(","); }
            labels.append("\"").append(escapeJson(entry.getKey())).append("\"");
            data.append(entry.getValue());
            first = false;
        }
        labels.append("]");
        data.append("]");
        sendJson(response, "{\"labels\":" + labels + ",\"data\":" + data + "}");
    }

    private void handlePeakHours(HttpServletResponse response) throws IOException {
        Map<Integer, Integer> hours = orderDAO.getOrderCountByHour();
        StringBuilder labels = new StringBuilder("[");
        StringBuilder data = new StringBuilder("[");
        // Fill all 24 hours
        for (int h = 0; h < 24; h++) {
            if (h > 0) { labels.append(","); data.append(","); }
            labels.append(h);
            data.append(hours.getOrDefault(h, 0));
        }
        labels.append("]");
        data.append("]");
        sendJson(response, "{\"labels\":" + labels + ",\"data\":" + data + "}");
    }

    private void handleTopItems(HttpServletResponse response) throws IOException {
        String sql = "SELECT d.`name` AS dish_name, SUM(oi.`quantity`) AS total_qty, SUM(oi.`price_at_purchase` * oi.`quantity`) AS total_revenue " +
                     "FROM `order_items` oi JOIN `dishes` d ON oi.`dish_id` = d.`id` " +
                     "GROUP BY d.`id`, d.`name` ORDER BY total_qty DESC LIMIT 5";
        StringBuilder sb = new StringBuilder("{\"items\":[");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                sb.append(String.format("{\"name\":\"%s\",\"count\":%d,\"revenue\":%.2f}",
                    escapeJson(rs.getString("dish_name")),
                    rs.getInt("total_qty"),
                    rs.getDouble("total_revenue")));
                first = false;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        sb.append("]}");
        sendJson(response, sb.toString());
    }

    private void handleTopRestaurants(HttpServletResponse response) throws IOException {
        String sql = "SELECT r.`name`, r.`rating`, COUNT(o.`id`) AS order_count " +
                     "FROM `restaurants` r INNER JOIN `orders` o ON r.`id` = o.`restaurant_id` " +
                     "GROUP BY r.`id`, r.`name`, r.`rating` ORDER BY order_count DESC LIMIT 5";
        StringBuilder sb = new StringBuilder("{\"restaurants\":[");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                sb.append(String.format("{\"name\":\"%s\",\"orders\":%d,\"rating\":%.1f}",
                    escapeJson(rs.getString("name")),
                    rs.getInt("order_count"),
                    rs.getDouble("rating")));
                first = false;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        sb.append("]}");
        sendJson(response, sb.toString());
    }

    private void handleAllUsers(HttpServletResponse response) throws IOException {
        List<User> users = userDAO.getAllUsers();
        StringBuilder sb = new StringBuilder("{\"users\":[");
        boolean first = true;
        for (User u : users) {
            if (!first) sb.append(",");
            sb.append(String.format("{\"id\":%d,\"fullName\":\"%s\",\"email\":\"%s\",\"phone\":\"%s\",\"role\":\"%s\",\"createdAt\":\"%s\"}",
                u.getId(),
                escapeJson(u.getFullName()),
                escapeJson(u.getEmail()),
                escapeJson(u.getPhone() != null ? u.getPhone() : ""),
                escapeJson(u.getRole() != null ? u.getRole() : "Customer"),
                u.getCreatedAt() != null ? u.getCreatedAt().toString() : ""));
            first = false;
        }
        sb.append("]}");
        sendJson(response, sb.toString());
    }

    private void handleAllRestaurants(HttpServletResponse response) throws IOException {
        String sql = "SELECT r.*, COUNT(o.`id`) AS order_count, " +
                     "(SELECT GROUP_CONCAT(mc.`category_name` SEPARATOR ', ') FROM `menu_categories` mc WHERE mc.`restaurant_id` = r.`id`) AS cuisines " +
                     "FROM `restaurants` r LEFT JOIN `orders` o ON r.`id` = o.`restaurant_id` " +
                     "GROUP BY r.`id`";
        StringBuilder sb = new StringBuilder("{\"restaurants\":[");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                sb.append(String.format(
                    "{\"id\":\"%s\",\"name\":\"%s\",\"rating\":%.1f,\"ratingCount\":%d,\"deliveryTime\":\"%s\",\"costForTwo\":%d,\"outletLocation\":\"%s\",\"cuisines\":\"%s\",\"orderCount\":%d}",
                    escapeJson(rs.getString("id")),
                    escapeJson(rs.getString("name")),
                    rs.getDouble("rating"),
                    rs.getInt("rating_count"),
                    escapeJson(rs.getString("delivery_time") != null ? rs.getString("delivery_time") : ""),
                    rs.getInt("cost_for_two"),
                    escapeJson(rs.getString("outlet_location") != null ? rs.getString("outlet_location") : ""),
                    escapeJson(rs.getString("cuisines") != null ? rs.getString("cuisines") : ""),
                    rs.getInt("order_count")
                ));
                first = false;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        sb.append("]}");
        sendJson(response, sb.toString());
    }

    private void handleAllOrders(HttpServletResponse response) throws IOException {
        String sql = "SELECT o.*, u.`full_name` AS user_name, r.`name` AS restaurant_name, " +
                     "(SELECT COUNT(*) FROM `order_items` oi WHERE oi.`order_id` = o.`id`) AS item_count " +
                     "FROM `orders` o " +
                     "LEFT JOIN `users` u ON o.`user_id` = u.`id` " +
                     "LEFT JOIN `restaurants` r ON o.`restaurant_id` = r.`id` " +
                     "ORDER BY o.`created_at` DESC";
        StringBuilder sb = new StringBuilder("{\"orders\":[");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                sb.append(String.format(
                    "{\"id\":%d,\"userName\":\"%s\",\"restaurantName\":\"%s\",\"grandTotal\":%.2f,\"orderStatus\":\"%s\",\"paymentMethod\":\"%s\",\"createdAt\":\"%s\",\"itemCount\":%d}",
                    rs.getInt("id"),
                    escapeJson(rs.getString("user_name") != null ? rs.getString("user_name") : "Unknown"),
                    escapeJson(rs.getString("restaurant_name") != null ? rs.getString("restaurant_name") : "Unknown"),
                    rs.getDouble("grand_total"),
                    escapeJson(rs.getString("order_status") != null ? rs.getString("order_status") : ""),
                    escapeJson(rs.getString("payment_method") != null ? rs.getString("payment_method") : ""),
                    rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toString() : "",
                    rs.getInt("item_count")
                ));
                first = false;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        sb.append("]}");
        sendJson(response, sb.toString());
    }

    private void handleAllCoupons(HttpServletResponse response) throws IOException {
        StringBuilder sb = new StringBuilder("{\"coupons\":[");
        try {
            List<Coupon> coupons = couponDAO.getAllCoupons();
            boolean first = true;
            for (Coupon c : coupons) {
                if (!first) sb.append(",");
                sb.append(String.format(
                    "{\"id\":%d,\"code\":\"%s\",\"discountPercent\":%.2f,\"maxDiscount\":%.2f,\"minOrderValue\":%.2f,\"isActive\":%b}",
                    c.getId(),
                    escapeJson(c.getCode()),
                    c.getDiscountPercent(),
                    c.getMaxDiscount(),
                    c.getMinOrderValue(),
                    c.isActive()
                ));
                first = false;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        sb.append("]}");
        sendJson(response, sb.toString());
    }

    private void handlePaymentSummary(HttpServletResponse response) throws IOException {
        double totalRevenue = orderDAO.getTotalRevenue();
        double totalRefunds = orderDAO.getTotalRefunds();
        double avgOrderValue = orderDAO.getAvgOrderValue();
        int totalTransactions = orderDAO.getTotalOrderCount();

        String json = String.format(
            "{\"totalRevenue\":%.2f,\"totalRefunds\":%.2f,\"avgOrderValue\":%.2f,\"totalTransactions\":%d}",
            totalRevenue, totalRefunds, avgOrderValue, totalTransactions
        );
        sendJson(response, json);
    }

    // ==================== POST Handlers ====================

    private void handleBlockUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int userId = Integer.parseInt(request.getParameter("userId"));
        boolean blocked = Boolean.parseBoolean(request.getParameter("blocked"));

        // Update user role to include/remove "Blocked" prefix
        User user = userDAO.getUserById(userId);
        if (user != null) {
            String currentRole = user.getRole() != null ? user.getRole() : "Customer";
            String newRole;
            if (blocked) {
                newRole = currentRole.startsWith("Blocked-") ? currentRole : "Blocked-" + currentRole;
            } else {
                newRole = currentRole.startsWith("Blocked-") ? currentRole.substring(8) : currentRole;
            }
            // Update role directly in DB
            String sql = "UPDATE `users` SET `role` = ? WHERE `id` = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newRole);
                ps.setInt(2, userId);
                ps.executeUpdate();
            } catch (SQLException e) { e.printStackTrace(); }
        }
        sendJson(response, "{\"success\":true}");
    }

    private void handleDeleteUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int userId = Integer.parseInt(request.getParameter("userId"));
        userDAO.deleteUser(userId);
        sendJson(response, "{\"success\":true}");
    }

    private void handleUpdateOrderStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        String status = request.getParameter("status");
        orderDAO.updateOrderStatus(orderId, status);
        sendJson(response, "{\"success\":true}");
    }

    private void handleCancelOrder(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        orderDAO.updateOrderStatus(orderId, "Cancelled");
        sendJson(response, "{\"success\":true}");
    }

    private void handleAddCoupon(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String code = request.getParameter("code");
        double discountPercent = Double.parseDouble(request.getParameter("discountPercent"));
        double maxDiscount = Double.parseDouble(request.getParameter("maxDiscount"));
        double minOrderValue = Double.parseDouble(request.getParameter("minOrderValue"));

        Coupon coupon = new Coupon();
        coupon.setCode(code);
        coupon.setDiscountPercent(discountPercent);
        coupon.setMaxDiscount(maxDiscount);
        coupon.setMinOrderValue(minOrderValue);
        coupon.setActive(true);

        try {
            couponDAO.addCoupon(coupon);
            sendJson(response, "{\"success\":true,\"id\":" + coupon.getId() + "}");
        } catch (SQLException e) {
            e.printStackTrace();
            sendError(response, 500, "Failed to add coupon: " + e.getMessage());
        }
    }

    private void handleToggleCoupon(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int couponId = Integer.parseInt(request.getParameter("couponId"));
        boolean active = Boolean.parseBoolean(request.getParameter("active"));
        try {
            couponDAO.toggleCoupon(couponId, active);
            sendJson(response, "{\"success\":true}");
        } catch (SQLException e) {
            e.printStackTrace();
            sendError(response, 500, "Failed to toggle coupon");
        }
    }

    private void handleDeleteCoupon(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int couponId = Integer.parseInt(request.getParameter("couponId"));
        try {
            couponDAO.deleteCoupon(couponId);
            sendJson(response, "{\"success\":true}");
        } catch (SQLException e) {
            e.printStackTrace();
            sendError(response, 500, "Failed to delete coupon");
        }
    }

    private void handleToggleRestaurant(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String restaurantId = request.getParameter("restaurantId");
        boolean enabled = Boolean.parseBoolean(request.getParameter("enabled"));
        // Toggle by updating the restaurant name with a [DISABLED] prefix or removing it
        String sql;
        if (!enabled) {
            sql = "UPDATE `restaurants` SET `name` = CONCAT('[DISABLED] ', `name`) WHERE `id` = ? AND `name` NOT LIKE '[DISABLED]%'";
        } else {
            sql = "UPDATE `restaurants` SET `name` = REPLACE(`name`, '[DISABLED] ', '') WHERE `id` = ?";
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, restaurantId);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
        sendJson(response, "{\"success\":true}");
    }
}
