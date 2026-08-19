package com.khaalo.model;

public class Coupon {
    private int id;
    private String code;
    private double discountPercent;
    private double maxDiscount;
    private double minOrderValue;
    private boolean isActive;

    // Constructors
    public Coupon() {}

    public Coupon(int id, String code, double discountPercent, double maxDiscount, double minOrderValue, boolean isActive) {
        this.id = id;
        this.code = code;
        this.discountPercent = discountPercent;
        this.maxDiscount = maxDiscount;
        this.minOrderValue = minOrderValue;
        this.isActive = isActive;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public double getDiscountPercent() { return discountPercent; }
    public void setDiscountPercent(double discountPercent) { this.discountPercent = discountPercent; }

    public double getMaxDiscount() { return maxDiscount; }
    public void setMaxDiscount(double maxDiscount) { this.maxDiscount = maxDiscount; }

    public double getMinOrderValue() { return minOrderValue; }
    public void setMinOrderValue(double minOrderValue) { this.minOrderValue = minOrderValue; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
}
