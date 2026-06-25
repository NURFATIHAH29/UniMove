<%-- 
    Document   : driverHistory
    Created on : 18 May 2026, 12:31:28 am
    Author     : user
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userName") == null) {
        response.sendRedirect("../Staff/login.jsp");
        return;
    }
    String fullName = (String) session.getAttribute("userName");
    Integer driverId = (Integer) session.getAttribute("driverId");
    String driverIdStr = (driverId != null) ? String.valueOf(driverId) : "";

    String currentStatus = "AVAILABLE";
    Connection connStat = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        connStat = DriverManager.getConnection("jdbc:mysql://localhost:3306/uvbs_db", "root", "admin");
        PreparedStatement psStat = connStat.prepareStatement("SELECT status FROM drivers WHERE driver_id = ?");
        psStat.setInt(1, (driverId != null ? driverId : 0));
        ResultSet rsStat = psStat.executeQuery();
        if (rsStat.next()) currentStatus = rsStat.getString("status");
    } catch (Exception e) {
        System.out.println("Error: " + e.getMessage());
    } finally {
        if (connStat != null) connStat.close();
    }

    String statusColor = "green"; String statusIcon = "fa-check-circle";
    if("ON TRIP".equals(currentStatus)) { statusColor = "blue"; statusIcon = "fa-clock"; }
    else if("OFF DUTY".equals(currentStatus)) { statusColor = "red"; statusIcon = "fa-power-off"; }

    // Kira total completed (TUKAR KE 'COMPLETED')
    int totalCompleted = 0;
    Connection connCount = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        connCount = DriverManager.getConnection("jdbc:mysql://localhost:3306/uvbs_db", "root", "admin");
        PreparedStatement psC = connCount.prepareStatement(
            "SELECT COUNT(*) FROM bookings WHERE assigned_driver_id = ? AND status = 'COMPLETED'");
        psC.setString(1, driverIdStr);
        ResultSet rsC = psC.executeQuery();
        if(rsC.next()) totalCompleted = rsC.getInt(1);
    } catch(Exception e) {
        System.out.println(e.getMessage());
    } finally {
        if(connCount != null) connCount.close();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Trip History | UVBS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>body, h1, h2, h3, h4, p, span, table { font-family: 'Public Sans', sans-serif !important; }</style>
</head>
<body class="bg-[#f8f9fa] min-h-screen flex">

    <aside class="w-64 bg-[#1a2a3a] text-white fixed h-full flex flex-col shadow-xl z-50">
        <div class="p-8 text-center border-b border-white/10">
            <div class="w-16 h-16 bg-[#b8974d] rounded-full flex items-center justify-center text-xl font-bold mx-auto mb-4">
                <%= fullName.substring(0,1).toUpperCase() %>
            </div>
            <h2 class="text-xs font-bold uppercase tracking-widest">Driver</h2>
            <p class="text-[10px] text-gray-400 mt-1"><%= fullName %></p>
            <div class="mt-3 inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[9px] font-bold uppercase
                <%= "green".equals(statusColor) ? "bg-green-500/20 text-green-400" :
                    "blue".equals(statusColor) ? "bg-blue-500/20 text-blue-400" :
                    "bg-red-500/20 text-red-400" %>">
                <i class="fas <%= statusIcon %> text-[8px]"></i> <%= currentStatus %>
            </div>
        </div>
        <nav class="flex-grow mt-6">
            <a href="driverDashboard.jsp" class="flex items-center gap-4 px-8 py-4 text-gray-400 hover:text-white transition"><i class="fas fa-th-large w-5"></i> Dashboard</a>
            <a href="driverSchedule.jsp" class="flex items-center gap-4 px-8 py-4 text-gray-400 hover:text-white transition"><i class="fas fa-calendar-alt w-5"></i> Schedule</a>
            <a href="driverHistory.jsp" class="flex items-center gap-4 px-8 py-4 bg-white/10 border-l-4 border-[#b8974d] text-white"><i class="fas fa-history w-5"></i> Trip History</a>
            <a href="driverProfile.jsp" class="flex items-center gap-4 px-8 py-4 text-gray-400 hover:text-white transition"><i class="fas fa-user w-5"></i> Profile</a>
        </nav>
        <div class="p-4 mb-4">
            <a href="../LogoutServlet" class="bg-[#4a1d1f] w-full flex items-center justify-center gap-2 py-3 rounded-lg text-[10px] font-bold uppercase hover:opacity-90 transition text-white">
                <i class="fas fa-sign-out-alt"></i> Logout
            </a>
        </div>
    </aside>

    <main class="ml-64 flex-grow p-10">
        <header class="mb-10">
            <h1 class="text-3xl font-bold text-[#1a2a3a]">Trip History</h1>
            <p class="text-gray-500 text-sm">All completed trips assigned to you.</p>
        </header>

        <div class="grid grid-cols-3 gap-6 mb-10">
            <div class="bg-white p-6 rounded-2xl shadow-sm border-l-4 border-[#b8974d]">
                <h3 class="text-gray-400 text-[10px] font-bold uppercase tracking-widest">Total Trips Completed</h3>
                <p class="text-3xl font-bold text-gray-800 mt-1"><%= String.format("%02d", totalCompleted) %></p>
            </div>
        </div>

        <div class="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden">
            <div class="px-6 py-4 bg-gray-50/50 border-b border-gray-100">
                <h4 class="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Completed Trips Record</h4>
            </div>
            <table class="w-full text-left">
                <thead class="bg-gray-50 text-[10px] font-bold text-gray-400 uppercase border-b">
                    <tr>
                        <th class="px-6 py-4">Booking ID</th>
                        <th class="px-6 py-4">Destination</th>
                        <th class="px-6 py-4">Trip Date</th>
                        <th class="px-6 py-4">Slot</th>
                        <th class="px-6 py-4">Status</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                <%
                    Connection connHist = null;
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        connHist = DriverManager.getConnection("jdbc:mysql://localhost:3306/uvbs_db", "root", "admin");
                        
                        // Query tukar ke 'COMPLETED' & setString
                        String sql = "SELECT * FROM bookings WHERE assigned_driver_id = ? AND status = 'COMPLETED' ORDER BY start_date DESC";
                        PreparedStatement ps = connHist.prepareStatement(sql);
                        ps.setString(1, driverIdStr);
                        
                        ResultSet rs = ps.executeQuery();
                        boolean hasData = false;
                        while(rs.next()) {
                            hasData = true;
                %>
                    <tr class="hover:bg-gray-50 transition">
                        <td class="px-6 py-4 font-bold text-gray-600">#BK-<%= rs.getInt("booking_id") %></td>
                        <td class="px-6 py-4 font-medium uppercase"><%= rs.getString("destination") %></td>
                        <td class="px-6 py-4 text-[11px] text-gray-500"><%= rs.getDate("start_date") %></td>
                        <td class="px-6 py-4 text-[11px] text-gray-500"><%= rs.getString("trip_slot") %></td>
                        <td class="px-6 py-4">
                            <span class="bg-emerald-100 text-emerald-700 text-[9px] font-bold px-2 py-1 rounded uppercase">
                                ✓ Completed
                            </span>
                        </td>
                    </tr>
                <%      }
                        if(!hasData) { %>
                    <tr>
                        <td colspan="5" class="p-16 text-center">
                            <i class="fas fa-road text-5xl text-gray-200 mb-4 block"></i>
                            <p class="text-gray-400 font-medium text-sm">No completed trips yet.</p>
                            <p class="text-gray-300 text-xs mt-1">Completed trips will appear here.</p>
                        </td>
                    </tr>
                <%      }
                    } catch(Exception e) {
                        out.println("<tr><td colspan='5' class='p-4 text-red-500'>Error: " + e.getMessage() + "</td></tr>");
                    } finally {
                        if(connHist != null) connHist.close();
                    }
                %>
                </tbody>
            </table>
        </div>

        <footer class="mt-10 text-center">
            <p class="text-[10px] text-gray-400 font-bold uppercase tracking-[0.2em]">© 2026 UVBS | Driver Portal</p>
        </footer>
    </main>
</body>
</html>