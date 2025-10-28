package com.weathermate.model;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private LocationHistoryDAO locationDAO = new LocationHistoryDAO();
    private FavoriteCityDAO favoriteDAO = new FavoriteCityDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== DashboardServlet GET ===");

        HttpSession session = request.getSession(false);
        if (session == null) {
            System.out.println("❌ No session found");
            response.sendRedirect("index.jsp");
            return;
        }

        System.out.println("✅ Session ID: " + session.getId());

        User user = (User) session.getAttribute("user");
        if (user == null) {
            System.out.println("❌ No user in session");
            response.sendRedirect("index.jsp");
            return;
        }

        System.out.println("✅ Loading dashboard for user: " + user.getUsername());

        try {
            List<LocationHistory> locationHistory = locationDAO.getLocationHistory(user.getId());
            List<FavoriteCity> favoriteCities = favoriteDAO.getFavoriteCities(user.getId());

            System.out.println("📊 Location history: " + locationHistory.size() + " items");
            System.out.println("⭐ Favorite cities: " + favoriteCities.size() + " items");

            request.setAttribute("locationHistory", locationHistory);
            request.setAttribute("favoriteCities", favoriteCities);
            request.setAttribute("username", user.getUsername());
        } catch (Exception e) {
            System.err.println("❌ Error loading dashboard data: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Unable to load dashboard data: " + e.getMessage());
        }

        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== DashboardServlet POST ===");

        HttpSession session = request.getSession(false);
        if (session == null) {
            System.out.println("❌ No session in POST");
            response.sendRedirect("index.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user == null) {
            System.out.println("❌ No user in session (POST)");
            response.sendRedirect("index.jsp");
            return;
        }

        String action = request.getParameter("action");
        System.out.println("🔍 Action: " + action);

        if ("addFavorite".equals(action)) {
            handleAddFavorite(request, response, user, session);
        } else if ("removeFavorite".equals(action)) {
            handleRemoveFavorite(request, response, user, session);
        } else {
            doGet(request, response);
        }
    }

    private void handleAddFavorite(HttpServletRequest request, HttpServletResponse response,
                                   User user, HttpSession session) throws ServletException, IOException {

        String cityName = request.getParameter("cityName");
        String country = request.getParameter("country");
        String latStr = request.getParameter("latitude");
        String lonStr = request.getParameter("longitude");

        System.out.println("➕ Adding favorite: " + cityName);
        System.out.println("   Country: " + country);
        System.out.println("   Coordinates: " + latStr + ", " + lonStr);

        if (cityName == null || cityName.trim().isEmpty()) {
            session.setAttribute("error", "City name is required!");
            response.sendRedirect("DashboardServlet");
            return;
        }

        boolean alreadyExists = favoriteDAO.isCityInFavorites(user.getId(), cityName);
        if (alreadyExists) {
            System.out.println("⚠️ City already in favorites");
            session.setAttribute("message", cityName + " is already in your favorites!");
        } else {
            FavoriteCity city = new FavoriteCity();
            city.setUserId(user.getId());
            city.setCityName(cityName);
            city.setCountry(country != null ? country : "");

            try {
                double lat = (latStr != null && !latStr.isEmpty()) ? Double.parseDouble(latStr) : 0.0;
                double lon = (lonStr != null && !lonStr.isEmpty()) ? Double.parseDouble(lonStr) : 0.0;
                city.setLatitude(lat);
                city.setLongitude(lon);
            } catch (NumberFormatException e) {
                System.err.println("⚠️ Invalid coordinates, using 0.0");
                city.setLatitude(0.0);
                city.setLongitude(0.0);
            }

            try {
                favoriteDAO.addFavoriteCity(city);
                System.out.println("✅ Favorite city added successfully!");
                session.setAttribute("message", cityName + " added to favorites!");
            } catch (SQLException e) {
                System.err.println("❌ SQL error while adding favorite: " + e.getMessage());
                request.setAttribute("error", "Database error: " + e.getMessage());
                request.getRequestDispatcher("error.jsp").forward(request, response);
                return;
            }
        }

        response.sendRedirect("DashboardServlet");
    }

    private void handleRemoveFavorite(HttpServletRequest request, HttpServletResponse response,
                                     User user, HttpSession session) throws ServletException, IOException {

        String cityIdStr = request.getParameter("cityId");
        System.out.println("🗑️ Removing favorite ID: " + cityIdStr);

        try {
            int cityId = Integer.parseInt(cityIdStr);
            boolean removed = favoriteDAO.removeFavoriteCity(cityId, user.getId());

            if (removed) {
                System.out.println("✅ Favorite removed");
                session.setAttribute("message", "City removed from favorites!");
            } else {
                System.out.println("❌ Failed to remove favorite");
                session.setAttribute("error", "Failed to remove city.");
            }
        } catch (NumberFormatException e) {
            System.err.println("❌ Invalid city ID");
            session.setAttribute("error", "Invalid city ID.");
        }

        response.sendRedirect("DashboardServlet");
    }
}