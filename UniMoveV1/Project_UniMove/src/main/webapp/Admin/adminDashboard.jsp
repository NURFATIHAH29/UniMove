<%-- 
    Document   : adminDashboard
    Created on : 2 May 2026, 1:12:44 am
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

    int totalVehicles = 0;
    int totalDrivers = 0;
    int totalBookings = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection c = DriverManager.getConnection(dbUrl, dbUser, dbPass);
        
        ResultSet rs1 = c.createStatement().executeQuery("SELECT COUNT(*) FROM vehicles");
        if(rs1.next()) totalVehicles = rs1.getInt(1);
        
        ResultSet rs2 = c.createStatement().executeQuery("SELECT COUNT(*) FROM drivers");
        if(rs2.next()) totalDrivers = rs2.getInt(1);
        
        ResultSet rs3 = c.createStatement().executeQuery("SELECT COUNT(*) FROM bookings");
        if(rs3.next()) totalBookings = rs3.getInt(1);
        
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
    <title>Operational Overview | UVBS Admin</title>
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
            <a href="adminDashboard.jsp" class="nav-active flex items-center gap-4 px-8 py-4">
                <i class="fas fa-th-large w-5 text-center"></i> Dashboard
            </a>
            <a href="../Admin/adminApprovals.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 hover:text-white transition">
                <i class="fas fa-check-square w-5 text-center"></i> Booking Approvals
            </a>
            <a href="manageReports.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 hover:text-white transition">
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
                <h1 class="text-2xl font-bold text-[#1a2a3a]">Operational Overview</h1>
                <p class="text-sm text-gray-500 italic">Centralized management for vehicles and drivers.</p>
            </div>
            <div class="bg-white px-4 py-2 rounded-xl shadow-sm border border-gray-100 flex items-center gap-2 mt-1">
                <i class="far fa-clock text-[#b8974d] text-xs"></i>
                <span class="text-xs font-bold text-[#1a2a3a] tracking-wide uppercase"><%= currentDateStr %></span>
            </div>
        </header>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
            <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex justify-between items-center relative overflow-hidden group">
                <div class="absolute left-0 top-0 bottom-0 w-1.5 bg-blue-500"></div>
                <div>
                    <p class="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Total Vehicles</p>
                    <h3 class="text-3xl font-bold text-gray-800 mt-1"><%= totalVehicles %></h3>
                </div>
                <i class="fas fa-bus text-3xl text-blue-100 group-hover:scale-110 transition-transform"></i>
            </div>
            
            <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex justify-between items-center relative overflow-hidden group">
                <div class="absolute left-0 top-0 bottom-0 w-1.5 bg-purple-500"></div>
                <div>
                    <p class="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Total Drivers</p>
                    <h3 class="text-3xl font-bold text-gray-800 mt-1"><%= totalDrivers %></h3>
                </div>
                <i class="fas fa-id-card text-3xl text-purple-100 group-hover:scale-110 transition-transform"></i>
            </div>

            <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex justify-between items-center relative overflow-hidden group">
                <div class="absolute left-0 top-0 bottom-0 w-1.5 bg-yellow-500"></div>
                <div>
                    <p class="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Total Bookings</p>
                    <h3 class="text-3xl font-bold text-gray-800 mt-1"><%= totalBookings %></h3>
                </div>
                <i class="fas fa-book text-3xl text-yellow-100 group-hover:scale-110 transition-transform"></i>
            </div>
        </div>

        <div class="w-full">
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
                <div class="flex justify-between items-center border-b pb-4 mb-4">
                    <h4 class="font-bold text-xs uppercase tracking-tighter text-gray-700">Recent Booking Assignments</h4>
                    <a href="../Admin/adminApprovals.jsp" class="text-[10px] font-bold text-blue-600 uppercase hover:underline">Manage All</a>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-xs">
                        <thead>
                            <tr class="text-gray-400 uppercase text-[9px] border-b font-bold">
                                <th class="pb-2">Booking ID</th>
                                <th class="pb-2">Staff Name</th>
                                <th class="pb-2">Destination</th>
                                <th class="pb-2">Vehicle Type</th>
                                <th class="pb-2">Status</th>
                                <th class="pb-2 text-center">Action</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-50 text-gray-700">
                            <%
                                Connection conn = null;
                                Statement st = null;
                                ResultSet rs = null;
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
                                    
                                    // DIBAIKI: Menggunakan subquery GROUP_CONCAT & FIND_IN_SET untuk cantum maklumat berbilang kenderaan/pemandu
                                    String query = "SELECT b.*, " +
                                                   "(SELECT GROUP_CONCAT(d.full_name SEPARATOR ' & ') FROM drivers d WHERE FIND_IN_SET(d.driver_id, b.assigned_driver_id) > 0) AS multiple_drivers, " +
                                                   "(SELECT GROUP_CONCAT(CONCAT(v.model, ' (', v.plate_number, ')') SEPARATOR ' , ') FROM vehicles v WHERE FIND_IN_SET(v.vehicle_id, b.assigned_vehicle_id) > 0) AS multiple_vehicles " +
                                                   "FROM bookings b " +
                                                   "ORDER BY b.booking_id DESC LIMIT 5";
                                                   
                                    st = conn.createStatement();
                                    rs = st.executeQuery(query);
                                    
                                    while(rs.next()) {
                                        int id = rs.getInt("booking_id");
                                        String staff = rs.getString("staff_name");
                                        String dest = rs.getString("destination");
                                        String vType = rs.getString("vehicle_type");
                                        String status = rs.getString("status");
                                        
                                        String phone = rs.getString("phone_number");
                                        String pLocation = rs.getString("pickup_location");
                                        String sDate = rs.getString("start_date");
                                        String eDate = rs.getString("end_date");
                                        String purpose = rs.getString("purpose") != null ? rs.getString("purpose").replace("'", "\\'") : "";
                                        
                                        // DIBAIKI: Mengambil data gabungan baru dari alias subquery
                                        String dName = rs.getString("multiple_drivers");
                                        if (dName == null || dName.trim().isEmpty()) {
                                            dName = "Belum Ditugaskan";
                                        }
                                        
                                        String vModel = rs.getString("multiple_vehicles");
                                        if (vModel == null || vModel.trim().isEmpty()) {
                                            vModel = "Belum Ditugaskan";
                                        }
                                        
                                        String badgeColor = "bg-yellow-50 text-yellow-600";
                                        if("Confirmed".equalsIgnoreCase(status) || "Approved".equalsIgnoreCase(status)) badgeColor = "bg-green-50 text-green-600";
                                        else if("Completed".equalsIgnoreCase(status)) badgeColor = "bg-gray-100 text-gray-600";
                                        else if("Cancelled".equalsIgnoreCase(status) || "Rejected".equalsIgnoreCase(status)) badgeColor = "bg-red-50 text-red-600";
                            %>
                            <tr class="hover:bg-gray-50 transition">
                                <td class="py-3 font-bold text-blue-900">#BK-<%= id %></td>
                                <td class="py-3 uppercase"><%= staff %></td>
                                <td class="py-3 uppercase truncate max-w-[200px]" title="<%= dest %>"><%= dest %></td>
                                <td class="py-3 font-medium"><%= vType %></td>
                                <td class="py-3">
                                    <span class="<%= badgeColor %> px-2 py-0.5 rounded text-[9px] font-bold uppercase"><%= status %></span>
                                </td>
                                <td class="py-3 text-center">
                                    <button onclick="showDetails('<%= id %>', '<%= staff %>', '<%= phone %>', '<%= pLocation %>', '<%= dest %>', '<%= sDate %>', '<%= eDate %>', '<%= vModel.replace("'", "\\'") %>', '<%= dName.replace("'", "\\'") %>', '<%= purpose %>')" 
                                            class="text-blue-600 hover:text-blue-900 font-bold tracking-tight text-[10px] uppercase">
                                        <i class="fas fa-eye mr-1"></i> Details
                                    </button>
                                </td>
                            </tr>
                            <%
                                    }
                                } catch(Exception e) {
                                    e.printStackTrace();
                                } finally {
                                    if(rs != null) rs.close();
                                    if(st != null) st.close();
                                    if(conn != null) conn.close();
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </main>

    <div id="detailsModal" class="fixed inset-0 bg-black/50 z-[100] hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-xl shadow-2xl w-full max-w-lg overflow-hidden animate-in fade-in duration-200">
            <div class="bg-[#1a2a3a] text-white px-6 py-4 flex justify-between items-center">
                <h3 class="font-bold text-sm tracking-wide uppercase">
                    <i class="fas fa-info-circle text-[#b8974d] mr-2"></i> Assignment Information
                </h3>
                <button onclick="closeModal()" class="text-gray-400 hover:text-white transition">
                    <i class="fas fa-times text-lg"></i>
                </button>
            </div>
            <div class="p-6 space-y-4 max-h-[75vh] overflow-y-auto text-xs text-gray-700">
                <div class="grid grid-cols-2 gap-4 border-b pb-3">
                    <div>
                        <p class="text-[10px] uppercase font-bold text-gray-400">Booking ID</p>
                        <p id="modalBid" class="font-bold text-blue-900 text-sm"></p>
                    </div>
                    <div>
                        <p class="text-[10px] uppercase font-bold text-gray-400">Staff Name</p>
                        <p id="modalStaff" class="font-bold uppercase"></p>
                    </div>
                </div>
                
                <div class="grid grid-cols-2 gap-4 border-b pb-3">
                    <div>
                        <p class="text-[10px] uppercase font-bold text-gray-400">Phone Number</p>
                        <p id="modalPhone" class="font-medium"></p>
                    </div>
                    <div>
                        <p class="text-[10px] uppercase font-bold text-gray-400">Date Duration</p>
                        <p id="modalDuration" class="font-medium text-gray-600"></p>
                    </div>
                </div>

                <div class="border-b pb-3">
                    <p class="text-[10px] uppercase font-bold text-gray-400">Trip Destination</p>
                    <p id="modalDest" class="font-bold text-gray-800 uppercase mt-0.5"></p>
                    <p class="text-[10px] text-gray-400 mt-1">Pickup: <span id="modalPickup" class="uppercase font-medium text-gray-600"></span></p>
                </div>

                <div class="grid grid-cols-1 gap-3 bg-gray-50 p-3 rounded-lg border border-gray-100">
                    <div>
                        <p class="text-[10px] uppercase font-bold text-blue-900"><i class="fas fa-car mr-1 text-[#b8974d]"></i> Assigned Vehicle</p>
                        <p id="modalVehicle" class="font-bold text-gray-800 mt-0.5 uppercase whitespace-normal break-words"></p>
                    </div>
                    <div class="mt-1">
                        <p class="text-[10px] uppercase font-bold text-blue-900"><i class="fas fa-user-tie mr-1 text-[#b8974d]"></i> Assigned Driver</p>
                        <p id="modalDriver" class="font-bold text-gray-800 mt-0.5 uppercase whitespace-normal break-words"></p>
                    </div>
                </div>

                <div>
                    <p class="text-[10px] uppercase font-bold text-gray-400">Purpose of Trip</p>
                    <p id="modalPurpose" class="mt-1 bg-gray-50 p-2 rounded text-gray-600 italic border border-gray-100"></p>
                </div>
            </div>
            <div class="bg-gray-50 px-6 py-3 border-t flex justify-end">
                <button onclick="closeModal()" class="bg-gray-800 hover:bg-black text-white px-5 py-2 font-bold uppercase rounded-lg tracking-wider text-[10px] transition">
                    Close Details
                </button>
            </div>
        </div>
    </div>

    <script>
        function showDetails(id, staff, phone, pickup, dest, sDate, eDate, vehicle, driver, purpose) {
            document.getElementById('modalBid').innerText = '#BK-' + id;
            document.getElementById('modalStaff').innerText = staff;
            document.getElementById('modalPhone').innerText = phone;
            document.getElementById('modalDuration').innerText = sDate + ' to ' + eDate;
            document.getElementById('modalPickup').innerText = pickup;
            document.getElementById('modalDest').innerText = dest;
            document.getElementById('modalVehicle').innerText = vehicle;
            document.getElementById('modalDriver').innerText = driver;
            document.getElementById('modalPurpose').innerText = purpose;

            // Paparkan Modal
            document.getElementById('detailsModal').classList.remove('hidden');
        }

        function closeModal() {
            // Sembunyikan Modal
            document.getElementById('detailsModal').classList.add('hidden');
        }

        // Tutup modal jika user ter-klik background luar modal
        window.onclick = function(event) {
            let modal = document.getElementById('detailsModal');
            if (event.target == modal) {
                closeModal();
            }
        }
    </script>

</body>
</html>