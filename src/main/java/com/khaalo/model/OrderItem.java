package com.khaalo.model;

public class OrderItem {
    private int id;
    private int orderId;
    private int dishId;
    private int quantity;
    private double priceAtPurchase;
    private String customizations;
    private String dishName;

    public OrderItem() {}

    public OrderItem(int id, int orderId, int dishId, int quantity, double priceAtPurchase, String customizations) {
        this.id = id;
        this.orderId = orderId;
        this.dishId = dishId;
        this.quantity = quantity;
        this.priceAtPurchase = priceAtPurchase;
        this.customizations = customizations;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getDishId() { return dishId; }
    public void setDishId(int dishId) { this.dishId = dishId; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public double getPriceAtPurchase() { return priceAtPurchase; }
    public void setPriceAtPurchase(double priceAtPurchase) { this.priceAtPurchase = priceAtPurchase; }

    public String getCustomizations() { return customizations; }
    public void setCustomizations(String customizations) { this.customizations = customizations; }

    public String getDishName() { return dishName; }
    public void setDishName(String dishName) { this.dishName = dishName; }

    @Override
    public String toString() {
        return "OrderItem [id=" + id + ", dishId=" + dishId + ", quantity=" + quantity + "]";
    }
}
