<%-- 
    Document   : updateBookingStatus
    Created on : 2 May 2026, 2:34:05 am
    Author     : fatihah
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String bID = request.getParameter("booking_id");
    String nStatus = request.getParameter("new_status");

    if (bID != null && nStatus != null) {
        String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
        String dbUser = "root";
        String dbPass = "admin";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            String sql = "UPDATE bookings SET status = ? WHERE booking_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, nStatus);
            ps.setInt(2, Integer.parseInt(bID));
            
            ps.executeUpdate();
            ps.close();
            conn.close();
            
            // Redirect balik ke page approvals
            response.sendRedirect("adminApprovals.jsp");
        } catch (Exception e) {
            out.println("Update Error: " + e.getMessage());
        }
    }
%>

