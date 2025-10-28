package com.weathermate.model;
import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class LoginServlet extends HttpServlet {
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/weather";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASS = "";

    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        String user = req.getParameter("username");
        String pass = req.getParameter("password");

        System.out.println("=== LoginServlet Debug ===");
        System.out.println("Login attempt for user: " + user);

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASS)) {
                PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE username=? AND password=?");
                ps.setString(1, user);
                ps.setString(2, pass);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    // Create User object
                    User userObj = new User();
                    userObj.setId(rs.getInt("id"));
                    userObj.setUsername(rs.getString("username"));
                    userObj.setPassword(rs.getString("password"));

                    // Get or create session
                    HttpSession session = req.getSession(true);
                    session.setAttribute("user", userObj);
                    session.setMaxInactiveInterval(30 * 60); // 30 minutes

                    System.out.println("✅ Login successful!");
                    System.out.println("✅ User ID: " + userObj.getId());
                    System.out.println("✅ Username: " + userObj.getUsername());
                    System.out.println("✅ Session ID: " + session.getId());
                    System.out.println("✅ Session timeout: " + session.getMaxInactiveInterval() + " seconds");

                    // Redirect to WeatherServlet
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