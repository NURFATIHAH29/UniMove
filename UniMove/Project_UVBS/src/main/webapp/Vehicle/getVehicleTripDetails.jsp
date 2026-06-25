<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    String bookingIdStr = request.getParameter("bid");
    String vehicleIdStr = request.getParameter("vid");
    
    // Jika kedua-dua parameter kosong, barulah keluar ralat
    if ((bookingIdStr == null || bookingIdStr.trim().isEmpty()) && (vehicleIdStr == null || vehicleIdStr.trim().isEmpty())) {
        out.print("<p class='text-center text-xs text-red-500 font-mono p-4'>❌ Error: Missing identification parameter (bid/vid).</p>");
        return;
    }

    String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
    String dbUser = "root";
    String dbPass = "admin";

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        int targetBookingId = 0;

        // ── 1. LOGIK UNTUK MENCARI BOOKING ID JIKA PARAMETER ADALAH VEHICLE ID (vid) ──
        if (vehicleIdStr != null && !vehicleIdStr.trim().isEmpty()) {
            String findBookingSql = "SELECT booking_id FROM bookings "
                                  + "WHERE status = 'Confirmed' AND FIND_IN_SET(?, assigned_vehicle_id) > 0 "
                                  + "ORDER BY booking_id DESC LIMIT 1";
            PreparedStatement psFind = conn.prepareStatement(findBookingSql);
            psFind.setInt(1, Integer.parseInt(vehicleIdStr.trim()));
            ResultSet rsFind = psFind.executeQuery();
            if (rsFind.next()) {
                targetBookingId = rsFind.getInt("booking_id");
            }
            rsFind.close();
            psFind.close();
            
            // Jika tiada booking aktif dijumpai untuk kenderaan ini
            if (targetBookingId == 0) {
                out.print("<div class='p-4 text-center'><p class='text-amber-600 font-bold text-xs uppercase'>ℹ️ No active confirmed booking tied to this vehicle right now.</p></div>");
                return;
            }
        } else {
            // Jika memang sedia menerima 'bid' dari Booking Approvals page
            targetBookingId = Integer.parseInt(bookingIdStr.trim());
        }

        // ── 2. QUERY UTAMA: DAPATKAN MAKLUMAT ASAS BOOKING SAHAJA ──
        String sql = "SELECT b.* FROM bookings b WHERE b.booking_id = ?";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, targetBookingId);
        rs = ps.executeQuery();

        if (rs.next()) {
            String staffName = rs.getString("staff_name") != null ? rs.getString("staff_name") : "N/A";
            String staffPhone = rs.getString("phone_number") != null ? rs.getString("phone_number") : "N/A";
            String pickup = rs.getString("pickup_location") != null ? rs.getString("pickup_location") : "-";
            String destination = rs.getString("destination") != null ? rs.getString("destination") : "-";
            int passengers = rs.getInt("passengers");
            
            // DIUBAHSUAI: Tarik data purpose dari database bookings
            String purpose = rs.getString("purpose") != null ? rs.getString("purpose") : "-";
            
            String assignedVehicles = rs.getString("assigned_vehicle_id") != null ? rs.getString("assigned_vehicle_id") : "";
            String assignedDrivers = rs.getString("assigned_driver_id") != null ? rs.getString("assigned_driver_id") : "";

            // ── 3. SUB-QUERY A: AMBIL SENARAI KENDERAAN YANG DIPADANKAN ──
            List<Map<String, String>> vehicleList = new ArrayList<>();
            if (!assignedVehicles.trim().isEmpty()) {
                String vSql = "SELECT model, plate_number, type FROM vehicles WHERE FIND_IN_SET(vehicle_id, ?) > 0";
                try (PreparedStatement psV = conn.prepareStatement(vSql)) {
                    psV.setString(1, assignedVehicles);
                    try (ResultSet rsV = psV.executeQuery()) {
                        while (rsV.next()) {
                            Map<String, String> vehicle = new HashMap<>();
                            vehicle.put("model", rsV.getString("model"));
                            vehicle.put("plate", rsV.getString("plate_number") != null ? rsV.getString("plate_number") : "-");
                            vehicle.put("type", rsV.getString("type") != null ? rsV.getString("type") : "");
                            vehicleList.add(vehicle);
                        }
                    }
                }
            }

            // ── 4. SUB-QUERY B: AMBIL SENARAI PEMANDU YANG DIPADANKAN ──
            List<Map<String, String>> driverList = new ArrayList<>();
            if (!assignedDrivers.trim().isEmpty()) {
                String dSql = "SELECT full_name, phone_number FROM drivers WHERE FIND_IN_SET(driver_id, ?) > 0";
                try (PreparedStatement psD = conn.prepareStatement(dSql)) {
                    psD.setString(1, assignedDrivers);
                    try (ResultSet rsD = psD.executeQuery()) {
                        while (rsD.next()) {
                            Map<String, String> driver = new HashMap<>();
                            driver.put("name", rsD.getString("full_name"));
                            driver.put("phone", rsD.getString("phone_number") != null ? rsD.getString("phone_number") : "");
                            driverList.add(driver);
                        }
                    }
                }
            }
%>
            <div class="grid grid-cols-2 gap-4 border-b pb-4 mb-4">
                <div>
                    <p class="text-[10px] font-bold uppercase text-gray-400 tracking-wider">Staff Name</p>
                    <p class="text-sm font-black text-slate-800 uppercase mt-0.5"><%= staffName %></p>
                </div>
                <div>
                    <p class="text-[10px] font-bold uppercase text-gray-400 tracking-wider">Phone Number</p>
                    <p class="text-sm font-bold text-blue-600 mt-0.5"><%= staffPhone %></p>
                </div>
            </div>

            <div class="border border-gray-100 rounded-xl p-4 bg-gray-50/50 text-left">
                <p class="text-[10px] font-bold uppercase text-gray-400 tracking-wider mb-3 flex items-center gap-1.5">
                    <i class="fas fa-layer-group text-slate-400"></i> Assigned Deployment Assets (<%= vehicleList.size() %> Vehicles)
                </p>
                
                <div class="grid grid-cols-1 gap-4 bg-white p-4 rounded-xl border border-gray-200 shadow-sm mb-4">
                    <div class="space-y-3">
                        <% if(vehicleList.isEmpty()) { %>
                            <p class="text-xs text-gray-400 italic">No vehicles assigned.</p>
                        <% } else { 
                            for(Map<String, String> v : vehicleList) { %>
                                <div class="flex items-start gap-3 pb-2 border-b border-gray-50 last:border-0 last:pb-0">
                                    <div class="p-2 bg-blue-50 text-blue-600 rounded-lg text-sm">
                                        <i class="fas fa-bus"></i>
                                    </div>
                                    <div>
                                        <p class="font-bold text-slate-800 text-xs"><%= v.get("model") %></p>
                                        <span class="inline-block bg-blue-50 text-blue-700 text-[9px] font-bold font-mono px-1.5 py-0.5 rounded border border-blue-200 mt-0.5 uppercase">
                                            [<%= v.get("plate") %>]
                                        </span>
                                    </div>
                                </div>
                        <%   } 
                           } %>
                    </div>

                    <div class="border-t pt-3 space-y-3">
                        <p class="text-[9px] font-bold text-gray-400 uppercase"><i class="fas fa-user-tie mr-1"></i> Assigned Driver(s)</p>
                        <% if(driverList.isEmpty()) { %>
                            <p class="text-xs text-slate-500 font-bold italic">Not Assigned Yet</p>
                        <% } else { 
                            for(Map<String, String> d : driverList) { %>
                                <div class="flex items-start gap-3">
                                    <div class="p-2 bg-slate-100 text-slate-600 rounded-lg text-sm">
                                        <i class="fas fa-user-tie"></i>
                                    </div>
                                    <div>
                                        <p class="font-bold text-slate-800 text-xs mt-0.5"><%= d.get("name") %></p>
                                        <% if(!d.get("phone").isEmpty()) { %>
                                            <p class="text-[10px] text-gray-500 mt-0.5"><i class="fas fa-phone-alt text-[9px]"></i> <%= d.get("phone") %></p>
                                        <% } %>
                                    </div>
                                </div>
                        <%   } 
                           } %>
                    </div>
                </div>

                <div class="mt-4 border-t pt-4">
                    <% 
                    boolean hasDoubleDecker = false;
                    String primaryType = "Standard Vehicle";
                    for(Map<String, String> v : vehicleList) {
                        String m = v.get("model").toLowerCase();
                        if(m.contains("decker") || m.contains("double")) {
                            hasDoubleDecker = true;
                        }
                        if(!v.get("type").isEmpty()) {
                            primaryType = v.get("type");
                        }
                    }

                    if (hasDoubleDecker) { 
                    %>
                        <div class="bg-amber-50/60 border border-amber-200 rounded-xl p-3.5">
                            <p class="text-[11px] font-bold text-amber-800 uppercase tracking-tight mb-2 flex items-center gap-1.5">
                                <i class="fas fa-hotel"></i> Double-Decker Asset Distribution Layout
                            </p>
                            <div class="grid grid-cols-2 gap-3 text-center">
                                <div class="bg-white p-2.5 rounded-lg border border-amber-100 shadow-sm">
                                    <p class="text-[9px] font-bold text-amber-600 uppercase">Upper Deck Capacity</p>
                                    <p class="text-base font-black text-slate-800 mt-0.5">30 <span class="text-[10px] font-normal text-gray-400">Seats</span></p>
                                </div>
                                <div class="bg-white p-2.5 rounded-lg border border-amber-100 shadow-sm">
                                    <p class="text-[9px] font-bold text-amber-600 uppercase">Lower Deck Capacity</p>
                                    <p class="text-base font-black text-slate-800 mt-0.5">20 <span class="text-[10px] font-normal text-gray-400">Seats</span></p>
                                </div>
                            </div>
                            <div class="mt-2 text-center bg-white py-1.5 px-3 rounded-lg border border-amber-100 text-[10px] font-medium text-amber-900">
                                Total Passengers Transported: <span class="font-bold text-blue-600"><%= passengers %> Pax</span>
                            </div>
                        </div>
                    <% } else { %>
                        <div class="bg-blue-50/40 border border-blue-100 rounded-xl p-3 flex justify-between items-center text-[11px]">
                            <span class="text-slate-600 font-medium">Vehicle Category Type:</span>
                            <span class="font-bold text-slate-900 uppercase"><%= primaryType %></span>
                        </div>
                        <div class="mt-2 bg-slate-50 border border-gray-200 rounded-xl p-3 flex justify-between items-center text-[11px]">
                            <span class="text-slate-600 font-medium">Total Registered Pax:</span>
                            <span class="font-black text-blue-600 text-sm"><%= passengers %> Passengers</span>
                        </div>
                    <% } %>
                </div>
            </div>

            <%-- DIUBAHSUAI: Menambah paparan kad Purpose di sini --%>
            <div class="bg-blue-50/60 rounded-xl p-4 border border-blue-100 mt-4 text-left">
                <p class="text-[10px] font-bold uppercase text-blue-500 tracking-wider mb-1">
                    <i class="fas fa-bullseye mr-1"></i> Booking Purpose / Tujuan Tempahan
                </p>
                <p class="text-slate-800 font-semibold text-xs leading-relaxed mt-1">
                    <%= purpose %>
                </p>
            </div>

            <div class="bg-slate-50 rounded-xl p-4 space-y-2 border border-gray-200 mt-4 text-left">
                <p class="text-[10px] font-bold uppercase text-gray-400 tracking-wider mb-1"><i class="fas fa-route"></i> Deployment Route</p>
                <div class="flex flex-col gap-1.5 text-[11px]">
                    <p class="text-slate-700 font-medium"><i class="fas fa-map-marker-alt text-red-500 w-4"></i> <strong>Pickup:</strong> <%= pickup %></p>
                    <p class="text-slate-700 font-medium"><i class="fas fa-flag-checkered text-green-500 w-4"></i> <strong>Destination:</strong> <%= destination %></p>
                </div>
            </div>
<%
        } else {
            out.print("<p class='text-center py-4 text-gray-400 italic'>No deployment record found for ID #" + targetBookingId + "</p>");
        }
    } catch (Exception e) {
        out.print("<div class='p-4 bg-red-50 border border-red-200 rounded-xl text-xs text-red-600 font-mono'>");
        out.print("<p class='font-bold mb-1'>JSP Runtime Error:</p> " + e.getMessage());
        out.print("</div>");
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>