package com.khaalo.model;

import java.util.List;

public class Restaurant {
    private String id;
    private String name;
    private double rating;
    private int ratingCount;
    private String deliveryTime;
    private int costForTwo;
    private String closesAt;
    private String outletLocation;
    private String bannerUrl;
    private String discountTag;
    private List<String> cuisines;

    public Restaurant() {}

    public Restaurant(String id, String name, double rating, int ratingCount, String deliveryTime, int costForTwo, String closesAt, String outletLocation, String bannerUrl, String discountTag) {
        this.id = id;
        this.name = name;
        this.rating = rating;
        this.ratingCount = ratingCount;
        this.deliveryTime = deliveryTime;
        this.costForTwo = costForTwo;
        this.closesAt = closesAt;
        this.outletLocation = outletLocation;
        this.bannerUrl = bannerUrl;
        this.discountTag = discountTag;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public double getRating() { return rating; }
    public void setRating(double rating) { this.rating = rating; }

    public int getRatingCount() { return ratingCount; }
    public void setRatingCount(int ratingCount) { this.ratingCount = ratingCount; }

    public String getDeliveryTime() { return deliveryTime; }
    public void setDeliveryTime(String deliveryTime) { this.deliveryTime = deliveryTime; }

    public int getCostForTwo() { return costForTwo; }
    public void setCostForTwo(int costForTwo) { this.costForTwo = costForTwo; }

    public String getClosesAt() { return closesAt; }
    public void setClosesAt(String closesAt) { this.closesAt = closesAt; }

    public String getOutletLocation() { return outletLocation; }
    public void setOutletLocation(String outletLocation) { this.outletLocation = outletLocation; }

    public String getBannerUrl() { return bannerUrl; }
    public void setBannerUrl(String bannerUrl) { this.bannerUrl = bannerUrl; }

    public String getDiscountTag() { return discountTag; }
    public void setDiscountTag(String discountTag) { this.discountTag = discountTag; }

    public List<String> getCuisines() { return cuisines; }
    public void setCuisines(List<String> cuisines) { this.cuisines = cuisines; }

    @Override
    public String toString() {
        return "Restaurant [id=" + id + ", name=" + name + "]";
    }
}
