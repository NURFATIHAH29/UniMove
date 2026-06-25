<%-- 
    Document   : manageFeedback
    Created on : 21 Jun 2026, 9:20:55 am
    Author     : fatihah
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    // 1. Security Check
    if (session.getAttribute("userName") == null || !"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("../Staff/login.jsp");
        return;
    }

    String fullName = (String) session.getAttribute("userName");
    
    // 2. Database Configuration
    String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
    String dbUser = "root";
    String dbPass = "admin"; 

    // 3. Ambil parameter sorting & filter bulan dari URL
    String sortBy = request.getParameter("sort");
    if (sortBy == null || sortBy.trim().isEmpty()) {
        sortBy = "desc"; // Default tarikh paling baharu
    }

    String selectedMonth = request.getParameter("month");
    if (selectedMonth == null || selectedMonth.trim().isEmpty()) {
        selectedMonth = "all"; // Default tunjuk semua bulan
    }

    // 4. Format Tarikh Semasa Untuk Header
    LocalDate today = LocalDate.now();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d MMM yyyy", Locale.ENGLISH);
    String currentDateStr = today.format(formatter);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Feedback | UVBS Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .force-table { width: 100% !important; text-align: left !important; font-size: 0.875rem !important; border-collapse: collapse !important; }
        .force-th { font-size: 10px !important; text-transform: uppercase !important; font-weight: 700 !important; color: #9ca3af !important; background-color: #ffffff !important; padding: 16px !important; border-bottom: 1px solid #e5e7eb !important; }
        .force-td { padding: 16px !important; border-bottom: 1px solid #e5e7eb !important; vertical-align: middle !important; }
        
        .nav-active { 
            color: white !important; 
            background-color: rgba(184, 151, 77, 0.1) !important; 
            border-left: 4px solid #b8974d !important; 
        }
    </style>
</head>
<body class="flex flex-col md:flex-row min-h-screen bg-gray-100" style="display: flex !important; flex-direction: row !important; margin: 0 !important;">

    <aside class="hidden md:flex w-64 bg-[#1a2a3a] flex-col text-white shadow-xl fixed top-0 bottom-0 left-0 z-50" style="display: flex !important; flex-direction: column !important; height: 100vh !important;">
        <div class="p-8 text-center border-b border-gray-700">
            <i class="fas fa-user-shield text-5xl mb-3 text-[#b8974d]"></i>
            <h2 class="font-bold text-sm uppercase tracking-widest leading-tight"><%= fullName %></h2>
            <p class="text-[10px] text-gray-400 mt-1 uppercase tracking-tighter">System Admin</p>
        </div>
        
        <nav class="flex-grow mt-6" style="display: flex !important; flex-direction: column !important;">
            <a href="adminDashboard.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 transition hover:bg-white/5 hover:text-white">
                <i class="fas fa-th-large w-5 text-center"></i> Dashboard
            </a>
            <a href="adminApprovals.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 transition hover:bg-white/5 hover:text-white">
                <i class="fas fa-check-square w-5 text-center"></i> Booking Approvals
            </a>
            <a href="manageReports.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 transition hover:bg-white/5 hover:text-white">
                <i class="fas fa-tools w-5 text-center"></i> Maintenance Reports
            </a>
            <a href="../Vehicle/manageVehicle.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 transition hover:bg-white/5 hover:text-white">
                <i class="fas fa-car-side w-5 text-center"></i> Vehicle Management
            </a>
            <a href="../driver/manageDrivers.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 transition hover:bg-white/5 hover:text-white">
                <i class="fas fa-user-tie w-5 text-center"></i> Driver Management
            </a>
            <a href="manageFeedback.jsp" class="nav-active flex items-center gap-4 px-8 py-4">
                <i class="fas fa-comment-alt w-5 text-center"></i> User Feedback
            </a>
        </nav>

        <div class="p-4 mb-2">
            <a href="../LogoutServlet" class="bg-[#4a1d1f] hover:bg-red-900 flex items-center justify-center gap-3 px-6 py-3 text-white text-[11px] font-bold rounded-lg shadow-lg uppercase tracking-wider transition">
                <i class="fas fa-sign-out-alt" style="transform: rotate(180deg) !important;"></i> LOGOUT
            </a>
        </div>
    </aside>

    <main class="flex-grow md:ml-64 p-4 md:p-10" style="flex-grow: 1 !important; margin-left: 16rem !important;">
        
        <header class="mb-10 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
            <div>
                <h1 class="text-2xl font-bold text-gray-800">User Feedback Management</h1>
                <p class="text-sm text-gray-500 italic text-blue-600">Review and monitor driver and staff user feedback.</p>
            </div>
            
            <div class="flex items-center gap-2.5 bg-white px-4 py-2.5 rounded-lg border shadow-sm font-bold text-xs text-gray-700 tracking-wide uppercase">
                <i class="far fa-clock text-[#b8974d] text-sm"></i>
                <span><%= currentDateStr %></span>
            </div>
        </header>

        <div class="bg-white rounded-xl shadow-md border border-gray-200 overflow-hidden">
            <div class="p-6 bg-gray-50 border-b flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4" style="display: flex !important; justify-content: space-between !important; align-items: center !important;">
                <h4 class="font-bold text-xs uppercase tracking-tighter text-gray-700">Submitted Feedback Log</h4>
                
                <div class="flex flex-wrap items-center gap-4">
                    <div class="flex items-center gap-2">
                        <label for="monthFilter" class="text-[10px] font-bold uppercase text-gray-400 tracking-wider"><i class="far fa-calendar-alt"></i> Month:</label>
                        <select id="monthFilter" onchange="updateFilters()" class="text-xs bg-white border border-gray-300 rounded-lg px-2.5 py-1.5 font-medium text-gray-700 shadow-sm focus:outline-none focus:border-blue-500 cursor-pointer">
                            <option value="all" <%= "all".equals(selectedMonth) ? "selected" : "" %>>All Months</option>
                            <option value="1" <%= "1".equals(selectedMonth) ? "selected" : "" %>>January</option>
                            <option value="2" <%= "2".equals(selectedMonth) ? "selected" : "" %>>February</option>
                            <option value="3" <%= "3".equals(selectedMonth) ? "selected" : "" %>>March</option>
                            <option value="4" <%= "4".equals(selectedMonth) ? "selected" : "" %>>April</option>
                            <option value="5" <%= "5".equals(selectedMonth) ? "selected" : "" %>>May</option>
                            <option value="6" <%= "6".equals(selectedMonth) ? "selected" : "" %>>June</option>
                            <option value="7" <%= "7".equals(selectedMonth) ? "selected" : "" %>>July</option>
                            <option value="8" <%= "8".equals(selectedMonth) ? "selected" : "" %>>August</option>
                            <option value="9" <%= "9".equals(selectedMonth) ? "selected" : "" %>>September</option>
                            <option value="10" <%= "10".equals(selectedMonth) ? "selected" : "" %>>October</option>
                            <option value="11" <%= "11".equals(selectedMonth) ? "selected" : "" %>>November</option>
                            <option value="12" <%= "12".equals(selectedMonth) ? "selected" : "" %>>December</option>
                        </select>
                    </div>

                    <div class="flex items-center gap-2">
                        <label for="sortSelector" class="text-[10px] font-bold uppercase text-gray-400 tracking-wider"><i class="fas fa-sort"></i> Date Order:</label>
                        <select id="sortSelector" onchange="updateFilters()" class="text-xs bg-white border border-gray-300 rounded-lg px-2.5 py-1.5 font-medium text-gray-700 shadow-sm focus:outline-none focus:border-blue-500 cursor-pointer">
                            <option value="desc" <%= "desc".equals(sortBy) ? "selected" : "" %>>Latest Feedback (Newest)</option>
                            <option value="asc" <%= "asc".equals(sortBy) ? "selected" : "" %>>Oldest Feedback (Ascending)</option>
                        </select>
                    </div>
                </div>
            </div>
            
            <div class="overflow-x-auto">
                <table class="force-table">
                    <thead>
                        <tr>
                            <th class="force-th" style="width: 10%;">ID</th>
                            <th class="force-th" style="width: 25%;">User Info</th>
                            <th class="force-th" style="width: 45%;">Comments / Message</th>
                            <th class="force-th" style="width: 20%; text-align: right;">Submission Date</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y text-gray-600">
                        <%
                            Connection conn = null;
                            PreparedStatement ps = null;
                            ResultSet rs = null;
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
                                
                                String sql = "SELECT * FROM feedback WHERE 1=1 ";
                                
                                if (!"all".equals(selectedMonth)) {
                                    sql += "AND MONTH(created_at) = ? ";
                                }
                                
                                if ("asc".equals(sortBy)) {
                                    sql += "ORDER BY created_at ASC";
                                } else {
                                    sql += "ORDER BY created_at DESC";
                                }
                                
                                ps = conn.prepareStatement(sql);
                                
                                if (!"all".equals(selectedMonth)) {
                                    ps.setInt(1, Integer.parseInt(selectedMonth));
                                }
                                
                                rs = ps.executeQuery();
                                
                                boolean hasData = false;
                                while(rs.next()) {
                                    hasData = true;
                                    int fId = rs.getInt("feedback_id");
                                    String userId = rs.getString("user_id");
                                    
                                    // PEMBETULAN DI SINI: Ditukar ke "message" sepadan dengan struktur DB
                                    String comments = rs.getString("message"); 
                                    
                                    Timestamp createdAt = rs.getTimestamp("created_at");
                                    
                                    String formattedDate = (createdAt != null) ? createdAt.toString().substring(0, 16) : "-";
                        %>
                        <tr class="hover:bg-gray-50 transition">
                            <td class="force-td font-bold text-gray-400">
                                #FB-<%= fId %>
                            </td>
                            
                            <td class="force-td">
                                <div class="flex flex-col">
                                    <p class="font-bold text-blue-900" style="color: #1e3a8a !important; font-weight: 700 !important;"><%= (userId != null ? userId : "Anonymous") %></p>
                                    <span class="text-[10px] text-gray-400">Sender Account</span>
                                </div>
                            </td>
                            
                            <td class="force-td">
                                <p class="text-sm text-gray-700 font-medium whitespace-pre-line"><%= comments %></p>
                            </td>
                            
                            <td class="force-td text-right font-bold text-gray-500" style="text-align: right !important; font-size: 11px;">
                                <i class="far fa-calendar-alt text-gray-400 mr-1"></i> <%= formattedDate %>
                            </td>
                        </tr>
                        <% 
                                }
                                if(!hasData) {
                        %>
                                    <tr><td colspan='4' class='p-10 text-center text-gray-400 font-bold uppercase' style='text-align: center !important; padding: 40px !important;'>No user feedback entries found for the selected filter.</td></tr>
                        <%
                                }
                            } catch(Exception e) {
                        %>
                                <tr><td colspan='4' class='p-4 text-red-600 bg-red-50 text-xs'>Error Loading Feedback: <%= e.getMessage() %></td></tr>
                        <%
                            } finally {
                                if(rs != null) try { rs.close(); } catch(Exception e){}
                                if(ps != null) try { ps.close(); } catch(Exception e){}
                                if(conn != null) try { conn.close(); } catch(Exception e){}
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <script>
        function updateFilters() {
            const monthValue = document.getElementById('monthFilter').value;
            const sortValue = document.getElementById('sortSelector').value;
            window.location.href = "manageFeedback.jsp?month=" + monthValue + "&sort=" + sortValue;
        }
    </script>
</body>
</html>