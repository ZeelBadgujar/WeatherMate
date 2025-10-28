<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html>
<head>
    <title>Error - WeatherMate</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            color: white;
        }
        .error-container {
            background: rgba(255, 255, 255, 0.95);
            color: #333;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            text-align: center;
            max-width: 500px;
        }
        h1 { color: #e74c3c; margin-bottom: 20px; }
        .btn {
            background: #3498db;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            text-decoration: none;
            display: inline-block;
            margin-top: 20px;
            cursor: pointer;
        }
        .btn:hover { background: #2980b9; }
    </style>
</head>
<body>
    <div class="error-container">
        <h1>⚠️ Oops! Something went wrong</h1>
        <p>We're sorry, but an error occurred while processing your request.</p>
        
        <% if (exception != null) { %>
            <p style="font-size: 14px; color: #666; margin-top: 15px;">
                <strong>Error:</strong> <%= exception.getMessage() %>
            </p>
        <% } %>
        
        <a href="index.jsp" class="btn">🏠 Return to Login</a>
        <a href="WeatherServlet" class="btn" style="background: #27ae60;">🌤️ Go to Weather</a>
    </div>
</body>
</html>
