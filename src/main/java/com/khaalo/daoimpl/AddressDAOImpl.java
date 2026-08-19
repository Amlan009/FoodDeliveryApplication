package com.khaalo.daoimpl;
import com.khaalo.dao.*;

import com.khaalo.model.Address;
import com.util.connection.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AddressDAOImpl implements AddressDAO {

    @Override
    public void addAddress(Address address) throws SQLException {
        String sql = "INSERT INTO `addresses` (`user_id`, `address_type`, `flat_no`, `area_details`, `landmark`, `city`, `pincode`) VALUES (?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, address.getUserId());
            ps.setString(2, address.getAddressType());
            ps.setString(3, address.getFlatNo());
            ps.setString(4, address.getAreaDetails());
            ps.setString(5, address.getLandmark());
            ps.setString(6, address.getCity());
            ps.setString(7, address.getPincode());
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                address.setId(rs.getInt(1));
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    @Override
    public Address getAddressById(int addressId) throws SQLException {
        String sql = "SELECT * FROM `addresses` WHERE `id` = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, addressId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return new Address(
                    rs.getInt("id"),
                    rs.getInt("user_id"),
                    rs.getString("address_type"),
                    rs.getString("flat_no"),
                    rs.getString("area_details"),
                    rs.getString("landmark"),
                    rs.getString("city"),
                    rs.getString("pincode")
                );
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
        return null;
    }

    @Override
    public List<Address> getAddressesByUserId(int userId) throws SQLException {
        String sql = "SELECT * FROM `addresses` WHERE `user_id` = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Address> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new Address(
                    rs.getInt("id"),
                    rs.getInt("user_id"),
                    rs.getString("address_type"),
                    rs.getString("flat_no"),
                    rs.getString("area_details"),
                    rs.getString("landmark"),
                    rs.getString("city"),
                    rs.getString("pincode")
                ));
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
        return list;
    }

    @Override
    public void updateAddress(Address address) throws SQLException {
        String sql = "UPDATE `addresses` SET `user_id` = ?, `address_type` = ?, `flat_no` = ?, `area_details` = ?, `landmark` = ?, `city` = ?, `pincode` = ? WHERE `id` = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, address.getUserId());
            ps.setString(2, address.getAddressType());
            ps.setString(3, address.getFlatNo());
            ps.setString(4, address.getAreaDetails());
            ps.setString(5, address.getLandmark());
            ps.setString(6, address.getCity());
            ps.setString(7, address.getPincode());
            ps.setInt(8, address.getId());
            ps.executeUpdate();
        } finally {
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    @Override
    public void deleteAddress(int addressId, int userId) throws SQLException {
        String sql = "DELETE FROM `addresses` WHERE `id` = ? AND `user_id` = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, addressId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } finally {
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }
}

