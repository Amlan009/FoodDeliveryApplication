package com.khaalo.daoimpl;
import com.khaalo.dao.*;

import com.khaalo.model.Dish;
import com.util.connection.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DishDAOImpl implements DishDAO {

    private Dish mapRow(ResultSet rs) throws SQLException {
        return new Dish(
            rs.getInt("id"),
            rs.getInt("category_id"),
            rs.getString("name"),
            rs.getDouble("price"),
            rs.getBoolean("is_veg"),
            rs.getBoolean("is_bestseller"),
            rs.getBoolean("is_chef_pick"),
            rs.getDouble("rating"),
            rs.getInt("rating_count"),
            rs.getString("description"),
            rs.getString("image_url")
        );
    }

    @Override
    public void addDish(Dish dish) throws SQLException {
        String sql = "INSERT INTO `dishes` (`category_id`, `name`, `price`, `is_veg`, `is_bestseller`, `is_chef_pick`, `rating`, `rating_count`, `description`, `image_url`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, dish.getCategoryId());
            ps.setString(2, dish.getName());
            ps.setDouble(3, dish.getPrice());
            ps.setBoolean(4, dish.isVeg());
            ps.setBoolean(5, dish.isBestseller());
            ps.setBoolean(6, dish.isChefPick());
            ps.setDouble(7, dish.getRating());
            ps.setInt(8, dish.getRatingCount());
            ps.setString(9, dish.getDescription());
            ps.setString(10, dish.getImageUrl());
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                dish.setId(rs.getInt(1));
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    @Override
    public Dish getDishById(int dishId) throws SQLException {
        String sql = "SELECT * FROM `dishes` WHERE `id` = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, dishId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
        return null;
    }

    @Override
    public Dish getDish(int id) throws SQLException {
        return getDishById(id);
    }

    @Override
    public List<Dish> getAllDishes() throws SQLException {
        String sql = "SELECT * FROM `dishes`";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Dish> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
        return list;
    }

    @Override
    public List<Dish> getDishesByCategoryId(int categoryId) throws SQLException {
        String sql = "SELECT * FROM `dishes` WHERE `category_id` = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Dish> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, categoryId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
        return list;
    }

    @Override
    public void updateDish(Dish dish) throws SQLException {
        String sql = "UPDATE `dishes` SET `category_id` = ?, `name` = ?, `price` = ?, `is_veg` = ?, `is_bestseller` = ?, `is_chef_pick` = ?, `rating` = ?, `rating_count` = ?, `description` = ?, `image_url` = ? WHERE `id` = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, dish.getCategoryId());
            ps.setString(2, dish.getName());
            ps.setDouble(3, dish.getPrice());
            ps.setBoolean(4, dish.isVeg());
            ps.setBoolean(5, dish.isBestseller());
            ps.setBoolean(6, dish.isChefPick());
            ps.setDouble(7, dish.getRating());
            ps.setInt(8, dish.getRatingCount());
            ps.setString(9, dish.getDescription());
            ps.setString(10, dish.getImageUrl());
            ps.setInt(11, dish.getId());
            ps.executeUpdate();
        } finally {
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    @Override
    public void deleteDish(int dishId) throws SQLException {
        String sql = "DELETE FROM `dishes` WHERE `id` = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, dishId);
            ps.executeUpdate();
        } finally {
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }
}

