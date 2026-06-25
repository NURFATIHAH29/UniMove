package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/AdminDeleteBookingServlet")
public class AdminDeleteBookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. Retrieve parameters from the Admin cancellation form
        String bookingIdStr = request.getParameter("booking_id");
        String staffIC = request.getParameter("staff_ic");
        String staffEmail = request.getParameter("staff_email");
        String reason = request.getParameter("reason");

        // Basic validation for empty input
        if (bookingIdStr == null || staffIC == null || reason == null || reason.trim().isEmpty()) {
            response.sendRedirect("Admin/adminDashboard.jsp?status=invalid_input");
            return;
        }

        int bookingId = Integer.parseInt(bookingIdStr.trim());
        Connection conn = null;
        
        PreparedStatement psSelect = null;
        PreparedStatement psUpdateBooking = null;
        PreparedStatement psUpdateDriver = null;
        PreparedStatement psUpdateVehicle = null;
        PreparedStatement psInsertNotif = null;
        
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/uvbs_db?useSSL=false&serverTimezone=UTC", "root", "admin");
            conn.setAutoCommit(false); // Start transaction

            // 2. Fetch driver & vehicle information stored within this booking record
            String selectSql = "SELECT assigned_driver_id, assigned_vehicle_id, vehicle_type FROM bookings WHERE booking_id = ?";
            psSelect = conn.prepareStatement(selectSql);
            psSelect.setInt(1, bookingId);
            rs = psSelect.executeQuery();
            
            String driverIds = "";
            String vehicleIds = "";
            String vehicleType = "";
            
            if (rs.next()) {
                driverIds = rs.getString("assigned_driver_id");
                vehicleIds = rs.getString("assigned_vehicle_id");
                vehicleType = rs.getString("vehicle_type");
            } else {
                // If the booking record does not exist in the database
                conn.rollback();
                response.sendRedirect("Admin/adminDashboard.jsp?status=not_found");
                return;
            }

            // 3. Update the original booking status to 'Cancelled by Admin'
            String updateBookingSql = "UPDATE bookings SET status = 'Cancelled by Admin' WHERE booking_id = ?";
            psUpdateBooking = conn.prepareStatement(updateBookingSql);
            psUpdateBooking.setInt(1, bookingId);
            psUpdateBooking.executeUpdate();

            // 4. Reset Driver status back to 'AVAILABLE' (Use FIND_IN_SET to handle comma-separated IDs like "1,2")
            if (driverIds != null && !driverIds.trim().isEmpty()) {
                String updateDriverSql = "UPDATE drivers SET status = 'AVAILABLE' WHERE FIND_IN_SET(driver_id, ?)";
                psUpdateDriver = conn.prepareStatement(updateDriverSql);
                psUpdateDriver.setString(1, driverIds);
                psUpdateDriver.executeUpdate();
            }

            // 5. Reset Vehicle status back to 'Available'
            if (vehicleIds != null && !vehicleIds.trim().isEmpty()) {
                String updateVehicleSql = "UPDATE vehicles SET status = 'Available' WHERE FIND_IN_SET(vehicle_id, ?)";
                psUpdateVehicle = conn.prepareStatement(updateVehicleSql);
                psUpdateVehicle.setString(1, vehicleIds);
                psUpdateVehicle.executeUpdate();
            }

            // 6. Insert critical warning message into the `notifications` table for the staff dashboard pop-up display
            String notificationMessage = "CRITICAL WARNING: Your booking (Booking ID: #" + bookingId + " for vehicle " + vehicleType + ") has been cancelled by the Admin due to: " + reason;
            String insertNotifSql = "INSERT INTO notifications (user_id, booking_id, message, is_read) VALUES (?, ?, ?, 0)";
            psInsertNotif = conn.prepareStatement(insertNotifSql);
            psInsertNotif.setString(1, staffIC);
            psInsertNotif.setInt(2, bookingId);
            psInsertNotif.setString(3, notificationMessage);
            psInsertNotif.executeUpdate();

            // All database operations succeeded, execute commit!
            conn.commit();

            response.sendRedirect("Admin/adminDashboard.jsp?status=deleted");

        } catch (Exception e) {
            // If any SQL/Database error occurs, roll back all data modifications
            if (conn != null) { 
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); } 
            }
            e.printStackTrace();
            response.getWriter().print("Operational Error on Deletion: " + e.getMessage());
        } finally {
            // Close all JDBC objects to prevent memory leaks
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (psSelect != null) psSelect.close(); } catch (Exception e) {}
            try { if (psUpdateBooking != null) psUpdateBooking.close(); } catch (Exception e) {}
            try { if (psUpdateDriver != null) psUpdateDriver.close(); } catch (Exception e) {}
            try { if (psUpdateVehicle != null) psUpdateVehicle.close(); } catch (Exception e) {}
            try { if (psInsertNotif != null) psInsertNotif.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }

    
}