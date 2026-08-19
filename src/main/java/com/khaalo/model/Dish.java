package com.khaalo.model;

public class Dish {
    private int id;
    private int categoryId;
    private String name;
    private double price;
    private boolean isVeg;
    private boolean isBestseller;
    private boolean isChefPick;
    private double rating;
    private int ratingCount;
    private String description;
    private String imageUrl;

    public Dish() {}

    public Dish(int id, int categoryId, String name, double price, boolean isVeg, boolean isBestseller, boolean isChefPick, double rating, int ratingCount, String description, String imageUrl) {
        this.id = id;
        this.categoryId = categoryId;
        this.name = name;
        this.price = price;
        this.isVeg = isVeg;
        this.isBestseller = isBestseller;
        this.isChefPick = isChefPick;
        this.rating = rating;
        this.ratingCount = ratingCount;
        this.description = description;
        this.imageUrl = imageUrl;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public boolean isVeg() { return isVeg; }
    public void setVeg(boolean veg) { this.isVeg = veg; }

    public boolean isBestseller() { return isBestseller; }
    public void setBestseller(boolean bestseller) { isBestseller = bestseller; }

    public boolean isChefPick() { return isChefPick; }
    public void setChefPick(boolean chefPick) { this.isChefPick = chefPick; }

    public double getRating() { return rating; }
    public void setRating(double rating) { this.rating = rating; }

    public int getRatingCount() { return ratingCount; }
    public void setRatingCount(int ratingCount) { this.ratingCount = ratingCount; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
}
