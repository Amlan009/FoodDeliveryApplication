package com.khaalo.model;

import java.util.List;

public class MenuCategory {
    private int id;
    private String restaurantId;
    private String categoryName;
    private int sortOrder;
    private List<Dish> dishes;

    public MenuCategory() {}

    public MenuCategory(int id, String restaurantId, String categoryName, int sortOrder) {
        this.id = id;
        this.restaurantId = restaurantId;
        this.categoryName = categoryName;
        this.sortOrder = sortOrder;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getRestaurantId() { return restaurantId; }
    public void setRestaurantId(String restaurantId) { this.restaurantId = restaurantId; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }

    public List<Dish> getDishes() { return dishes; }
    public void setDishes(List<Dish> dishes) { this.dishes = dishes; }
}
