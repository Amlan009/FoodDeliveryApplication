package com.khaalo.dao;

import com.khaalo.model.User;
import java.util.List;

public interface UserDAO {
    void addUser(User user);
    User getUser(int userId);
    User getUserById(int userId);
    User getUserByEmail(String email);
    User validateLogin(String email, String password);
    void updateUser(User user);
    void deleteUser(int userId);
    List<User> getAllUsers();
}
