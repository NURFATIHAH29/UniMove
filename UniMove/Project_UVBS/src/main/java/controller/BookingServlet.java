package controller;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/BookingServlet")
public class BookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String ic = (String) session.getAttribute("userIC");
        
        // Semakan sesi pengguna bagi mengelakkan NullPointerException
        if (ic == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String staffName = request.getParameter("staff_name");
        String phoneNumber = request.getParameter("phone_number");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String vehicleType = request.getParameter("vehicleType"); 
        String quantityStr = request.getParameter("vehicleQuantity"); 
        String pickup = request.getParameter("pickup");
        String destination = request.getParameter("destination");
        String mapLink = request.getParameter("mapLink"); 
        String passengersStr = request.getParameter("passengers");
        String purpose = request.getParameter("purpose");
        String bookingType = request.getParameter("bookingType"); 

        String tripSlot = "Full Day"; 
        
        // ── PERBAIKAN BUG: Validasi kuantiti kenderaan ──
        int requestedQty = 1;
        try {
            if (quantityStr != null && !quantityStr.trim().isEmpty()) {
                requestedQty = Integer.parseInt(quantityStr.trim());
            }
            if (requestedQty < 1) { requestedQty = 1; }
        } catch (NumberFormatException e) {
            requestedQty = 1;
        }

        // ── PERBAIKAN BUG: Validasi bilangan penumpang bagi mengelakkan Crash ──
        int numPassengers = 0;
        try {
            if (passengersStr != null && !passengersStr.trim().isEmpty()) {
                numPassengers = Integer.parseInt(passengersStr.trim());
            }
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Ralat: Sila masukkan jumlah penumpang dalam bentuk angka yang sah.");
            response.sendRedirect("Staff/newBooking.jsp");
            return;
        }

        Connection conn = null;
        PreparedStatement psCheckStock = null;
        PreparedStatement psDriver = null;
        PreparedStatement psVehicle = null; 
        PreparedStatement psInsert = null;
        PreparedStatement psUpdateDriver = null;
        PreparedStatement psUpdateVehicle = null;
        
        ResultSet rsStock = null;
        ResultSet rsDriver = null;
        ResultSet rsVehicle = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/uvbs_db?useSSL=false&serverTimezone=UTC", "root", "admin");
            conn.setAutoCommit(false);

            // ── 1. SEMAKAN JUMLAH STOK SEMASA ──
            String checkStockSql = "SELECT COUNT(vehicle_id) - COALESCE((" +
                                   "    SELECT SUM(b.vehicle_quantity) FROM bookings b " +
                                   "    WHERE UPPER(TRIM(b.vehicle_type)) = UPPER(TRIM(?)) " +
                                   "    AND b.status NOT IN ('Rejected', 'Cancelled', 'Completed') " +
                                   "    AND (? <= b.end_date AND ? >= b.start_date)" +
                                   "), 0) as available_qty " +
                                   "FROM vehicles WHERE status != 'Maintenance' AND UPPER(TRIM(type)) = UPPER(TRIM(?))";
            
            psCheckStock = conn.prepareStatement(checkStockSql);
            psCheckStock.setString(1, vehicleType);
            psCheckStock.setString(2, startDate);
            psCheckStock.setString(3, endDate);
            psCheckStock.setString(4, vehicleType);
            rsStock = psCheckStock.executeQuery();
            
            int availableQty = 0;
            if (rsStock.next()) {
                availableQty = rsStock.getInt("available_qty");
            }
            
            if (requestedQty > availableQty) {
                conn.rollback();
                session.setAttribute("errorMessage", "Ralat: Kuantiti kenderaan tidak mencukupi! Baki semasa untuk " + vehicleType + " pada tarikh tersebut cuma tinggal " + availableQty + " buah.");
                response.sendRedirect("Staff/newBooking.jsp");
                return;
            }

            // ── 2. AUTO-ASSIGN DRIVERS (PERBAIKAN BUG: LOGIK SYARAT LUAR TERENGGANU KHAS UNTUK BAS SAHAJA) ──
            boolean isOutOfTerengganu = (destination != null && !destination.toLowerCase().contains("terengganu"));
            boolean isBus = "Bus".equalsIgnoreCase(vehicleType);
            
            // Perjalanan luar Terengganu HANYA memerlukan 2 pemandu bagi setiap unit jika jenis kenderaan adalah "Bus"
            int requiredDriversQty = (isOutOfTerengganu && isBus) ? (requestedQty * 2) : requestedQty;

            List<Integer> allocatedDriverIds = new ArrayList<>();
            String licenseFilter = "%D%";
            if (isBus || "Lori".equalsIgnoreCase(vehicleType) || "Lorry".equalsIgnoreCase(vehicleType)) {
                licenseFilter = "%E%";
            }
            
            String driverSql = "SELECT d.driver_id FROM drivers d " +
                               "WHERE UPPER(TRIM(d.license_class)) LIKE ? " +
                               "AND d.status != 'OFF DUTY' " + 
                               "AND d.driver_id NOT IN (" +
                               "    SELECT DISTINCT d2.driver_id " +
                               "    FROM bookings b " +
                               "    JOIN drivers d2 ON FIND_IN_SET(d2.driver_id, b.assigned_driver_id) > 0 " +
                               "    WHERE b.status NOT IN ('Rejected', 'Cancelled', 'Completed') " +
                               "    AND (? <= b.end_date AND ? >= b.start_date)" +
                               ") LIMIT ?";
            
            psDriver = conn.prepareStatement(driverSql);
            psDriver.setString(1, licenseFilter);
            psDriver.setString(2, startDate);
            psDriver.setString(3, endDate);
            psDriver.setInt(4, requiredDriversQty); 
            rsDriver = psDriver.executeQuery();
            
            while (rsDriver.next()) {
                allocatedDriverIds.add(rsDriver.getInt("driver_id"));
            }

            if (allocatedDriverIds.size() < requiredDriversQty) {
                conn.rollback();
                String msg = (isOutOfTerengganu && isBus) ? 
                    "Error: Insufficient drivers available. Bus trips outside of Terengganu require 2 drivers per vehicle (" + requiredDriversQty + " drivers needed)." : 
                    "Error: Insufficient drivers available for the requested vehicle quantity on these dates.";
                session.setAttribute("errorMessage", msg);
                response.sendRedirect("Staff/newBooking.jsp");
                return;
            }

            // ── 3. AUTO-ASSIGN VEHICLES ──
            List<Integer> allocatedVehicleIds = new ArrayList<>();
            String vehicleSql = "SELECT v.vehicle_id FROM vehicles v " +
                               "WHERE UPPER(TRIM(v.type)) = UPPER(TRIM(?)) AND v.status != 'Maintenance' " +
                               "AND v.vehicle_id NOT IN (" +
                               "    SELECT DISTINCT b.assigned_vehicle_id FROM bookings b " +
                               "    WHERE b.assigned_vehicle_id IS NOT NULL " +
                               "    AND b.status NOT IN ('Rejected', 'Cancelled', 'Completed') " +
                               "    AND (? <= b.end_date AND ? >= b.start_date) " +
                               ") LIMIT ?";
            
            psVehicle = conn.prepareStatement(vehicleSql);
            psVehicle.setString(1, vehicleType);
            psVehicle.setString(2, startDate);
            psVehicle.setString(3, endDate);
            psVehicle.setInt(4, requestedQty);
            rsVehicle = psVehicle.executeQuery();
            
            while (rsVehicle.next()) {
                allocatedVehicleIds.add(rsVehicle.getInt("vehicle_id"));
            }
            
            // Semakan tambahan keselamatan data sebelum pembentangan rentetan
            if (allocatedVehicleIds.size() < requestedQty) {
                conn.rollback();
                session.setAttribute("errorMessage", "Error: Data inconsistency. Vehicles suddenly unavailable.");
                response.sendRedirect("Staff/newBooking.jsp");
                return;
            }

            // ── 4. GABUNGKAN ID KEPADA FORMAT KOMA (Contoh: Vehicle "1,2", Driver "5,6") ──
            StringBuilder vehicleIdsStr = new StringBuilder();
            StringBuilder driverIdsStr = new StringBuilder();
            
            for (int i = 0; i < requestedQty; i++) {
                if (i > 0) vehicleIdsStr.append(",");
                vehicleIdsStr.append(allocatedVehicleIds.get(i));
            }

            for (int i = 0; i < requiredDriversQty; i++) {
                if (i > 0) driverIdsStr.append(",");
                driverIdsStr.append(allocatedDriverIds.get(i));
            }

            // ── 5. INSERT SATU REKOD SAHAJA KEDALAM DATABASE ──
            String insertSql = "INSERT INTO bookings (user_id, staff_name, phone_number, vehicle_type, start_date, end_date, "
                             + "trip_slot, pickup_location, destination, map_link, passengers, purpose, "
                             + "status, assigned_vehicle_id, assigned_driver_id, vehicle_quantity) "
                             + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            psInsert = conn.prepareStatement(insertSql);
            
            psInsert.setString(1, ic);
            psInsert.setString(2, staffName);      
            psInsert.setString(3, phoneNumber);    
            psInsert.setString(4, vehicleType);    
            psInsert.setString(5, startDate);
            psInsert.setString(6, endDate);
            psInsert.setString(7, tripSlot);
            psInsert.setString(8, pickup);
            psInsert.setString(9, destination);
            psInsert.setString(10, mapLink); 
            psInsert.setInt(11, numPassengers); 
            
            if ("EMERGENCY".equals(bookingType)) {
                psInsert.setString(12, "[EMERGENCY] " + purpose);
            } else {
                psInsert.setString(12, purpose);
            }

            psInsert.setString(13, "Confirmed");
            psInsert.setString(14, vehicleIdsStr.toString()); 
            psInsert.setString(15, driverIdsStr.toString());  
            psInsert.setInt(16, requestedQty); 
            
            psInsert.executeUpdate();
            
            // ── 6. UPDATE STATUS DRIVER & VEHICLE
            String updateDriverSql = "UPDATE drivers SET status = 'AVAILABLE' WHERE driver_id = ?";
            psUpdateDriver = conn.prepareStatement(updateDriverSql);
            for (int i = 0; i < requiredDriversQty; i++) {
                psUpdateDriver.setInt(1, allocatedDriverIds.get(i));
                psUpdateDriver.executeUpdate();
            }

            String updateVehicleSql = "UPDATE vehicles SET status = 'Available' WHERE vehicle_id = ?";
            psUpdateVehicle = conn.prepareStatement(updateVehicleSql);
            for (int i = 0; i < requestedQty; i++) {
                psUpdateVehicle.setInt(1, allocatedVehicleIds.get(i));
                psUpdateVehicle.executeUpdate();
            }
            
            conn.commit();
            response.sendRedirect("Staff/staffDashboard.jsp?success=booked");
            
        } catch (Exception e) {
            if (conn != null) { try { conn.rollback(); } catch (SQLException ex) {} }
            e.printStackTrace();
            response.getWriter().print("Operational Error: " + e.getMessage());
        } finally {
            try { if (rsStock != null) rsStock.close(); } catch (Exception e) {}
            try { if (rsDriver != null) rsDriver.close(); } catch (Exception e) {}
            try { if (rsVehicle != null) rsVehicle.close(); } catch (Exception e) {}
            try { if (psCheckStock != null) psCheckStock.close(); } catch (Exception e) {}
            try { if (psDriver != null) psDriver.close(); } catch (Exception e) {}
            try { if (psVehicle != null) psVehicle.close(); } catch (Exception e) {}
            try { if (psInsert != null) psInsert.close(); } catch (Exception e) {}
            try { if (psUpdateDriver != null) psUpdateDriver.close(); } catch (Exception e) {}
            try { if (psUpdateVehicle != null) psUpdateVehicle.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}