<%@ page import="com.weathermate.model.User" %>
<%@ page import="javax.servlet.http.*,javax.servlet.*,java.io.*,java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ✅ Check if user is logged in
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // ✅ Get weather data safely
    String city = (String) request.getAttribute("city");
    String temp = (String) request.getAttribute("temp");
    String desc = (String) request.getAttribute("desc");
    String icon = (String) request.getAttribute("icon");
    String humidity = (String) request.getAttribute("humidity");
    String wind = (String) request.getAttribute("wind");
    String pressure = (String) request.getAttribute("pressure");
    String sunrise = (String) request.getAttribute("sunrise");
    String sunset = (String) request.getAttribute("sunset");
    String[] days = (String[]) request.getAttribute("days");
    String[] temps = (String[]) request.getAttribute("temps");
    String[] icons = (String[]) request.getAttribute("icons");

    // ✅ Dashboard attributes
    Boolean canAddFavorite = (Boolean) request.getAttribute("canAddFavorite");
    String currentCityName = (String) request.getAttribute("currentCityName");
    String currentCountry = (String) request.getAttribute("currentCountry");
    String currentLat = (String) request.getAttribute("currentLat");
    String currentLon = (String) request.getAttribute("currentLon");

    // ✅ Detect if it's first load (default city)
    String requestedCity = request.getParameter("city");
    boolean isFirstLoad = (requestedCity == null || requestedCity.trim().isEmpty())
                          && city != null && city.equals("Kolkata");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>WeatherMate</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;600&display=swap" rel="stylesheet">
    <style>
        body {
            margin: 0;
            font-family: 'Poppins', sans-serif;
            color: white;
            animation: fadein 1.5s ease;
            background: linear-gradient(to right, #2193b0, #6dd5ed);
            overflow-x: hidden;
        }
        @keyframes fadein {
            from {opacity: 0;}
            to {opacity: 1;}
        }
        .container { padding: 40px; max-width: 1000px; margin: auto; }
        .top-bar { display: flex; justify-content: space-between; align-items: flex-start; padding: 20px 0; }
        .top-left h1 { font-size: 42px; margin: 0; color: #fff; text-shadow: 2px 2px 8px rgba(0,0,0,0.3); }
        .top-right { text-align: right; }
        .location { font-size: 22px; font-weight: 500; }
        #toggleBtn { background: #ff5722; color: white; border: none; border-radius: 8px; padding: 6px 12px; cursor: pointer; font-size: 14px; margin-top: 8px; }
        .location-buttons, .dashboard-buttons { display: flex; gap: 10px; justify-content: center; margin: 15px 0; }
        .location-btn, .dashboard-btn, .favorite-btn {
            border: none; padding: 10px 15px; border-radius: 8px; cursor: pointer;
            font-size: 14px; color: white; text-decoration: none; display: inline-block;
        }
        .location-btn { background: #4CAF50; }
        .location-btn:hover { background: #45a049; }
        .dashboard-btn { background: #9C27B0; }
        .dashboard-btn:hover { background: #7B1FA2; }
        .favorite-btn { background: #FF9800; }
        .favorite-btn:hover { background: #F57C00; }
        form { text-align: center; margin: 20px 0; }
        form input[type="text"] { padding: 10px; border-radius: 8px; border: none; width: 240px; font-size: 16px; }
        form button { background: #ff9800; color: white; border: none; padding: 10px 18px; border-radius: 8px; cursor: pointer; font-size: 16px; margin-left: 10px; }
        .current-weather { text-align: center; margin: 30px 0; }
        .current-weather img { width: 120px; }
        .weather-details {
            display: flex; justify-content: space-around; flex-wrap: wrap;
            background: rgba(255,255,255,0.2); border-radius: 15px; padding: 20px;
            margin: 30px auto; box-shadow: 0 0 12px rgba(0,0,0,0.2);
        }
        .weather-details div { margin: 10px 20px; text-align: center; }
        .forecast {
            display: flex; justify-content: space-evenly; flex-wrap: wrap;
            background: rgba(0,0,0,0.2); border-radius: 16px; padding: 20px; margin-top: 40px;
        }
        .day { text-align: center; padding: 12px; flex: 1; min-width: 120px; }
        .day img { width: 60px; }
        .error, .message, #geoStatus {
            text-align: center; font-weight: bold; margin: 10px auto; max-width: 500px;
            border-radius: 8px; padding: 10px;
        }
        .error { color: #ffbaba; background: rgba(255,0,0,0.2); }
        .message { color: #4CAF50; background: rgba(255,255,255,0.2); }
        #geoStatus { display: none; color: #fff; background: rgba(0,0,0,0.2); font-size: 16px; }
    </style>

    <script>
        let geolocationAttempted = false;

        function initGeolocation() {
            const isFirstLoad = <%= isFirstLoad %>;
            if (isFirstLoad && !geolocationAttempted) {
                geolocationAttempted = true;
                getLocation();
            }
        }

        function getLocation() {
            showGeoStatus("Detecting your location...");
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(showPosition, showError, {
                    enableHighAccuracy: true, timeout: 10000, maximumAge: 600000
                });
            } else {
                showGeoStatus("Geolocation not supported by your browser.");
            }
        }

        function showPosition(position) {
            const latitude = position.coords.latitude;
            const longitude = position.coords.longitude;
            showGeoStatus("Fetching weather for your location...");
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'WeatherServlet';
            form.innerHTML = `<input type="hidden" name="latitude" value="${latitude}">
                              <input type="hidden" name="longitude" value="${longitude}">`;
            document.body.appendChild(form);
            form.submit();
        }

        function showError(error) {
            let message = "Unable to access your location. ";
            switch(error.code) {
                case error.PERMISSION_DENIED: message += "Location access was denied."; break;
                case error.POSITION_UNAVAILABLE: message += "Location unavailable."; break;
                case error.TIMEOUT: message += "Location request timed out."; break;
                default: message += "An unknown error occurred."; break;
            }
            showGeoStatus(message);
            setTimeout(() => hideGeoStatus(), 5000);
        }

        function showGeoStatus(message) {
            const geoStatus = document.getElementById("geoStatus");
            geoStatus.innerHTML = message;
            geoStatus.style.display = "block";
        }

        function hideGeoStatus() {
            const geoStatus = document.getElementById("geoStatus");
            geoStatus.style.display = "none";
            geoStatus.innerHTML = "";
        }

        function detectLocation() {
            geolocationAttempted = true;
            getLocation();
        }

        function toggleTempUnit() {
            const toggleBtn = document.getElementById("toggleBtn");
            const isCelsius = toggleBtn.dataset.unit === "C";
            document.querySelectorAll(".tempValue, .forecastTemp").forEach(el => {
                const c = parseFloat(el.dataset.celsius);
                el.textContent = isCelsius ? ((c * 9 / 5) + 32).toFixed(1) : c.toFixed(1);
            });
            document.querySelectorAll(".unitSymbol").forEach(s => s.textContent = isCelsius ? "°F" : "°C");
            toggleBtn.dataset.unit = isCelsius ? "F" : "C";
            toggleBtn.textContent = isCelsius ? "Switch to °C" : "Switch to °F";
        }

        document.addEventListener('DOMContentLoaded', initGeolocation);
    </script>
</head>
<body>
    <div class="container">
        <div class="top-bar">
            <div class="top-left"><h1>WeatherMate</h1></div>
            <div class="top-right">
                <% if (city != null) { %>
                    <div class="location"><%= city %></div>
                <% } %>
                <button id="toggleBtn" data-unit="C" onclick="toggleTempUnit()">Switch to °F</button>
            </div>
        </div>

        <div id="geoStatus"></div>

        <div class="location-buttons">
            <button class="location-btn" onclick="detectLocation()">📍 Use My Current Location</button>
            <button class="location-btn" onclick="window.location.href='WeatherServlet'">🏠 Reset to Default</button>
        </div>

        <div class="dashboard-buttons">
            <a href="DashboardServlet" class="dashboard-btn">📊 View Dashboard</a>
            <% if (canAddFavorite != null && canAddFavorite && currentCityName != null) { %>
                <form action="DashboardServlet" method="post" style="display:inline;">
                    <input type="hidden" name="action" value="addFavorite">
                    <input type="hidden" name="cityName" value="<%= currentCityName %>">
                    <input type="hidden" name="country" value="<%= currentCountry != null ? currentCountry : "" %>">
                    <input type="hidden" name="latitude" value="<%= currentLat != null ? currentLat : "" %>">
                    <input type="hidden" name="longitude" value="<%= currentLon != null ? currentLon : "" %>">
                    <button type="submit" class="favorite-btn">⭐ Add to Favorites</button>
                </form>
            <% } %>
        </div>

        <div id="weatherContainer">
            <% if (temp != null) { %>
                <div class="current-weather">
                    <h2><span class="tempValue" data-celsius="<%= temp %>"><%= temp %></span><span class="unitSymbol">°C</span></h2>
                    <p><%= desc %></p>
                    <% if (icon != null) { %>
                        <img src="https://openweathermap.org/img/wn/<%= icon %>@2x.png" alt="weather icon">
                    <% } %>
                </div>
            <% } else { %>
                <h3>Fetching your weather...</h3>
            <% } %>
        </div>

        <form action="WeatherServlet" method="get">
            <input type="text" name="city" placeholder="Enter city name" value="<%= requestedCity != null ? requestedCity : "" %>">
            <button type="submit">Search Location</button>
        </form>

        <% if (humidity != null || wind != null || pressure != null || sunrise != null || sunset != null) { %>
        <div class="weather-details">
            <% if (humidity != null) { %><div><strong>Humidity</strong><br><%= humidity %>%</div><% } %>
            <% if (wind != null) { %><div><strong>Wind Speed</strong><br><%= wind %> km/h</div><% } %>
            <% if (pressure != null) { %><div><strong>Pressure</strong><br><%= pressure %> hPa</div><% } %>
            <% if (sunrise != null) { %><div><strong>Sunrise</strong><br><%= sunrise %></div><% } %>
            <% if (sunset != null) { %><div><strong>Sunset</strong><br><%= sunset %></div><% } %>
        </div>
        <% } %>

        <% if (days != null && temps != null && icons != null) { %>
        <div class="forecast">
            <% for (int i = 0; i < days.length; i++) { %>
                <div class="day">
                    <p><%= days[i] %></p>
                    <p><span class="forecastTemp" data-celsius="<%= temps[i] %>"><%= temps[i] %></span><span class="unitSymbol">°C</span></p>
                    <img src="https://openweathermap.org/img/wn/<%= icons[i] %>@2x.png" alt="icon">
                </div>
            <% } %>
        </div>
        <% } %>

        <% if (request.getAttribute("error") != null) { %>
            <div class="error"><%= request.getAttribute("error") %></div>
        <% } %>

        <% if (request.getAttribute("message") != null) { %>
            <div class="message"><%= request.getAttribute("message") %></div>
        <% } %>
    </div>
</body>
</html>