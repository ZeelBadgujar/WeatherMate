package com.weathermate.model;
import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class SignupServlet extends HttpServlet {
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/weather";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASS = "";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            req.setAttribute("error", "Username and password cannot be empty!");
            RequestDispatcher rd = req.getRequestDispatcher("signup.jsp");
            rd.forward(req, res);
            return;
        }

        Connection conn = null;
        PreparedStatement checkStmt = null;
        PreparedStatement insertStmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASS);

            // Check if username already exists
            String checkQuery = "SELECT id FROM users WHERE username = ?";
            checkStmt = conn.prepareStatement(checkQuery);
            checkStmt.setString(1, username);
            rs = checkStmt.executeQuery();

            if (rs.next()) {
                req.setAttribute("error", "Username already exists!");
                RequestDispatcher rd = req.getRequestDispatcher("signup.jsp");
                rd.forward(req, res);
                return;
            }

            // Insert new user
            String insertQuery = "INSERT INTO users(username, password) VALUES(?, ?)";
            insertStmt = conn.prepareStatement(insertQuery);
            insertStmt.setString(1, username);
            insertStmt.setString(2, password);
            insertStmt.executeUpdate();

            req.setAttribute("message", "Account created successfully! Please login.");
            RequestDispatcher rd = req.getRequestDispatcher("index.jsp");
            rd.forward(req, res);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Database error: " + e.getMessage());
            RequestDispatcher rd = req.getRequestDispatcher("signup.jsp");
            rd.forward(req, res);
        } finally {
            try {
                if (rs != null) rs.close();
                if (checkStmt != null) checkStmt.close();
                if (insertStmt != null) insertStmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}