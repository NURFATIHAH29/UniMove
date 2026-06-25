
<%-- 
    Document   : processVehicle
    Created on : 2 May 2026, 12:10:37 pm
    Author     : fatih
--%>

<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 1. Ambil data dari form manageVehicle.jsp
    String model = request.getParameter("model");
    String plate = request.getParameter("plate");
    String type = request.getParameter("type");
    String capacityStr = request.getParameter("capacity");

    // 2. Database Connection Config
    String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
    String dbUser = "root";
    String dbPass = "admin"; // Ikut password XAMPP kau

    if (model != null && plate != null && capacityStr != null) {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            // 3. Load Driver & Connect
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // 4. SQL Query (Sesuai dengan table vehicles yang kita buat tadi)
            String sql = "INSERT INTO vehicles (model, plate_number, type, capacity, status) VALUES (?, ?, ?, ?, 'Available')";
            
            ps = conn.prepareStatement(sql);
            ps.setString(1, model);
            ps.setString(2, plate.toUpperCase()); // Paksa plate jadi huruf besar
            ps.setString(3, type);
            ps.setInt(4, Integer.parseInt(capacityStr));

            // 5. Execute Update
            int rowAffected = ps.executeUpdate();

            if (rowAffected > 0) {
                // Berjaya! Redirect balik ke page management
                response.sendRedirect("manageVehicle.jsp?success=1");
            } else {
                out.println("Failed to register vehicle.");
            }

        } catch (Exception e) {
            // Kalau plate number duplicate, dia akan masuk sini sebab kita set UNIQUE tadi
            out.println("Error: " + e.getMessage());
            out.println("<br><a href='manageVehicle.jsp'>Back to Management</a>");
        } finally {
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        }
    } else {
        response.sendRedirect("manageVehicle.jsp");
    }
%>