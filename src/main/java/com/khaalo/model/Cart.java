package com.khaalo.model;

import java.util.List;

public class Cart {
    private int id;
    private int userId;
    private List<CartItem> items;

    public Cart() {}

    public Cart(int id, int userId, List<CartItem> items) {
        this.id = id;
        this.userId = userId;
        this.items = items;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public List<CartItem> getItems() { return items; }
    public void setItems(List<CartItem> items) { this.items = items; }

    @Override
    public String toString() {
        return "Cart [id=" + id + ", userId=" + userId + "]";
    }
}
