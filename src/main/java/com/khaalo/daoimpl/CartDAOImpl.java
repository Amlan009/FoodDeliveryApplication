package com.khaalo.daoimpl;
import com.khaalo.dao.*;

import com.khaalo.model.Cart;
import com.khaalo.model.CartItem;
import com.util.connection.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDAOImpl implements CartDAO {

    @Override
    public void saveCart(Cart cart) {
        String insertCartSql = "INSERT INTO `carts` (`user_id`) VALUES (?) ON DUPLICATE KEY UPDATE `updated_at` = CURRENT_TIMESTAMP";
        String selectCartSql = "SELECT `id` FROM `carts` WHERE `user_id` = ?";
        String deleteItemsSql = "DELETE FROM `cart_items` WHERE `cart_id` = ?";
        String insertItemSql = "INSERT INTO `cart_items` (`cart_id`, `dish_id`, `quantity`, `customizations`) VALUES (?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement cartPs = conn.prepareStatement(insertCartSql)) {
                cartPs.setInt(1, cart.getUserId());
                cartPs.executeUpdate();
            }

            int cartId = -1;
            try (PreparedStatement selectPs = conn.prepareStatement(selectCartSql)) {
                selectPs.setInt(1, cart.getUserId());
                try (ResultSet rs = selectPs.executeQuery()) {
                    if (rs.next()) {
                        cartId = rs.getInt("id");
                        cart.setId(cartId);
                    } else {
                        throw new SQLException("Saving cart failed, no ID obtained.");
                    }
                }
            }

            try (PreparedStatement delPs = conn.prepareStatement(deleteItemsSql)) {
                delPs.setInt(1, cartId);
                delPs.executeUpdate();
            }

            if (cart.getItems() != null && !cart.getItems().isEmpty()) {
                try (PreparedStatement itemPs = conn.prepareStatement(insertItemSql)) {
                    for (CartItem item : cart.getItems()) {
                        itemPs.setInt(1, cartId);
                        itemPs.setInt(2, item.getDishId());
                        itemPs.setInt(3, item.getQuantity());
                        if (item.getCustomizations() != null) {
                            itemPs.setString(4, item.getCustomizations());
                        } else {
                            itemPs.setNull(4, Types.VARCHAR);
                        }
                        itemPs.executeUpdate();
                    }
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
    public Cart getCartByUserId(int userId) {
        String selectCartSql = "SELECT `id` FROM `carts` WHERE `user_id` = ?";
        String selectItemsSql = "SELECT ci.*, d.`name` AS dish_name, d.`price` AS dish_price FROM `cart_items` ci " +
                                "JOIN `dishes` d ON ci.`dish_id` = d.`id` " +
                                "WHERE ci.`cart_id` = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement cartPs = conn.prepareStatement(selectCartSql)) {
            cartPs.setInt(1, userId);
            try (ResultSet cartRs = cartPs.executeQuery()) {
                if (cartRs.next()) {
                    int cartId = cartRs.getInt("id");
                    Cart cart = new Cart(cartId, userId, new ArrayList<>());
                    
                    try (PreparedStatement itemsPs = conn.prepareStatement(selectItemsSql)) {
                        itemsPs.setInt(1, cartId);
                        try (ResultSet itemsRs = itemsPs.executeQuery()) {
                            while (itemsRs.next()) {
                                CartItem item = new CartItem(
                                    itemsRs.getInt("id"),
                                    itemsRs.getInt("cart_id"),
                                    itemsRs.getInt("dish_id"),
                                    itemsRs.getInt("quantity"),
                                    itemsRs.getString("customizations")
                                );
                                item.setDishName(itemsRs.getString("dish_name"));
                                item.setDishPrice(itemsRs.getDouble("dish_price"));
                                cart.getItems().add(item);
                            }
                        }
                    }
                    return cart;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public void clearCart(int userId) {
        String selectCartSql = "SELECT `id` FROM `carts` WHERE `user_id` = ?";
        String deleteItemsSql = "DELETE FROM `cart_items` WHERE `cart_id` = ?";
        String deleteCartSql = "DELETE FROM `carts` WHERE `id` = ?";
        
        try (Connection conn = DBConnection.getConnection()) {
            int cartId = -1;
            try (PreparedStatement selectPs = conn.prepareStatement(selectCartSql)) {
                selectPs.setInt(1, userId);
                try (ResultSet rs = selectPs.executeQuery()) {
                    if (rs.next()) {
                        cartId = rs.getInt("id");
                    }
                }
            }
            if (cartId != -1) {
                try (PreparedStatement delPs = conn.prepareStatement(deleteItemsSql)) {
                    delPs.setInt(1, cartId);
                    delPs.executeUpdate();
                }
                try (PreparedStatement delCartPs = conn.prepareStatement(deleteCartSql)) {
                    delCartPs.setInt(1, cartId);
                    delCartPs.executeUpdate();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void deleteCartItem(int cartItemId) {
        String sql = "DELETE FROM `cart_items` WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartItemId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}

