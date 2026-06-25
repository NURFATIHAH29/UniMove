<%-- 
    Document   : manageReports
    Created on : 17 Jun 2026, 11:35:00 am
    Author     : fatihah
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    if (session.getAttribute("userName") == null || !"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("../Staff/login.jsp");
        return;
    }
    String fullName = (String) session.getAttribute("userName");
    String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
    String dbUser = "root";
    String dbPass = "admin";

    int activeAlerts = 0;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection c = DriverManager.getConnection(dbUrl, dbUser, dbPass);
        // Anda boleh tukar query ini mengikut nama table maintenance/reports sebenar anda
        ResultSet rs = c.createStatement().executeQuery("SELECT COUNT(*) FROM vehicles WHERE status='Maintenance'");
        if(rs.next()) activeAlerts = rs.getInt(1);
        c.close();
    } catch(Exception e) {}

    // Menjana Tarikh Semasa Secara Dinamik
    LocalDate today = LocalDate.now();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d MMM yyyy", Locale.ENGLISH);
    String currentDateStr = today.format(formatter);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Maintenance Reports | UVBS Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="../Style.css">
    <style>
        .nav-active { color: white !important; background-color: rgba(184, 151, 77, 0.1) !important; border-left: 4px solid #b8974d !important; }
    </style>
</head>
<body class="flex flex-col md:flex-row min-h-screen bg-gray-100">

    <aside class="hidden md:flex w-64 bg-[#1a2a3a] flex-col text-white shadow-xl fixed h-full z-50">
        <div class="p-8 text-center border-b border-gray-700">
            <i class="fas fa-user-shield text-5xl mb-3 text-[#b8974d]"></i>
            <h2 class="font-bold text-sm uppercase tracking-widest leading-tight"><%= fullName %></h2>
            <p class="text-[10px] text-gray-400 mt-1 uppercase tracking-tighter">System Admin</p>
        </div>
        <nav class="flex-grow mt-6">
            <a href="../Admin/adminDashboard.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 hover:text-white transition">
                <i class="fas fa-th-large w-5 text-center"></i> Dashboard
            </a>
            <a href="../Admin/adminApprovals.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 hover:text-white transition">
                <i class="fas fa-check-square w-5 text-center"></i> Booking Approvals
            </a>
            <a href="manageReports.jsp" class="nav-active flex items-center gap-4 px-8 py-4">
                <i class="fas fa-tools w-5 text-center"></i> Maintenance Reports
            </a>
            <a href="../Vehicle/manageVehicle.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 hover:text-white transition">
                <i class="fas fa-car-side w-5 text-center"></i> Vehicle Management
            </a>
            <a href="../driver/manageDrivers.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 hover:text-white transition">
                <i class="fas fa-user-tie w-5 text-center"></i> Driver Management
            </a>
            <a href="manageFeedback.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 hover:text-white transition">
                <i class="fas fa-comment-alt w-5 text-center"></i> User Feedback
            </a>
        </nav>
        <div class="p-4 mb-2">
            <a href="../LogoutServlet" class="bg-[#4a1d1f] hover:bg-red-900 flex items-center justify-center gap-3 px-6 py-3 text-white text-[11px] font-bold rounded-lg uppercase transition">
                <i class="fas fa-sign-out-alt rotate-180"></i> LOGOUT
            </a>
        </div>
    </aside>

    <main class="flex-grow md:ml-64 p-4 md:p-10">
        
        <header class="mb-8 flex justify-between items-start">
            <div>
                <h1 class="text-2xl font-bold text-[#1a2a3a]">Maintenance Reports</h1>
                <p class="text-sm text-gray-500 italic">Track, review, and manage active vehicle health alerts filed by drivers.</p>
            </div>
            <div class="bg-white px-4 py-2 rounded-xl shadow-sm border border-gray-100 flex items-center gap-2 mt-1">
                <i class="far fa-clock text-[#b8974d] text-xs"></i>
                <span class="text-xs font-bold text-[#1a2a3a] tracking-wide uppercase"><%= currentDateStr %></span>
            </div>
        </header>

        <div class="bg-white rounded-xl shadow-md border border-gray-100 overflow-hidden">
            <div class="p-6 bg-gray-50 border-b flex justify-between items-center">
                <div class="flex items-center gap-3">
                    <span class="p-2 bg-red-50 text-red-600 rounded-lg">
                        <i class="fas fa-exclamation-triangle"></i>
                    </span>
                    <div>
                        <h4 class="font-bold text-xs uppercase text-gray-700">Active Maintenance Alerts</h4>
                        <p class="text-[10px] text-gray-400 uppercase mt-0.5">Total unresolved issues: <%= activeAlerts %></p>
                    </div>
                </div>
                <span class="bg-red-100 text-red-700 text-[10px] font-bold px-3 py-1 rounded-full uppercase tracking-wider">Action Required</span>
            </div>
            
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead class="bg-white border-b text-[10px] uppercase font-bold text-gray-400">
                        <tr>
                            <th class="px-8 py-4">Vehicle Details</th>
                            <th class="px-8 py-4">Reported By</th>
                            <th class="px-8 py-4">Condition</th>
                            <th class="px-8 py-4">Driver's Note</th>
                            <th class="px-8 py-4 text-right">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 text-xs text-gray-700">
                        <%
                            try {
                                Connection c = DriverManager.getConnection(dbUrl, dbUser, dbPass);
                                // Sila tukar query ini berdasarkan design table reports / issues anda
                                String query = "SELECT v.model, v.plate_number, v.vehicle_id FROM vehicles v WHERE v.status='Maintenance' ORDER BY v.vehicle_id DESC";
                                Statement st = c.createStatement();
                                ResultSet rs = st.executeQuery(query);
                                boolean hasData = false;
                                while(rs.next()) {
                                    hasData = true;
                        %>
                        <tr class="hover:bg-gray-50 transition">
                            <td class="px-8 py-4">
                                <p class="font-bold text-gray-800 uppercase"><%= rs.getString("model") %></p>
                                <p class="text-[10px] text-blue-900 font-mono font-bold tracking-widest"><%= rs.getString("plate_number") %></p>
                            </td>
                            <td class="px-8 py-4 text-gray-500">Mhd Shahrul (Staff)</td>
                            <td class="px-8 py-4">
                                <span class="bg-red-50 text-red-600 px-2.5 py-0.5 rounded font-bold uppercase text-[9px] border border-red-200">
                                    Engine Issue
                                </span>
                            </td>
                            <td class="px-8 py-4 italic text-gray-400 max-w-xs truncate">
                                "Enjin keluar bunyi bising semasa bawa kelajuan 80km/j, lampu check engine menyala."
                            </td>
                            <td class="px-8 py-4 text-right">
                                <a href="resolveIssue.jsp?vid=<%= rs.getInt("vehicle_id") %>" class="px-4 py-1.5 bg-[#1a2a3a] hover:bg-green-700 text-white font-bold text-[10px] uppercase rounded-lg transition shadow-sm">
                                    Mark Resolved
                                </a>
                            </td>
                        </tr>
                        <% 
                                }
                                if(!hasData) {
                        %>
                        <tr>
                            <td colspan="5" class="px-8 py-12 text-center text-gray-400 bg-white">
                                <div class="flex flex-col items-center justify-center gap-2">
                                    <i class="fas fa-check-circle text-green-500 text-3xl"></i>
                                    <p class="italic text-xs font-medium text-gray-500">All vehicles are in good condition. No active reports from drivers</p>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                                c.close();
                            } catch(Exception e) {
                        %>
                        <tr><td colspan="5" class="p-4 text-center text-red-500">Error loading data: <%= e.getMessage() %></td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</body>
</html>