package com.weathermate.model;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import org.json.JSONArray;
import org.json.JSONObject;

public class WeatherServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, java.io.IOException {

        HttpSession session = request.getSession(false);

        System.out.println("=== WeatherServlet Debug ===");
        System.out.println("Session exists: " + (session != null));

        if (session == null) {
            System.out.println("❌ No session found - redirecting to login");
            response.sendRedirect("index.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        System.out.println("User in session: " + (user != null ? user.getUsername() : "NULL"));
        System.out.println("Session ID: " + session.getId());

        if (user == null) {
            System.out.println("❌ No user attribute in session - redirecting to login");
            response.sendRedirect("index.jsp");
            return;
        }

        System.out.println("✅ Session valid for user: " + user.getUsername());

        String cityInput = request.getParameter("city");
        String lat = request.getParameter("latitude");
        String lon = request.getParameter("longitude");

        System.out.println("📍 Input parameters - City: " + cityInput + ", Lat: " + lat + ", Lon: " + lon);

        final String apiKey = "838ed5e79999dec35d6a3ef5b7b836e4";

        String currentUrl;
        String forecastUrl;
        String displayName = "";
        String timezoneName = "India Standard Time"; // Default to IST

        // Scenario 1: User provided coordinates (Current Location)
        if (lat != null && lon != null && !lat.isEmpty() && !lon.isEmpty()) {
            System.out.println("📍 Using coordinates for weather data");
            currentUrl = "https://api.openweathermap.org/data/2.5/weather?lat=" + lat + "&lon=" + lon
                    + "&appid=" + apiKey + "&units=metric";
            forecastUrl = "https://api.openweathermap.org/data/2.5/forecast?lat=" + lat + "&lon=" + lon
                    + "&appid=" + apiKey + "&units=metric";
        } 
        // Scenario 2: User provided city name
        else if (cityInput != null && !cityInput.trim().isEmpty()) {
            System.out.println("🏙️ Using city name for weather data: " + cityInput);
            String encodedCity = URLEncoder.encode(cityInput.trim(), "UTF-8");
            currentUrl = "https://api.openweathermap.org/data/2.5/weather?q=" + encodedCity
                    + "&appid=" + apiKey + "&units=metric";
            forecastUrl = "https://api.openweathermap.org/data/2.5/forecast?q=" + encodedCity
                    + "&appid=" + apiKey + "&units=metric";
        } 
        // Scenario 3: Default city (Kolkata) - First load or Reset
        else {
            System.out.println("🇮🇳 Using default city: Kolkata");
            cityInput = "Kolkata";
            String encodedCity = URLEncoder.encode(cityInput.trim(), "UTF-8");
            currentUrl = "https://api.openweathermap.org/data/2.5/weather?q=" + encodedCity
                    + "&appid=" + apiKey + "&units=metric";
            forecastUrl = "https://api.openweathermap.org/data/2.5/forecast?q=" + encodedCity
                    + "&appid=" + apiKey + "&units=metric";
        }

        try {
            // 🌤 Fetch Forecast Data
            System.out.println("🌤️ Fetching forecast data from: " + forecastUrl);
            URL forecastAPI = new URL(forecastUrl);
            HttpURLConnection forecastConn = (HttpURLConnection) forecastAPI.openConnection();
            forecastConn.setRequestMethod("GET");
            forecastConn.setConnectTimeout(10000);
            forecastConn.setReadTimeout(10000);

            StringBuilder forecastContent = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(forecastConn.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    forecastContent.append(line);
                }
            }

            JSONObject forecastJson = new JSONObject(forecastContent.toString());
            JSONArray list = forecastJson.getJSONArray("list");

            String[] days = new String[6];
            String[] temps = new String[6];
            String[] icons = new String[6];
            int[] indices = {0, 8, 16, 24, 32, 39};

            for (int i = 0; i < indices.length && i < list.length(); i++) {
                JSONObject day = list.getJSONObject(indices[i]);
                days[i] = day.getString("dt_txt").split(" ")[0];
                temps[i] = day.getJSONObject("main").get("temp").toString();
                icons[i] = day.getJSONArray("weather").getJSONObject(0).getString("icon");
            }

            // 🌡 Fetch Current Weather Data
            System.out.println("🌡️ Fetching current weather data from: " + currentUrl);
            URL currentAPI = new URL(currentUrl);
            HttpURLConnection currentConn = (HttpURLConnection) currentAPI.openConnection();
            currentConn.setRequestMethod("GET");
            currentConn.setConnectTimeout(10000);
            currentConn.setReadTimeout(10000);

            StringBuilder currentContent = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(currentConn.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    currentContent.append(line);
                }
            }

            JSONObject currentJson = new JSONObject(currentContent.toString());
            JSONObject mainObj = currentJson.getJSONObject("main");
            JSONObject weatherObj = currentJson.getJSONArray("weather").getJSONObject(0);

            String temp = mainObj.get("temp").toString();
            String desc = weatherObj.getString("description");
            String icon = weatherObj.getString("icon");
            String cityName = currentJson.optString("name", "");
            String country = currentJson.has("sys") ? currentJson.getJSONObject("sys").optString("country", "") : "";
            String state = "";

            double actualLat = 0.0;
            double actualLon = 0.0;

            if (currentJson.has("coord")) {
                JSONObject coordObj = currentJson.getJSONObject("coord");
                actualLat = coordObj.optDouble("lat", 0.0);
                actualLon = coordObj.optDouble("lon", 0.0);
            }

            // 🕐 Get timezone information
            int timezoneOffset = currentJson.optInt("timezone", 19800); // Default to IST (5:30)
            timezoneName = getTimezoneNameFromOffset(timezoneOffset);
            System.out.println("🕐 Timezone detected: " + timezoneName + " (Offset: " + timezoneOffset + " seconds)");

            // 🌍 Geocoding for better display name
            try {
                String geoUrl = "https://api.openweathermap.org/geo/1.0/reverse?lat=" + actualLat + "&lon=" + actualLon
                        + "&limit=1&appid=" + apiKey;
                URL geoAPI = new URL(geoUrl);
                HttpURLConnection geoConn = (HttpURLConnection) geoAPI.openConnection();
                geoConn.setRequestMethod("GET");

                StringBuilder geoContent = new StringBuilder();
                try (BufferedReader geoReader = new BufferedReader(new InputStreamReader(geoConn.getInputStream()))) {
                    String geoLine;
                    while ((geoLine = geoReader.readLine()) != null) {
                        geoContent.append(geoLine);
                    }
                }

                JSONArray geoArray = new JSONArray(geoContent.toString());
                if (geoArray.length() > 0) {
                    JSONObject geoData = geoArray.getJSONObject(0);
                    String reverseCityName = geoData.optString("name", cityName);
                    String reverseState = geoData.optString("state", "");
                    String reverseCountry = geoData.optString("country", country);

                    // Use reverse geocoding result if available
                    if (!reverseCityName.isEmpty()) {
                        cityName = reverseCityName;
                    }
                    if (!reverseState.isEmpty()) {
                        state = reverseState;
                    }
                    if (!reverseCountry.isEmpty()) {
                        country = reverseCountry;
                    }

                    displayName = cityName;
                    if (!state.isEmpty()) displayName += ", " + state;
                    if (!country.isEmpty()) displayName += ", " + country;
                    
                } else {
                    displayName = cityName + (country.isEmpty() ? "" : ", " + country);
                }
            } catch (Exception ignore) {
                System.out.println("⚠️ Reverse geocoding failed, using direct API data");
                displayName = cityName + (country.isEmpty() ? "" : ", " + country);
            }

            String humidity = mainObj.get("humidity").toString();
            String pressure = mainObj.get("pressure").toString();
            String windSpeed = currentJson.getJSONObject("wind").get("speed").toString();

            long sunriseUnix = currentJson.getJSONObject("sys").getLong("sunrise");
            long sunsetUnix = currentJson.getJSONObject("sys").getLong("sunset");

            String sunrise = new java.text.SimpleDateFormat("hh:mm a")
                    .format(new java.util.Date(sunriseUnix * 1000L));
            String sunset = new java.text.SimpleDateFormat("hh:mm a")
                    .format(new java.util.Date(sunsetUnix * 1000L));

            // 🧩 JSP Attributes
            request.setAttribute("city", displayName);
            request.setAttribute("temp", temp);
            request.setAttribute("desc", desc);
            request.setAttribute("icon", icon);
            request.setAttribute("days", days);
            request.setAttribute("temps", temps);
            request.setAttribute("icons", icons);
            request.setAttribute("humidity", humidity);
            request.setAttribute("pressure", pressure);
            request.setAttribute("wind", windSpeed);
            request.setAttribute("sunrise", sunrise);
            request.setAttribute("sunset", sunset);
            request.setAttribute("timezone", timezoneName); // Add timezone info

            // 🧠 Save Location to PostgreSQL (only if not coordinates to avoid duplicates)
            try {
                LocationHistory location = new LocationHistory();
                location.setUserId(user.getId());
                location.setCityName(cityName);
                location.setCountry(country);
                location.setLatitude(actualLat);
                location.setLongitude(actualLon);

                LocationHistoryDAO locationDAO = new LocationHistoryDAO();
                locationDAO.addLocationHistory(location);
                System.out.println("✅ Location history saved: " + cityName);
            } catch (Exception daoEx) {
                System.err.println("⚠️ Failed to save location history: " + daoEx.getMessage());
                daoEx.printStackTrace();
            }

            request.setAttribute("canAddFavorite", true);
            request.setAttribute("currentCityName", cityName);
            request.setAttribute("currentCountry", country);
            request.setAttribute("currentLat", String.valueOf(actualLat));
            request.setAttribute("currentLon", String.valueOf(actualLon));

            System.out.println("✅ Weather data loaded successfully for: " + displayName);
            System.out.println("🕐 Timezone: " + timezoneName);

        } catch (Exception e) {
            System.err.println("❌ Error loading weather data: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Weather data could not be loaded. Please try again.");
        }

