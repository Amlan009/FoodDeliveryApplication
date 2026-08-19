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
import java.util.ArrayList;
import java.util.List;

@WebServlet({"/owner-api", "/OwnerServlet"})
public class RestaurantOwnerServlet extends HttpServlet {

    private final UserDAOImpl userDAO = new UserDAOImpl();

    private boolean isOwner(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        User user = (User) session.getAttribute("user");
        if (user == null) return false;
        return "Restaurant Owner".equals(user.getRole());
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
        if (!isOwner(request)) {
            sendError(response, 403, "Access denied");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            sendError(response, 400, "Missing action parameter");
            return;
        }

        User user = (User) request.getSession().getAttribute("user");
        String restaurantId = user.getRestaurantId();
        if (restaurantId == null || restaurantId.trim().isEmpty()) {
            try {
                User freshUser = userDAO.getUserByEmail(user.getEmail());
                if (freshUser != null && freshUser.getRestaurantId() != null && !freshUser.getRestaurantId().trim().isEmpty()) {
                    user.setRestaurantId(freshUser.getRestaurantId());
                    restaurantId = freshUser.getRestaurantId();
                    request.getSession().setAttribute("user", user);
                }
            } catch (Exception ignored) {}
        }

        try {
            if ("available_restaurants".equals(action)) {
                handleAvailableRestaurants(response);
                return;
            }

            if (restaurantId == null || restaurantId.trim().isEmpty()) {
                sendError(response, 403, "Restaurant not selected");
                return;
            }

            switch (action) {
                case "dashboard_stats":
                    handleDashboardStats(response, restaurantId);
                    break;
                case "order_trends":
                    handleOrderTrends(response, restaurantId);
                    break;
                case "top_items":
                    handleTopItems(response, restaurantId);
                    break;
                case "recent_reviews":
                    handleRecentReviews(response, restaurantId);
                    break;
                case "all_orders":
                    handleAllOrders(response, restaurantId);
                    break;
                case "menu_categories":
                    handleMenuCategories(response, restaurantId);
                    break;
                case "menu_items":
                    handleMenuItems(response, restaurantId);
                    break;
                case "restaurant_profile":
                    handleRestaurantProfile(response, restaurantId);
                    break;
                case "earnings_summary":
                    handleEarningsSummary(response, restaurantId);
                    break;
                case "menu_data":
                    handleMenuData(response, restaurantId);
                    break;
                case "notifications":
                    handleNotifications(response, restaurantId);
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
        if (!isOwner(request)) {
            sendError(response, 403, "Access denied");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            sendError(response, 400, "Missing action parameter");
            return;
        }

        User user = (User) request.getSession().getAttribute("user");
        String restaurantId = user.getRestaurantId();
        if (restaurantId == null || restaurantId.trim().isEmpty()) {
            try {
                User freshUser = userDAO.getUserByEmail(user.getEmail());
                if (freshUser != null && freshUser.getRestaurantId() != null && !freshUser.getRestaurantId().trim().isEmpty()) {
                    user.setRestaurantId(freshUser.getRestaurantId());
                    restaurantId = freshUser.getRestaurantId();
                    request.getSession().setAttribute("user", user);
                }
            } catch (Exception ignored) {}
        }

        try {
            if ("select_restaurant".equals(action)) {
                handleSelectRestaurant(request, response, user);
                return;
            }

            if (restaurantId == null || restaurantId.trim().isEmpty()) {
                sendError(response, 403, "Restaurant not selected");
                return;
            }

            switch (action) {
                case "update_order_status":
                    handleUpdateOrderStatus(request, response, restaurantId);
                    break;
                case "add_dish":
                    handleAddDish(request, response, restaurantId);
                    break;
                case "update_dish":
                    handleUpdateDish(request, response, restaurantId);
                    break;
                case "delete_dish":
                    handleDeleteDish(request, response, restaurantId);
                    break;
                case "add_category":
                    handleAddCategory(request, response, restaurantId);
                    break;
                case "delete_category":
                    handleDeleteCategory(request, response, restaurantId);
                    break;
                case "update_restaurant_profile":
                    handleUpdateRestaurantProfile(request, response, restaurantId);
                    break;
                default:
                    sendError(response, 400, "Unknown action: " + action);
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, 500, "Server error: " + e.getMessage());
        }
    }

    private void handleAvailableRestaurants(HttpServletResponse response) throws IOException, SQLException {
        String sql = "SELECT id, name FROM restaurants ORDER BY name";
        StringBuilder sb = new StringBuilder("{\"restaurants\":[");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                sb.append(String.format("{\"id\":\"%s\",\"name\":\"%s\"}",
                    escapeJson(rs.getString("id")),
                    escapeJson(rs.getString("name"))));
                first = false;
            }
        }
        sb.append("]}");
        sendJson(response, sb.toString());
    }

