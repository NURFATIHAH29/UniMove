<%-- 
    Document   : updateDriver
    Created on : 17 Jun 2026, 2:06:35 pm
    Author     : fatih
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String staffId = request.getParameter("staff_id");
    String name = request.getParameter("name");
    String phone = request.getParameter("phone");
    String license = request.getParameter("license");
    String expiry = request.getParameter("license_expiration");
    String emergency = request.getParameter("emergency_contact");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection c = DriverManager.getConnection("jdbc:mysql://localhost:3306/uvbs_db", "root", "admin");
        
        String query = "UPDATE drivers SET full_name=?, phone_number=?, license_class=?, license_expiration=?, emergency_contact=? WHERE staff_id=?";
        PreparedStatement ps = c.prepareStatement(query);
        ps.setString(1, name);
        ps.setString(2, phone);
        ps.setString(3, license);
        ps.setString(4, expiry);
        ps.setString(5, emergency);
        ps.setString(6, staffId);
        
        ps.executeUpdate();
        c.close();
    } catch(Exception e) {
        e.printStackTrace();
    }
    response.sendRedirect("manageDrivers.jsp");
%>