package com.khaalo.daoimpl;
import com.khaalo.dao.*;

import com.khaalo.model.Coupon;
import com.util.connection.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CouponDAOImpl implements CouponDAO {

    private Coupon mapRow(ResultSet rs) throws SQLException {
        return new Coupon(
            rs.getInt("id"),
            rs.getString("code"),
            rs.getDouble("discount_percent"),
            rs.getDouble("max_discount"),
            rs.getDouble("min_order_value"),
            rs.getBoolean("is_active")
        );
    }

    @Override
    public Coupon getCouponByCode(String code) throws SQLException {
        String sql = "SELECT * FROM `coupons` WHERE `code` = ? AND `is_active` = TRUE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    @Override
    public Coupon getCouponById(int couponId) throws SQLException {
        String sql = "SELECT * FROM `coupons` WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, couponId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    @Override
    public List<Coupon> getAllActiveCoupons() throws SQLException {
        String sql = "SELECT * FROM `coupons` WHERE `is_active` = TRUE";
        List<Coupon> list = new ArrayList<>();
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
    public List<Coupon> getAllCoupons() throws SQLException {
        String sql = "SELECT * FROM `coupons`";
        List<Coupon> list = new ArrayList<>();
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
    public void addCoupon(Coupon coupon) throws SQLException {
        String sql = "INSERT INTO `coupons` (`code`, `discount_percent`, `max_discount`, `min_order_value`, `is_active`) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, coupon.getCode());
            ps.setDouble(2, coupon.getDiscountPercent());
            ps.setDouble(3, coupon.getMaxDiscount());
            ps.setDouble(4, coupon.getMinOrderValue());
            ps.setBoolean(5, coupon.isActive());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    coupon.setId(rs.getInt(1));
                }
            }
        }
    }

    @Override
    public void updateCoupon(Coupon coupon) throws SQLException {
        String sql = "UPDATE `coupons` SET `code` = ?, `discount_percent` = ?, `max_discount` = ?, `min_order_value` = ?, `is_active` = ? WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, coupon.getCode());
            ps.setDouble(2, coupon.getDiscountPercent());
            ps.setDouble(3, coupon.getMaxDiscount());
            ps.setDouble(4, coupon.getMinOrderValue());
            ps.setBoolean(5, coupon.isActive());
            ps.setInt(6, coupon.getId());
            ps.executeUpdate();
        }
    }

    @Override
    public void deleteCoupon(int couponId) throws SQLException {
        String sql = "DELETE FROM `coupons` WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, couponId);
            ps.executeUpdate();
        }
    }

    public void toggleCoupon(int couponId, boolean active) throws SQLException {
        String sql = "UPDATE `coupons` SET `is_active` = ? WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, couponId);
            ps.executeUpdate();
        }
    }
}

