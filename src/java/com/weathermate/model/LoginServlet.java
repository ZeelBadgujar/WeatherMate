package com.weathermate.model;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class LoginServlet extends HttpServlet {

    // ✅ Use your Render PostgreSQL database URL
    private static final String JDBC_URL = "jdbc:postgresql://dpg-d405n67diees73ajmcb0-a.singapore-postgres.render.com/weathermate?sslmode=require";
    private static final String JDBC_USER = "weathermate_user";
    private static final String JDBC_PASS = "izD40YsOV495aSYPHin5jMrndAkynrrU";

    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        String user = req.getParameter("username");
        String pass = req.getParameter("password");

        System.out.println("=== LoginServlet Debug ===");
        System.out.println("Login attempt for user: " + user);

        try {
            // ✅ Load PostgreSQL driver
            Class.forName("org.postgresql.Driver");

            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASS)) {
                // ✅ PostgreSQL query is same as MySQL here
                String sql = "SELECT * FROM users WHERE username = ? AND password = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, user);
                ps.setString(2, pass);

                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    // Create User object
                    User userObj = new User();
                    userObj.setId(rs.getInt("id"));
                    userObj.setUsername(rs.getString("username"));
                    userObj.setPassword(rs.getString("password"));

                    // Create or get session
                    HttpSession session = req.getSession(true);
                    session.setAttribute("user", userObj);
                    session.setMaxInactiveInterval(30 * 60); // 30 minutes

                    System.out.println("✅ Login successful!");
                    System.out.println("✅ User ID: " + userObj.getId());
                    System.out.println("✅ Username: " + userObj.getUsername());
                    System.out.println("✅ Session ID: " + session.getId());
                    System.out.println("✅ Session timeout: " + session.getMaxInactiveInterval() + " seconds");

                    // Redirect to main page or servlet
                    res.sendRedirect("WeatherServlet");
                } else {
                    System.out.println("❌ Invalid credentials");
                    req.setAttribute("error", "Invalid username or password!");
                    RequestDispatcher rd = req.getRequestDispatcher("index.jsp");
                    rd.forward(req, res);
                }
            }

        } catch (Exception e) {
            System.err.println("❌ Login error: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "Database error: " + e.getMessage());
            RequestDispatcher rd = req.getRequestDispatcher("index.jsp");
            rd.forward(req, res);
        }
    }
}
