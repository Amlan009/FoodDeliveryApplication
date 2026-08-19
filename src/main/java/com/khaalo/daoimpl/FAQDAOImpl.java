package com.khaalo.daoimpl;
import com.khaalo.dao.*;

import com.khaalo.model.FAQ;
import com.util.connection.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FAQDAOImpl implements FAQDAO {

    private FAQ mapRow(ResultSet rs) throws SQLException {
        return new FAQ(
            rs.getInt("id"),
            rs.getString("restaurant_id"),
            rs.getString("question"),
            rs.getString("answer")
        );
    }

    @Override
    public void addFAQ(FAQ faq) throws SQLException {
        String sql = "INSERT INTO `restaurant_faqs` (`restaurant_id`, `question`, `answer`) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, faq.getRestaurantId());
            ps.setString(2, faq.getQuestion());
            ps.setString(3, faq.getAnswer());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    faq.setId(rs.getInt(1));
                }
            }
        }
    }

    @Override
    public FAQ getFAQById(int faqId) throws SQLException {
        String sql = "SELECT * FROM `restaurant_faqs` WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, faqId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    @Override
    public List<FAQ> getFAQsByRestaurantId(String restaurantId) throws SQLException {
        String sql = "SELECT * FROM `restaurant_faqs` WHERE `restaurant_id` = ?";
        List<FAQ> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    @Override
    public void updateFAQ(FAQ faq) throws SQLException {
        String sql = "UPDATE `restaurant_faqs` SET `restaurant_id` = ?, `question` = ?, `answer` = ? WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, faq.getRestaurantId());
            ps.setString(2, faq.getQuestion());
            ps.setString(3, faq.getAnswer());
            ps.setInt(4, faq.getId());
            ps.executeUpdate();
        }
    }

    @Override
    public void deleteFAQ(int faqId) throws SQLException {
        String sql = "DELETE FROM `restaurant_faqs` WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, faqId);
            ps.executeUpdate();
        }
    }

    @Override
    public List<FAQ> getAllFAQs() throws SQLException {
        String sql = "SELECT * FROM `restaurant_faqs`";
        List<FAQ> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }
}

