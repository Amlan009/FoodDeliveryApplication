package com.khaalo.model;

public class Address {
    private int id;
    private int userId;
    private String addressType; // Home, Work, Other
    private String flatNo;
    private String areaDetails;
    private String landmark;
    private String city;
    private String pincode;

    // Constructors
    public Address() {}

    public Address(int id, int userId, String addressType, String flatNo, String areaDetails, String landmark, String city, String pincode) {
        this.id = id;
        this.userId = userId;
        this.addressType = addressType;
        this.flatNo = flatNo;
        this.areaDetails = areaDetails;
        this.landmark = landmark;
        this.city = city;
        this.pincode = pincode;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getAddressType() { return addressType; }
    public void setAddressType(String addressType) { this.addressType = addressType; }

    public String getFlatNo() { return flatNo; }
    public void setFlatNo(String flatNo) { this.flatNo = flatNo; }

    public String getAreaDetails() { return areaDetails; }
    public void setAreaDetails(String areaDetails) { this.areaDetails = areaDetails; }

    public String getLandmark() { return landmark; }
    public void setLandmark(String landmark) { this.landmark = landmark; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getPincode() { return pincode; }
    public void setPincode(String pincode) { this.pincode = pincode; }
}
