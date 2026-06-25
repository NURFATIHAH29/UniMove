<%-- 
    Document   : driverProfile
    Created on : 18 May 2026, 12:32:11 am
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

    String driverFullName = ""; String staffId = ""; String licenseClass = "";
    String phoneNumber = ""; String emergencyContact = "N/A"; String currentStatus = "AVAILABLE";

    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/uvbs_db", "root", "admin");
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM drivers WHERE driver_id = ?");
        ps.setInt(1, (driverId != null ? driverId : 0));
        ResultSet rs = ps.executeQuery();
        if(rs.next()) {
            driverFullName = rs.getString("full_name");
            staffId = rs.getString("staff_id");
            licenseClass = rs.getString("license_class");
            phoneNumber = rs.getString("phone_number");
            currentStatus = rs.getString("status");
            
            // Tarik data emergency contact dari database
            String emg = rs.getString("emergency_contact");
            if(emg != null && !emg.trim().isEmpty()) {
                emergencyContact = emg;
            }
        }
    } catch(Exception e) {
        System.out.println("Profile error: " + e.getMessage());
    } finally {
        if(conn != null) conn.close();
    }

    String statusColor = "green"; String statusIcon = "fa-check-circle";
    if("ON TRIP".equals(currentStatus)) { statusColor = "blue"; statusIcon = "fa-clock"; }
    else if("OFF DUTY".equals(currentStatus)) { statusColor = "red"; statusIcon = "fa-power-off"; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Driver Profile | UVBS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>body, h1, h2, h3, h4, p, span { font-family: 'Public Sans', sans-serif !important; }</style>
</head>
<body class="bg-[#f8f9fa] min-h-screen flex">

    <aside class="w-64 bg-[#1a2a3a] text-white fixed h-full flex flex-col shadow-xl z-50">
        <div class="p-8 text-center border-b border-white/10">
            <div class="w-16 h-16 bg-[#b8974d] rounded-full flex items-center justify-center text-xl font-bold mx-auto mb-4">
                <%= fullName != null && !fullName.isEmpty() ? fullName.substring(0,1).toUpperCase() : "?" %>
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
            <a href="driverHistory.jsp" class="flex items-center gap-4 px-8 py-4 text-gray-400 hover:text-white transition"><i class="fas fa-history w-5"></i> Trip History</a>
            <a href="driverProfile.jsp" class="flex items-center gap-4 px-8 py-4 bg-white/10 border-l-4 border-[#b8974d] text-white"><i class="fas fa-user w-5"></i> Profile</a>
        </nav>
        <div class="p-4 mb-4">
            <a href="../LogoutServlet" class="bg-[#4a1d1f] w-full flex items-center justify-center gap-2 py-3 rounded-lg text-[10px] font-bold uppercase hover:opacity-90 transition text-white">
                <i class="fas fa-sign-out-alt"></i> Logout
            </a>
        </div>
    </aside>

    <main class="ml-64 flex-grow p-10">
        <header class="mb-10">
            <h1 class="text-3xl font-bold text-[#1a2a3a]">My Profile</h1>
            <p class="text-gray-500 text-sm">Your personal information and credentials.</p>
        </header>

        <div class="max-w-2xl">
            <!-- Profile Card -->
            <div class="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden mb-6">
                <div class="bg-[#1a2a3a] px-8 py-10 text-center">
                    <div class="w-20 h-20 bg-[#b8974d] rounded-full flex items-center justify-center text-2xl font-bold mx-auto mb-4 text-white">
                        <%= driverFullName.isEmpty() ? "?" : driverFullName.substring(0,1).toUpperCase() %>
                    </div>
                    <h2 class="text-white font-bold text-lg uppercase"><%= driverFullName %></h2>
                    <p class="text-gray-400 text-xs mt-1">Driver | UVBS</p>
                    <div class="mt-3 inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[9px] font-bold uppercase
                        <%= "green".equals(statusColor) ? "bg-green-500/20 text-green-400" :
                            "blue".equals(statusColor) ? "bg-blue-500/20 text-blue-400" :
                            "bg-red-500/20 text-red-400" %>">
                        <i class="fas <%= statusIcon %> text-[8px]"></i> <%= currentStatus %>
                    </div>
                </div>

                <div class="p-8 space-y-5">
                    <!-- Seksyen 1: Sistem & Pengenalan (ID Staff & ID Pemandu disusun bersebelahan) -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div class="flex items-center gap-4 p-4 bg-gray-50 rounded-xl">
                            <div class="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center shrink-0">
                                <i class="fas fa-id-card text-blue-500 text-sm"></i>
                            </div>
                            <div>
                                <p class="text-[9px] font-bold text-gray-400 uppercase tracking-widest">Staff ID</p>
                                <p class="font-bold text-gray-800 text-sm uppercase"><%= staffId %></p>
                            </div>
                        </div>

                        <div class="flex items-center gap-4 p-4 bg-gray-50 rounded-xl">
                            <div class="w-10 h-10 bg-purple-100 rounded-xl flex items-center justify-center shrink-0">
                                <i class="fas fa-hashtag text-purple-500 text-sm"></i>
                            </div>
                            <div>
                                <p class="text-[9px] font-bold text-gray-400 uppercase tracking-widest">Driver ID</p>
                                <p class="font-bold text-gray-800 text-sm">#<%= driverId %></p>
                            </div>
                        </div>
                    </div>

                    <!-- Seksyen 2: Maklumat Lesen -->
                    <div class="flex items-center gap-4 p-4 bg-gray-50 rounded-xl">
                        <div class="w-10 h-10 bg-[#b8974d]/10 rounded-xl flex items-center justify-center shrink-0">
                            <i class="fas fa-certificate text-[#b8974d] text-sm"></i>
                        </div>
                        <div>
                            <p class="text-[9px] font-bold text-gray-400 uppercase tracking-widest">License Class</p>
                            <p class="font-bold text-gray-800 text-sm uppercase"><%= licenseClass %></p>
                        </div>
                    </div>

                    <!-- Seksyen 3: Hubungan & Kecemasan (Disusun bersebelahan untuk perbandingan mudah) -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div class="flex items-center gap-4 p-4 bg-gray-50 rounded-xl">
                            <div class="w-10 h-10 bg-green-100 rounded-xl flex items-center justify-center shrink-0">
                                <i class="fas fa-phone text-green-500 text-sm"></i>
                            </div>
                            <div>
                                <p class="text-[9px] font-bold text-gray-400 uppercase tracking-widest">Phone Number</p>
                                <p class="font-bold text-gray-800 text-sm"><%= phoneNumber %></p>
                            </div>
                        </div>

                        <div class="flex items-center gap-4 p-4 bg-red-50 rounded-xl border border-red-100">
                            <div class="w-10 h-10 bg-red-100 rounded-xl flex items-center justify-center shrink-0">
                                <i class="fas fa-ambulance text-red-500 text-sm"></i>
                            </div>
                            <div>
                                <p class="text-[9px] font-bold text-red-400 uppercase tracking-widest">Emergency Contact</p>
                                <p class="font-bold text-red-700 text-sm"><%= emergencyContact %></p>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </main>
</body>
</html>