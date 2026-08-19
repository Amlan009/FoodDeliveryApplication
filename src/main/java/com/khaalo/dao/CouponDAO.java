package com.khaalo.dao;

import com.khaalo.model.Coupon;
import java.sql.SQLException;
import java.util.List;

public interface CouponDAO {
    Coupon getCouponByCode(String code) throws SQLException;
    Coupon getCouponById(int couponId) throws SQLException;
    List<Coupon> getAllActiveCoupons() throws SQLException;
    List<Coupon> getAllCoupons() throws SQLException;
    
    // CRUD write operations
    void addCoupon(Coupon coupon) throws SQLException;
    void updateCoupon(Coupon coupon) throws SQLException;
    void deleteCoupon(int couponId) throws SQLException;
}
