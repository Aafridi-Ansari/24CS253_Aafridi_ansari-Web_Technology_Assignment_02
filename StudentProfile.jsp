<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    // Session Verification
    if (session == null || session.getAttribute("user_id") == null) {
        response.sendRedirect("index.html?error=unauthorized");
        return;
    }
    
    Map<String, Object> student = (Map<String, Object>) request.getAttribute("student");
    List<Map<String, Object>> files = (List<Map<String, Object>>) request.getAttribute("files");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Dynamic Student Profile — KPR StudentHub (JSP / Servlet)</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body style="background: #F8FAFC; color: #0F172A;">
  <header class="site-header">
    <div class="container header-inner">
      <div class="brand-logo">
        <div class="brand-icon">🎓</div>
        <span>KPR StudentHub</span>
        <span class="brand-badge">JSP / Servlet View</span>
      </div>
      <div class="header-actions">
        <span style="font-size:0.88rem; font-weight:600; color:#64748B;">User: <%= session.getAttribute("username") %></span>
        <a href="portal.html" class="btn btn-secondary">Student Dashboard</a>
        <a href="index.html?action=logout" class="btn btn-danger" style="padding:0.45rem 0.9rem; font-size:0.82rem;">Sign Out</a>
      </div>
    </div>
  </header>

  <main class="container" style="padding-top: 2.5rem; padding-bottom: 3.5rem;">
    <% if (student != null) { %>
      <div class="card" style="max-width: 900px; margin: 0 auto; box-shadow: var(--shadow-lg);">
        <div class="card-header" style="display:flex; align-items:center; justify-content:space-between;">
          <h2 style="font-size: 1.5rem; color: var(--text-dark);">
            Academic Student Record: <%= student.get("name") %>
          </h2>
          <span class="badge badge-success">Enrolled Active</span>
        </div>

        <div style="display: grid; grid-template-columns: 200px 1fr; gap: 2rem; margin-top: 1.5rem;">
          <!-- 3. Profile Image Dynamic Stream via Servlet -->
          <div style="text-align: center;">
            <% 
              Integer profileImgId = null;
              if (files != null) {
                for (Map<String, Object> f : files) {
                  String mime = (String) f.get("file_type");
                  if (mime != null && mime.startsWith("image/")) {
                    profileImgId = (Integer) f.get("id");
                    break;
                  }
                }
              }
            %>
            <div style="width: 160px; height: 160px; border-radius: 50%; overflow: hidden; margin: 0 auto 1rem; border: 4px solid #EDE9FE; box-shadow: var(--shadow-md);">
              <% if (profileImgId != null) { %>
                <!-- Pointing dynamically to FileStreamServlet -->
                <img src="streamFile?fileId=<%= profileImgId %>" alt="<%= student.get("name") %>" style="width: 100%; height: 100%; object-fit: cover;">
              <% } else { %>
                <div style="width:100%; height:100%; background: #EDE9FE; color:#7C3AED; display:flex; align-items:center; justify-content:center; font-size:3.5rem; font-weight:700;">
                  <%= String.valueOf(student.get("name")).substring(0, 1) %>
                </div>
              <% } %>
            </div>
            <p style="font-size: 0.85rem; color: var(--text-muted); font-weight: 600;"><%= student.get("roll_number") %></p>
          </div>

          <!-- Student Meta Details -->
          <div>
            <table class="custom-table" style="margin-bottom: 1.5rem;">
              <tbody>
                <tr>
                  <th style="width: 30%;">Full Name</th>
                  <td><strong><%= student.get("name") %></strong></td>
                </tr>
                <tr>
                  <th>Roll / Reg Number</th>
                  <td><span class="badge badge-primary"><%= student.get("roll_number") %></span></td>
                </tr>
                <tr>
                  <th>Department</th>
                  <td><%= student.get("department") %></td>
                </tr>
                <tr>
                  <th>Year of Study</th>
                  <td><%= student.get("year_of_study") %></td>
                </tr>
                <tr>
                  <th>Official Email</th>
                  <td><%= student.get("email") %></td>
                </tr>
                <tr>
                  <th>Phone</th>
                  <td><%= student.get("phone") %></td>
                </tr>
                <tr>
                  <th>Course / Degree</th>
                  <td><%= student.get("course") %></td>
                </tr>
                <tr>
                  <th>Total Fee Calculated</th>
                  <td><strong style="color: #059669;">₹<%= String.format("%,.2f", student.get("total_fee")) %></strong></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- 4. Looping and Conditional Logic for Uploaded Files -->
        <div style="margin-top: 2rem; border-top: 1px solid var(--border-color); padding-top: 1.5rem;">
          <h3 style="font-size: 1.2rem; margin-bottom: 1rem; color: var(--text-dark);">
            Uploaded Student Documents & Identity Proofs
          </h3>
          <% if (files != null && !files.isEmpty()) { %>
            <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 1rem;">
              <% for (Map<String, Object> fileItem : files) { %>
                <div style="background: #F8FAFC; border: 1px solid var(--border-color); border-radius: var(--r-md); padding: 1rem; display: flex; align-items: center; justify-content: space-between;">
                  <div>
                    <strong style="font-size: 0.88rem; display:block; color: var(--text-dark);"><%= fileItem.get("file_name") %></strong>
                    <span style="font-size: 0.75rem; color: var(--text-muted);"><%= fileItem.get("file_type") %></span>
                  </div>
                  <a href="streamFile?fileId=<%= fileItem.get("id") %>" target="_blank" class="btn btn-secondary" style="padding: 0.35rem 0.75rem; font-size: 0.75rem;">
                    View / Download
                  </a>
                </div>
              <% } %>
            </div>
          <% } else { %>
            <p style="font-size: 0.88rem; color: var(--text-muted); font-style: italic;">
              No documents uploaded for this student record yet.
            </p>
          <% } %>
        </div>
      </div>
    <% } else { %>
      <div class="card" style="text-align: center; padding: 3rem;">
        <h3>No Student Record Loaded</h3>
        <p>Please pass a valid roll number parameter or log in to view.</p>
      </div>
    <% } %>
  </main>
</body>
</html>
