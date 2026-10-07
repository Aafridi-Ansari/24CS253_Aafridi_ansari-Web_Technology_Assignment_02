package com.kpr.studenthub;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Student Details & Profile Servlet with Session Protection
 * KPR StudentHub — Question 3 (CO5)
 * Connects to MySQL via JDBC, fetches student details, verifies session, forwards to JSP.
 * Author: Aafridi Ansari (24CS253)
 */
@WebServlet("/student")
public class StudentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 5. Ensure session handling so only logged-in users can access portal
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("index.html?error=unauthorized");
            return;
        }

        String rollParam = request.getParameter("roll");
        if (rollParam == null || rollParam.trim().isEmpty()) {
            rollParam = (String) session.getAttribute("roll_number");
        }

        try (Connection conn = DBUtil.getConnection()) {
            // 1. Fetch Student Details
            String sqlStudent = "SELECT * FROM students WHERE roll_number = ?";
            PreparedStatement psStudent = conn.prepareStatement(sqlStudent);
            psStudent.setString(1, rollParam);
            ResultSet rsStudent = psStudent.executeQuery();

            if (rsStudent.next()) {
                Map<String, Object> student = new HashMap<>();
                int studentId = rsStudent.getInt("id");
                student.put("id", studentId);
                student.put("name", rsStudent.getString("name"));
                student.put("roll_number", rsStudent.getString("roll_number"));
                student.put("email", rsStudent.getString("email"));
                student.put("phone", rsStudent.getString("phone"));
                student.put("department", rsStudent.getString("department"));
                student.put("year_of_study", rsStudent.getString("year_of_study"));
                student.put("course", rsStudent.getString("course"));
                student.put("total_fee", rsStudent.getDouble("total_fee"));

                // 1. Fetch Associated File Paths from DB
                String sqlFiles = "SELECT * FROM student_files WHERE student_id = ?";
                PreparedStatement psFiles = conn.prepareStatement(sqlFiles);
                psFiles.setInt(1, studentId);
                ResultSet rsFiles = psFiles.executeQuery();

                List<Map<String, Object>> files = new ArrayList<>();
                while (rsFiles.next()) {
                    Map<String, Object> f = new HashMap<>();
                    f.put("id", rsFiles.getInt("id"));
                    f.put("file_name", rsFiles.getString("file_name"));
                    f.put("file_path", rsFiles.getString("file_path"));
                    f.put("file_type", rsFiles.getString("file_type"));
                    f.put("upload_date", rsFiles.getTimestamp("upload_date"));
                    files.add(f);
                }

                request.setAttribute("student", student);
                request.setAttribute("files", files);

                // 3. Forward to JSP for dynamic display
                request.getRequestDispatcher("/StudentProfile.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", "Student record not found for roll: " + rollParam);
                request.getRequestDispatcher("/error.jsp").forward(request, response);
            }

        } catch (Exception e) {
            throw new ServletException("Database or Processing Error in StudentServlet", e);
        }
    }
}
