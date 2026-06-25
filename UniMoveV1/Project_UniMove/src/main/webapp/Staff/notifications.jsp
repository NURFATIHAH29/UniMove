<%-- 
    Document   : notifications
    Created on : 27 Apr 2026, 10:49:23 pm
    Author     : fatihah
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

    // 2. Database Configuration
    String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
    String dbUser = "root";
    String dbPass = "admin"; 

    Connection conn = null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notifications | UVBS</title>
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

        .notif-card { transition: all 0.2s; border-left: 4px solid #d1d5db; background-color: white; }
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
                
                <a href="notifications.jsp" class="nav-link nav-active flex justify-between items-center pr-6">
                    <div class="flex items-center gap-4">
                        <i class="fas fa-bell w-5 text-center"></i> Notifications
                    </div>
                    <span id="notif-badge" class="hidden bg-red-500 text-white text-[10px] font-bold px-2 py-0.5 rounded-full min-w-[20px] text-center animate-pulse">
                        0
                    </span>
                </a>
                
                <a href="profile.jsp" class="nav-link">
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
        <div class="max-w-4xl mx-auto">
            <header class="mb-8">
                <h1 class="text-3xl font-bold text-gray-800 tracking-tight">Your Notifications</h1>
                <p class="text-sm text-gray-500 italic">Stay updated with your trip approvals and fleet assignments.</p>
            </header>

            <div class="space-y-4">
                <%
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

                        // Ambil semua senarai tempahan bukan 'Pending' disusun mengikut ID paling besar di atas
                        String sql = "SELECT * FROM bookings WHERE user_id = ? AND status != 'Pending' ORDER BY booking_id DESC";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ps.setString(1, userIC);
                        ResultSet rs = ps.executeQuery();

                        boolean found = false;
                        int index = 0;
                        
                        while (rs.next()) {
                            found = true;
                            int currentBookingId = rs.getInt("booking_id");
                            
                            // Ambil ID booking yang paling tinggi (rekod teratas sekali) untuk penanda aras 'Sudah Dibaca'
                            if (index == 0) {
                                session.setAttribute("lastSeenBookingId", currentBookingId);
                            }
                            index++;
                            
                            String status = rs.getString("status");
                            String iconClass = "fa-check-circle text-green-600";
                            String iconBg = "bg-green-100";
                            String borderLeft = "border-l-green-500";
                            
                            if (status.equalsIgnoreCase("Rejected")) {
                                iconClass = "fa-times-circle text-red-600";
                                iconBg = "bg-red-100";
                                borderLeft = "border-l-red-500";
                            } else if (status.equalsIgnoreCase("Completed")) {
                                iconClass = "fa-flag-checkered text-blue-600";
                                iconBg = "bg-blue-100";
                                borderLeft = "border-l-blue-500";
                            }
                %>
                
                <div class="notif-card p-6 rounded-2xl shadow-sm flex items-start gap-4 hover:shadow-md transition-all border border-gray-100 <%= borderLeft %>">
                    <div class="<%= iconBg %> p-3 rounded-full shadow-inner">
                        <i class="fas <%= iconClass %> text-lg"></i>
                    </div>
                    <div class="flex-grow">
                        <div class="flex justify-between items-start">
                            <h4 class="font-bold text-sm text-gray-800 uppercase tracking-tight">Trip <%= status %></h4>
                            <span class="text-[9px] font-bold text-gray-400 uppercase border border-gray-200 px-2 py-0.5 rounded">Update</span>
                        </div>
                        <p class="text-xs text-gray-600 mt-2 leading-relaxed">
                            Your booking <b>#BK-<%= currentBookingId %></b> to <b><%= rs.getString("destination") %></b> has been <%= status %>.
                        </p>
                        <div class="flex items-center gap-4 mt-4 pt-3 border-t border-gray-50">
                            <p class="text-[10px] text-gray-400">
                                <i class="far fa-calendar-alt mr-1"></i> 
                                From: <%= rs.getString("start_date") %> To: <%= rs.getString("end_date") %>
                            </p>
                            <p class="text-[10px] text-gray-400">
                                <i class="fas fa-bus mr-1"></i> 
                                Slot: <%= rs.getString("trip_slot") %>
                            </p>
                        </div>
                    </div>
                </div>

                <% 
                        } // Tamat loop
                        
                        if (!found) {
                %>
                    <div class="text-center py-20 bg-white rounded-2xl border border-dashed border-gray-300">
                        <div class="bg-gray-50 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                            <i class="fas fa-bell-slash text-2xl text-gray-200"></i>
                        </div>
                        <p class="text-gray-400 text-sm italic">No new updates on your trip requests.</p>
                    </div>
                <%
                        }
                    } catch (Exception e) {
                        out.println("<div class='p-4 bg-red-100 text-red-700 rounded-lg'>Error: " + e.getMessage() + "</div>");
                    } finally {
                        if (conn != null) conn.close();
                    }
                %>
            </div>
        </div>
    </main>

    <script>
        function checkNotificationCount() {
            // Naik satu level ke root directory menggunakan "../" untuk panggil Servlet
            const servletUrl = "../NotificationCountServlet";

            fetch(servletUrl)
                .then(res => {
                    if (!res.ok) {
                        throw new Error("HTTP error! Status: " + res.status);
                    }
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

        // Jalankan semakan sebaik sahaja halaman siap dimuatkan
        document.addEventListener("DOMContentLoaded", function() {
            checkNotificationCount();
            // Jalankan semakan secara latar belakang setiap 5 saat sekali
            setInterval(checkNotificationCount, 5000);
        });
    </script>
</body>
</html>