package com.khaalo.model;

public class Favorite {
    private int userId;
    private String restaurantId;

    public Favorite() {}

    public Favorite(int userId, String restaurantId) {
        this.userId = userId;
        this.restaurantId = restaurantId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getRestaurantId() {
        return restaurantId;
    }

    public void setRestaurantId(String restaurantId) {
        this.restaurantId = restaurantId;
    }

    @Override
    public String toString() {
        return "Favorite [userId=" + userId + ", restaurantId=" + restaurantId + "]";
    }
}
