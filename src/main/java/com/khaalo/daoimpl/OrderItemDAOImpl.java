package com.khaalo.daoimpl;
import com.khaalo.dao.*;

import com.khaalo.model.OrderItem;
import com.util.connection.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderItemDAOImpl implements OrderItemDAO {

    private OrderItem mapRow(ResultSet rs) throws SQLException {
        OrderItem item = new OrderItem(
            rs.getInt("id"),
            rs.getInt("order_id"),
            rs.getInt("dish_id"),
            rs.getInt("quantity"),
            rs.getDouble("price_at_purchase"),
            rs.getString("customizations")
        );
        item.setDishName(rs.getString("dish_name"));
        return item;
    }

    @Override
    public void addOrderItem(OrderItem item) {
        String sql = "INSERT INTO `order_items` (`order_id`, `dish_id`, `quantity`, `price_at_purchase`, `customizations`) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, item.getOrderId());
            ps.setInt(2, item.getDishId());
            ps.setInt(3, item.getQuantity());
            ps.setDouble(4, item.getPriceAtPurchase());
            if (item.getCustomizations() != null) {
                ps.setString(5, item.getCustomizations());
            } else {
                ps.setNull(5, Types.VARCHAR);
            }
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    item.setId(rs.getInt(1));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public OrderItem getOrderItemById(int itemId) {
        String sql = "SELECT oi.*, d.`name` AS dish_name FROM `order_items` oi " +
                     "JOIN `dishes` d ON oi.`dish_id` = d.`id` " +
                     "WHERE oi.`id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, itemId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<OrderItem> getOrderItemsByOrderId(int orderId) {
        String sql = "SELECT oi.*, d.`name` AS dish_name FROM `order_items` oi " +
                     "JOIN `dishes` d ON oi.`dish_id` = d.`id` " +
                     "WHERE oi.`order_id` = ?";
        List<OrderItem> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public void updateOrderItem(OrderItem item) {
        String sql = "UPDATE `order_items` SET `quantity` = ?, `price_at_purchase` = ?, `customizations` = ? WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getQuantity());
            ps.setDouble(2, item.getPriceAtPurchase());
            if (item.getCustomizations() != null) {
                ps.setString(3, item.getCustomizations());
            } else {
                ps.setNull(3, Types.VARCHAR);
            }
            ps.setInt(4, item.getId());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void deleteOrderItem(int itemId) {
        String sql = "DELETE FROM `order_items` WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, itemId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}

