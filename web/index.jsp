<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login</title>
    <link rel="stylesheet" href="style.css">
</head>
<body class="auth-body">
    <div class="form-container slide-in">
        <h2>Welcome Back</h2>
        <form method="post" action="LoginServlet">
            <input type="text" name="username" placeholder="Username" required />
            <input type="password" name="password" placeholder="Password" required />
            <button type="submit">Login</button>
            <p>Don't have an account? <a href="signup.jsp">Sign Up</a></p>
            
            <% 
                String error = (String) request.getAttribute("error");
                if (error != null && !error.trim().isEmpty()) { 
            %>
                <div class="error-msg"><%= error %></div>
            <% 
                } 
                String message = (String) request.getAttribute("message");
                if (message != null && !message.trim().isEmpty()) { 
            %>
                <div class="success-msg"><%= message %></div>
            <% } %>
        </form>
    </div>
</body>
</html>
