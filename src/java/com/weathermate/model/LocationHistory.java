package com.weathermate.model;

import java.io.Serializable;

public class LocationHistory implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private String cityName;
    private String country;
    private double latitude;
    private double longitude;
    private String searchDate;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getCityName() { return cityName; }
    public void setCityName(String cityName) { this.cityName = cityName; }

    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }

    public double getLatitude() { return latitude; }
    public void setLatitude(double latitude) { this.latitude = latitude; }

    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }

    public String getSearchDate() { return searchDate; }
    public void setSearchDate(String searchDate) { this.searchDate = searchDate; }

    @Override
    public String toString() {
        return "LocationHistory{cityName='" + cityName + "', country='" + country + "'}";
    }
}
