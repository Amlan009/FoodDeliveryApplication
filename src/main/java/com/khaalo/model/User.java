package com.khaalo.model;

import java.sql.Timestamp;

public class User {
    private int id;
    private String fullName;
    private String email;
    private String phone;
    private String passwordHash;
    private String address;
    private String role;
    private Timestamp createdAt;
    private Timestamp lastLoginDate;
    private String restaurantId;

    // Constructors
    public User() {}

    // Parameterized constructor excluding auto-incremented primary key id
    public User(String fullName, String email, String phone, String passwordHash, String address, String role, Timestamp createdAt, Timestamp lastLoginDate) {
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.passwordHash = passwordHash;
        this.address = address;
        this.role = role;
        this.createdAt = createdAt;
        this.lastLoginDate = lastLoginDate;
    }

    // Full constructor
    public User(int id, String fullName, String email, String phone, String passwordHash, String address, String role, Timestamp createdAt, Timestamp lastLoginDate) {
        this.id = id;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.passwordHash = passwordHash;
        this.address = address;
        this.role = role;
        this.createdAt = createdAt;
        this.lastLoginDate = lastLoginDate;
    }

    // Getters and Setters (supporting both teacher and original project names)
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return id; }
    public void setUserId(int userId) { this.id = userId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getName() { return fullName; }
    public void setName(String name) { this.fullName = name; }

    public String getUsername() { return fullName; }
    public void setUsername(String username) { this.fullName = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getPassword() { return passwordHash; }
    public void setPassword(String password) { this.passwordHash = password; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getCreatedDate() { return createdAt; }
    public void setCreatedDate(Timestamp createdDate) { this.createdAt = createdDate; }

    public Timestamp getLastLoginDate() { return lastLoginDate; }
    public void setLastLoginDate(Timestamp lastLoginDate) { this.lastLoginDate = lastLoginDate; }

    public String getRestaurantId() { return restaurantId; }
    public void setRestaurantId(String restaurantId) { this.restaurantId = restaurantId; }

    @Override
    public String toString() {
        return "User [id=" + id + ", fullName=" + fullName + ", email=" + email + ", role=" + role + "]";
    }
}
