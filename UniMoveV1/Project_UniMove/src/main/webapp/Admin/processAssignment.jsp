<%-- 
    Document   : processAssignment
    Created on : 2 May 2026, 2:30:59 pm
    Author     : fatih
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 1. Ambil data dari form 
    String bookingId = request.getParameter("booking_id");
    String vehicleId = request.getParameter("vehicle_id");
    String driverId = request.getParameter("driver_id"); 
    String action = request.getParameter("btnAction");

    // 2. Database Config
    String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
    String dbUser = "root";
    String dbPass = "admin";

    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
        conn.setAutoCommit(false); 

        if ("approve".equalsIgnoreCase(action)) {
            //Update status booking + Assign Vehicle + Assign Driver
            String sqlBooking = "UPDATE bookings SET status='Approved', assigned_vehicle_id=?, assigned_driver_id=? WHERE booking_id=?";
            PreparedStatement ps1 = conn.prepareStatement(sqlBooking);
            ps1.setInt(1, Integer.parseInt(vehicleId));
            ps1.setInt(2, Integer.parseInt(driverId)); 
            ps1.setInt(3, Integer.parseInt(bookingId));
            ps1.executeUpdate();

            //Update status kenderaan jadi 'In-Use'
            String sqlVehicle = "UPDATE vehicles SET status='In-Use' WHERE vehicle_id=?";
            PreparedStatement ps2 = conn.prepareStatement(sqlVehicle);
            ps2.setInt(1, Integer.parseInt(vehicleId));
            ps2.executeUpdate();

            //Update status driver jadi 'ON TRIP'
            String sqlDriver = "UPDATE drivers SET status='ON TRIP' WHERE driver_id=?";
            PreparedStatement ps3 = conn.prepareStatement(sqlDriver);
            ps3.setInt(1, Integer.parseInt(driverId));
            ps3.executeUpdate();

            conn.commit(); 
            response.sendRedirect("adminApprovals.jsp?msg=ApprovedSuccessfully");

        } else if ("reject".equalsIgnoreCase(action)) {
            String sqlReject = "UPDATE bookings SET status='Rejected' WHERE booking_id=?";
            PreparedStatement ps4 = conn.prepareStatement(sqlReject);
            ps4.setInt(1, Integer.parseInt(bookingId));
            ps4.executeUpdate();
            
            conn.commit();
            response.sendRedirect("adminApprovals.jsp?msg=RejectedSuccessfully");
        }

    } catch (Exception e) {
        if (conn != null) conn.rollback(); 
        out.println("Error Detail: " + e.getMessage());
    } finally {
        if (conn != null) conn.close();
    }
%>