<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Sign Up</title>
    <link rel="stylesheet" href="style.css">
</head>
<body class="auth-body">
    <div class="form-container slide-in">
        <h2>Create Account</h2>
        <form method="post" action="SignupServlet">
            <input type="text" name="username" placeholder="Username" required />
            <input type="password" name="password" placeholder="Password" required />
            <button type="submit">Sign Up</button>
            <p>Already have an account? <a href="index.jsp">Login</a></p>
            <%
                String error = (String) request.getAttribute("error");
                if (error != null && !error.trim().isEmpty()) {
            %>
                <div class="error-msg"><%= error %></div>
            <% } 
                String message = (String) request.getAttribute("message");
                if (message != null && !message.trim().isEmpty()) {
            %>
                <div class="success-msg"><%= message %></div>
            <% } %>
        </form>
    </div>
</body>
</html>
