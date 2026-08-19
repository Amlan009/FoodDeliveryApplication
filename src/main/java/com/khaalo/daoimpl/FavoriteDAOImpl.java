package com.khaalo.daoimpl;

import com.khaalo.dao.FavoriteDAO;
import com.khaalo.model.Restaurant;
import com.util.connection.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class FavoriteDAOImpl implements FavoriteDAO {

    @Override
    public boolean isFavorite(int userId, String restaurantId) {
        String sql = "SELECT * FROM `khaalo`.`user_favorites` WHERE `user_id` = ? AND `restaurant_id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean addFavorite(int userId, String restaurantId) {
        if (isFavorite(userId, restaurantId)) {
            return true;
        }
        String sql = "INSERT INTO `khaalo`.`user_favorites` (`user_id`, `restaurant_id`) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, restaurantId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean removeFavorite(int userId, String restaurantId) {
        String sql = "DELETE FROM `khaalo`.`user_favorites` WHERE `user_id` = ? AND `restaurant_id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, restaurantId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public Set<String> getFavoriteRestaurantIds(int userId) {
        Set<String> set = new HashSet<>();
        String sql = "SELECT `restaurant_id` FROM `khaalo`.`user_favorites` WHERE `user_id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    set.add(rs.getString("restaurant_id"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return set;
    }

    @Override
    public List<Restaurant> getFavoriteRestaurants(int userId) {
        Set<String> ids = getFavoriteRestaurantIds(userId);
        List<Restaurant> list = new ArrayList<>();
        RestaurantDAOImpl restaurantDAO = new RestaurantDAOImpl();
        for (String id : ids) {
            Restaurant r = restaurantDAO.getRestaurantById(id);
            if (r != null) {
                list.add(r);
            }
        }
        return list;
    }
}
