package com.weathermate.model;

import java.sql.*;

public class DBUtil {
    private static final String URL = "jdbc:postgresql://dpg-d405n67diees73ajmcb0-a.singapore-postgres.render.com/weathermate?sslmode=require";
    private static final String USER = "weathermate_user";
    private static final String PASSWORD = "izD40YsOV495aSYPHin5jMrndAkynrrU";

    static {
        try {
            Class.forName("org.postgresql.Driver");
            System.out.println("✅ PostgreSQL Driver loaded successfully");
        } catch (ClassNotFoundException e) {
            System.err.println("❌ PostgreSQL Driver not found!");
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("✅ PostgreSQL connection established");
            return conn;
        } catch (SQLException e) {
            System.err.println("❌ Database connection failed: " + e.getMessage());
            throw e;
        }
    }
}