        request.getRequestDispatcher("home.jsp").forward(request, response);
    }

    // 🧩 Helper: Convert timezone offset to readable name
    private String getTimezoneNameFromOffset(int offsetSeconds) {
        int offsetHours = offsetSeconds / 3600;
        switch (offsetHours) {
            case 5: return "India Standard Time (IST)";
            case 9: return "Japan Standard Time (JST)";
            case 1: return "Central European Time (CET)";
            case -5: return "Eastern Standard Time (EST)";
            case -8: return "Pacific Standard Time (PST)";
            case 0: return "Greenwich Mean Time (GMT)";
            case 8: return "China Standard Time (CST)";
            case 10: return "Australian Eastern Standard Time (AEST)";
            case -4: return "Atlantic Standard Time (AST)";
            case 3: return "Moscow Time (MSK)";
            case -6: return "Central Standard Time (CST)";
            case -7: return "Mountain Standard Time (MST)";
            case 2: return "Eastern European Time (EET)";
            case 7: return "Indochina Time (ICT)";
            case 4: return "Gulf Standard Time (GST)";
            case -3: return "Argentina Time (ART)";
            default: 
                if (offsetHours >= 0) {
                    return "UTC+" + offsetHours;
                } else {
                    return "UTC" + offsetHours;
                }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, java.io.IOException {
        doGet(request, response);
    }
}