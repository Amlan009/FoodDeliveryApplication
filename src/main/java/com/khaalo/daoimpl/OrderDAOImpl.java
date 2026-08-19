package com.khaalo.daoimpl;
import com.khaalo.dao.*;

import com.khaalo.model.Order;
import com.khaalo.model.OrderItem;
import com.util.connection.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class OrderDAOImpl implements OrderDAO {

    @Override
    public void placeOrder(Order order) {
        String insertOrderSql = "INSERT INTO `orders` (`user_id`, `restaurant_id`, `address_id`, `subtotal`, `delivery_fee`, `taxes`, `grand_total`, `order_status`, `payment_method`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String insertItemSql = "INSERT INTO `order_items` (`order_id`, `dish_id`, `quantity`, `price_at_purchase`, `customizations`) VALUES (?, ?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int orderId = -1;
            try (PreparedStatement orderPs = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS)) {
                orderPs.setInt(1, order.getUserId());
                orderPs.setString(2, order.getRestaurantId());
                orderPs.setInt(3, order.getAddressId());
                orderPs.setDouble(4, order.getSubtotal());
                orderPs.setDouble(5, order.getDeliveryFee());
                orderPs.setDouble(6, order.getTaxes());
                orderPs.setDouble(7, order.getGrandTotal());
                orderPs.setString(8, order.getOrderStatus() != null ? order.getOrderStatus() : "Pending");
                orderPs.setString(9, order.getPaymentMethod());
                
                int affectedRows = orderPs.executeUpdate();
                if (affectedRows == 0) {
                    throw new SQLException("Creating order failed, no rows affected.");
                }
                try (ResultSet generatedKeys = orderPs.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        orderId = generatedKeys.getInt(1);
                        order.setId(orderId);
                    } else {
                        throw new SQLException("Creating order failed, no ID obtained.");
                    }
                }
            }

            if (orderId != -1 && order.getOrderItems() != null && !order.getOrderItems().isEmpty()) {
                try (PreparedStatement itemPs = conn.prepareStatement(insertItemSql)) {
                    for (OrderItem item : order.getOrderItems()) {
                        itemPs.setInt(1, orderId);
                        itemPs.setInt(2, item.getDishId());
                        itemPs.setInt(3, item.getQuantity());
                        itemPs.setDouble(4, item.getPriceAtPurchase());
                        if (item.getCustomizations() != null) {
                            itemPs.setString(5, item.getCustomizations());
                        } else {
                            itemPs.setNull(5, Types.VARCHAR);
                        }
                        itemPs.addBatch();
                    }
                    itemPs.executeBatch();
                }
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    @Override
    public List<Order> getOrdersByUserId(int userId) {
        String sql = "SELECT * FROM `orders` WHERE `user_id` = ? ORDER BY `created_at` DESC";
        List<Order> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapOrder(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public Order getOrderById(int orderId) {
        String sql = "SELECT * FROM `orders` WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapOrder(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public void updateOrderStatus(int orderId, String status) {
        String sql = "UPDATE `orders` SET `order_status` = ? WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void deleteOrder(int orderId) {
        String sql = "DELETE FROM `orders` WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public List<Order> getAllOrders() {
        String sql = "SELECT * FROM `orders` ORDER BY `created_at` DESC";
        List<Order> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapOrder(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Order mapOrder(ResultSet rs) throws SQLException {
        return new Order(
            rs.getInt("id"),
            rs.getInt("user_id"),
            rs.getString("restaurant_id"),
            rs.getInt("address_id"),
            rs.getDouble("subtotal"),
            rs.getDouble("delivery_fee"),
            rs.getDouble("taxes"),
            rs.getDouble("grand_total"),
            rs.getString("order_status"),
            rs.getString("payment_method"),
            rs.getTimestamp("created_at")
        );
    }

    // ---- Admin Analytics Methods ----

    public int getOrderCountToday() {
        String sql = "SELECT COUNT(*) FROM `orders` WHERE DATE(`created_at`) = CURDATE()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int getTotalOrderCount() {
        String sql = "SELECT COUNT(*) FROM `orders`";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public double getTotalRevenue() {
        String sql = "SELECT COALESCE(SUM(`grand_total`), 0) FROM `orders` WHERE `order_status` != 'Cancelled'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getDouble(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0.0;
    }

    public int getPendingOrderCount() {
        String sql = "SELECT COUNT(*) FROM `orders` WHERE `order_status` = 'Pending'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public Map<String, Integer> getOrderCountByDate(int days) {
        String sql = "SELECT DATE(`created_at`) AS order_date, COUNT(*) AS cnt FROM `orders` WHERE `created_at` >= DATE_SUB(CURDATE(), INTERVAL ? DAY) GROUP BY DATE(`created_at`) ORDER BY order_date";
        Map<String, Integer> map = new LinkedHashMap<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getString("order_date"), rs.getInt("cnt"));
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return map;
    }

    public Map<Integer, Integer> getOrderCountByHour() {
        String sql = "SELECT HOUR(`created_at`) AS hr, COUNT(*) AS cnt FROM `orders` GROUP BY HOUR(`created_at`) ORDER BY hr";
        Map<Integer, Integer> map = new LinkedHashMap<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getInt("hr"), rs.getInt("cnt"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return map;
    }

    public double getTotalRefunds() {
        String sql = "SELECT COALESCE(SUM(`grand_total`), 0) FROM `orders` WHERE `order_status` = 'Cancelled'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getDouble(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0.0;
    }

    public double getAvgOrderValue() {
        String sql = "SELECT COALESCE(AVG(`grand_total`), 0) FROM `orders` WHERE `order_status` != 'Cancelled'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getDouble(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0.0;
    }
}

