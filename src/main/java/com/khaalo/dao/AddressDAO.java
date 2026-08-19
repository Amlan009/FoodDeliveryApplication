package com.khaalo.dao;

import com.khaalo.model.Address;
import java.sql.SQLException;
import java.util.List;

public interface AddressDAO {
    void addAddress(Address address) throws SQLException;
    Address getAddressById(int addressId) throws SQLException;
    List<Address> getAddressesByUserId(int userId) throws SQLException;
    void updateAddress(Address address) throws SQLException;
    void deleteAddress(int addressId, int userId) throws SQLException;
}
