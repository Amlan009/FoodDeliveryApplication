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

@WebServlet("/delivery-api")
public class DeliveryPartnerServlet extends HttpServlet {

    private final UserDAOImpl userDAO = new UserDAOImpl();

    private boolean isDeliveryPartner(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        User user = (User) session.getAttribute("user");
        if (user == null) return false;
        return "Delivery Partner".equals(user.getRole());
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

    private void ensureDeliveryPartnerData(int userId) {
        try (Connection conn = DBConnection.getConnection()) {
            String checkSql = "SELECT id FROM delivery_partners WHERE user_id = ?";
            boolean exists = false;
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) exists = true;
                }
            }
            if (!exists) {
                String insertSql = "INSERT INTO delivery_partners (user_id, is_online, document_status, rating, acceptance_rate, ontime_rate) VALUES (?, false, 'Pending', 5.0, 100.0, 100.0)";
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setInt(1, userId);
                    ps.executeUpdate();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!isDeliveryPartner(request)) {
            sendError(response, 403, "Access denied");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            sendError(response, 400, "Missing action parameter");
            return;
        }

        User user = (User) request.getSession().getAttribute("user");
        int userId = user.getId();
        ensureDeliveryPartnerData(userId);

        try {
            switch (action) {
                case "dashboard_stats":
                    handleDashboardStats(response, userId);
                    break;
                case "delivery_requests":
                    handleDeliveryRequests(response);
                    break;
                case "active_delivery":
                    handleActiveDelivery(response, userId);
                    break;
                case "earnings_history":
                    handleEarningsHistory(response, userId);
                    break;
                case "partner_profile":
                    handlePartnerProfile(response, userId);
                    break;
                case "notifications":
                    handleNotifications(response, userId);
                    break;
                case "recent_feedback":
                    handleRecentFeedback(response);
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
        if (!isDeliveryPartner(request)) {
            sendError(response, 403, "Access denied");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            sendError(response, 400, "Missing action parameter");
            return;
        }

        User user = (User) request.getSession().getAttribute("user");
        int userId = user.getId();
        ensureDeliveryPartnerData(userId);

        try {
            switch (action) {
                case "toggle_online":
                    handleToggleOnline(request, response, userId);
                    break;
                case "accept_delivery":
                    handleAcceptDelivery(request, response, userId);
                    break;
                case "update_delivery_status":
                    handleUpdateDeliveryStatus(request, response, userId);
                    break;
                case "update_profile":
                    handleUpdateProfile(request, response, userId);
                    break;
                case "upload_documents":
                    handleUploadDocuments(request, response, userId);
                    break;
                default:
                    sendError(response, 400, "Unknown action: " + action);
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, 500, "Server error: " + e.getMessage());
        }
    }

    private void handleDashboardStats(HttpServletResponse response, int userId) throws IOException, SQLException {
        double todayEarnings = 0.0;
        int completedDeliveries = 0;
        boolean isOnline = false;
        double rating = 5.0;
        double acceptanceRate = 100.0;
        double ontimeRate = 100.0;

        String partnerSql = "SELECT is_online, rating, acceptance_rate, ontime_rate FROM delivery_partners WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(partnerSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        isOnline = rs.getBoolean("is_online");
                        rating = rs.getDouble("rating");
                        acceptanceRate = rs.getDouble("acceptance_rate");
                        ontimeRate = rs.getDouble("ontime_rate");
                    }
                }
            }

            String statsSql = "SELECT SUM(delivery_fee), COUNT(*) FROM orders WHERE delivery_partner_id = ? AND order_status = 'Delivered' AND DATE(created_at) = CURDATE()";
            try (PreparedStatement ps = conn.prepareStatement(statsSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        todayEarnings = rs.getDouble(1);
                        completedDeliveries = rs.getInt(2);
                    }
                }
            }
        }
        String json = String.format("{\"todayEarnings\":%.2f,\"completedDeliveries\":%d,\"isOnline\":%b,\"rating\":%.1f,\"acceptanceRate\":%.1f,\"ontimeRate\":%.1f}",
            todayEarnings, completedDeliveries, isOnline, rating, acceptanceRate, ontimeRate);
        sendJson(response, json);
    }

    private void handleDeliveryRequests(HttpServletResponse response) throws IOException, SQLException {
        String sql = "SELECT o.id, o.grand_total, o.delivery_fee, o.created_at, o.restaurant_id, r.name AS restaurant_name, r.outlet_location, u.full_name " +
                     "FROM orders o " +
                     "LEFT JOIN restaurants r ON o.restaurant_id = r.id " +
                     "LEFT JOIN users u ON o.user_id = u.id " +
                     "WHERE o.order_status = 'Ready for Pickup' AND o.delivery_partner_id IS NULL";
                      
        StringBuilder sb = new StringBuilder("{\"requests\":[");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            boolean first = true;
            while (rs.next()) {
                if (!first) sb.append(",");
                sb.append(String.format("{\"orderId\":%d,\"restaurantName\":\"%s\",\"pickupAddress\":\"%s\",\"customerName\":\"%s\",\"grandTotal\":%.2f,\"deliveryFee\":%.2f,\"createdAt\":\"%s\"}",
                    rs.getInt("id"),
                    escapeJson(rs.getString("restaurant_name")),
                    escapeJson(rs.getString("outlet_location")),
                    escapeJson(rs.getString("full_name")),
                    rs.getDouble("grand_total"),
                    rs.getDouble("delivery_fee"),
                    rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toString() : ""
                ));
                first = false;
            }
        }
        sb.append("]}");
        sendJson(response, sb.toString());
    }

    private void handleActiveDelivery(HttpServletResponse response, int userId) throws IOException, SQLException {
        String sql = "SELECT o.id, o.order_status, o.delivery_fee, r.name AS restaurant_name, r.outlet_location, u.full_name, " +
                     "(SELECT GROUP_CONCAT(CONCAT(oi.quantity, 'x ', d.name) SEPARATOR ', ') " +
                     " FROM order_items oi JOIN dishes d ON oi.dish_id = d.id WHERE oi.order_id = o.id) AS items_summary " +
                     "FROM orders o " +
                     "LEFT JOIN restaurants r ON o.restaurant_id = r.id " +
                     "LEFT JOIN users u ON o.user_id = u.id " +
                     "WHERE o.delivery_partner_id = ? AND o.order_status NOT IN ('Delivered', 'Cancelled') LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String items = rs.getString("items_summary");
                    if (items == null) items = "";
                    String json = String.format("{\"activeDelivery\":{\"orderId\":%d,\"status\":\"%s\",\"restaurantName\":\"%s\",\"pickupLocation\":\"%s\",\"customerName\":\"%s\",\"items\":\"%s\",\"deliveryFee\":%.2f}}",
                        rs.getInt("id"),
                        escapeJson(rs.getString("order_status")),
                        escapeJson(rs.getString("restaurant_name")),
                        escapeJson(rs.getString("outlet_location")),
                        escapeJson(rs.getString("full_name")),
                        escapeJson(items),
                        rs.getDouble("delivery_fee")
                    );
                    sendJson(response, json);
                } else {
                    sendJson(response, "{\"activeDelivery\":null}");
                }
            }
        }
    }

    private void handleEarningsHistory(HttpServletResponse response, int userId) throws IOException, SQLException {
        String sql = "SELECT id, delivery_fee, created_at FROM orders WHERE delivery_partner_id = ? AND order_status = 'Delivered' AND created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) ORDER BY created_at DESC";
        StringBuilder sb = new StringBuilder("{\"earnings\":[");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                boolean first = true;
                while (rs.next()) {
                    if (!first) sb.append(",");
                    sb.append(String.format("{\"orderId\":%d,\"deliveryFee\":%.2f,\"date\":\"%s\"}",
                        rs.getInt("id"),
                        rs.getDouble("delivery_fee"),
                        rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toString() : ""
                    ));
                    first = false;
                }
            }
        }
        sb.append("]}");
        sendJson(response, sb.toString());
    }

    private void handlePartnerProfile(HttpServletResponse response, int userId) throws IOException, SQLException {
        String sql = "SELECT vehicle_type, vehicle_number, license_number, document_status, bank_name, account_number, ifsc_code FROM delivery_partners WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String json = String.format("{\"profile\":{\"vehicleType\":\"%s\",\"vehicleNumber\":\"%s\",\"licenseNumber\":\"%s\",\"documentStatus\":\"%s\",\"bankName\":\"%s\",\"accountNumber\":\"%s\",\"ifscCode\":\"%s\"}}",
                        escapeJson(rs.getString("vehicle_type")),
                        escapeJson(rs.getString("vehicle_number")),
                        escapeJson(rs.getString("license_number")),
                        escapeJson(rs.getString("document_status")),
                        escapeJson(rs.getString("bank_name")),
                        escapeJson(rs.getString("account_number")),
                        escapeJson(rs.getString("ifsc_code"))
                    );
                    sendJson(response, json);
                } else {
                    sendError(response, 404, "Profile not found");
                }
            }
        }
    }

    private void handleNotifications(HttpServletResponse response, int userId) throws IOException, SQLException {
        String sql = "SELECT id, order_status, created_at FROM orders WHERE delivery_partner_id = ? ORDER BY created_at DESC LIMIT 10";
        StringBuilder sb = new StringBuilder("{\"notifications\":[");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                boolean first = true;
                while (rs.next()) {
                    if (!first) sb.append(",");
                    sb.append(String.format("{\"message\":\"Order #%d status: %s\",\"date\":\"%s\"}",
                        rs.getInt("id"),
                        escapeJson(rs.getString("order_status")),
                        rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toString() : ""
                    ));
                    first = false;
                }
            }
        }
        sb.append("]}");
        sendJson(response, sb.toString());
    }

    private void handleRecentFeedback(HttpServletResponse response) throws IOException {
        String json = "{\"feedback\":[{\"rating\":5,\"comment\":\"Great!\",\"date\":\"2026-07-28\"},{\"rating\":4,\"comment\":\"Good\",\"date\":\"2026-07-27\"}]}";
        sendJson(response, json);
    }

    private void handleToggleOnline(HttpServletRequest request, HttpServletResponse response, int userId) throws IOException, SQLException {
        boolean isOnline = Boolean.parseBoolean(request.getParameter("isOnline"));
        String sql = "UPDATE delivery_partners SET is_online = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isOnline);
            ps.setInt(2, userId);
            ps.executeUpdate();
            sendJson(response, "{\"success\":true}");
        }
    }

    private void handleAcceptDelivery(HttpServletRequest request, HttpServletResponse response, int userId) throws IOException, SQLException {
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        String sql = "UPDATE orders SET delivery_partner_id = ?, order_status = 'Picked Up' WHERE id = ? AND delivery_partner_id IS NULL AND order_status = 'Ready for Pickup'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, orderId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                sendJson(response, "{\"success\":true}");
            } else {
                sendError(response, 400, "Order is no longer available or already picked up.");
            }
        }
    }

    private void handleUpdateDeliveryStatus(HttpServletRequest request, HttpServletResponse response, int userId) throws IOException, SQLException {
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        String status = request.getParameter("status");
        if (!("Picked Up".equals(status) || "On the Way".equals(status) || "Delivered".equals(status))) {
            sendError(response, 400, "Invalid status transition");
            return;
        }

        String sql = "UPDATE orders SET order_status = ? WHERE id = ? AND delivery_partner_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            ps.setInt(3, userId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                sendJson(response, "{\"success\":true}");
            } else {
                sendError(response, 400, "Order not found or unauthorized");
            }
        }
    }

    private void handleUpdateProfile(HttpServletRequest request, HttpServletResponse response, int userId) throws IOException, SQLException {
        String vehicleType = request.getParameter("vehicleType");
        String vehicleNumber = request.getParameter("vehicleNumber");
        String licenseNumber = request.getParameter("licenseNumber");
        String bankName = request.getParameter("bankName");
        String accountNumber = request.getParameter("accountNumber");
        String ifscCode = request.getParameter("ifscCode");

        String sql = "UPDATE delivery_partners SET vehicle_type=?, vehicle_number=?, license_number=?, bank_name=?, account_number=?, ifsc_code=? WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, vehicleType);
            ps.setString(2, vehicleNumber);
            ps.setString(3, licenseNumber);
            ps.setString(4, bankName);
            ps.setString(5, accountNumber);
            ps.setString(6, ifscCode);
            ps.setInt(7, userId);
            ps.executeUpdate();
            sendJson(response, "{\"success\":true}");
        }
    }

    private void handleUploadDocuments(HttpServletRequest request, HttpServletResponse response, int userId) throws IOException, SQLException {
        String sql = "UPDATE delivery_partners SET document_status = 'Under Review' WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
            sendJson(response, "{\"success\":true}");
        }
    }
}
