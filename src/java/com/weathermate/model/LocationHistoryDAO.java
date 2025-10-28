package com.weathermate.model;
import java.sql.*;
import java.util.*;

public class LocationHistoryDAO {

    public List<LocationHistory> getLocationHistory(int userId) {
        List<LocationHistory> list = new ArrayList<>();
        String sql = "SELECT id, user_id, city_name, country, latitude, longitude, search_date FROM location_history WHERE user_id=? ORDER BY id DESC LIMIT 20";

        try (Connection con = DBUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                LocationHistory l = new LocationHistory();
                l.setId(rs.getInt("id"));
                l.setUserId(rs.getInt("user_id"));
                l.setCityName(rs.getString("city_name"));
                l.setCountry(rs.getString("country"));
                l.setLatitude(rs.getDouble("latitude"));
                l.setLongitude(rs.getDouble("longitude"));
                l.setSearchDate(rs.getString("search_date"));
                list.add(l);
            }
        } catch (SQLException e) {
            System.err.println("❌ Error fetching location history: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public void addLocationHistory(LocationHistory loc) throws SQLException {
        String sql = "INSERT INTO location_history (user_id, city_name, country, latitude, longitude) VALUES (?,?,?,?,?)";
        try (Connection con = DBUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, loc.getUserId());
            ps.setString(2, loc.getCityName());
            ps.setString(3, loc.getCountry());
            ps.setDouble(4, loc.getLatitude());
            ps.setDouble(5, loc.getLongitude());
            ps.executeUpdate();
        }
    }
}