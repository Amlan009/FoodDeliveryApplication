package com.khaalo.daoimpl;
import com.khaalo.dao.*;

import com.khaalo.model.Review;
import com.util.connection.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAOImpl implements ReviewDAO {

    private Review mapRow(ResultSet rs) throws SQLException {
        return new Review(
            rs.getInt("id"),
            rs.getInt("user_id"),
            rs.getString("restaurant_id"),
            rs.getDouble("rating"),
            rs.getString("review_text"),
            rs.getTimestamp("created_at")
        );
    }

    @Override
    public void addReview(Review review) throws SQLException {
        String sql = "INSERT INTO `reviews` (`user_id`, `restaurant_id`, `rating`, `review_text`) VALUES (?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, review.getUserId());
            ps.setString(2, review.getRestaurantId());
            ps.setDouble(3, review.getRating());
            ps.setString(4, review.getReviewText());
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                review.setId(rs.getInt(1));
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    @Override
    public Review getReviewById(int reviewId) throws SQLException {
        String sql = "SELECT * FROM `reviews` WHERE `id` = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, reviewId);
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
    public List<Review> getReviewsByRestaurantId(String restaurantId) throws SQLException {
        String sql = "SELECT * FROM `reviews` WHERE `restaurant_id` = ? ORDER BY `created_at` DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Review> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, restaurantId);
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
    public List<Review> getReviewsByUserId(int userId) throws SQLException {
        String sql = "SELECT * FROM `reviews` WHERE `user_id` = ? ORDER BY `created_at` DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Review> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
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
    public void updateReview(Review review) throws SQLException {
        String sql = "UPDATE `reviews` SET `user_id` = ?, `restaurant_id` = ?, `rating` = ?, `review_text` = ? WHERE `id` = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, review.getUserId());
            ps.setString(2, review.getRestaurantId());
            ps.setDouble(3, review.getRating());
            ps.setString(4, review.getReviewText());
            ps.setInt(5, review.getId());
            ps.executeUpdate();
        } finally {
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    @Override
    public void deleteReview(int reviewId) throws SQLException {
        String sql = "DELETE FROM `reviews` WHERE `id` = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, reviewId);
            ps.executeUpdate();
        } finally {
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    @Override
    public List<Review> getAllReviews() throws SQLException {
        String sql = "SELECT * FROM `reviews` ORDER BY `created_at` DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Review> list = new ArrayList<>();
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
}

