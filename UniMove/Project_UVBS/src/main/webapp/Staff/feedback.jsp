<%-- 
    Document   : feedback
    Created on : 28 Apr 2026
    Author     : fatih
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 1. Security Check & Anti-Cache
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

    // Database Connection
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
    <title>Feedback & Support | UVBS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #f3f4f6; }
        .nav-link { color: #9ca3af; transition: all 0.3s; display: flex; align-items: center; gap: 1rem; padding: 1rem 2rem; font-size: 0.875rem; }
        .nav-link:hover { color: white; background-color: rgba(255,255,255,0.05); }
        .nav-active { color: white; background-color: rgba(255,255,255,0.1); border-right: 4px solid white; }
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
                <a href="feedback.jsp" class="nav-link nav-active">
                    <i class="fas fa-comment-dots w-5 text-center"></i> Feedback
                </a>
                <a href="notifications.jsp" class="nav-link">
                    <i class="fas fa-bell w-5 text-center"></i> Notifications
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
        <div class="max-w-5xl mx-auto">
            <header class="mb-8">
                <h1 class="text-3xl font-bold text-gray-800 tracking-tight">Feedback & Support</h1>
                <p class="text-sm text-gray-500 italic">Share your thoughts or report any system/trip operational issues.</p>
            </header>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <div class="bg-white rounded-2xl shadow-sm p-6 border border-gray-100 lg:col-span-1 h-fit">
                    <h3 class="text-xs font-bold uppercase mb-4 text-blue-600 tracking-widest flex items-center gap-2">
                        <i class="fas fa-pen-fancy"></i> Submit New Feedback
                    </h3>
                    
                    <form action="../FeedbackServlet" method="POST" class="space-y-4">
                        <div>
                            <label class="block text-[10px] uppercase font-bold text-gray-400 mb-1">Feedback Category</label>
                            <select name="category" class="w-full p-3 border rounded-xl text-sm outline-none focus:ring-2 focus:ring-blue-500" required>
                                <option value="System Issue">System Issue / Bug</option>
                                <option value="Vehicle Condition">Vehicle Condition</option>
                                <option value="Driver Behaviour">Driver Conduct</option>
                                <option value="Suggestion">General Suggestion</option>
                            </select>
                        </div>

                        <div>
                            <label class="block text-[10px] uppercase font-bold text-gray-400 mb-1">Message / Details</label>
                            <textarea name="message" rows="5" placeholder="Describe your experience or problem clearly..." class="w-full p-3 bg-gray-50 border rounded-xl text-sm focus:ring-2 focus:ring-blue-500 outline-none resize-none" required></textarea>
                        </div>

                        <button type="submit" class="w-full bg-[#1a2a3a] text-white py-3 rounded-xl font-bold text-xs uppercase tracking-widest shadow-md hover:bg-slate-800 transition">
                            Send Feedback
                        </button>
                    </form>
                </div>

                <div class="bg-white rounded-2xl shadow-sm overflow-hidden border border-gray-200 lg:col-span-2">
                    <div class="p-5 border-b bg-gray-50/70">
                        <h4 class="font-bold text-gray-700 uppercase text-[10px] tracking-widest">Your Feedback History</h4>
                    </div>
                    
                    <div class="overflow-x-auto">
                        <table class="w-full text-left text-sm">
                            <thead class="bg-white text-[10px] uppercase font-bold text-gray-400 border-b">
                                <tr>
                                    <th class="px-6 py-4">Submitted Date</th>
                                    <th class="px-6 py-4">Category</th>
                                    <th class="px-6 py-4">Your Message</th>
                                    <th class="px-6 py-4 text-center">Status</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-100">
                                <%
                                    try {
                                        Class.forName("com.mysql.cj.jdbc.Driver");
                                        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

                                        String sqlFeedback = "SELECT * FROM feedback WHERE user_id = ? ORDER BY created_at DESC";
                                        PreparedStatement psFeed = conn.prepareStatement(sqlFeedback);
                                        psFeed.setString(1, userIC);
                                        ResultSet rsFeed = psFeed.executeQuery();

                                        boolean hasFeedback = false;
                                        while (rsFeed.next()) {
                                            hasFeedback = true;
                                            String category = rsFeed.getString("category");
                                            String msg = rsFeed.getString("message");
                                            String status = rsFeed.getString("status"); // Pending / Reviewed
                                            String date = rsFeed.getString("created_at");

                                            String badgeColor = "bg-amber-100 text-amber-600";
                                            if ("Reviewed".equalsIgnoreCase(status)) {
                                                badgeColor = "bg-green-100 text-green-600";
                                            }
                                %>
                                <tr class="hover:bg-gray-50/50 transition">
                                    <td class="px-6 py-4 text-xs text-gray-600 font-medium whitespace-nowrap"><%= date %></td>
                                    <td class="px-6 py-4 text-xs font-bold text-gray-700"><%= category %></td>
                                    <td class="px-6 py-4 text-xs text-gray-500 max-w-xs truncate" title="<%= msg %>"><%= msg %></td>
                                    <td class="px-6 py-4 text-center whitespace-nowrap">
                                        <span class="px-2.5 py-1 rounded-full text-[9px] font-black uppercase tracking-wider <%= badgeColor %>">
                                            <%= status != null ? status : "Pending" %>
                                        </span>
                                    </td>
                                </tr>
                                <% 
                                        }
                                        if (!hasFeedback) {
                                %>
                                <tr>
                                    <td colspan="4" class="px-6 py-20 text-center text-gray-400 text-xs italic">You haven't submitted any feedback yet.</td>
                                </tr>
                                <% 
                                        }
                                    } catch (Exception e) {
                                        out.println("<tr><td colspan='4' class='p-4 text-red-500 text-xs font-mono'>Error: " + e.getMessage() + "</td></tr>");
                                    } finally {
                                        if (conn != null) conn.close();
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </main>
</body>
</html>