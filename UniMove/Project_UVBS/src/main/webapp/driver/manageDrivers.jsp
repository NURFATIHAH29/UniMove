<%-- 
    Document   : manageDriver
    Created on : 2 May 2026, 2:46:09 pm
    Author     : fatih
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

    // Logic untuk kira stats
    int activeDrivers = 0;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection c = DriverManager.getConnection(dbUrl, dbUser, dbPass);
        ResultSet rs = c.createStatement().executeQuery("SELECT COUNT(*) FROM drivers WHERE status='READY' OR status='AVAILABLE'");
        if(rs.next()) activeDrivers = rs.getInt(1);
        c.close();
    } catch(Exception e) {}

    // Menjana Tarikh Semasa Secara Dinamik untuk Header
    LocalDate today = LocalDate.now();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d MMM yyyy", Locale.ENGLISH);
    String currentDateStr = today.format(formatter);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Driver Management | UVBS Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="../Style.css">
    <style>
        .nav-active { color: white; background-color: rgba(184, 151, 77, 0.1); border-left: 4px solid #b8974d; }
        .status-ready { color: #10b981; font-weight: 800; }
        .status-ontrip { color: #3b82f6; font-weight: 800; }
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
            <a href="../Admin/manageReports.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 hover:text-white transition">
                <i class="fas fa-tools w-5 text-center"></i> Maintenance Reports
            </a>
            <a href="../Vehicle/manageVehicle.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 hover:text-white transition">
                <i class="fas fa-car-side w-5 text-center"></i> Vehicle Management
            </a>
            <a href="manageDrivers.jsp" class="nav-active flex items-center gap-4 px-8 py-4">
                <i class="fas fa-user-tie w-5 text-center"></i> Driver Management
            </a>
            <a href="../Admin/manageFeedback.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 hover:text-white transition">
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
                <h1 class="text-2xl font-bold text-[#1a2a3a]">Driver Management</h1>
                <p class="text-sm text-gray-500 italic">Assign tasks and manage personnel records.</p>
            </div>
            <div class="bg-white px-4 py-2 rounded-xl shadow-sm border border-gray-100 flex items-center gap-2 mt-1">
                <i class="far fa-clock text-[#b8974d] text-xs"></i>
                <span class="text-xs font-bold text-[#1a2a3a] tracking-wide uppercase"><%= currentDateStr %></span>
            </div>
        </header>

        <div class="grid grid-cols-1 lg:grid-cols-12 gap-8">
            
            <div class="lg:col-span-4 bg-white rounded-xl shadow-md p-8 border border-gray-100 h-fit">
                <h3 class="text-xs font-bold text-blue-900 uppercase tracking-widest mb-6 flex items-center">
                    <i class="fas fa-user-plus mr-2 text-[#b8974d]"></i> Driver Registration
                </h3>
                <form action="processDriver.jsp" method="POST" class="space-y-4">
                    <div>
                        <label class="text-[10px] font-bold uppercase text-gray-400">Full Name</label>
                        <input type="text" name="name" placeholder="e.g. Ahmad bin Rosli" required 
                               class="w-full bg-gray-50 border border-gray-200 rounded-lg p-3 text-sm outline-none focus:border-[#b8974d]">
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="text-[10px] font-bold uppercase text-gray-400">Staff ID</label>
                            <input type="text" name="staff_id" placeholder="DRV-9901" required 
                                   class="w-full bg-gray-50 border border-gray-200 rounded-lg p-3 text-sm outline-none focus:border-[#b8974d]">
                        </div>
                        <div>
                            <label class="text-[10px] font-bold uppercase text-gray-400">License Class</label>
                            <select name="license" class="w-full bg-gray-50 border border-gray-200 rounded-lg p-3 text-sm outline-none">
                                <option>Class D</option>
                                <option>Class E (Bus)</option>
                                <option>Class E (Lori)</option>
                                <option>Class G</option>
                            </select>
                        </div>
                    </div>
                    <div>
                        <label class="text-[10px] font-bold uppercase text-gray-400">License Expiration Date</label>
                        <input type="date" name="license_expiration" required 
                               class="w-full bg-gray-50 border border-gray-200 rounded-lg p-3 text-sm outline-none focus:border-[#b8974d]">
                    </div>
                    <div>
                        <label class="text-[10px] font-bold uppercase text-gray-400">Phone Number</label>
                        <input type="text" name="phone" placeholder="+6012-3456789" required 
                               class="w-full bg-gray-50 border border-gray-200 rounded-lg p-3 text-sm outline-none focus:border-[#b8974d]">
                    </div>
                    <div>
                        <label class="text-[10px] font-bold uppercase text-gray-400">Emergency Contact</label>
                        <input type="text" name="emergency_contact" placeholder="e.g. +6013-9876543 (Isteri)" required 
                               class="w-full bg-gray-50 border border-gray-200 rounded-lg p-3 text-sm outline-none focus:border-[#b8974d]">
                    </div>
                    <button type="submit" class="w-full bg-[#1a2a3a] text-white py-4 rounded-lg font-bold text-xs uppercase hover:bg-black transition-all tracking-widest cursor-pointer mt-2">
                        Add New Driver
                    </button>
                </form>
            </div>

            <div class="lg:col-span-8">
                <div class="bg-white rounded-xl shadow-md border border-gray-100 overflow-hidden">
                    
                    <div class="p-6 bg-gray-50 border-b flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                        <div>
                            <h4 class="font-bold text-xs uppercase tracking-tighter text-gray-700">Driver Registry</h4>
                            <span class="inline-block mt-1 bg-green-100 text-green-600 text-[10px] font-bold px-3 py-1 rounded-full uppercase">Active: <%= activeDrivers %></span>
                        </div>
                        
                        <div class="relative w-full sm:w-64">
                            <span class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                                <i class="fas fa-search text-gray-400 text-xs"></i>
                            </span>
                            <input type="text" id="driverSearch" onkeyup="searchDrivers()" placeholder="Search name, ID or license..." 
                                   class="w-full bg-white border border-gray-200 rounded-lg pl-9 pr-4 py-2 text-xs outline-none focus:border-[#b8974d] shadow-sm">
                        </div>
                    </div>
                    
                    <div class="overflow-x-auto">
                        <table class="w-full text-left border-collapse" id="driverTable">
                            <thead class="bg-white border-b text-[10px] uppercase font-bold text-gray-400">
                                <tr>
                                    <th class="px-8 py-5">Driver Profile</th>
                                    <th class="px-8 py-5">License Details</th>
                                    <th class="px-8 py-5 text-center">Status</th>
                                    <th class="px-8 py-5 text-right">Action</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-100">
                                <%
                                    try {
                                        Connection c = DriverManager.getConnection(dbUrl, dbUser, dbPass);
                                        ResultSet rs = c.createStatement().executeQuery("SELECT * FROM drivers ORDER BY driver_id DESC");
                                        while(rs.next()) {
                                            String dName = rs.getString("full_name");
                                            String dStaffId = rs.getString("staff_id");
                                            String dPhone = rs.getString("phone_number");
                                            String dLicenseClass = rs.getString("license_class");
                                            String status = rs.getString("status");
                                            
                                            String dEmergency = "N/A";
                                            try {
                                                dEmergency = rs.getString("emergency_contact");
                                                if(dEmergency == null) dEmergency = "N/A";
                                            } catch(Exception e) { dEmergency = "N/A"; }

                                            String sColor = (status.equalsIgnoreCase("READY") || status.equalsIgnoreCase("AVAILABLE")) ? "text-green-500" : "text-blue-500";
                                            String sIcon = (status.equalsIgnoreCase("READY") || status.equalsIgnoreCase("AVAILABLE")) ? "fa-circle" : "fa-bus";
                                            String expiryDate = rs.getString("license_expiration");
                                            if(expiryDate == null) expiryDate = "N/A";
                                %>
                                <tr class="driver-row hover:bg-gray-50 transition">
                                    <td class="px-8 py-5 flex items-center gap-4">
                                        <div class="w-10 h-10 rounded-full bg-gray-800 text-white flex items-center justify-center font-bold text-xs uppercase shrink-0">
                                            <%= dName != null && dName.length() > 0 ? dName.substring(0, 1) : "?" %>
                                        </div>
                                        <div>
                                            <p class="font-bold text-gray-800 leading-tight"><%= dName %></p>
                                            <p class="text-[10px] text-gray-400 uppercase font-medium">ID: <%= dStaffId %></p>
                                            <p class="text-[10px] text-gray-500 font-medium"><i class="fas fa-phone text-[8px] mr-1"></i><%= dPhone %></p>
                                        </div>
                                    </td>
                                    <td class="px-8 py-5">
                                        <p class="text-xs font-bold text-gray-700 uppercase"><%= dLicenseClass %></p>
                                        <p class="text-[10px] text-red-500 font-semibold uppercase mt-0.5">Expires: <%= expiryDate %></p>
                                    </td>
                                    <td class="px-8 py-5 text-center">
                                        <span class="text-[10px] font-bold uppercase <%= sColor %> flex items-center justify-center gap-2">
                                            <i class="fas <%= sIcon %> text-[6px]"></i> <%= status %>
                                        </span>
                                    </td>
                                    <td class="px-8 py-5 text-right">
                                        <div class="flex justify-end items-center gap-4 text-gray-400 text-base">
                                            <button type="button" title="View & Edit Info" 
                                                    onclick="openDriverModal('<%= dName %>', '<%= dStaffId %>', '<%= dPhone %>', '<%= dLicenseClass %>', '<%= expiryDate %>', '<%= dEmergency %>')"
                                                    class="text-blue-500 hover:text-blue-700 cursor-pointer transition">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                            <a href="deleteDriver.jsp?id=<%= dStaffId %>" onclick="return confirm('Delete driver <%= dName %>?')" class="hover:text-red-600 transition"><i class="fas fa-trash"></i></a>
                                        </div>
                                    </td>
                                </tr>
                                <% } c.close(); } catch(Exception e) {} %>
                            </tbody>
                        </table>
                    </div>
                </div>
                
            </div>
        </div>
    </main>

    <div id="driverDetailsModal" class="fixed inset-0 bg-black/50 hidden justify-center items-center z-50 p-4 transition-all">
        <div class="bg-white rounded-xl shadow-2xl w-full max-w-sm overflow-hidden border border-gray-200">
            
            <form action="updateDriver.jsp" method="POST">
                <div class="p-4 text-white flex justify-between items-center bg-[#1a2a3a]">
                    <h4 class="text-xs font-bold uppercase tracking-widest flex items-center gap-2">
                        <i class="fas fa-user-edit text-[#b8974d]"></i> Driver Profile & Editor
                    </h4>
                    <button type="button" onclick="closeDriverModal()" class="text-white/70 hover:text-white text-lg font-bold cursor-pointer">&times;</button>
                </div>
                
                <div class="p-6 space-y-4 text-gray-700 text-xs">
                    <input type="hidden" name="staff_id" id="m_input_id">

                    <div>
                        <label class="text-[9px] font-bold uppercase text-gray-400 tracking-wider block mb-1">Full Name</label>
                        <input type="text" name="name" id="m_input_name" required
                               class="w-full bg-gray-50 border border-gray-200 rounded p-2 text-xs font-bold uppercase text-gray-800 outline-none focus:border-[#b8974d]">
                    </div>
                    
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="text-[9px] font-bold uppercase text-gray-400 tracking-wider block mb-1">Phone Number</label>
                            <input type="text" name="phone" id="m_input_phone" required
                                   class="w-full bg-gray-50 border border-gray-200 rounded p-2 text-xs font-mono font-bold text-gray-700 outline-none focus:border-[#b8974d]">
                        </div>
                        <div>
                            <label class="text-[9px] font-bold uppercase text-gray-400 tracking-wider block mb-1">Emergency Contact</label>
                            <input type="text" name="emergency_contact" id="m_input_emergency" required
                                   class="w-full bg-red-50 border border-red-100 rounded p-2 text-xs font-mono font-bold text-red-600 outline-none focus:border-red-400">
                        </div>
                    </div>
                    
                    <hr class="border-gray-100">
                    
                    <div class="grid grid-cols-2 gap-4 bg-gray-50 p-3 rounded-lg border border-gray-100">
                        <div>
                            <label class="text-[9px] font-bold uppercase text-gray-400 tracking-wider block mb-1">License Class</label>
                            <select name="license" id="m_select_license" class="w-full bg-white border border-gray-200 rounded p-1.5 text-xs font-bold text-blue-900 outline-none">
                                <option value="Class D">Class D</option>
                                <option value="Class E (Bus)">Class E (Bus)</option>
                                <option value="Class E (Lori)">Class E (Lori)</option>
                                <option value="Class G">Class G</option>
                            </select>
                        </div>
                        <div>
                            <label class="text-[9px] font-bold uppercase text-gray-400 tracking-wider block mb-1">License Expiration</label>
                            <input type="date" name="license_expiration" id="m_input_expiry" required
                                   class="w-full bg-white border border-gray-200 rounded p-1 text-xs font-bold text-gray-600 outline-none">
                        </div>
                    </div>
                </div>
                
                <div class="p-3 bg-gray-50 border-t flex justify-end gap-2">
                    <button type="button" onclick="closeDriverModal()" class="px-4 py-1.5 border border-gray-300 text-gray-600 text-[10px] font-bold uppercase rounded hover:bg-gray-100 transition cursor-pointer">
                        Cancel
                    </button>
                    <button type="submit" class="px-4 py-1.5 bg-blue-600 hover:bg-blue-700 text-white text-[10px] font-bold uppercase rounded shadow transition cursor-pointer">
                        Save Changes
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
    function searchDrivers() {
        const input = document.getElementById("driverSearch");
        const filter = input.value.toUpperCase();
        const rows = document.getElementsByClassName("driver-row");

        for (let i = 0; i < rows.length; i++) {
            const profileText = rows[i].getElementsByTagName("td")[0].textContent || rows[i].getElementsByTagName("td")[0].innerText;
            const licenseText = rows[i].getElementsByTagName("td")[1].textContent || rows[i].getElementsByTagName("td")[1].innerText;
            const combinedText = profileText + " " + licenseText;

            if (combinedText.toUpperCase().indexOf(filter) > -1) {
                rows[i].style.display = "";
            } else {
                rows[i].style.display = "none";
            }
        }
    }

    function openDriverModal(name, id, phone, license, expiry, emergency) {
        document.getElementById('m_input_id').value = id;
        document.getElementById('m_input_name').value = name;
        document.getElementById('m_input_phone').value = phone;
        document.getElementById('m_input_emergency').value = emergency;
        document.getElementById('m_input_expiry').value = expiry;
        
        const selectLicense = document.getElementById('m_select_license');
        for(let i=0; i < selectLicense.options.length; i++) {
            if(selectLicense.options[i].value === license) {
                selectLicense.selectedIndex = i;
                break;
            }
        }

        const modal = document.getElementById('driverDetailsModal');
        modal.classList.remove('hidden');
        modal.classList.add('flex');
    }

    function closeDriverModal() {
        const modal = document.getElementById('driverDetailsModal');
        modal.classList.remove('flex');
        modal.classList.add('hidden');
    }
    </script>
</body>
</html>