<%@ page import="com.weathermate.model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // ✅ FIXED: Session validation to prevent redirect loops
    if (session == null || session.getAttribute("user") == null) {
        System.out.println("❌ dashboard.jsp - No session or user, redirecting to login");
        response.sendRedirect("index.jsp");
        return;
    }
    
    // ✅ Debug: Log session info
    User sessionUser = (User) session.getAttribute("user");
    System.out.println("✅ dashboard.jsp - Session valid for user: " + sessionUser.getUsername());
    System.out.println("✅ Session ID: " + session.getId());
%>
<!DOCTYPE html>
<html>
<head>
    <title>WeatherMate - Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;600&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
            min-height: 100vh;
        }
        .dashboard-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding: 20px;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        .header h1 {
            color: #2c3e50;
            font-size: 2.5em;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.1);
        }
        .user-info {
            text-align: right;
        }
        .user-info .welcome {
            font-size: 1.2em;
            color: #34495e;
            margin-bottom: 10px;
        }
        .nav-buttons {
            display: flex;
            gap: 15px;
        }
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-block;
            text-align: center;
        }
        .btn-primary { background: #3498db; color: white; }
        .btn-primary:hover { background: #2980b9; transform: translateY(-2px); }
        .btn-secondary { background: #95a5a6; color: white; }
        .btn-secondary:hover { background: #7f8c8d; transform: translateY(-2px); }
        .btn-success { background: #27ae60; color: white; }
        .btn-success:hover { background: #219a52; transform: translateY(-2px); }
        .btn-danger { background: #e74c3c; color: white; }
        .btn-danger:hover { background: #c0392b; transform: translateY(-2px); }
        .dashboard-content {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-bottom: 30px;
        }
        .section {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            backdrop-filter: blur(10px);
        }
        .section h2 {
            color: #2c3e50;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 3px solid #3498db;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .card {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border: 1px solid #dee2e6;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 15px;
            transition: all 0.3s ease;
        }
        .card:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
        }
        .favorite-card {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .city-info h3 {
            color: #2c3e50;
            margin-bottom: 8px;
            font-size: 1.3em;
        }
        .city-details {
            color: #7f8c8d;
            font-size: 0.9em;
        }
        .location-card h3 {
            color: #2c3e50;
            margin-bottom: 8px;
            font-size: 1.2em;
        }
        .location-details {
            color: #7f8c8d;
            font-size: 0.9em;
            margin-bottom: 8px;
        }
        .timestamp {
            color: #95a5a6;
            font-size: 0.8em;
            font-style: italic;
        }
        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #7f8c8d;
        }
        .empty-state i {
            font-size: 3em;
            margin-bottom: 15px;
            color: #bdc3c7;
        }
        .message {
            padding: 15px;
            margin: 20px 0;
            border-radius: 8px;
            text-align: center;
            font-weight: 600;
        }
        .message.success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .message.error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .action-buttons { display: flex; gap: 10px; }
        .btn-small { padding: 8px 16px; font-size: 0.9em; }
        .stats {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
            margin-top: 20px;
        }
        .stat-card {
            background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
        }
        .stat-number {
            font-size: 2.5em;
            font-weight: bold;
            margin-bottom: 5px;
        }
        .stat-label { font-size: 0.9em; opacity: 0.9; }
        @media (max-width: 768px) {
            .dashboard-content { grid-template-columns: 1fr; }
            .header { flex-direction: column; text-align: center; gap: 15px; }
            .user-info { text-align: center; }
            .nav-buttons { justify-content: center; }
            .stats { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="header">
            <h1>🌤️ WeatherMate Dashboard</h1>
            <div class="user-info">
                <div class="welcome">Welcome, <strong><c:out value="${sessionScope.user.username}" /></strong>!</div>
                <div class="nav-buttons">
                    <a href="WeatherServlet" class="btn btn-primary">🌤️ Check Weather</a>
                    <a href="LogoutServlet" class="btn btn-secondary">🚪 Logout</a>
                </div>
            </div>
        </div>

        <c:if test="${not empty sessionScope.message}">
            <div class="message success">${sessionScope.message}</div>
            <c:remove var="message" scope="session" />
        </c:if>
        <c:if test="${not empty sessionScope.error}">
            <div class="message error">${sessionScope.error}</div>
            <c:remove var="error" scope="session" />
        </c:if>

        <div class="stats">
            <div class="stat-card">
                <div class="stat-number">${favoriteCities != null ? favoriteCities.size() : 0}</div>
                <div class="stat-label">Favorite Cities</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">${locationHistory != null ? locationHistory.size() : 0}</div>
                <div class="stat-label">Location Searches</div>
            </div>
        </div>

        <div class="dashboard-content">
            <div class="section">
                <h2>⭐ Favorite Cities 
                    <span style="font-size: 0.8em; color: #7f8c8d;">${favoriteCities != null ? favoriteCities.size() : 0} cities</span>
                </h2>
                <c:if test="${empty favoriteCities}">
                    <div class="empty-state">
                        <div>⭐</div>
                        <h3>No Favorite Cities Yet</h3>
                        <p>Start adding cities to your favorites while checking weather!</p>
                        <a href="WeatherServlet" class="btn btn-primary" style="margin-top: 15px;">Check Weather</a>
                    </div>
                </c:if>
                <c:forEach var="city" items="${favoriteCities}">
                    <div class="card favorite-card">
                        <div class="city-info">
                            <h3>${city.cityName}</h3>
                            <div class="city-details">
                                <c:if test="${not empty city.country}">${city.country}</c:if>
                                <c:if test="${not empty city.latitude && city.latitude != 0.0}">
                                    • 📍 ${city.latitude}, ${city.longitude}
                                </c:if>
                            </div>
                        </div>
                        <div class="action-buttons">
                            <form action="WeatherServlet" method="get" style="display:inline;">
                                <input type="hidden" name="city" value="${city.cityName}">
                                <button type="submit" class="btn btn-primary btn-small">🌤️ Weather</button>
                            </form>
                            <form action="DashboardServlet" method="post" style="display:inline;" onsubmit="return confirm('Remove ${city.cityName} from favorites?');">
                                <input type="hidden" name="action" value="removeFavorite">
                                <input type="hidden" name="cityId" value="${city.id}">
                                <button type="submit" class="btn btn-danger btn-small">🗑️ Remove</button>
                            </form>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <div class="section">
                <h2>📍 Location History 
                    <span style="font-size: 0.8em; color: #7f8c8d;">${locationHistory != null ? locationHistory.size() : 0} searches</span>
                </h2>
                <c:if test="${empty locationHistory}">
                    <div class="empty-state">
                        <div>📍</div>
                        <h3>No Location History</h3>
                        <p>Your searched locations will appear here</p>
                        <a href="WeatherServlet" class="btn btn-primary" style="margin-top: 15px;">Search Weather</a>
                    </div>
                </c:if>
                <c:forEach var="location" items="${locationHistory}">
                    <div class="card location-card">
                        <h3>${location.cityName}</h3>
                        <div class="location-details">
                            <c:if test="${not empty location.country}">${location.country}</c:if>
                            <c:if test="${not empty location.latitude && location.latitude != 0.0}">
                                • 📍 ${location.latitude}, ${location.longitude}
                            </c:if>
                        </div>
                        <div class="action-buttons" style="margin-top: 10px;">
                            <form action="WeatherServlet" method="get" style="display:inline;">
                                <input type="hidden" name="city" value="${location.cityName}">
                                <button type="submit" class="btn btn-primary btn-small">🌤️ Check Again</button>
                            </form>
                            <form action="DashboardServlet" method="post" style="display:inline;">
                                <input type="hidden" name="action" value="addFavorite">
                                <input type="hidden" name="cityName" value="${location.cityName}">
                                <input type="hidden" name="country" value="${location.country}">
                                <input type="hidden" name="latitude" value="${location.latitude}">
                                <input type="hidden" name="longitude" value="${location.longitude}">
                                <button type="submit" class="btn btn-success btn-small">⭐ Add Favorite</button>
                            </form>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>

    <script>
        // ✅ Auto-hide messages after 5 seconds
        setTimeout(() => {
            const messages = document.querySelectorAll('.message');
            messages.forEach(msg => {
                msg.style.opacity = '0';
                msg.style.transition = 'opacity 0.5s ease';
                setTimeout(() => msg.remove(), 500);
            });
        }, 5000);

        // ✅ Debug: Log page load
        console.log('✅ Dashboard loaded successfully');
        console.log('Favorites count:', ${favoriteCities != null ? favoriteCities.size() : 0});
        console.log('Location history count:', ${locationHistory != null ? locationHistory.size() : 0});
    </script>
</body>
</html>
