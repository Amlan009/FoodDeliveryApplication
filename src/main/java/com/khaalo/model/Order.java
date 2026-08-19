package com.khaalo.model;

import java.sql.Timestamp;
import java.util.List;

public class Order {
    private int id;
    private int userId;
    private String restaurantId;
    private int addressId;
    private double subtotal;
    private double deliveryFee;
    private double taxes;
    private double grandTotal;
    private String orderStatus;
    private String paymentMethod;
    private Timestamp createdAt;
    private List<OrderItem> orderItems;

    public Order() {}

    public Order(int id, int userId, String restaurantId, int addressId, double subtotal, double deliveryFee, double taxes, double grandTotal, String orderStatus, String paymentMethod, Timestamp createdAt) {
        this.id = id;
        this.userId = userId;
        this.restaurantId = restaurantId;
        this.addressId = addressId;
        this.subtotal = subtotal;
        this.deliveryFee = deliveryFee;
        this.taxes = taxes;
        this.grandTotal = grandTotal;
        this.orderStatus = orderStatus;
        this.paymentMethod = paymentMethod;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getRestaurantId() { return restaurantId; }
    public void setRestaurantId(String restaurantId) { this.restaurantId = restaurantId; }

    public int getAddressId() { return addressId; }
    public void setAddressId(int addressId) { this.addressId = addressId; }

    public double getSubtotal() { return subtotal; }
    public void setSubtotal(double subtotal) { this.subtotal = subtotal; }

    public double getDeliveryFee() { return deliveryFee; }
    public void setDeliveryFee(double deliveryFee) { this.deliveryFee = deliveryFee; }

    public double getTaxes() { return taxes; }
    public void setTaxes(double taxes) { this.taxes = taxes; }

    public double getGrandTotal() { return grandTotal; }
    public void setGrandTotal(double grandTotal) { this.grandTotal = grandTotal; }

    public String getOrderStatus() { return orderStatus; }
    public void setOrderStatus(String orderStatus) { this.orderStatus = orderStatus; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public List<OrderItem> getOrderItems() { return orderItems; }
    public void setOrderItems(List<OrderItem> orderItems) { this.orderItems = orderItems; }

    @Override
    public String toString() {
        return "Order [id=" + id + ", userId=" + userId + ", grandTotal=" + grandTotal + "]";
    }
}
