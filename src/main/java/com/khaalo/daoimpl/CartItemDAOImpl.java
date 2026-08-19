package com.khaalo.daoimpl;
import com.khaalo.dao.*;

import com.khaalo.model.CartItem;
import com.util.connection.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartItemDAOImpl implements CartItemDAO {

    private CartItem mapRow(ResultSet rs) throws SQLException {
        CartItem item = new CartItem(
            rs.getInt("id"),
            rs.getInt("cart_id"),
            rs.getInt("dish_id"),
            rs.getInt("quantity"),
            rs.getString("customizations")
        );
        item.setDishName(rs.getString("dish_name"));
        item.setDishPrice(rs.getDouble("dish_price"));
        return item;
    }

    @Override
    public void addCartItem(CartItem item) {
        String sql = "INSERT INTO `cart_items` (`cart_id`, `dish_id`, `quantity`, `customizations`) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, item.getCartId());
            ps.setInt(2, item.getDishId());
            ps.setInt(3, item.getQuantity());
            if (item.getCustomizations() != null) {
                ps.setString(4, item.getCustomizations());
            } else {
                ps.setNull(4, Types.VARCHAR);
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
    public CartItem getCartItemById(int itemId) {
        String sql = "SELECT ci.*, d.`name` AS dish_name, d.`price` AS dish_price FROM `cart_items` ci " +
                     "JOIN `dishes` d ON ci.`dish_id` = d.`id` " +
                     "WHERE ci.`id` = ?";
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
    public List<CartItem> getCartItemsByCartId(int cartId) {
        String sql = "SELECT ci.*, d.`name` AS dish_name, d.`price` AS dish_price FROM `cart_items` ci " +
                     "JOIN `dishes` d ON ci.`dish_id` = d.`id` " +
                     "WHERE ci.`cart_id` = ?";
        List<CartItem> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartId);
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
    public void updateCartItem(CartItem item) {
        String sql = "UPDATE `cart_items` SET `quantity` = ?, `customizations` = ? WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getQuantity());
            if (item.getCustomizations() != null) {
                ps.setString(2, item.getCustomizations());
            } else {
                ps.setNull(2, Types.VARCHAR);
            }
            ps.setInt(3, item.getId());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void deleteCartItem(int itemId) {
        String sql = "DELETE FROM `cart_items` WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, itemId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}

