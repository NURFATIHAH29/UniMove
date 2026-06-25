package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "GetAvailableVehiclesServlet", urlPatterns = {"/GetAvailableVehiclesServlet"})
public class GetAvailableVehiclesServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/uvbs_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "admin";

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String passengersStr = request.getParameter("passengers");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        Connection conn = null;
        PreparedStatement psVehicles = null;
        PreparedStatement psBookings = null;
        ResultSet rsVehicles = null;
        ResultSet rsBookings = null;
        
        StringBuilder jsonBuilder = new StringBuilder();
        jsonBuilder.append("[");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            int paxCount = 0;
            if (passengersStr != null && !passengersStr.trim().isEmpty()) {
                paxCount = Integer.parseInt(passengersStr);
            }

            // DIPERBAIKI LOGIK: Jika kurang atau sama dengan 10, benarkan 'Car' dan 'Lorry'. Jika lebih 10, benarkan 'Bus' dan 'Van'.
            String typeFilter = paxCount <= 10 ? "('Car', 'Lorry')" : "('Bus', 'Van')";

            // 1. SEMAK JUMLAH UNIT KENDERAAN YANG TELAH DITEMPAH DARI JADUAL BOOKINGS
            Map<String, Integer> bookedMap = new HashMap<>();
            
            String sqlBookings = "SELECT UPPER(TRIM(vehicle_type)) as v_type, SUM(vehicle_quantity) as qty " +
                                 "FROM bookings " +
                                 "WHERE status NOT IN ('Rejected', 'Cancelled', 'Completed') " +
                                 "AND (? <= end_date AND ? >= start_date) " +
                                 "GROUP BY UPPER(TRIM(vehicle_type))";
            
            psBookings = conn.prepareStatement(sqlBookings);
            psBookings.setString(1, startDate);
            psBookings.setString(2, endDate);
            rsBookings = psBookings.executeQuery();
            
            while (rsBookings.next()) {
                String vType = rsBookings.getString("v_type");
                if (vType != null) {
                    bookedMap.put(vType, rsBookings.getInt("qty"));
                }
            }

            // 2. TARIK DATA UNIK KUMPULAN KENDERAAN DARIPADA JADUAL VEHICLES
            String sqlVehicles = "SELECT type, MAX(capacity) as max_capacity, COUNT(*) as total_owned " +
                                 "FROM vehicles WHERE status != 'Maintenance' AND type IN " + typeFilter + " GROUP BY type";
            
            psVehicles = conn.prepareStatement(sqlVehicles);
            rsVehicles = psVehicles.executeQuery();
            
            boolean first = true;
            while (rsVehicles.next()) {
                String type = rsVehicles.getString("type");
                int maxCapacity = rsVehicles.getInt("max_capacity");
                int totalOwned = rsVehicles.getInt("total_owned");
                
                int totalBooked = bookedMap.getOrDefault(type.toUpperCase(), 0);
                int availableQty = totalOwned - totalBooked;

                if (availableQty <= 0) {
                    continue;
                }

                if (!first) { jsonBuilder.append(","); }
                
                jsonBuilder.append("{")
                           .append("\"type\":\"").append(type).append("\",")
                           .append("\"capacity\":").append(maxCapacity).append(",")
                           .append("\"available_qty\":").append(availableQty)
                           .append("}");
                first = false;
            }

            jsonBuilder.append("]"); // Tutup array JSON normal

        } catch (Exception e) {
            e.printStackTrace();
            // Jika berlaku ralat, kosongkan stringbuilder dan hantar JSON ralat yang bersih
            jsonBuilder = new StringBuilder();
            jsonBuilder.append("[{\"error\":\"Ralat SQL Backend: ").append(e.getMessage().replace("\"", "\\\"")).append("\"}]");
        } finally {
            try { if (rsBookings != null) rsBookings.close(); } catch (Exception e) {}
            try { if (psBookings != null) psBookings.close(); } catch (Exception e) {}
            try { if (rsVehicles != null) rsVehicles.close(); } catch (Exception e) {}
            try { if (psVehicles != null) psVehicles.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }

        try (PrintWriter out = response.getWriter()) {
            out.print(jsonBuilder.toString());
            out.flush();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }
    
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }
}