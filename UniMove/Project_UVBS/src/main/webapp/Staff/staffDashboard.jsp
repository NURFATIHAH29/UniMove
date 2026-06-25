<%-- 
    Document   : staffDashboard
    Created on : 27 Apr 2026
    Author     : fatihah
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "0");

    if (session.getAttribute("userName") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String fullName = (String) session.getAttribute("userName");
    String userRole = (String) session.getAttribute("userRole");
    String userIC = (String) session.getAttribute("userIC"); 

    String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
    String dbUser = "root";
    String dbPass = "admin"; 

    int pendingCount = 0;
    int confirmedCount = 0;
    int completedCount = 0;

    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        String sqlStats = "SELECT status, COUNT(*) as total FROM bookings WHERE user_id = ? GROUP BY status";
        PreparedStatement psStats = conn.prepareStatement(sqlStats);
        psStats.setString(1, userIC);
        ResultSet rsStats = psStats.executeQuery();

        while (rsStats.next()) {
            String status = rsStats.getString("status");
            int total = rsStats.getInt("total");
            if ("Pending".equalsIgnoreCase(status) || "Pending Approval".equalsIgnoreCase(status)) pendingCount = total;
            else if ("Confirmed".equalsIgnoreCase(status) || "Approved".equalsIgnoreCase(status)) confirmedCount = total;
            else if ("Completed".equalsIgnoreCase(status)) completedCount = total;
        }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Dashboard | UVBS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #f3f4f6; }
        .nav-link { color: #9ca3af; transition: all 0.3s; display: flex; align-items: center; gap: 1rem; padding: 1rem 2rem; font-size: 0.875rem; }
        .nav-link:hover { color: white; background-color: rgba(255,255,255,0.05); }
        .nav-active { color: white; background-color: rgba(255,255,255,0.1); border-right: 4px solid white; }
        dialog::backdrop { background: rgba(0, 0, 0, 0.5); backdrop-filter: blur(4px); }
        dialog[open] { animation: slideUp 0.3s ease-out; }
        @keyframes slideUp { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
    </style>
</head>
<body class="flex flex-col md:flex-row min-h-screen">
    
    <aside class="hidden md:flex w-64 bg-[#1a2a3a] flex-col text-white fixed top-0 bottom-0 left-0 z-50">
        <div class="p-8 text-center border-b border-gray-700/50">
            <img src="https://ui-avatars.com/api/?name=<%= fullName %>&background=b8974d&color=fff" class="w-16 h-16 rounded-full border-2 border-gray-600 mx-auto mb-4">
            <h2 class="font-bold text-xs uppercase tracking-widest"><%= fullName %></h2>
            <p class="text-[10px] text-gray-400 mt-1 uppercase">Role: <%= userRole %></p>
        </div>
        <nav class="flex-grow flex flex-col justify-between py-4">
            <div>
                <a href="staffDashboard.jsp" class="nav-link nav-active"><i class="fas fa-th-large w-5 text-center"></i> Dashboard</a>
                <a href="newBooking.jsp" class="nav-link"><i class="fas fa-plus w-5 text-center"></i> New Booking</a>
                <a href="feedback.jsp" class="nav-link"><i class="fas fa-comment-dots w-5 text-center"></i> Feedback</a>
                <a href="notifications.jsp" class="nav-link"><i class="fas fa-bell w-5 text-center"></i> Notifications</a>
                <a href="profile.jsp" class="nav-link"><i class="fas fa-user-circle w-5 text-center"></i> Profile</a>
            </div>
            <div class="border-t border-gray-700/50 pt-4">
                <a href="../LogoutServlet" class="nav-link text-red-400 hover:bg-red-500/10 transition"><i class="fas fa-sign-out-alt w-5 text-center"></i> Logout</a>
            </div>
        </nav>
    </aside>

    <main class="flex-grow md:ml-64 p-4 md:p-10">
        <header class="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
            <div>
                <h1 class="text-3xl font-bold text-gray-800 tracking-tight">Operational Overview</h1>
                <p class="text-sm text-gray-500 italic">Welcome back, <%= fullName %>.</p>
            </div>
            <a href="newBooking.jsp" class="bg-[#1a2a3a] text-white px-6 py-3 rounded-xl font-bold text-[11px] shadow-sm uppercase tracking-widest hover:bg-slate-800 transition text-center">
                <i class="fas fa-plus mr-2"></i> NEW BOOKING REQUEST
            </a>
        </header>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 border-l-4 border-l-yellow-500">
                <p class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Pending Approval</p>
                <p class="text-2xl font-black text-gray-800 mt-1"><%= pendingCount %></p>
            </div>
            <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 border-l-4 border-l-green-500">
                <p class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Confirmed & Approved Trips</p>
                <p class="text-2xl font-black text-gray-800 mt-1"><%= confirmedCount %></p>
            </div>
            <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 border-l-4 border-l-blue-500">
                <p class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Total Completed</p>
                <p class="text-2xl font-black text-gray-800 mt-1"><%= completedCount %></p>
            </div>
        </div>

        <div class="bg-white rounded-2xl shadow-sm overflow-hidden border border-gray-200">
            <div class="p-5 border-b flex justify-between items-center bg-gray-50/70">
                <h4 class="font-bold text-gray-700 uppercase text-[10px] tracking-widest">Your Recent Booking Activity</h4>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead class="bg-white text-[10px] uppercase font-bold text-gray-400 border-b">
                        <tr>
                            <th class="px-6 py-4">Booking ID</th>
                            <th class="px-6 py-4">Start Date</th>
                            <th class="px-6 py-4">Route</th>
                            <th class="px-6 py-4">Trip Assignment Info</th>
                            <th class="px-6 py-4 text-center">Status</th>
                            <th class="px-6 py-4 text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        <%
                            String sqlTable = "SELECT b.*, " +
                                              "(SELECT GROUP_CONCAT(d.full_name SEPARATOR ' & ') FROM drivers d WHERE FIND_IN_SET(d.driver_id, b.assigned_driver_id) > 0) AS multiple_drivers, " +
                                              "(SELECT GROUP_CONCAT(d.phone_number SEPARATOR ' / ') FROM drivers d WHERE FIND_IN_SET(d.driver_id, b.assigned_driver_id) > 0) AS multiple_phones, " +
                                              "(SELECT GROUP_CONCAT(v.plate_number SEPARATOR ' , ') FROM vehicles v WHERE FIND_IN_SET(v.vehicle_id, b.assigned_vehicle_id) > 0) AS multiple_plates, " +
                                              "(SELECT GROUP_CONCAT(v.model SEPARATOR ' & ') FROM vehicles v WHERE FIND_IN_SET(v.vehicle_id, b.assigned_vehicle_id) > 0) AS multiple_models " +
                                              "FROM bookings b " +
                                              "WHERE b.user_id = ? " +
                                              "ORDER BY b.created_at DESC LIMIT 10";
                                              
                            PreparedStatement psTable = conn.prepareStatement(sqlTable);
                            psTable.setString(1, userIC);
                            ResultSet rsTable = psTable.executeQuery();

                            boolean hasData = false;
                            while (rsTable.next()) {
                                hasData = true;
                                int bID = rsTable.getInt("booking_id");
                                int qtyBooked = rsTable.getInt("vehicle_quantity");
                                String status = rsTable.getString("status");
                                
                                String driverNames = rsTable.getString("multiple_drivers");
                                String driverPhones = rsTable.getString("multiple_phones");
                                
                                String plateNumber = rsTable.getString("multiple_plates");
                                String vehicleModel = rsTable.getString("multiple_models");
                                String pickup = rsTable.getString("pickup_location");
                                
                                String badgeClass = "bg-yellow-100 text-yellow-600";
                                if("Confirmed".equalsIgnoreCase(status) || "Approved".equalsIgnoreCase(status)) {
                                    badgeClass = "bg-green-100 text-green-600";
                                } else if("Rejected".equalsIgnoreCase(status) || "Cancelled by Admin".equalsIgnoreCase(status)) {
                                    badgeClass = "bg-red-100 text-red-600";
                                } else if("Completed".equalsIgnoreCase(status)) {
                                    badgeClass = "bg-blue-100 text-blue-600";
                                }
                        %>
                        <tr class="hover:bg-gray-50/80 transition">
                            <td class="px-6 py-4 font-mono text-xs text-gray-600">#BK-<%= bID %></td>
                            <td class="px-6 py-4 font-medium text-xs text-gray-700"><%= rsTable.getString("start_date") %></td>
                            <td class="px-6 py-4 text-xs text-gray-500">
                                <%= pickup %> <i class="fas fa-arrow-right mx-2 text-[9px] text-gray-400"></i> <%= rsTable.getString("destination") %>
                            </td>
<td class="px-6 py-4">
    <%-- FIXED: Ditambah semakan status "In-Progress" supaya butang maklumat pemandu tidak hilang semasa trip berjalan --%>
    <% if ("Confirmed".equalsIgnoreCase(status) || "Approved".equalsIgnoreCase(status) || "In-Progress".equalsIgnoreCase(status)) { %>
        <button onclick="document.getElementById('modal-<%= bID %>').showModal()" 
                class="bg-blue-50 text-blue-600 border border-blue-100 px-3 py-1.5 rounded-xl text-[10px] font-bold hover:bg-blue-600 hover:text-white transition-all flex items-center gap-2">
            <i class="fas fa-eye"></i> CLICK FOR DETAILS
        </button>

        <dialog id="modal-<%= bID %>" class="rounded-2xl shadow-2xl p-0 w-11/12 max-w-md backdrop:bg-gray-900/50">
            <div class="p-6">
                <div class="flex justify-between items-center mb-6">
                    <h3 class="text-base font-bold text-gray-800">Trip Assignment Details</h3>
                    <form method="dialog">
                        <button class="text-gray-400 hover:text-gray-600"><i class="fas fa-times"></i></button>
                    </form>
                </div>

                <div class="space-y-4">
                    <div class="bg-blue-50 p-4 rounded-xl border border-blue-100">
                        <p class="text-[10px] font-black text-blue-400 uppercase mb-1">Specific Pickup Point</p>
                        <p class="text-xs font-bold text-blue-900"><i class="fas fa-map-pin mr-2"></i><%= pickup %></p>
                    </div>

                    <div class="flex items-start gap-4 p-3 border border-gray-100 rounded-xl">
                        <div class="bg-gray-50 w-12 h-12 rounded-full flex items-center justify-center text-gray-400 text-base flex-shrink-0 mt-1">
                            <i class="fas fa-user-tie"></i>
                        </div>
                        <div class="w-full">
                            <p class="text-[10px] font-bold text-gray-400 uppercase">Driver Assignment</p>
                            <% if (driverNames != null && !driverNames.trim().isEmpty()) { %>
                                <p class="text-xs font-bold text-gray-800 mt-0.5 whitespace-normal break-words"><%= driverNames %></p>
                                <div class="text-[11px] text-blue-600 font-semibold block mt-1 whitespace-normal break-words">
                                    <i class="fas fa-phone-alt mr-1"></i> <%= driverPhones %>
                                </div>
                            <% } else { %>
                                <p class="text-xs italic text-gray-400 mt-0.5">Awaiting Driver Allocation...</p>
                            <% } %>
                        </div>
                    </div>

                    <div class="flex items-start gap-4 p-3 border border-gray-100 rounded-xl">
                        <div class="bg-gray-50 w-12 h-12 rounded-full flex items-center justify-center text-gray-400 text-base flex-shrink-0 mt-1">
                            <i class="fas fa-bus"></i>
                        </div>
                        <div class="w-full">
                            <p class="text-[10px] font-bold text-gray-400 uppercase">Vehicle Assignment (<%= qtyBooked %> Unit)</p>
                            <% if (plateNumber != null && !plateNumber.trim().isEmpty()) { %>
                                <div class="mt-1 bg-gray-50 p-2.5 rounded-lg border border-gray-100 font-mono text-xs text-blue-700 font-bold tracking-wider whitespace-normal break-words">
                                    <%= plateNumber %>
                                </div>
                                <p class="text-[10px] text-gray-500 font-medium mt-1 italic whitespace-normal break-words"><%= vehicleModel %></p>
                            <% } else { %>
                                <p class="text-xs italic text-gray-400 mt-0.5">Awaiting Vehicle Allocation...</p>
                            <% } %>
                        </div>
                    </div>
                </div>

                <form method="dialog" class="mt-6">
                    <button class="w-full bg-gray-800 text-white py-3 rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-black transition">Close Window</button>
                </form>
            </div>
        </dialog>
    <% } else if ("Rejected".equalsIgnoreCase(status) || "Cancelled by Admin".equalsIgnoreCase(status)) { %>
        <span class="text-red-400 text-[10px] italic font-medium">Request Declined / Cancelled</span>
    <% } else if ("Completed".equalsIgnoreCase(status)) { %>
        <span class="text-blue-400 text-[10px] italic font-medium">Trip Completed</span>
    <% } else { %>
        <span class="text-gray-400 text-[10px] italic">Awaiting System Allocation...</span>
    <% } %>
</td>
                            <td class="px-6 py-4 text-center">
                                <span class="px-3 py-1 rounded-full text-[9px] font-black uppercase tracking-wider <%= badgeClass %>">
                                    <%= status %>
                                </span>
                            </td>
                            <td class="px-6 py-4 text-center">
                                <form action="${pageContext.request.contextPath}/DeleteBookingServlet" method="POST" onsubmit="return confirm('Are you sure you want to delete this booking from the system?');">
                                    <input type="hidden" name="booking_id" value="<%= bID %>">
                                    <button type="submit" class="text-red-500 hover:text-red-700 bg-red-50 hover:bg-red-100 p-2 rounded-xl transition-all">
                                        <i class="fas fa-trash-alt"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <%  
                            } 
                            if (!hasData) { 
                        %>
                        <tr>
                            <td colspan="6" class="px-6 py-20 text-center text-gray-400 text-xs italic">No recent booking activity found.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <%-- DETECT & DISPLAY CRITICAL UNREAD NOTIFICATIONS FROM DB             --%>

    <%
        if (userIC != null) {
            PreparedStatement psNotifCheck = null;
            ResultSet rsNotifCheck = null;
            try {
                String sqlNotifCheck = "SELECT notification_id, message FROM notifications WHERE user_id = ? AND is_read = 0 ORDER BY created_at DESC LIMIT 1";
                psNotifCheck = conn.prepareStatement(sqlNotifCheck);
                psNotifCheck.setString(1, userIC);
                rsNotifCheck = psNotifCheck.executeQuery();

                if (rsNotifCheck.next()) {
                    int databaseNotifId = rsNotifCheck.getInt("notification_id");
                    String alertContent = rsNotifCheck.getString("message");
    %>
                    <script>
                        document.addEventListener("DOMContentLoaded", function() {
                            Swal.fire({
                                icon: 'error',
                                title: '<span style="color: #dc2626; font-weight: 900; tracking-wide"><i class="fas fa-exclamation-triangle"></i> CRITICAL NOTIFICATION</span>',
                                html: `<div style="text-align: left; font-size: 0.875rem; padding: 0.75rem; background-color: #fef2f2; border: 1px solid #fee2e2; border-radius: 0.75rem; color: #374151;">
                                         <p style="font-weight: 500; color: #991b1b; line-height: 1.6;"><%= alertContent.replace("'", "\\'").replace("\n", " ").replace("\r", "") %></p>
                                       </div>`,
                                confirmButtonText: 'I UNDERSTAND & ACKNOWLEDGE',
                                confirmButtonColor: '#dc2626',
                                allowOutsideClick: false,
                                allowEscapeKey: false
                            }).then((result) => {
                                if (result.isConfirmed) {
                                    // FIXED: Menambah tanda petik tunggal '' dan menukar parameter kepada ?id= bagi menyokong fail pemprosesan
                                    fetch('markAsRead.jsp?id=' + '<%= databaseNotifId %>')
                                    .then(res => {
                                        if(res.ok) {
                                            console.log("Notification read status successfully updated.");
                                        } else {
                                            console.error("Server returned an error when updating status.");
                                        }
                                    })
                                    .catch(err => console.error("AJAX Error:", err));
                                }
                            });
                        });
                    </script>
    <%
                }
            } catch (Exception ex) {
                System.out.println("Pop-up processing error: " + ex.getMessage());
            } finally {
                if (rsNotifCheck != null) rsNotifCheck.close();
                if (psNotifCheck != null) psNotifCheck.close();
            }
        }
    %>

    <%
        String statusParam = request.getParameter("deleteStatus");
        if ("success".equals(statusParam)) {
    %>
        <script>alert("Booking successfully deleted from the system!");</script>
    <%
        } else if ("not_found".equals(statusParam) || "invalid_id".equals(statusParam)) {
    %>
        <script>alert("Error: Booking record not found.");</script>
    <%
        } else if ("error".equals(statusParam)) {
    %>
        <script>alert("Failed to delete booking. A database constraint occurred.");</script>
    <%
        }
    %>
</body>
</html>
<%
    } catch (Exception e) {
        out.println("<div class='m-10 p-5 bg-red-100 text-red-700 rounded-xl border border-red-300 font-bold'>Error: " + e.getMessage() + "</div>");
    } finally {
        if (conn != null) conn.close();
    }
%>