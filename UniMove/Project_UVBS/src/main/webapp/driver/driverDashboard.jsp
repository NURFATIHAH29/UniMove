<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, java.util.Date" %>
<%
    // Security Check & Anti-Back Protection
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session.getAttribute("userName") == null) {
        response.sendRedirect("../Staff/login.jsp");
        return;
    }
    String fullName = (String) session.getAttribute("userName");
    Integer driverId = (Integer) session.getAttribute("driverId");
    if (driverId == null) { driverId = 0; }

    String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
    String dbUser = "root";
    String dbPass = "admin";

    // ── 1. HANDLE QUICK TOGGLE DUTY STATUS (AVAILABLE <-> OFF DUTY) ──
    String toggleStatus = request.getParameter("toggleStatus");
    if (toggleStatus != null && !toggleStatus.isEmpty()) {
        Connection c = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            c = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            PreparedStatement ps = c.prepareStatement("UPDATE drivers SET status = ? WHERE driver_id = ?");
            ps.setString(1, toggleStatus);
            ps.setInt(2, driverId);
            ps.executeUpdate();
            ps.close();
        } catch(Exception e) { 
            e.printStackTrace(); 
        } finally {
            if (c != null) try { c.close(); } catch(Exception ex){}
        }
        response.sendRedirect("driverDashboard.jsp?toast=status_updated");
        return;
    }

    // ── 2. HANDLE START TRIP ACTION (NEW FUNCTION) ──────────────────
    String startBookingId = request.getParameter("startBookingId");
    if (startBookingId != null && !startBookingId.isEmpty()) {
        Connection connStart = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connStart = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            connStart.setAutoCommit(false);

            // TUKAR STATUS BOOKING KE 'In-Progress'
            PreparedStatement ps1 = connStart.prepareStatement("UPDATE bookings SET status = 'In-Progress' WHERE booking_id = ?");
            ps1.setInt(1, Integer.parseInt(startBookingId));
            ps1.executeUpdate();
            ps1.close();

            // TUKAR STATUS DRIVER KE 'ON TRIP'
            PreparedStatement ps2 = connStart.prepareStatement("UPDATE drivers SET status = 'ON TRIP' WHERE driver_id = ?");
            ps2.setInt(1, driverId);
            ps2.executeUpdate();
            ps2.close();

            connStart.commit();
        } catch(Exception e) {
            if(connStart != null) try { connStart.rollback(); } catch(Exception ex){}
            e.printStackTrace();
        } finally {
            if(connStart != null) try { connStart.close(); } catch(Exception ex){}
        }
        response.sendRedirect("driverDashboard.jsp?toast=trip_started");
        return;
    }

    // ── 3. HANDLE COMPLETE BOOKING (TRIP END WITH REPORT) ───────────
    String completeId = request.getParameter("completeBookingId");
    if (completeId != null && !completeId.isEmpty()) {
        String nextDriverStatus = request.getParameter("nextDriverStatus"); 
        String vehicleCondition = request.getParameter("vehicleCondition"); 
        String driverNotes = request.getParameter("driverNotes");
        
        Connection connComp = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connComp = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            connComp.setAutoCommit(false); 

            // Update booking ke Completed
            String sqlBooking = "UPDATE bookings SET status = 'Completed', "
                              + "vehicle_condition_post = ?, driver_notes_post = ?, "
                              + "trip_completed_at = NOW() WHERE booking_id = ?";
            PreparedStatement psComp = connComp.prepareStatement(sqlBooking);
            psComp.setString(1, vehicleCondition);
            psComp.setString(2, driverNotes);
            psComp.setInt(3, Integer.parseInt(completeId));
            psComp.executeUpdate();
            psComp.close();
            
            // Update status ketersediaan pemandu
            PreparedStatement psAvail = connComp.prepareStatement("UPDATE drivers SET status = ? WHERE driver_id = ?");
            psAvail.setString(1, nextDriverStatus);
            psAvail.setInt(2, driverId);
            psAvail.executeUpdate();
            psAvail.close();

            // Update status kenderaan (Jika rosak, masuk Maintenance)
            String targetVehStatus = "Good".equalsIgnoreCase(vehicleCondition) ? "Available" : "Maintenance";
            String sqlVehicle = "UPDATE vehicles SET status = ? WHERE vehicle_id = "
                              + "(SELECT assigned_vehicle_id FROM bookings WHERE booking_id = ?)";
            PreparedStatement psVeh = connComp.prepareStatement(sqlVehicle);
            psVeh.setString(1, targetVehStatus);
            psVeh.setInt(2, Integer.parseInt(completeId));
            psVeh.executeUpdate();
            psVeh.close();

            connComp.commit(); 
        } catch (Exception e) {
            if (connComp != null) try { connComp.rollback(); } catch(Exception ex){}
            e.printStackTrace();
        } finally {
            if (connComp != null) try { connComp.close(); } catch(Exception ex){}
        }
        response.sendRedirect("driverDashboard.jsp?toast=completed");
        return;
    }

    // ── DATA DISPLAY FETCHING ──────────────────────────────────────
    String currentDate = new SimpleDateFormat("EEE, dd MMM yyyy").format(new Date()).toUpperCase();
    String assignedPlate = "N/A";
    String assignedModel = "No Vehicle Assigned";
    int todayTrips = 0;
    String driverStatus = "AVAILABLE";

    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // Ambil kenderaan aktif
        String sqlVeh = "SELECT v.plate_number, v.model FROM vehicles v " +
                        "JOIN bookings b ON v.vehicle_id = b.assigned_vehicle_id " +
                        "WHERE b.assigned_driver_id = ? AND (b.status = 'Confirmed' OR b.status = 'In-Progress') LIMIT 1";
        PreparedStatement psVeh = conn.prepareStatement(sqlVeh);
        psVeh.setInt(1, driverId);
        ResultSet rsVeh = psVeh.executeQuery();
        if(rsVeh.next()) {
            assignedPlate = rsVeh.getString("plate_number");
            assignedModel = rsVeh.getString("model");
        }
        rsVeh.close();
        psVeh.close();

        // Kira trip aktif hari ini
        String sqlCount = "SELECT COUNT(*) FROM bookings WHERE assigned_driver_id = ? " +
                          "AND (status = 'Confirmed' OR status = 'In-Progress') AND DATE(start_date) = CURDATE()";
        PreparedStatement psCount = conn.prepareStatement(sqlCount);
        psCount.setInt(1, driverId);
        ResultSet rsCount = psCount.executeQuery();
        if(rsCount.next()) { todayTrips = rsCount.getInt(1); }
        rsCount.close();
        psCount.close();

        // Live status driver
        PreparedStatement psStat = conn.prepareStatement("SELECT status FROM drivers WHERE driver_id = ?");
        psStat.setInt(1, driverId);
        ResultSet rsStat = psStat.executeQuery();
        if(rsStat.next()) { driverStatus = rsStat.getString("status"); }
        rsStat.close();
        psStat.close();

    } catch(Exception e) { 
        e.printStackTrace(); 
    }

    // UI Configuration based on status
    String statusBadgeColor = "bg-green-500/20 text-green-400";
    String statusTextColor = "text-green-600";
    String statusIcon = "fa-check-circle";
    
    if("ON TRIP".equalsIgnoreCase(driverStatus)) { 
        statusBadgeColor = "bg-blue-500/20 text-blue-400"; 
        statusTextColor = "text-blue-600";
        statusIcon = "fa-bus"; 
    } else if("OFF DUTY".equalsIgnoreCase(driverStatus)) { 
        statusBadgeColor = "bg-red-500/20 text-red-400"; 
        statusTextColor = "text-red-600";
        statusIcon = "fa-power-off"; 
    }

    String toastMsg = request.getParameter("toast");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Driver Dashboard | UVBS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght=300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body, h1, h2, h3, h4, p, span, table { font-family: 'Public Sans', sans-serif !important; }
        #toast { transition: all 0.4s ease; transform: translateY(100px); opacity: 0; }
        #toast.show { transform: translateY(0); opacity: 1; }
        .nav-link { color: #9ca3af; transition: all 0.3s; display: flex; align-items: center; gap: 1rem; padding: 1rem 2rem; font-size: 0.875rem; }
        .nav-link:hover { color: white; background-color: rgba(255,255,255,0.05); }
        .nav-active { color: white; background-color: rgba(255,255,255,0.1); border-left: 4px solid #b8974d; }
    </style>
</head>
<body class="bg-[#f8f9fa] min-h-screen flex flex-col md:flex-row">

    <div id="toast" class="fixed bottom-6 right-6 z-[999] bg-[#1a2a3a] text-white px-6 py-4 rounded-2xl shadow-2xl flex items-center gap-3">
        <i class="fas fa-check-circle text-green-400 text-lg"></i>
        <div>
            <p class="text-xs font-bold" id="toastTitle">Success!</p>
            <p class="text-[10px] text-gray-300" id="toastMsg">Action completed.</p>
        </div>
    </div>

    <aside class="hidden md:flex w-64 bg-[#1a2a3a] flex-col text-white fixed top-0 bottom-0 left-0 z-50 justify-between">
        <div>
            <div class="p-8 text-center border-b border-white/10">
                <div class="w-16 h-16 bg-[#b8974d] rounded-full flex items-center justify-center text-xl font-bold mx-auto mb-4 text-white uppercase">
                    <%= fullName != null && !fullName.isEmpty() ? fullName.substring(0,1) : "D" %>
                </div>
                <h2 class="text-xs font-bold uppercase tracking-widest">Driver</h2>
                <p class="text-[10px] text-gray-400 mt-1 truncate max-w-[180px] mx-auto"><%= fullName %></p>
                <div class="mt-3 inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[9px] font-bold uppercase <%= statusBadgeColor %>">
                    <i class="fas <%= statusIcon %> text-[8px]"></i> <%= driverStatus %>
                </div>
            </div>
            <nav class="mt-6 flex flex-col">
                <a href="driverDashboard.jsp" class="nav-link nav-active"><i class="fas fa-th-large w-5 text-center"></i> Dashboard</a>
                <a href="driverSchedule.jsp" class="nav-link"><i class="fas fa-calendar-alt w-5 text-center"></i> Schedule</a>
                <a href="driverHistory.jsp" class="nav-link"><i class="fas fa-history w-5 text-center"></i> Trip History</a>
                <a href="driverProfile.jsp" class="nav-link"><i class="fas fa-user w-5 text-center"></i> Profile</a>
            </nav>
        </div>
        <div class="p-4 border-t border-white/10">
            <a href="../LogoutServlet" class="bg-[#4a1d1f] w-full flex items-center justify-center gap-2 py-3 rounded-lg text-[10px] font-bold uppercase hover:opacity-90 transition text-white">
                <i class="fas fa-sign-out-alt"></i> Logout
            </a>
        </div>
    </aside>

    <main class="flex-grow md:ml-64 p-4 md:p-10">
        <header class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-10">
            <div>
                <h1 class="text-3xl font-bold text-[#1a2a3a] tracking-tight">Operational Overview</h1>
                <p class="text-gray-500 text-sm">Centralized management for your daily tasks.</p>
            </div>
            <div class="bg-white px-4 py-2 rounded-xl shadow-sm border border-gray-100 min-w-[140px]">
                <p class="text-[9px] font-black text-gray-400 uppercase tracking-wider">Current Date</p>
                <p class="text-xs font-bold text-gray-700 uppercase mt-0.5"><%= currentDate %></p>
            </div>
        </header>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
            <div class="bg-white p-6 rounded-2xl shadow-sm border-l-4 border-blue-500">
                <h3 class="text-gray-400 text-[10px] font-bold uppercase tracking-widest">Today's Active Trips</h3>
                <p class="text-3xl font-bold text-gray-800 mt-1"><%= String.format("%02d", todayTrips) %></p>
            </div>
            
            <div class="bg-white p-6 rounded-2xl shadow-sm border-l-4 border-[#b8974d]">
                <h3 class="text-gray-400 text-[10px] font-bold uppercase tracking-widest">Assigned Vehicle</h3>
                <p class="text-xl font-bold text-gray-800 mt-1 uppercase tracking-tight"><%= assignedPlate %></p>
                <p class="text-[10px] text-gray-500 uppercase font-medium mt-0.5 truncate"><%= assignedModel %></p>
            </div>
            
            <div class="bg-white p-6 rounded-2xl shadow-sm border-l-4 border-green-500 flex flex-col justify-between">
                <div>
                    <h3 class="text-gray-400 text-[10px] font-bold uppercase tracking-widest">Duty Status</h3>
                    <p class="text-xl font-bold mt-1 uppercase <%= statusTextColor %>"><%= driverStatus %></p>
                </div>
                <div class="mt-3 pt-2 border-t border-gray-100 flex items-center justify-between">
                    <span class="text-[9px] text-gray-400 font-bold uppercase">Quick Switch:</span>
                    <% if("OFF DUTY".equalsIgnoreCase(driverStatus)) { %>
                        <a href="driverDashboard.jsp?toggleStatus=AVAILABLE" class="text-[10px] bg-green-600 text-white font-bold px-3 py-1 rounded hover:bg-green-700 transition">Go On-Duty</a>
                    <% } else if("AVAILABLE".equalsIgnoreCase(driverStatus)) { %>
                        <a href="driverDashboard.jsp?toggleStatus=OFF DUTY" class="text-[10px] bg-red-600 text-white font-bold px-3 py-1 rounded hover:bg-red-700 transition">Go Off-Duty</a>
                    <% } else { %>
                        <span class="text-[10px] text-blue-500 italic font-bold"><i class="fas fa-lock text-[8px] mr-1"></i>Locked (On Trip)</span>
                    <% } %>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden">
            <div class="px-6 py-4 bg-gray-50/50 border-b border-gray-100">
                <h4 class="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Recent Booking Assignments</h4>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="bg-gray-50 text-[10px] font-bold text-gray-400 uppercase border-b">
                        <tr>
                            <th class="px-6 py-4">Booking ID</th>
                            <th class="px-6 py-4">Destination</th>
                            <th class="px-6 py-4">Date</th>
                            <th class="px-6 py-4">Status</th>
                            <th class="px-6 py-4 text-center">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-50">
                        <%
                            try {
                                if (conn == null || conn.isClosed()) {
                                    conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
                                }
                                String sql = "SELECT * FROM bookings WHERE assigned_driver_id = ? " +
                                             "AND (status = 'Confirmed' OR status = 'In-Progress') ORDER BY start_date ASC";
                                PreparedStatement ps = conn.prepareStatement(sql);
                                ps.setInt(1, driverId);
                                ResultSet rs = ps.executeQuery();
                                boolean hasData = false;
                                while(rs.next()) {
                                    hasData = true;
                                    String bStatus = rs.getString("status");
                                    int bookingId = rs.getInt("booking_id");
                                    String dest = rs.getString("destination");
                                    String mapLink = rs.getString("map_link"); // Membaca map_link spesifik dari pangkalan data
                                    
                                    String badgeStyle = "bg-green-100 text-green-700";
                                    if("In-Progress".equalsIgnoreCase(bStatus)) { badgeStyle = "bg-blue-100 text-blue-700"; }
                        %>
                        <tr class="hover:bg-gray-50 transition">
                            <td class="px-6 py-4 font-bold text-blue-600 whitespace-nowrap">#BK-<%= bookingId %></td>
                            <td class="px-6 py-4 font-medium uppercase"><%= dest %></td>
                            <td class="px-6 py-4 text-[11px] text-gray-500 whitespace-nowrap"><%= rs.getDate("start_date") %></td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <span class="<%= badgeStyle %> text-[9px] font-bold px-2 py-1 rounded uppercase">
                                    <%= bStatus %>
                                </span>
                            </td>
                            <td class="px-6 py-4 text-center whitespace-nowrap">
                                <div class="flex gap-2 justify-center items-center">
                                    <%-- Urus Pautan Navigasi secara Pintar --%>
                                    <% if (mapLink != null && !mapLink.trim().isEmpty()) { %>
                                        <a href="<%= mapLink %>" target="_blank"
                                           class="bg-blue-500 text-white text-[10px] font-bold px-3 py-2 rounded-lg hover:bg-blue-600 transition shadow-sm" title="Buka Navigasi Lokasi Tepat">
                                            <i class="fas fa-location-arrow"></i>
                                        </a>
                                    <% } else { %>
                                        <a href="https://www.google.com/maps/search/?api=1&query=<%= java.net.URLEncoder.encode(dest, "UTF-8") %>" target="_blank"
                                           class="bg-blue-500 text-white text-[10px] font-bold px-3 py-2 rounded-lg hover:bg-blue-600 transition shadow-sm" title="Buka Carian Nama Tempat">
                                            <i class="fas fa-location-arrow"></i>
                                        </a>
                                    <% } %>

                                    <% if("Confirmed".equalsIgnoreCase(bStatus)) { %>
                                        <a href="driverDashboard.jsp?startBookingId=<%= bookingId %>" 
                                           onclick="return confirm('Mula pemanduan untuk trip #BK-<%= bookingId %> sekarang?')"
                                           class="bg-blue-600 text-white text-[10px] font-bold px-4 py-2 rounded-lg uppercase hover:bg-blue-700 transition shadow-sm">
                                             Start Trip
                                        </a>
                                    <% } else if("In-Progress".equalsIgnoreCase(bStatus)) { %>
                                        <button type="button" class="bg-[#10b981] text-white text-[10px] font-bold px-4 py-2 rounded-lg uppercase hover:bg-[#059669] transition shadow-sm"
                                            onclick="openCompleteModal('<%= bookingId %>', '<%= dest.replace("'", "\\'") %>')">
                                             Complete Trip
                                        </button>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <%      }
                                rs.close();
                                ps.close();
                                if(!hasData) {
                        %>
                        <tr>
                            <td colspan="5" class="p-16 text-center">
                                <i class="fas fa-clipboard-check text-5xl text-gray-200 mb-4 block"></i>
                                <p class="text-gray-400 font-medium text-sm">No active assignments right now.</p>
                            </td>
                        </tr>
                        <%      }
                            } catch(Exception e) {
                                out.println("<tr><td colspan='5' class='p-4 text-red-500 font-mono text-xs'>Error: " + e.getMessage() + "</td></tr>");
                            } finally {
                                if (conn != null) try { conn.close(); } catch(Exception ex){}
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <div id="completeModal" class="fixed inset-0 bg-black/50 z-[100] hidden items-center justify-center p-4">
        <div class="bg-white rounded-2xl max-w-md w-full shadow-2xl overflow-hidden p-6">
            <div class="flex justify-between items-center border-b pb-3 mb-4">
                <h3 class="text-base font-bold text-gray-800">
                    <i class="fas fa-clipboard-list text-emerald-500 mr-2"></i>End Trip Report <span id="modalBkId" class="text-blue-600"></span>
                </h3>
                <button onclick="closeCompleteModal()" class="text-gray-400 hover:text-gray-600"><i class="fas fa-times"></i></button>
            </div>
            
            <p class="text-xs text-gray-500 mb-4">Destination: <span id="modalDest" class="font-bold text-gray-700 uppercase"></span></p>
            
            <form method="POST" action="driverDashboard.jsp" class="space-y-4">
                <input type="hidden" name="completeBookingId" id="inputBookingId">
                
                <div>
                    <label class="block text-[10px] font-bold text-gray-400 uppercase tracking-wider mb-1">Your Next Duty Status</label>
                    <select name="nextDriverStatus" class="w-full text-xs bg-gray-50 border border-gray-200 rounded-lg p-2.5 font-medium text-gray-700 focus:outline-none focus:border-blue-500">
                        <option value="AVAILABLE">AVAILABLE (Boleh ambil trip seterusnya)</option>
                        <option value="OFF DUTY">OFF DUTY (Selesai shif / Rehat)</option>
                    </select>
                </div>
                
                <div>
                    <label class="block text-[10px] font-bold text-gray-400 uppercase tracking-wider mb-1">Vehicle Condition Post-Trip</label>
                    <select name="vehicleCondition" class="w-full text-xs bg-gray-50 border border-gray-200 rounded-lg p-2.5 font-medium text-gray-700 focus:outline-none focus:border-blue-500">
                        <option value="Good">Good & Clean (Tiada Kerosakan)</option>
                        <option value="Need Maintenance">Need Maintenance (Isu Kecil - Aircond/Servis Enjin)</option>
                        <option value="Damaged">Damaged / Rosak (Perlu Pembaikan Segera)</option>
                    </select>
                </div>
                
                <div>
                    <label class="block text-[10px] font-bold text-gray-400 uppercase tracking-wider mb-1">Damage Reports / Maintenance Notes</label>
                    <textarea name="driverNotes" rows="3" placeholder="Sila taip aduan kerosakan di sini sekiranya ada..." 
                        class="w-full text-xs bg-gray-50 border border-gray-200 rounded-lg p-2.5 font-medium text-gray-700 focus:outline-none focus:border-blue-500 resize-none"></textarea>
                </div>
                
                <div class="flex gap-3 pt-2">
                    <button type="button" onclick="closeCompleteModal()" class="w-1/3 bg-gray-100 text-gray-600 text-xs font-bold py-2.5 rounded-lg uppercase hover:bg-gray-200 transition">Cancel</button>
                    <button type="submit" class="w-2/3 bg-emerald-500 text-white text-xs font-bold py-2.5 rounded-lg uppercase hover:bg-emerald-600 transition shadow-sm">Submit & Complete</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openCompleteModal(bookingId, destination) {
            document.getElementById('modalBkId').textContent = '#BK-' + bookingId;
            document.getElementById('modalDest').textContent = destination;
            document.getElementById('inputBookingId').value = bookingId;
            const modal = document.getElementById('completeModal');
            modal.classList.remove('hidden'); modal.classList.add('flex');
        }
        function closeCompleteModal() {
            const modal = document.getElementById('completeModal');
            modal.classList.add('hidden'); modal.classList.remove('flex');
        }

        // Handling Toast Alerts
        const toastParam = "<%= toastMsg != null ? toastMsg : "" %>";
        const toast = document.getElementById('toast');
        if (toastParam === 'completed') {
            document.getElementById('toastTitle').textContent = 'Trip Completed!';
            document.getElementById('toastMsg').textContent = 'Laporan dihantar. Status kenderaan & pemandu telah dikemas kini.';
            toast.classList.add('show');
            setTimeout(() => toast.classList.remove('show'), 4000);
        } else if (toastParam === 'status_updated') {
            document.getElementById('toastTitle').textContent = 'Status Updated!';
            document.getElementById('toastMsg').textContent = 'Status tugasan kerja anda berjaya dikemas kini.';
            toast.classList.add('show');
            setTimeout(() => toast.classList.remove('show'), 4000);
        } else if (toastParam === 'trip_started') {
            document.getElementById('toastTitle').textContent = 'Trip Started!';
            document.getElementById('toastMsg').textContent = 'Selamat memandu! Status bertukar ke ON TRIP.';
            toast.classList.add('show');
            setTimeout(() => toast.classList.remove('show'), 4000);
        }
    </script>
</body>
</html>