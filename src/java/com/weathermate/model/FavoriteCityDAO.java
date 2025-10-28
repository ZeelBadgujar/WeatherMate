package com.weathermate.model;
import java.sql.*;
import java.util.*;

public class FavoriteCityDAO {

    // Fetch all favorite cities for a user
    public List<FavoriteCity> getFavoriteCities(int userId) {
        List<FavoriteCity> list = new ArrayList<>();
        String sql = "SELECT id, user_id, city_name, country, latitude, longitude, added_date " +
                     "FROM favorite_cities WHERE user_id = ? ORDER BY id DESC";

        try (Connection con = DBUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                FavoriteCity city = new FavoriteCity();
                city.setId(rs.getInt("id"));
                city.setUserId(rs.getInt("user_id"));
                city.setCityName(rs.getString("city_name"));
                city.setCountry(rs.getString("country"));
                city.setLatitude(rs.getDouble("latitude"));
                city.setLongitude(rs.getDouble("longitude"));
                city.setAddedDate(rs.getString("added_date"));
                list.add(city);
            }
        } catch (SQLException e) {
            System.err.println("❌ Error fetching favorites: " + e.getMessage());
        }
        return list;
    }

    // Check if a city already exists in user's favorite list
    public boolean isCityInFavorites(int userId, String cityName) {
        String sql = "SELECT COUNT(*) FROM favorite_cities WHERE user_id = ? AND city_name = ?";
        try (Connection con = DBUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, cityName);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("❌ Error checking favorite: " + e.getMessage());
        }
        return false;
    }

    // Add a new favorite city
    public void addFavoriteCity(FavoriteCity city) throws SQLException {
        String sql = "INSERT INTO favorite_cities (user_id, city_name, country, latitude, longitude, added_date) " +
                     "VALUES (?, ?, ?, ?, ?, NOW())";
        try (Connection con = DBUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, city.getUserId());
            ps.setString(2, city.getCityName());
            ps.setString(3, city.getCountry());
            ps.setDouble(4, city.getLatitude());
            ps.setDouble(5, city.getLongitude());
            ps.executeUpdate();
        }
    }

    // Remove a city from favorites by cityId and userId
    public boolean removeFavoriteCity(int cityId, int userId) {
        String sql = "DELETE FROM favorite_cities WHERE id = ? AND user_id = ?";
        try (Connection con = DBUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, cityId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error removing favorite: " + e.getMessage());
        }
        return false;
    }
}
