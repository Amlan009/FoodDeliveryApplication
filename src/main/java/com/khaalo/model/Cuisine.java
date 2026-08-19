package com.khaalo.model;

public class Cuisine {
    private int id;
    private String cuisineName;

    // Constructors
    public Cuisine() {}

    public Cuisine(int id, String cuisineName) {
        this.id = id;
        this.cuisineName = cuisineName;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCuisineName() { return cuisineName; }
    public void setCuisineName(String cuisineName) { this.cuisineName = cuisineName; }
}
