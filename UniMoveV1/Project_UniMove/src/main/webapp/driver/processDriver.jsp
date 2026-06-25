<%-- 
    Document   : processDriver
    Created on : 2 May 2026, 2:46:53 pm
    Author     : fatih
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 1. Ambil semua parameter input dari form manageDriver.jsp
    String name = request.getParameter("name");
    String staffId = request.getParameter("staff_id");
    String license = request.getParameter("license");
    String licenseExpiration = request.getParameter("license_expiration"); // Ambil data tarikh
    String phone = request.getParameter("phone");
    String emergencyContact = request.getParameter("emergency_contact"); // Ambil data hubungan kecemasan

    // --- LOGIC AUTO PASSWORD BARU ---
    // Ambil nama, tukar ke lowercase, buang space
    String cleanName = (name != null) ? name.toLowerCase().replaceAll("\\s+", "") : "driver";
    String dynamicPass = cleanName + "123"; 
    
    String email = staffId.toLowerCase() + "@umt.edu.my"; 

    String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
    String dbUser = "root";
    String dbPass = "admin"; 

    if (name != null && !name.trim().isEmpty() && staffId != null && !staffId.trim().isEmpty()) {
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            conn.setAutoCommit(false);

            // 2. Kemas kini SQL Query untuk memasukkan license_expiration dan emergency_contact
            String sqlDriver = "INSERT INTO drivers (full_name, staff_id, license_class, license_expiration, phone_number, emergency_contact, status) VALUES (?, ?, ?, ?, ?, ?, 'READY')";
            PreparedStatement psDriver = conn.prepareStatement(sqlDriver);
            psDriver.setString(1, name);
            psDriver.setString(2, staffId);
            psDriver.setString(3, license);
            psDriver.setString(4, licenseExpiration); // Memasukkan tarikh luput
            psDriver.setString(5, phone);
            psDriver.setString(6, emergencyContact);   // Memasukkan nombor kecemasan
            psDriver.executeUpdate();

            // Simpan ke users 
            String sqlUser = "INSERT INTO users (user_id, full_name, email, password, role, status) VALUES (?, ?, ?, ?, 'driver', 'APPROVED')";
            PreparedStatement psUser = conn.prepareStatement(sqlUser);
            psUser.setString(1, staffId); 
            psUser.setString(2, name);
            psUser.setString(3, email);
            psUser.setString(4, dynamicPass); 
            psUser.executeUpdate();

            conn.commit();
            response.sendRedirect("manageDrivers.jsp?success=1");

        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            out.println("<script>alert('Error: " + e.getMessage().replace("'", "\\'") + "'); window.history.back();</script>");
        } finally {
            if (conn != null) conn.close();
        }
    }
%>