    private void handleDashboardStats(HttpServletResponse response, String restaurantId) throws IOException, SQLException {
        int todayOrders = 0;
        double todayRevenue = 0.0;
        int totalOrders = 0;
        double totalRevenue = 0.0;
        int pendingOrders = 0;
        double avgRating = 0.0;

        String sqlToday = "SELECT COUNT(*), SUM(grand_total) FROM orders WHERE restaurant_id = ? AND DATE(created_at) = CURDATE() AND order_status != 'Cancelled'";
        String sqlTotal = "SELECT COUNT(*), SUM(grand_total) FROM orders WHERE restaurant_id = ? AND order_status != 'Cancelled'";
        String sqlPending = "SELECT COUNT(*) FROM orders WHERE restaurant_id = ? AND order_status IN ('Pending', 'Preparing', 'Out for Delivery')";
        String sqlRating = "SELECT rating FROM restaurants WHERE id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlToday)) {
                ps.setString(1, restaurantId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    todayOrders = rs.getInt(1);
                    todayRevenue = rs.getDouble(2);
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlTotal)) {
                ps.setString(1, restaurantId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    totalOrders = rs.getInt(1);
                    totalRevenue = rs.getDouble(2);
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlPending)) {
                ps.setString(1, restaurantId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) pendingOrders = rs.getInt(1);
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlRating)) {
                ps.setString(1, restaurantId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) avgRating = rs.getDouble(1);
            }
        }

        String json = String.format(
            "{\"todayOrders\":%d,\"todayRevenue\":%.2f,\"totalOrders\":%d,\"totalRevenue\":%.2f,\"pendingOrders\":%d,\"avgRating\":%.1f}",
            todayOrders, todayRevenue, totalOrders, totalRevenue, pendingOrders, avgRating
        );
        sendJson(response, json);
    }

    private void handleOrderTrends(HttpServletResponse response, String restaurantId) throws IOException, SQLException {
        String sql = "SELECT DATE(created_at) as d, COUNT(*) as c FROM orders WHERE restaurant_id = ? AND created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) GROUP BY d ORDER BY d ASC";
        StringBuilder labels = new StringBuilder("[");
        StringBuilder data = new StringBuilder("[");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, restaurantId);
            ResultSet rs = ps.executeQuery();
            boolean first = true;
            while (rs.next()) {
                if (!first) { labels.append(","); data.append(","); }
                labels.append("\"").append(escapeJson(rs.getString("d"))).append("\"");
                data.append(rs.getInt("c"));
                first = false;
            }
        }
        labels.append("]");
        data.append("]");
        sendJson(response, "{\"labels\":" + labels + ",\"data\":" + data + "}");
    }

    private void handleTopItems(HttpServletResponse response, String restaurantId) throws IOException, SQLException {
        String sql = "SELECT d.`name` AS dish_name, SUM(oi.`quantity`) AS total_qty, SUM(oi.`price_at_purchase` * oi.`quantity`) AS total_revenue " +
                     "FROM `order_items` oi JOIN `dishes` d ON oi.`dish_id` = d.`id` JOIN `menu_categories` mc ON d.`category_id` = mc.`id` " +
                     "WHERE mc.`restaurant_id` = ? " +
                     "GROUP BY d.`id`, d.`name` ORDER BY total_qty DESC LIMIT 5";
        StringBuilder sb = new StringBuilder("{\"items\":[");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, restaurantId);
            ResultSet rs = ps.executeQuery();
            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                sb.append(String.format("{\"name\":\"%s\",\"count\":%d,\"revenue\":%.2f}",
                    escapeJson(rs.getString("dish_name")),
                    rs.getInt("total_qty"),
                    rs.getDouble("total_revenue")));
                first = false;
            }
        }
        sb.append("]}");
        sendJson(response, sb.toString());
    }

    private void handleRecentReviews(HttpServletResponse response, String restaurantId) throws IOException, SQLException {
        String sql = "SELECT rv.*, u.`full_name` FROM `reviews` rv LEFT JOIN `users` u ON rv.`user_id` = u.`id` WHERE rv.`restaurant_id` = ? ORDER BY rv.`created_at` DESC LIMIT 10";
        StringBuilder sb = new StringBuilder("{\"reviews\":[");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, restaurantId);
            ResultSet rs = ps.executeQuery();
            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                sb.append(String.format("{\"userName\":\"%s\",\"rating\":%d,\"comment\":\"%s\",\"createdAt\":\"%s\"}",
                    escapeJson(rs.getString("full_name") != null ? rs.getString("full_name") : "Anonymous"),
                    rs.getInt("rating"),
                    escapeJson(rs.getString("comment")),
                    rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toString() : ""));
                first = false;
            }
        }
        sb.append("]}");
        sendJson(response, sb.toString());
    }

    private void handleAllOrders(HttpServletResponse response, String restaurantId) throws IOException, SQLException {
        String sql = "SELECT o.*, u.`full_name` AS user_name, " +
                     "(SELECT COUNT(*) FROM `order_items` oi WHERE oi.`order_id` = o.`id`) AS item_count " +
                     "FROM `orders` o LEFT JOIN `users` u ON o.`user_id` = u.`id` WHERE o.`restaurant_id` = ? ORDER BY o.`created_at` DESC";
        StringBuilder sb = new StringBuilder("{\"orders\":[");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, restaurantId);
            ResultSet rs = ps.executeQuery();
            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                sb.append(String.format(
                    "{\"id\":%d,\"userName\":\"%s\",\"grandTotal\":%.2f,\"orderStatus\":\"%s\",\"createdAt\":\"%s\",\"itemCount\":%d}",
                    rs.getInt("id"),
                    escapeJson(rs.getString("user_name") != null ? rs.getString("user_name") : "Unknown"),
                    rs.getDouble("grand_total"),
                    escapeJson(rs.getString("order_status") != null ? rs.getString("order_status") : ""),
                    rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toString() : "",
                    rs.getInt("item_count")
                ));
                first = false;
            }
        }
        sb.append("]}");
        sendJson(response, sb.toString());
    }

    private void handleMenuCategories(HttpServletResponse response, String restaurantId) throws IOException, SQLException {
        String sql = "SELECT * FROM `menu_categories` WHERE `restaurant_id` = ? ORDER BY `sort_order` ASC";
        StringBuilder sb = new StringBuilder("{\"categories\":[");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, restaurantId);
            ResultSet rs = ps.executeQuery();
            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                sb.append(String.format("{\"id\":%d,\"name\":\"%s\",\"sortOrder\":%d}",
                    rs.getInt("id"),
                    escapeJson(rs.getString("category_name")),
                    rs.getInt("sort_order")));
                first = false;
            }
        }
        sb.append("]}");
        sendJson(response, sb.toString());
    }

    private void handleMenuItems(HttpServletResponse response, String restaurantId) throws IOException, SQLException {
        String sql = "SELECT d.*, mc.`category_name` FROM `dishes` d JOIN `menu_categories` mc ON d.`category_id` = mc.`id` WHERE mc.`restaurant_id` = ?";
        StringBuilder sb = new StringBuilder("{\"items\":[");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, restaurantId);
            ResultSet rs = ps.executeQuery();
            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                sb.append(String.format(
                    "{\"id\":%d,\"categoryId\":%d,\"categoryName\":\"%s\",\"name\":\"%s\",\"price\":%.2f,\"isVeg\":%b,\"isBestseller\":%b,\"rating\":%.1f,\"description\":\"%s\",\"imageUrl\":\"%s\"}",
                    rs.getInt("id"),
                    rs.getInt("category_id"),
                    escapeJson(rs.getString("category_name")),
                    escapeJson(rs.getString("name")),
                    rs.getDouble("price"),
                    rs.getBoolean("is_veg"),
                    rs.getBoolean("is_bestseller"),
                    rs.getDouble("rating"),
                    escapeJson(rs.getString("description")),
                    escapeJson(rs.getString("image_url"))
                ));
                first = false;
            }
        }
        sb.append("]}");
        sendJson(response, sb.toString());
    }

    private void handleRestaurantProfile(HttpServletResponse response, String restaurantId) throws IOException, SQLException {
        String sql = "SELECT * FROM `restaurants` WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, restaurantId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String json = String.format(
                    "{\"restaurant\":{\"id\":\"%s\",\"name\":\"%s\",\"rating\":%.1f,\"deliveryTime\":\"%s\",\"costForTwo\":%d,\"closesAt\":\"%s\",\"outletLocation\":\"%s\",\"bannerUrl\":\"%s\",\"discountTag\":\"%s\"}}",
                    escapeJson(rs.getString("id")),
                    escapeJson(rs.getString("name")),
                    rs.getDouble("rating"),
                    escapeJson(rs.getString("delivery_time")),
                    rs.getInt("cost_for_two"),
                    escapeJson(rs.getString("closes_at")),
                    escapeJson(rs.getString("outlet_location")),
                    escapeJson(rs.getString("banner_url")),
                    escapeJson(rs.getString("discount_tag"))
                );
                sendJson(response, json);
            } else {
                sendError(response, 404, "Restaurant not found");
            }
        }
    }

    private void handleEarningsSummary(HttpServletResponse response, String restaurantId) throws IOException, SQLException {
        double grossRevenue = 0.0;
        double cancelledRefunds = 0.0;
        int totalOrders = 0;

        String sql = "SELECT SUM(CASE WHEN order_status != 'Cancelled' THEN grand_total ELSE 0 END) as gross, " +
                     "SUM(CASE WHEN order_status = 'Cancelled' THEN grand_total ELSE 0 END) as refunds, " +
                     "COUNT(*) as orders FROM `orders` WHERE `restaurant_id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, restaurantId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                grossRevenue = rs.getDouble("gross");
                cancelledRefunds = rs.getDouble("refunds");
                totalOrders = rs.getInt("orders");
            }
        }
        double commission = grossRevenue * 0.20;
        double netEarnings = grossRevenue - commission;

        String json = String.format(
            "{\"grossRevenue\":%.2f,\"commission\":%.2f,\"netEarnings\":%.2f,\"totalOrders\":%d,\"cancelledRefunds\":%.2f}",
            grossRevenue, commission, netEarnings, totalOrders, cancelledRefunds
        );
        sendJson(response, json);
    }

    private void handleSelectRestaurant(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        String rId = request.getParameter("restaurantId");
        if (rId == null || rId.trim().isEmpty()) {
            sendError(response, 400, "Missing restaurantId");
            return;
        }
        userDAO.updateUserRestaurantId(user.getId(), rId);
        user.setRestaurantId(rId);
        request.getSession().setAttribute("user", user);
        sendJson(response, "{\"success\":true}");
    }

    private void handleUpdateOrderStatus(HttpServletRequest request, HttpServletResponse response, String restaurantId) throws IOException, SQLException {
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        String status = request.getParameter("status");
        String sql = "UPDATE `orders` SET `order_status` = ? WHERE `id` = ? AND `restaurant_id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            ps.setString(3, restaurantId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                sendJson(response, "{\"success\":true}");
            } else {
                sendError(response, 400, "Order not found or unauthorized");
            }
        }
    }

    private void handleAddDish(HttpServletRequest request, HttpServletResponse response, String restaurantId) throws IOException, SQLException {
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));
        
        // Verify category belongs to restaurant
        String verifySql = "SELECT id FROM `menu_categories` WHERE `id` = ? AND `restaurant_id` = ?";
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement psVerify = conn.prepareStatement(verifySql)) {
                psVerify.setInt(1, categoryId);
                psVerify.setString(2, restaurantId);
                ResultSet rs = psVerify.executeQuery();
                if (!rs.next()) {
                    sendError(response, 403, "Category does not belong to this restaurant");
                    return;
                }
            }
            
            String name = request.getParameter("name");
            double price = Double.parseDouble(request.getParameter("price"));
            String description = request.getParameter("description");
            boolean isVeg = Boolean.parseBoolean(request.getParameter("isVeg"));
            String imageUrl = request.getParameter("imageUrl");

            String sql = "INSERT INTO `dishes` (`category_id`, `name`, `price`, `description`, `is_veg`, `image_url`) VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, categoryId);
                ps.setString(2, name);
                ps.setDouble(3, price);
                ps.setString(4, description);
                ps.setBoolean(5, isVeg);
                ps.setString(6, imageUrl);
                ps.executeUpdate();
            }
            sendJson(response, "{\"success\":true}");
        }
    }

    private void handleUpdateDish(HttpServletRequest request, HttpServletResponse response, String restaurantId) throws IOException, SQLException {
        int dishId = Integer.parseInt(request.getParameter("dishId"));
        
        // Verify dish belongs to restaurant
        String verifySql = "SELECT d.id FROM `dishes` d JOIN `menu_categories` mc ON d.`category_id` = mc.`id` WHERE d.`id` = ? AND mc.`restaurant_id` = ?";
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement psVerify = conn.prepareStatement(verifySql)) {
                psVerify.setInt(1, dishId);
                psVerify.setString(2, restaurantId);
                ResultSet rs = psVerify.executeQuery();
                if (!rs.next()) {
                    sendError(response, 403, "Dish does not belong to this restaurant");
                    return;
                }
            }

            String name = request.getParameter("name");
            double price = Double.parseDouble(request.getParameter("price"));
            String description = request.getParameter("description");
            boolean isVeg = Boolean.parseBoolean(request.getParameter("isVeg"));
            String imageUrl = request.getParameter("imageUrl");

            String sql = "UPDATE `dishes` SET `name` = ?, `price` = ?, `description` = ?, `is_veg` = ?, `image_url` = ? WHERE `id` = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, name);
                ps.setDouble(2, price);
                ps.setString(3, description);
                ps.setBoolean(4, isVeg);
                ps.setString(5, imageUrl);
                ps.setInt(6, dishId);
                ps.executeUpdate();
            }
            sendJson(response, "{\"success\":true}");
        }
    }

    private void handleDeleteDish(HttpServletRequest request, HttpServletResponse response, String restaurantId) throws IOException, SQLException {
        int dishId = Integer.parseInt(request.getParameter("dishId"));
        
        // Verify dish belongs to restaurant
        String verifySql = "SELECT d.id FROM `dishes` d JOIN `menu_categories` mc ON d.`category_id` = mc.`id` WHERE d.`id` = ? AND mc.`restaurant_id` = ?";
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement psVerify = conn.prepareStatement(verifySql)) {
                psVerify.setInt(1, dishId);
                psVerify.setString(2, restaurantId);
                ResultSet rs = psVerify.executeQuery();
                if (!rs.next()) {
                    sendError(response, 403, "Dish does not belong to this restaurant");
                    return;
                }
            }

            String sql = "DELETE FROM `dishes` WHERE `id` = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, dishId);
                ps.executeUpdate();
            }
            sendJson(response, "{\"success\":true}");
        }
    }

    private void handleAddCategory(HttpServletRequest request, HttpServletResponse response, String restaurantId) throws IOException, SQLException {
        String categoryName = request.getParameter("categoryName");
        int sortOrder = Integer.parseInt(request.getParameter("sortOrder"));

        String sql = "INSERT INTO `menu_categories` (`restaurant_id`, `category_name`, `sort_order`) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, restaurantId);
            ps.setString(2, categoryName);
            ps.setInt(3, sortOrder);
            ps.executeUpdate();
        }
        sendJson(response, "{\"success\":true}");
    }

    private void handleDeleteCategory(HttpServletRequest request, HttpServletResponse response, String restaurantId) throws IOException, SQLException {
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));

        String sql = "DELETE FROM `menu_categories` WHERE `id` = ? AND `restaurant_id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            ps.setString(2, restaurantId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                sendJson(response, "{\"success\":true}");
            } else {
                sendError(response, 403, "Category not found or unauthorized");
            }
        }
    }

    private void handleUpdateRestaurantProfile(HttpServletRequest request, HttpServletResponse response, String restaurantId) throws IOException, SQLException {
        String name = request.getParameter("name");
        String outletLocation = request.getParameter("outletLocation");
        String closesAt = request.getParameter("closesAt");
        int costForTwo = Integer.parseInt(request.getParameter("costForTwo"));
        String deliveryTime = request.getParameter("deliveryTime");
        String bannerUrl = request.getParameter("bannerUrl");
        String discountTag = request.getParameter("discountTag");

        String sql = "UPDATE `restaurants` SET `name`=?, `outlet_location`=?, `closes_at`=?, `cost_for_two`=?, `delivery_time`=?, `banner_url`=?, `discount_tag`=? WHERE `id`=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, outletLocation);
            ps.setString(3, closesAt);
            ps.setInt(4, costForTwo);
            ps.setString(5, deliveryTime);
            ps.setString(6, bannerUrl);
            ps.setString(7, discountTag);
            ps.setString(8, restaurantId);
            ps.executeUpdate();
        }
        sendJson(response, "{\"success\":true}");
    }

    private void handleMenuData(HttpServletResponse response, String restaurantId) throws IOException, SQLException {
        String catSql = "SELECT * FROM `menu_categories` WHERE `restaurant_id` = ? ORDER BY `sort_order` ASC";
        String dishSql = "SELECT * FROM `dishes` WHERE `category_id` = ? ORDER BY `id` ASC";
        StringBuilder sb = new StringBuilder("{\"categories\":[");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement catPs = conn.prepareStatement(catSql)) {
            catPs.setString(1, restaurantId);
            try (ResultSet catRs = catPs.executeQuery()) {
                boolean firstCat = true;
                while (catRs.next()) {
                    if (!firstCat) sb.append(",");
                    int catId = catRs.getInt("id");
                    String catName = catRs.getString("category_name");
                    sb.append(String.format("{\"id\":%d,\"name\":\"%s\",\"dishes\":[", catId, escapeJson(catName)));
                    
                    try (PreparedStatement dishPs = conn.prepareStatement(dishSql)) {
                        dishPs.setInt(1, catId);
                        try (ResultSet dishRs = dishPs.executeQuery()) {
                            boolean firstDish = true;
                            while (dishRs.next()) {
                                if (!firstDish) sb.append(",");
                                sb.append(String.format("{\"id\":%d,\"categoryId\":%d,\"name\":\"%s\",\"price\":%.2f,\"isVeg\":%b,\"description\":\"%s\",\"imageUrl\":\"%s\"}",
                                    dishRs.getInt("id"),
                                    catId,
                                    escapeJson(dishRs.getString("name")),
                                    dishRs.getDouble("price"),
                                    dishRs.getBoolean("is_veg"),
                                    escapeJson(dishRs.getString("description")),
                                    escapeJson(dishRs.getString("image_url"))
                                ));
                                firstDish = false;
                            }
                        }
                    }
                    sb.append("]}");
                    firstCat = false;
                }
            }
        }
        sb.append("]}");
        sendJson(response, sb.toString());
    }

    private void handleNotifications(HttpServletResponse response, String restaurantId) throws IOException, SQLException {
        String sql = "SELECT `id`, `order_status`, `created_at` FROM `orders` WHERE `restaurant_id` = ? ORDER BY `created_at` DESC LIMIT 10";
        StringBuilder sb = new StringBuilder("{\"notifications\":[");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                boolean first = true;
                while (rs.next()) {
                    if (!first) sb.append(",");
                    int orderId = rs.getInt("id");
                    String status = rs.getString("order_status");
                    Timestamp createdAt = rs.getTimestamp("created_at");
                    String dateStr = createdAt != null ? createdAt.toString() : "";
                    
                    String message = "Order #" + orderId + " is " + status;
                    if ("Pending".equalsIgnoreCase(status)) {
                        message = "New order #" + orderId + " received";
                    } else if ("Delivered".equalsIgnoreCase(status)) {
                        message = "Order #" + orderId + " delivered successfully";
                    } else if ("Cancelled".equalsIgnoreCase(status)) {
                        message = "Order #" + orderId + " was cancelled";
                    }
                    
                    sb.append(String.format("{\"message\":\"%s\",\"date\":\"%s\"}", escapeJson(message), escapeJson(dateStr)));
                    first = false;
                }
            }
        }
        sb.append("]}");
        sendJson(response, sb.toString());
    }
}
