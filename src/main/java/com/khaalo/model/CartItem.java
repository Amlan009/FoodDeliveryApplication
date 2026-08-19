package com.khaalo.model;

public class CartItem {
    private int id;
    private int cartId;
    private int dishId;
    private int quantity;
    private String customizations;
    private String dishName;
    private double dishPrice;

    public CartItem() {}

    public CartItem(int id, int cartId, int dishId, int quantity, String customizations) {
        this.id = id;
        this.cartId = cartId;
        this.dishId = dishId;
        this.quantity = quantity;
        this.customizations = customizations;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCartId() { return cartId; }
    public void setCartId(int cartId) { this.cartId = cartId; }

    public int getDishId() { return dishId; }
    public void setDishId(int dishId) { this.dishId = dishId; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getCustomizations() { return customizations; }
    public void setCustomizations(String customizations) { this.customizations = customizations; }

    public String getDishName() { return dishName; }
    public void setDishName(String dishName) { this.dishName = dishName; }

    public double getDishPrice() { return dishPrice; }
    public void setDishPrice(double dishPrice) { this.dishPrice = dishPrice; }

    @Override
    public String toString() {
        return "CartItem [id=" + id + ", dishId=" + dishId + ", quantity=" + quantity + "]";
    }
}
