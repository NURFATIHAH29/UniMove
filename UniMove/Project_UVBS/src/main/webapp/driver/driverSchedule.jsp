<%-- 
    Document   : driverSchedule
    Created on : 3 May 2026, 10:01:47 pm
    Author     : fatih
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%
    if (session.getAttribute("userName") == null) {
        response.sendRedirect("../Staff/login.jsp");
        return;
    }
    String fullName = (String) session.getAttribute("userName");
    Integer driverId = (Integer) session.getAttribute("driverId");
    
    SimpleDateFormat dayFormat = new SimpleDateFormat("EEEE");

    // Tangkap parameter carian dan penapis
    String searchDest = request.getParameter("searchDest") != null ? request.getParameter("searchDest").trim() : "";
    String filterMonth = request.getParameter("filterMonth") != null ? request.getParameter("filterMonth") : "";
    String filterDate = request.getParameter("filterDate") != null ? request.getParameter("filterDate") : "";

    // ── HANDLE STATUS UPDATE ──────────────────────────────────────
    String newStatus = request.getParameter("dutyStatus");
    if (newStatus != null && !newStatus.isEmpty()) {
        Connection connUpd = null;
        PreparedStatement psUpd = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connUpd = DriverManager.getConnection("jdbc:mysql://localhost:3306/uvbs_db", "root", "admin");
            psUpd = connUpd.prepareStatement("UPDATE drivers SET status = ? WHERE driver_id = ?");
            psUpd.setString(1, newStatus);
            psUpd.setInt(2, (driverId != null ? driverId : 0));
            psUpd.executeUpdate();
        } catch (Exception e) {
            System.out.println("Status update error: " + e.getMessage());
        } finally {
            if (psUpd != null) try { psUpd.close(); } catch (SQLException e) {}
            if (connUpd != null) try { connUpd.close(); } catch (SQLException e) {}
        }
        response.sendRedirect("driverSchedule.jsp?toast=status");
        return;
    }

    // ── AMBIL STATUS SEMASA ───────────────────────────────────────
    String currentStatus = "AVAILABLE";
    Connection connStat = null;
    PreparedStatement psStat = null;
    ResultSet rsStat = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        connStat = DriverManager.getConnection("jdbc:mysql://localhost:3306/uvbs_db", "root", "admin");
        psStat = connStat.prepareStatement("SELECT status FROM drivers WHERE driver_id = ?");
        psStat.setInt(1, (driverId != null ? driverId : 0));
        rsStat = psStat.executeQuery();
        if (rsStat.next()) currentStatus = rsStat.getString("status");
    } catch (Exception e) {
        System.out.println("Status fetch error: " + e.getMessage());
    } finally {
        if (rsStat != null) try { rsStat.close(); } catch (SQLException e) {}
        if (psStat != null) try { psStat.close(); } catch (SQLException e) {}
        if (connStat != null) try { connStat.close(); } catch (SQLException e) {}
    }

    String statusColor = "green";
    String statusIcon = "fa-check-circle";
    if("ON TRIP".equals(currentStatus)) { statusColor = "blue"; statusIcon = "fa-clock"; }
    else if("OFF DUTY".equals(currentStatus)) { statusColor = "red"; statusIcon = "fa-power-off"; }

    String toastMsg = request.getParameter("toast");
    
    // Safety check untuk avatar ringkas
    String avatarChar = (fullName != null && !fullName.isEmpty()) ? fullName.substring(0,1).toUpperCase() : "D";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Work Schedule | UVBS</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/Staff/Style.css">
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body, h1, h2, h3, h4, p, span, table { font-family: 'Public Sans', sans-serif !important; }
        #toast { transition: all 0.4s ease; transform: translateY(100px); opacity: 0; }
        #toast.show { transform: translateY(0); opacity: 1; }
        .modal { transition: opacity 0.25s ease; }
        body.modal-active { overflow: hidden; }
    </style>
</head>

