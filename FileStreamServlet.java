package com.kpr.studenthub;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Image & Document Streaming Servlet
 * KPR StudentHub — Question 3 (CO5)
 * Retrieves and streams images/documents from folder using database file path reference.
 * Author: Aafridi Ansari (24CS253)
 */
@WebServlet("/streamFile")
public class FileStreamServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String fileIdParam = request.getParameter("fileId");
        if (fileIdParam == null || fileIdParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "File ID missing");
            return;
        }

        int fileId = Integer.parseInt(fileIdParam);

        try (Connection conn = DBUtil.getConnection()) {
            String sql = "SELECT file_name, file_path, file_type FROM student_files WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, fileId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String fileName = rs.getString("file_name");
                String relativePath = rs.getString("file_path");
                String mimeType = rs.getString("file_type");

                // Base application folder path
                String appPath = getServletContext().getRealPath("");
                File file = new File(appPath + File.separator + relativePath);

                if (!file.exists()) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found on storage disk.");
                    return;
                }

                // Set MIME Type and Content headers
                response.setContentType(mimeType != null ? mimeType : "application/octet-stream");
                response.setContentLength((int) file.length());
                
                // If it's an image, render inline; if attachment/doc, stream inline or disposition
                if (mimeType != null && mimeType.startsWith("image/")) {
                    response.setHeader("Content-Disposition", "inline; filename=\"" + fileName + "\"");
                } else {
                    response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
                }

                // Stream binary content
                try (FileInputStream in = new FileInputStream(file);
                     OutputStream out = response.getOutputStream()) {
                    byte[] buffer = new byte[4096];
                    int bytesRead;
                    while ((bytesRead = in.read(buffer)) != -1) {
                        out.write(buffer, 0, bytesRead);
                    }
                }
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "File metadata not found in database.");
            }

        } catch (Exception e) {
            throw new ServletException("Error streaming file", e);
        }
    }
}
