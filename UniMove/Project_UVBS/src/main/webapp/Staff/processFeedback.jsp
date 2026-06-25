<%-- 
    Document   : processFeedback
    Created on : 18 May 2026, 12:24:43 am
    Author     : fatihah
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 1. Ambil data dari form feedback.jsp
    String userId = request.getParameter("user_id");
    String category = request.getParameter("category");
    String subject = request.getParameter("subject");
    String message = request.getParameter("message");

    // 2. Database Configuration
    String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
    String dbUser = "root";
    String dbPass = "admin"; 

    // Pastikan data penting tidak kosong
    if (category != null && subject != null && message != null && !message.trim().isEmpty()) {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // SQL untuk simpan maklum balas staff
            String sql = "INSERT INTO feedbacks (user_id, category, subject, message) VALUES (?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, userId);
            ps.setString(2, category);
            ps.setString(3, subject);
            ps.setString(4, message);

            int rowAffected = ps.executeUpdate();

            if (rowAffected > 0) {
                //Hantar balik ke feedback.jsp dengan flag success
                response.sendRedirect("feedback.jsp?success=1");
            } else {
                out.println("<script>alert('Failed to submit feedback. Please try again.'); window.history.back();</script>");
            }

        } catch (Exception e) {
            out.println("<script>alert('Database Error: " + e.getMessage() + "'); window.history.back();</script>");
            e.printStackTrace();
        } finally {
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        }
    } else {
        // Kalau user cuba access file ni secara direct tanpa isi form
        response.sendRedirect("feedback.jsp");
    }
%>