<body class="bg-[#f8f9fa] min-h-screen flex">

    <div id="toast" class="fixed bottom-6 right-6 z-[999] bg-[#1a2a3a] text-white px-6 py-4 rounded-2xl shadow-2xl flex items-center gap-3">
        <i class="fas fa-check-circle text-green-400 text-lg"></i>
        <div>
            <p class="text-xs font-bold">Status Updated!</p>
            <p class="text-[10px] text-gray-300">Your duty status has been updated successfully.</p>
        </div>
    </div>

    <aside class="w-64 bg-[#1a2a3a] text-white fixed h-full flex flex-col shadow-xl z-50">
        <div class="p-8 text-center border-b border-white/10">
            <div class="w-16 h-16 bg-[#b8974d] rounded-full flex items-center justify-center text-xl font-bold mx-auto mb-4 shadow-lg">
                <%= avatarChar %>
            </div>
            <h2 class="text-xs font-bold uppercase tracking-widest">Driver</h2>
            <p class="text-[10px] text-gray-400 mt-1"><%= fullName %></p>
            <div class="mt-3 inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[9px] font-bold uppercase
                <%= "green".equals(statusColor) ? "bg-green-500/20 text-green-400" : 
                    "blue".equals(statusColor) ? "bg-blue-500/20 text-blue-400" : 
                    "bg-red-500/20 text-red-400" %>">
                <i class="fas <%= statusIcon %> text-[8px]"></i>
                <%= currentStatus %>
            </div>
        </div>

        <nav class="flex-grow mt-6">
            <a href="driverDashboard.jsp" class="flex items-center gap-4 px-8 py-4 text-gray-400 hover:text-white transition">
                <i class="fas fa-th-large w-5"></i> Dashboard
            </a>
            <a href="driverSchedule.jsp" class="flex items-center gap-4 px-8 py-4 bg-white/10 border-l-4 border-[#b8974d] text-white">
                <i class="fas fa-calendar-alt w-5"></i> Schedule
            </a>
            <a href="driverHistory.jsp" class="flex items-center gap-4 px-8 py-4 text-gray-400 hover:text-white transition">
                <i class="fas fa-history w-5"></i> Trip History
            </a>
            <a href="driverProfile.jsp" class="flex items-center gap-4 px-8 py-4 text-gray-400 hover:text-white transition">
                <i class="fas fa-user w-5"></i> Profile
            </a>
        </nav>

        <div class="p-4 mb-4">
            <a href="../LogoutServlet" class="bg-[#4a1d1f] w-full flex items-center justify-center gap-2 py-3 rounded-lg text-[10px] font-bold uppercase hover:opacity-90 transition text-white">
                <i class="fas fa-sign-out-alt"></i> Logout
            </a>
        </div>
    </aside>

    <main class="ml-64 flex-grow p-10">
        <header class="flex justify-between items-center mb-10">
            <div>
                <h1 class="text-3xl font-bold text-[#1a2a3a] tracking-tight">Work Schedule</h1>
                <p class="text-gray-500 text-sm">Update your availability and view upcoming roster.</p>
            </div>
        </header>

        <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 mb-10">
            <h3 class="text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-4">Live Duty Status Update</h3>
            <form method="post" action="driverSchedule.jsp">
                <div class="flex flex-wrap gap-4 items-center justify-between">
                    <div class="flex gap-3">
                        <button type="submit" name="dutyStatus" value="AVAILABLE"
                            class="status-btn flex items-center gap-2 px-6 py-3 rounded-xl font-bold text-xs transition
                            <%= "AVAILABLE".equals(currentStatus)
                                ? "border-2 border-green-500 text-green-600 bg-green-50"
                                : "bg-gray-50 text-gray-400 border border-gray-100 hover:bg-white hover:text-green-500 hover:border-green-500" %>">
                            <i class="fas fa-check-circle"></i> READY / AVAILABLE
                        </button>
                        <button type="submit" name="dutyStatus" value="ON TRIP"
                            class="status-btn flex items-center gap-2 px-6 py-3 rounded-xl font-bold text-xs transition
                            <%= "ON TRIP".equals(currentStatus)
                                ? "border-2 border-blue-500 text-blue-600 bg-blue-50"
                                : "bg-gray-50 text-gray-400 border border-gray-100 hover:bg-white hover:text-blue-500 hover:border-blue-500" %>">
                            <i class="fas fa-clock"></i> ON-DUTY (IN TRIP)
                        </button>
                        <button type="submit" name="dutyStatus" value="OFF DUTY"
                            class="status-btn flex items-center gap-2 px-6 py-3 rounded-xl font-bold text-xs transition
                            <%= "OFF DUTY".equals(currentStatus)
                                ? "border-2 border-red-500 text-red-600 bg-red-50"
                                : "bg-gray-50 text-gray-400 border border-gray-100 hover:bg-white hover:text-red-500 hover:border-red-500" %>">
                            <i class="fas fa-power-off"></i> OFF-DUTY
                        </button>
                    </div>
                    <button type="submit"
                        class="bg-[#1a2a3a] text-white px-8 py-3 rounded-xl font-bold text-xs flex items-center gap-2 hover:bg-slate-800 transition shadow-md active:scale-95">
                        <i class="fas fa-save"></i> UPDATE STATUS NOW
                    </button>
                </div>
                <p class="text-[10px] text-gray-400 mt-4 italic font-medium">
                    *Status semasa: <span class="font-bold text-[#b8974d]"><%= currentStatus %></span>
                    &nbsp;|&nbsp; Updating to 'Ready' allows <span class="text-[#b8974d]">System</span> to assign you to new trips.
                </p>
            </form>
        </div>

        <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 mb-6">
            <form method="get" action="driverSchedule.jsp" class="flex flex-wrap items-end gap-4">
                <div class="flex-grow min-w-[200px]">
                    <label class="text-[10px] font-bold text-gray-400 uppercase tracking-widest block mb-2">Search Destination</label>
                    <div class="relative">
                        <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                            <i class="fas fa-search"></i>
                        </span>
                        <input type="text" name="searchDest" value="<%= searchDest != null ? searchDest.replace("\"", "&quot;") : "" %>" placeholder="e.g. Kuantan, Kuala Lumpur..."
                            class="w-full pl-10 pr-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-xs focus:bg-white focus:border-[#b8974d] focus:outline-none transition">
                    </div>
                </div>
                <div class="w-48">
                    <label class="text-[10px] font-bold text-gray-400 uppercase tracking-widest block mb-2">Filter by Month</label>
                    <select name="filterMonth" class="w-full px-3 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-xs focus:bg-white focus:border-[#b8974d] focus:outline-none transition">
                        <option value="">All Months</option>
                        <option value="01" <%= "01".equals(filterMonth) ? "selected" : "" %>>January</option>
                        <option value="02" <%= "02".equals(filterMonth) ? "selected" : "" %>>February</option>
                        <option value="03" <%= "03".equals(filterMonth) ? "selected" : "" %>>March</option>
                        <option value="04" <%= "04".equals(filterMonth) ? "selected" : "" %>>April</option>
                        <option value="05" <%= "05".equals(filterMonth) ? "selected" : "" %>>May</option>
                        <option value="06" <%= "06".equals(filterMonth) ? "selected" : "" %>>June</option>
                        <option value="07" <%= "07".equals(filterMonth) ? "selected" : "" %>>July</option>
                        <option value="08" <%= "08".equals(filterMonth) ? "selected" : "" %>>August</option>
                        <option value="09" <%= "09".equals(filterMonth) ? "selected" : "" %>>September</option>
                        <option value="10" <%= "10".equals(filterMonth) ? "selected" : "" %>>October</option>
                        <option value="11" <%= "11".equals(filterMonth) ? "selected" : "" %>>November</option>
                        <option value="12" <%= "12".equals(filterMonth) ? "selected" : "" %>>December</option>
                    </select>
                </div>
                <div class="w-44">
                    <label class="text-[10px] font-bold text-gray-400 uppercase tracking-widest block mb-2">Filter Specific Date</label>
                    <input type="date" name="filterDate" value="<%= filterDate %>"
                        class="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl text-xs focus:bg-white focus:border-[#b8974d] focus:outline-none transition">
                </div>
                <div class="flex gap-2">
                    <button type="submit" class="bg-[#1a2a3a] text-white px-5 py-2.5 rounded-xl font-bold text-xs hover:bg-slate-800 transition">
                        Apply Filters
                    </button>
                    <a href="driverSchedule.jsp" class="bg-gray-100 text-gray-600 px-5 py-2.5 rounded-xl font-bold text-xs hover:bg-gray-200 transition flex items-center justify-center">
                        Reset
                    </a>
                </div>
            </form>
        </div>

        <div class="bg-white rounded-3xl shadow-sm border border-gray-100 overflow-hidden">
            <div class="px-8 py-6 bg-gray-50/50 border-b border-gray-100 flex justify-between items-center">
                <h4 class="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Upcoming Roster Schedule</h4>
            </div>

            <div class="grid grid-cols-12 gap-4 px-8 py-4 bg-gray-50 text-[9px] font-bold text-gray-400 uppercase border-b">
                <div class="col-span-3">Day / Date</div>
                <div class="col-span-3">Shift Time / Slot</div>
                <div class="col-span-4">Assigned Tasks</div>
                <div class="col-span-2 text-right pr-4">Availability</div>
            </div>

            <div class="divide-y divide-gray-50">
                <%
                    Connection conn = null;
                    PreparedStatement ps = null;
                    ResultSet rs = null;
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/uvbs_db", "root", "admin");
                        
                        StringBuilder sql = new StringBuilder("SELECT * FROM bookings WHERE assigned_driver_id = ? AND (status = 'CONFIRMED' OR status = 'IN-PROGRESS')");
                        
                        if (!searchDest.isEmpty()) {
                            sql.append(" AND destination LIKE ?");
                        }
                        if (!filterMonth.isEmpty()) {
                            sql.append(" AND MONTH(start_date) = ?");
                        }
                        if (!filterDate.isEmpty()) {
                            sql.append(" AND start_date = ?");
                        }
                        sql.append(" ORDER BY start_date ASC");

                        ps = conn.prepareStatement(sql.toString());
                        
                        int paramIndex = 1;
                        // PEMBAIKAN: Gunakan setInt untuk parameter Integer, pastikan safety jika null
                        ps.setInt(paramIndex++, (driverId != null ? driverId : 0));
                        
                        if (!searchDest.isEmpty()) {
                            ps.setString(paramIndex++, "%" + searchDest + "%");
                        }
                        if (!filterMonth.isEmpty()) {
                            ps.setInt(paramIndex++, Integer.parseInt(filterMonth));
                        }
                        if (!filterDate.isEmpty()) {
                            ps.setString(paramIndex++, filterDate);
                        }
                        
                        rs = ps.executeQuery();
                        boolean hasData = false;
                        while(rs.next()) {
                            hasData = true;
                            java.sql.Date tripDate = rs.getDate("start_date");
                            String dayName = dayFormat.format(tripDate);
                            
                            String bId = String.valueOf(rs.getInt("booking_id"));
                            String sName = rs.getString("staff_name") != null ? rs.getString("staff_name") : "N/A";
                            String pNum = rs.getString("phone_number") != null ? rs.getString("phone_number") : "N/A";
                            String vType = rs.getString("vehicle_type") != null ? rs.getString("vehicle_type") : "N/A";
                            String tSlot = rs.getString("trip_slot") != null ? rs.getString("trip_slot") : "N/A";
                            String dest = rs.getString("destination") != null ? rs.getString("destination") : "N/A";
                            String pLoc = rs.getString("pickup_location") != null ? rs.getString("pickup_location") : "N/A";
                            String mapL = rs.getString("map_link") != null ? rs.getString("map_link") : "#";
                            String passg = String.valueOf(rs.getInt("passengers"));
                            String purpose = rs.getString("purpose") != null ? rs.getString("purpose") : "-";
                            String bStatus = rs.getString("status");

                            // Escape single quotes untuk parameter JS onclick
                            String sNameEsc = sName.replace("'", "\\'");
                            String destEsc = dest.replace("'", "\\'");
                            String pLocEsc = pLoc.replace("'", "\\'");
                            String purposeEsc = purpose.replace("'", "\\'");
                %>
                <div class="grid grid-cols-12 gap-4 px-8 py-6 items-center hover:bg-slate-50 transition cursor-pointer"
                     onclick="openDetailsModal('<%= bId %>','<%= sNameEsc %>','<%= pNum %>','<%= vType %>','<%= tSlot %>','<%= destEsc %>','<%= pLocEsc %>','<%= mapL %>','<%= passg %>','<%= purposeEsc %>','<%= bStatus %>')">
                    
                    <div class="col-span-3">
                        <p class="font-bold text-gray-800 text-sm"><%= dayName %></p>
                        <p class="text-[10px] text-gray-400 font-medium tracking-wide"><%= tripDate %></p>
                    </div>
                    <div class="col-span-3 font-bold text-gray-700 text-xs tracking-tight">
                        <i class="far fa-clock text-[#b8974d] mr-2"></i><%= tSlot %>
                    </div>
                    <div class="col-span-4 pr-10">
                        <div class="border border-blue-100 bg-blue-50/40 p-4 rounded-2xl border-l-4 border-l-blue-500 shadow-sm transition hover:shadow-md">
                            <div class="flex justify-between items-start mb-1">
                                <p class="text-[10px] font-black text-blue-700 uppercase">#BK-<%= bId %> (<%= bStatus %>)</p>
                                <span class="text-[9px] text-blue-500 font-bold flex items-center gap-1">
                                    <i class="fas fa-info-circle"></i> Click for Details
                                </span>
                            </div>
                            <p class="text-[11px] text-gray-800 font-bold uppercase tracking-tight truncate">
                                <%= dest %>
                            </p>
                        </div>
                    </div>
                    <div class="col-span-2 text-right pr-4">
                        <span class="bg-green-100 text-green-700 text-[9px] font-black px-3 py-1.5 rounded-lg uppercase tracking-tighter shadow-sm border border-green-200">
                            WORKING
                        </span>
                    </div>
                </div>
                <%      }
                        if(!hasData) {
                            out.println("<div class='p-20 text-center text-gray-400'><i class='fas fa-calendar-day text-4xl mb-4 opacity-20 block'></i><p class='font-medium'>No assigned tasks match the criteria.</p></div>");
                        }
                    } catch(Exception e) {
                        out.println("<div class='p-10 text-red-500'>Error: " + e.getMessage() + "</div>");
                    } finally {
                        if(rs != null) try { rs.close(); } catch(SQLException e) {}
                        if(ps != null) try { ps.close(); } catch(SQLException e) {}
                        if(conn != null) try { conn.close(); } catch(SQLException e) {}
                    }
                %>
            </div>
        </div>

        <footer class="mt-10 text-center">
            <p class="text-[10px] text-gray-400 font-bold uppercase tracking-[0.2em]">© 2026 UVBS | Notification System</p>
        </footer>
    </main>

    <div id="bookingModal" class="modal opacity-0 pointer-events-none fixed w-full h-full top-0 left-0 flex items-center justify-center z-[9999]">
        <div class="modal-overlay absolute w-full h-full bg-slate-900/60 backdrop-blur-sm" onclick="closeDetailsModal()"></div>
        
        <div class="modal-container bg-white w-11/12 md:max-w-2xl mx-auto rounded-3xl shadow-2xl z-50 overflow-y-auto max-h-[90vh]">
            <div class="px-8 py-5 bg-[#1a2a3a] text-white flex justify-between items-center rounded-t-3xl">
                <div>
                    <h3 class="text-sm font-black uppercase tracking-wider text-[#b8974d]" id="modalBookingId">#BK-00</h3>
                    <p class="text-xs text-gray-300">Detailed Trip Assignment Information</p>
                </div>
                <button onclick="closeDetailsModal()" class="text-gray-400 hover:text-white transition text-xl">&times;</button>
            </div>

            <div class="p-8 space-y-6">
                <div class="bg-gray-50 p-5 rounded-2xl border border-gray-100">
                    <h4 class="text-[10px] font-bold text-[#b8974d] uppercase tracking-widest mb-3"><i class="fas fa-user-tie mr-2"></i>Staff (Passenger Officer) Details</h4>
                    <div class="grid grid-cols-2 gap-4 text-xs">
                        <div>
                            <p class="text-[10px] text-gray-400 uppercase font-medium">Full Name</p>
                            <p class="font-bold text-gray-800 uppercase mt-0.5" id="modalStaffName">N/A</p>
                        </div>
                        <div>
                            <p class="text-[10px] text-gray-400 uppercase font-medium">Phone Number</p>
                            <p class="font-bold text-gray-800 mt-0.5">
                                <a id="modalPhoneLink" href="#" class="text-blue-600 hover:underline"><i class="fas fa-phone-alt text-[10px] mr-1"></i><span id="modalPhoneNumber">N/A</span></a>
                            </p>
                        </div>
                    </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div class="border border-gray-100 p-5 rounded-2xl bg-white shadow-sm">
                        <h4 class="text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-3"><i class="fas fa-route mr-2"></i>Route Info</h4>
                        <div class="space-y-3 text-xs">
                            <div>
                                <p class="text-[10px] text-gray-400 uppercase font-medium">Pickup Point</p>
                                <p class="font-bold text-gray-700 mt-0.5" id="modalPickupLoc">N/A</p>
                            </div>
                            <div>
                                <p class="text-[10px] text-gray-400 uppercase font-medium">Destination</p>
                                <p class="font-bold text-[#1a2a3a] text-sm uppercase mt-0.5" id="modalDestination">N/A</p>
                            </div>
                        </div>
                    </div>

                    <div class="border border-gray-100 p-5 rounded-2xl bg-white shadow-sm">
                        <h4 class="text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-3"><i class="fas fa-car mr-2"></i>Logistics & Time</h4>
                        <div class="grid grid-cols-2 gap-2 text-xs">
                            <div>
                                <p class="text-[10px] text-gray-400 uppercase font-medium">Vehicle Type</p>
                                <p class="font-bold text-gray-700 uppercase mt-0.5" id="modalVehicleType">N/A</p>
                            </div>
                            <div>
                                <p class="text-[10px] text-gray-400 uppercase font-medium">Total Passengers</p>
                                <p class="font-bold text-gray-700 mt-0.5"><span id="modalPassengers">0</span> Person(s)</p>
                            </div>
                            <div class="col-span-2 mt-1">
                                <p class="text-[10px] text-gray-400 uppercase font-medium">Shift Slot</p>
                                <p class="font-bold text-gray-700 mt-0.5" id="modalTripSlot">N/A</p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="bg-gray-50 p-5 rounded-2xl border border-gray-100 text-xs">
                    <h4 class="text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-2"><i class="fas fa-bullseye mr-2"></i>Purpose of Trip</h4>
                    <p class="text-gray-700 leading-relaxed font-medium" id="modalPurpose">No specific purpose stated.</p>
                </div>

                <div>
                    <a id="modalMapBtn" href="#" target="_blank" 
                       class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs py-3.5 rounded-xl flex items-center justify-center gap-2 transition shadow-md">
                        <i class="fas fa-map-marked-alt text-sm"></i> OPEN DESTINATION NAVIGATION (GOOGLE MAPS)
                    </a>
                </div>
            </div>

            <div class="px-8 py-4 bg-gray-50 flex justify-end rounded-b-3xl border-t border-gray-100">
                <button onclick="closeDetailsModal()" class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-6 py-2 rounded-xl text-xs font-bold transition">
                    Close Details
                </button>
            </div>
        </div>
    </div>

    <script>
        // Pengurusan Toast Update Status
        const toastParam = "<%= toastMsg != null ? toastMsg : "" %>";
        const toast = document.getElementById('toast');
        if (toastParam === 'status') {
            toast.classList.add('show');
            setTimeout(() => toast.classList.remove('show'), 4000);
        }

        // Fungsi Buka Modal & Isi Kandungan Data
        function openDetailsModal(id, staffName, phone, vehicle, slot, destination, pickup, mapLink, passengers, purpose, status) {
            document.getElementById('modalBookingId').innerText = "#BK-" + id + " (" + status + ")";
            document.getElementById('modalStaffName').innerText = staffName;
            document.getElementById('modalPhoneNumber').innerText = phone;
            document.getElementById('modalPhoneLink').href = "tel:" + phone;
            document.getElementById('modalVehicleType').innerText = vehicle;
            document.getElementById('modalTripSlot').innerText = slot;
            document.getElementById('modalDestination').innerText = destination;
            document.getElementById('modalPickupLoc').innerText = pickup;
            document.getElementById('modalPassengers').innerText = passengers;
            document.getElementById('modalPurpose').innerText = purpose ? purpose : "No specific purpose recorded.";
            
            const mapBtn = document.getElementById('modalMapBtn');
            if (mapLink && mapLink !== '#' && mapLink !== 'NULL') {
                mapBtn.href = mapLink;
                mapBtn.style.display = "flex";
            } else {
                mapBtn.style.display = "none";
            }

            const modal = document.getElementById('bookingModal');
            document.body.classList.add('modal-active');
            modal.classList.remove('opacity-0', 'pointer-events-none');
        }

        // Fungsi Tutup Modal
        function closeDetailsModal() {
            const modal = document.getElementById('bookingModal');
            document.body.classList.remove('modal-active');
            modal.classList.add('opacity-0', 'pointer-events-none');
        }
    </script>
</body>
</html>