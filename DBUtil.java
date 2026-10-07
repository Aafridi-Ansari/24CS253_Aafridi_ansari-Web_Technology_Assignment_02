package com.kpr.studenthub;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * JDBC Database Utility Helper
 * KPR StudentHub — Question 3 (CO5)
 * Author: Aafridi Ansari (24CS253)
 */
public class DBUtil {
    private static final String URL = "jdbc:mysql://localhost:3306/kpr_studenthub?useSSL=false&allowPublicKeyRetrieval=true";
    private static final String USER = "root";
    private static final String PASSWORD = "";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
