package com.khaalo.daoimpl;
import com.khaalo.dao.*;

import com.khaalo.model.Restaurant;
import com.util.connection.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RestaurantDAOImpl implements RestaurantDAO {

    private List<String> getCuisinesForRestaurant(String restaurantId, Connection conn) {
        String sql = "SELECT `category_name` FROM `menu_categories` WHERE `restaurant_id` = ?";
        List<String> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getString("category_name"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public Restaurant getRestaurantById(String id) {
        String sql = "SELECT * FROM `restaurants` WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Restaurant r = mapRestaurant(rs);
                    r.setCuisines(getCuisinesForRestaurant(r.getId(), conn));
                    return r;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Restaurant> getAllRestaurants() {
        String sql = "SELECT * FROM `restaurants`";
        List<Restaurant> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Restaurant r = mapRestaurant(rs);
                r.setCuisines(getCuisinesForRestaurant(r.getId(), conn));
                list.add(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Restaurant mapRestaurant(ResultSet rs) throws SQLException {
        return new Restaurant(
            rs.getString("id"),
            rs.getString("name"),
            rs.getDouble("rating"),
            rs.getInt("rating_count"),
            rs.getString("delivery_time"),
            rs.getInt("cost_for_two"),
            rs.getString("closes_at"),
            rs.getString("outlet_location"),
            rs.getString("banner_url"),
            rs.getString("discount_tag")
        );
    }
}

