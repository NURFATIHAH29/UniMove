<%-- 
    Document   : profile
    Created on : 15 Jun 2026, 10:45:00 pm
    Author     : fatih
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // 1. Security Check & Anti-Back Protection
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session.getAttribute("userName") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String fullName = (String) session.getAttribute("userName");
    String userRole = (String) session.getAttribute("userRole");
    String userIC = (String) session.getAttribute("userIC"); 

    // Pembolehubah untuk memegang data tambahan jika ditarik dari DB
    String phoneNum = (session.getAttribute("userPhone") != null) ? (String) session.getAttribute("userPhone") : "Not Available";
    
    // 2. Database Configuration 
    String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
    String dbUser = "root";
    String dbPass = "admin"; 
    Connection conn = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
        
        // Cuba dapatkan nombor telefon terbaharu staf daripada table bookings jika ada
        String sql = "SELECT phone_number FROM bookings WHERE user_id = ? ORDER BY booking_id DESC LIMIT 1";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, userIC);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            phoneNum = rs.getString("phone_number");
        }
    } catch (Exception e) {
        // Jika error, dia akan kekalkan nilai default sedia ada
    } finally {
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Profile | UVBS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #f3f4f6; }
        
        .nav-link { 
            color: #9ca3af; 
            transition: all 0.3s; 
            display: flex; 
            align-items: center; 
            gap: 1rem; 
            padding: 1rem 2rem; 
            font-size: 0.875rem; 
        }
        .nav-link:hover { color: white; background-color: rgba(255,255,255,0.05); }
        .nav-active { 
            color: white; 
            background-color: rgba(255,255,255,0.1); 
            border-right: 4px solid white; 
        }
        .profile-card { background-color: white; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05), 0 2px 4px -1px rgba(0,0,0,0.03); }
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
                <a href="staffDashboard.jsp" class="nav-link">
                    <i class="fas fa-th-large w-5 text-center"></i> Dashboard
                </a>
                <a href="newBooking.jsp" class="nav-link">
                    <i class="fas fa-plus w-5 text-center"></i> New Booking
                </a>
                <a href="feedback.jsp" class="nav-link">
                    <i class="fas fa-comment-dots w-5 text-center"></i> Feedback
                </a>
                <a href="notifications.jsp" class="nav-link flex justify-between items-center pr-6">
                    <div class="flex items-center gap-4">
                        <i class="fas fa-bell w-5 text-center"></i> Notifications
                    </div>
                    <span id="notif-badge" class="hidden bg-red-500 text-white text-[10px] font-bold px-2 py-0.5 rounded-full min-w-[20px] text-center animate-pulse">0</span>
                </a>
                <a href="profile.jsp" class="nav-link nav-active">
                    <i class="fas fa-user-circle w-5 text-center"></i> Profile
                </a>
            </div>

            <div class="border-t border-gray-700/50 pt-4">
                <a href="../LogoutServlet" class="nav-link text-red-400 hover:bg-red-500/10 transition">
                    <i class="fas fa-sign-out-alt w-5 text-center"></i> Logout
                </a>
            </div>
        </nav>
    </aside>

    <main class="flex-grow md:ml-64 p-4 md:p-10">
        <div class="max-w-3xl mx-auto">
            <header class="mb-8">
                <h1 class="text-3xl font-bold text-gray-800 tracking-tight">My Profile</h1>
                <p class="text-sm text-gray-500 italic">View your personal account details and system credentials.</p>
            </header>

            <div class="profile-card rounded-2xl overflow-hidden border border-gray-100">
                <div class="h-32 bg-gradient-to-r align-middle from-[#1a2a3a] to-[#2c3e50] p-6 flex items-end">
                </div>

                <div class="px-8 pb-6 relative flex flex-col sm:flex-row items-center gap-6 border-b border-gray-100">
                    <div class="-mt-16 w-28 h-28 rounded-full border-4 border-white overflow-hidden shadow-md bg-white">
                        <img src="https://ui-avatars.com/api/?name=<%= fullName %>&background=b8974d&color=fff&size=128" class="w-full h-full object-cover">
                    </div>
                    <div class="text-center sm:text-left mt-2 sm:mt-4">
                        <h2 class="text-2xl font-bold text-gray-800 tracking-tight"><%= fullName %></h2>
                        <p class="text-xs font-semibold text-amber-600 bg-amber-50 inline-block px-3 py-1 rounded-full mt-1 border border-amber-200/50 uppercase tracking-wider"><i class="fas fa-id-badge mr-1"></i> <%= userRole %></p>
                    </div>
                </div>

                <div class="p-8 space-y-6">
                    <h3 class="text-sm font-bold text-gray-400 uppercase tracking-wider mb-4"><i class="fas fa-info-circle mr-2"></i> Account Details</h3>
                    
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div class="bg-gray-50 p-4 rounded-xl border border-gray-200/60">
                            <label class="block text-xs font-bold text-gray-400 uppercase">Full Name</label>
                            <span class="block text-sm font-semibold text-gray-700 mt-1 uppercase"><%= fullName %></span>
                        </div>

                        <div class="bg-gray-50 p-4 rounded-xl border border-gray-200/60">
                            <label class="block text-xs font-bold text-gray-400 uppercase">IC / Identification Number</label>
                            <span class="block text-sm font-semibold text-gray-700 mt-1"><%= userIC %></span>
                        </div>

                        <div class="bg-gray-50 p-4 rounded-xl border border-gray-200/60">
                            <label class="block text-xs font-bold text-gray-400 uppercase">Phone Number</label>
                            <span class="block text-sm font-semibold text-gray-700 mt-1"><%= phoneNum %></span>
                        </div>

                        <div class="bg-gray-50 p-4 rounded-xl border border-gray-200/60">
                            <label class="block text-xs font-bold text-gray-400 uppercase">Access Group</label>
                            <span class="block text-sm font-semibold text-gray-700 mt-1 uppercase"><%= userRole %> Portal</span>
                        </div>
                    </div>
                    
                    <div class="mt-8 p-4 bg-blue-50/70 border border-blue-200 rounded-xl flex items-start gap-3">
                        <i class="fas fa-shield-alt text-blue-500 mt-0.5"></i>
                        <p class="text-xs text-blue-700 leading-relaxed">
                            <b>Security Reminder:</b> These profile properties are controlled by the University Vehicle Booking System (UVBS) secure user environment. If your identification credentials or department roles require updates, kindly contact your system registry administrator.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <script>
        function checkNotificationCount() {
            const servletUrl = "../NotificationCountServlet";

            fetch(servletUrl)
                .then(res => {
                    if (!res.ok) throw new Error("HTTP error! Status: " + res.status);
                    return res.json();
                })
                .then(data => {
                    const badge = document.getElementById('notif-badge');
                    if (badge) {
                        if (data.count > 0) {
                            badge.innerText = data.count > 99 ? '99+' : data.count;
                            badge.classList.remove('hidden'); 
                        } else {
                            badge.classList.add('hidden'); 
                        }
                    }
                })
                .catch(err => console.error("Ralat semakan notifikasi:", err));
        }

        document.addEventListener("DOMContentLoaded", function() {
            checkNotificationCount();
            setInterval(checkNotificationCount, 5000); // Poll status every 5 seconds
        });
    </script>
</body>
</html>