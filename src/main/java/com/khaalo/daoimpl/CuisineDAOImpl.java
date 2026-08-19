package com.khaalo.daoimpl;
import com.khaalo.dao.*;

import com.khaalo.model.Cuisine;
import com.util.connection.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CuisineDAOImpl implements CuisineDAO {

    private Cuisine mapRow(ResultSet rs) throws SQLException {
        return new Cuisine(
            rs.getInt("id"),
            rs.getString("cuisine_name")
        );
    }

    @Override
    public List<Cuisine> getAllCuisines() throws SQLException {
        String sql = "SELECT * FROM `cuisines` ORDER BY `cuisine_name` ASC";
        List<Cuisine> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    @Override
    public Cuisine getCuisineById(int cuisineId) throws SQLException {
        String sql = "SELECT * FROM `cuisines` WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cuisineId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    @Override
    public Cuisine getCuisineByName(String cuisineName) throws SQLException {
        String sql = "SELECT * FROM `cuisines` WHERE `cuisine_name` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cuisineName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    @Override
    public void addCuisine(Cuisine cuisine) throws SQLException {
        String sql = "INSERT INTO `cuisines` (`cuisine_name`) VALUES (?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, cuisine.getCuisineName());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    cuisine.setId(rs.getInt(1));
                }
            }
        }
    }

    @Override
    public void updateCuisine(Cuisine cuisine) throws SQLException {
        String sql = "UPDATE `cuisines` SET `cuisine_name` = ? WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cuisine.getCuisineName());
            ps.setInt(2, cuisine.getId());
            ps.executeUpdate();
        }
    }

    @Override
    public void deleteCuisine(int cuisineId) throws SQLException {
        String sql = "DELETE FROM `cuisines` WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cuisineId);
            ps.executeUpdate();
        }
    }

    @Override
    public void linkRestaurantCuisine(String restaurantId, int cuisineId) throws SQLException {
        String sql = "INSERT IGNORE INTO `restaurant_cuisines` (`restaurant_id`, `cuisine_id`) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, restaurantId);
            ps.setInt(2, cuisineId);
            ps.executeUpdate();
        }
    }

    @Override
    public void unlinkRestaurantCuisine(String restaurantId, int cuisineId) throws SQLException {
        String sql = "DELETE FROM `restaurant_cuisines` WHERE `restaurant_id` = ? AND `cuisine_id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, restaurantId);
            ps.setInt(2, cuisineId);
            ps.executeUpdate();
        }
    }
}

