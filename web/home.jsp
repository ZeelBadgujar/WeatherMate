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
    String requestedLat = request.getParameter("latitude");
    String requestedLon = request.getParameter("longitude");
    
    boolean isFirstLoad = (requestedCity == null || requestedCity.trim().isEmpty())
                          && requestedLat == null && requestedLon == null;
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
    
    /* FIXED: Button container styles */
    .location-buttons, .dashboard-buttons { 
        display: flex; 
        gap: 10px; 
        justify-content: center; 
        align-items: center;
        margin: 15px 0; 
        flex-wrap: wrap;
    }
    
    .location-btn, .dashboard-btn, .favorite-btn {
        border: none; 
        padding: 12px 20px; 
        border-radius: 8px; 
        cursor: pointer;
        font-size: 14px; 
        color: white; 
        text-decoration: none; 
        display: inline-flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s ease;
        white-space: nowrap;
        min-width: fit-content;
    }
    .location-btn { background: #4CAF50; }
    .location-btn:hover { background: #45a049; transform: translateY(-2px); }
    .dashboard-btn { background: #9C27B0; }
    .dashboard-btn:hover { background: #7B1FA2; transform: translateY(-2px); }
    .favorite-btn { background: #FF9800; }
    .favorite-btn:hover { background: #F57C00; transform: translateY(-2px); }
    
    /* FIXED: Form styling */
    .dashboard-buttons form {
        display: inline;
        margin: 0;
        padding: 0;
    }
    
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
        border-radius: 8px; padding: 15px;
    }
    .error { color: #ffbaba; background: rgba(255,0,0,0.3); border: 1px solid #ff4444; }
    .message { color: #4CAF50; background: rgba(255,255,255,0.3); border: 1px solid #4CAF50; }
    #geoStatus { 
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        z-index: 1000;
        background: rgba(0, 0, 0, 0.9);
        color: white;
        padding: 30px;
        border-radius: 15px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.5);
        text-align: center;
        font-size: 18px;
    }
    .loading-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.7);
        z-index: 999;
        display: none;
    }
    .geo-buttons {
        margin-top: 15px;
        display: flex;
        gap: 10px;
        justify-content: center;
    }
    .geo-btn {
        padding: 8px 16px;
        border: none;
        border-radius: 5px;
        cursor: pointer;
        font-size: 14px;
    }
    .geo-retry { background: #4CAF50; color: white; }
    .geo-cancel { background: #f44336; color: white; }
    
    /* FIXED: Responsive design for buttons */
    @media (max-width: 768px) {
        .location-buttons, .dashboard-buttons {
            flex-direction: column;
            gap: 8px;
        }
        
        .location-btn, .dashboard-btn, .favorite-btn {
            width: 100%;
            max-width: 280px;
        }
        
        .top-bar {
            flex-direction: column;
            text-align: center;
            gap: 15px;
        }
        
        .top-right {
            text-align: center;
        }
        .timezone {
    font-size: 14px;
    color: #e0e0e0;
    margin-top: 5px;
    opacity: 0.9;
    font-weight: 300;
}
    }
</style>
</head>
<body>
    <!-- Loading Overlay -->
    <div id="loadingOverlay" class="loading-overlay"></div>
    
    <!-- Geolocation Status -->
    <div id="geoStatus" style="display: none;"></div>

    <div class="container">
        <div class="top-bar">
            <div class="top-left"><h1>WeatherMate</h1></div>
            <div class="top-right">
    <% if (city != null) { %>
        <div class="location"><%= city %></div>
        <% if (request.getAttribute("timezone") != null) { %>
            <div class="timezone" style="font-size: 14px; color: #e0e0e0; margin-top: 5px;">
                🕐 <%= request.getAttribute("timezone") %>
            </div>
        <% } %>
    <% } %>
    <% if (temp != null) { %>
        <button id="toggleBtn" data-unit="C" onclick="toggleTempUnit()">Switch to °F</button>
    <% } %>
</div>
        </div>

        <div class="location-buttons">
            <button class="location-btn" onclick="getCurrentLocation()">📍 Use My Current Location</button>
            <a href="WeatherServlet" class="location-btn">🏠 Reset to Default (Kolkata)</a>
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
                    <p style="text-transform: capitalize;"><%= desc %></p>
                    <% if (icon != null) { %>
                        <img src="https://openweathermap.org/img/wn/<%= icon %>@2x.png" alt="weather icon">
                    <% } %>
                </div>
            <% } else { %>
                <div style="text-align: center; padding: 40px;">
                    <h3>Loading weather data...</h3>
                </div>
            <% } %>
        </div>

        <form action="WeatherServlet" method="get" onsubmit="return validateCity()">
            <input type="text" name="city" id="cityInput" placeholder="Enter city name" value="<%= requestedCity != null ? requestedCity : "" %>">
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
                    <p><strong><%= days[i] %></strong></p>
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
    

    <script>
        // Global variable to track geolocation state
        let geolocationInProgress = false;

        function showGeoStatus(message, showButtons = false) {
            const geoStatus = document.getElementById("geoStatus");
            let buttonsHTML = '';
            
            if (showButtons) {
                buttonsHTML = `
                    <div class="geo-buttons">
                        <button class="geo-btn geo-retry" onclick="getCurrentLocation()">🔄 Retry</button>
                        <button class="geo-btn geo-cancel" onclick="hideGeoStatus()">❌ Cancel</button>
                    </div>
                `;
            }
            
            geoStatus.innerHTML = `
                <div style="font-size: 48px; margin-bottom: 15px;">📍</div>
                <div>${message}</div>
                ${buttonsHTML}
            `;
            geoStatus.style.display = 'block';
            document.getElementById('loadingOverlay').style.display = 'block';
        }

        function hideGeoStatus() {
            document.getElementById("geoStatus").style.display = 'none';
            document.getElementById('loadingOverlay').style.display = 'none';
            geolocationInProgress = false;
        }

        function showErrorStatus(message) {
            const geoStatus = document.getElementById("geoStatus");
            geoStatus.innerHTML = `
                <div style="font-size: 48px; margin-bottom: 15px;">❌</div>
                <div>${message}</div>
                <div class="geo-buttons">
                    <button class="geo-btn geo-retry" onclick="getCurrentLocation()">🔄 Retry</button>
                    <button class="geo-btn geo-cancel" onclick="hideGeoStatus()">❌ Close</button>
                </div>
            `;
            geoStatus.style.display = 'block';
            document.getElementById('loadingOverlay').style.display = 'block';
        }

        function getCurrentLocation() {
            if (geolocationInProgress) return;
            
            geolocationInProgress = true;
            showGeoStatus("🌍 Detecting your location...", false);

            if (!navigator.geolocation) {
                showErrorStatus("Geolocation is not supported by your browser. Please try searching for your city manually.");
                return;
            }

            const options = {
                enableHighAccuracy: true,
                timeout: 15000,
                maximumAge: 60000
            };

            navigator.geolocation.getCurrentPosition(
                // Success callback
                function(position) {
                    const latitude = position.coords.latitude;
                    const longitude = position.coords.longitude;
                    
                    console.log("📍 Location found:", latitude, longitude);
                    showGeoStatus("📍 Location found! Fetching weather data...", false);
                    
                    // Create and submit form with coordinates
                    submitLocationForm(latitude, longitude);
                },
                // Error callback
                function(error) {
                    geolocationInProgress = false;
                    let errorMessage = "Unable to access your location. ";
                    
                    switch(error.code) {
                        case error.PERMISSION_DENIED:
                            errorMessage += "Location access was denied. Please allow location access in your browser settings.";
                            break;
                        case error.POSITION_UNAVAILABLE:
                            errorMessage += "Location information is unavailable. Please check your connection.";
                            break;
                        case error.TIMEOUT:
                            errorMessage += "Location request timed out. Please try again.";
                            break;
                        default:
                            errorMessage += "An unknown error occurred.";
                            break;
                    }
                    
                    showErrorStatus(errorMessage);
                },
                options
            );
        }

        function submitLocationForm(latitude, longitude) {
            // Create a hidden form and submit it
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'WeatherServlet';
            
            const latInput = document.createElement('input');
            latInput.type = 'hidden';
            latInput.name = 'latitude';
            latInput.value = latitude;
            
            const lonInput = document.createElement('input');
            lonInput.type = 'hidden';
            lonInput.name = 'longitude';
            lonInput.value = longitude;
            
            form.appendChild(latInput);
            form.appendChild(lonInput);
            document.body.appendChild(form);
            
            // Show loading message while form submits
            showGeoStatus("⏳ Loading weather data for your location...", false);
            
            // Submit the form
            form.submit();
        }

        function validateCity() {
            const cityInput = document.getElementById('cityInput');
            if (cityInput.value.trim() === '') {
                alert('Please enter a city name');
                return false;
            }
            return true;
        }

        function toggleTempUnit() {
            const toggleBtn = document.getElementById("toggleBtn");
            const isCelsius = toggleBtn.dataset.unit === "C";
            
            // Convert all temperature elements
            document.querySelectorAll(".tempValue, .forecastTemp").forEach(el => {
                const celsiusTemp = parseFloat(el.dataset.celsius);
                if (!isNaN(celsiusTemp)) {
                    const convertedTemp = isCelsius ? 
                        ((celsiusTemp * 9/5) + 32).toFixed(1) : 
                        celsiusTemp.toFixed(1);
                    el.textContent = convertedTemp;
                }
            });
            
            // Update unit symbols
            document.querySelectorAll(".unitSymbol").forEach(s => {
                s.textContent = isCelsius ? "°F" : "°C";
            });
            
            // Update button
            toggleBtn.dataset.unit = isCelsius ? "F" : "C";
            toggleBtn.textContent = isCelsius ? "Switch to °C" : "Switch to °F";
        }

        // Auto-hide messages after 5 seconds
        document.addEventListener('DOMContentLoaded', function() {
            // Auto-hide flash messages
            setTimeout(() => {
                const messages = document.querySelectorAll('.message, .error');
                messages.forEach(msg => {
                    msg.style.transition = 'opacity 0.5s ease';
                    msg.style.opacity = '0';
                    setTimeout(() => {
                        if (msg.parentNode) {
                            msg.parentNode.removeChild(msg);
                        }
                    }, 500);
                });
            }, 5000);

            // Log page load for debugging
            console.log('✅ Weather page loaded successfully');
            console.log('Current city:', '<%= city != null ? city : "None" %>');
            console.log('Is first load:', <%= isFirstLoad %>);
        });
    </script>
</body>
</html>