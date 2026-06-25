<%-- 
    Document   : manageVehicle
    Created on : 2 May 2026, 1:45:12 am
    Author     : fatih
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    // 1. Semakan Sesi dan Autorisasi
    if (session.getAttribute("userName") == null || !"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("../Staff/login.jsp");
        return;
    }
    String fullName = (String) session.getAttribute("userName");
    
    // 2. Konfigurasi Pangkalan Data
    String dbUrl = "jdbc:mysql://localhost:3306/uvbs_db";
    String dbUser = "root";
    String dbPass = "admin";

    int total = 0, avail = 0, maint = 0;
    
    // 3. Menggunakan Try-With-Resources untuk mengelakkan "Resource Leak"
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection c = DriverManager.getConnection(dbUrl, dbUser, dbPass)) {
            
            // Mengoptimumkan query - mengambil semua kiraan dalam satu pangkalan data panggilan (pilihan)
            // Namun untuk mengekalkan logik asal anda secara selamat:
            try (Statement stmt = c.createStatement()) {
                try (ResultSet rs1 = stmt.executeQuery("SELECT COUNT(*) FROM vehicles")) {
                    if(rs1.next()) total = rs1.getInt(1);
                }
                try (ResultSet rs2 = stmt.executeQuery("SELECT COUNT(*) FROM vehicles WHERE status='Available'")) {
                    if(rs2.next()) avail = rs2.getInt(1);
                }
                try (ResultSet rs3 = stmt.executeQuery("SELECT COUNT(*) FROM vehicles WHERE status='Maintenance'")) {
                    if(rs3.next()) maint = rs3.getInt(1);
                }
            }
        }
    } catch(Exception e) {
        e.printStackTrace(); // Penting untuk debugging jika berlaku ralat DB
    }

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
    <title>Vehicle Management | UVBS Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="../Style.css">
    <style>
        .nav-active { 
            color: white !important; 
            background-color: rgba(184, 151, 77, 0.1) !important; 
            border-left: 4px solid #b8974d !important; 
        }
        .status-available { background-color: #dcfce7; color: #166534; }
        .status-inuse { background-color: #dbeafe; color: #1e40af; }
        .status-maintenance { background-color: #fee2e2; color: #991b1b; }
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
            <a href="../Admin/adminDashboard.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 transition hover:bg-white/5 hover:text-white">
                <i class="fas fa-th-large w-5 text-center"></i> Dashboard
            </a>
            <a href="../Admin/adminApprovals.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 transition hover:bg-white/5 hover:text-white">
                <i class="fas fa-check-square w-5 text-center"></i> Booking Approvals
            </a>
            <a href="../Admin/manageReports.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 transition hover:bg-white/5 hover:text-white">
                <i class="fas fa-tools w-5 text-center"></i> Maintenance Reports
            </a>
            <a href="manageVehicle.jsp" class="nav-active flex items-center gap-4 px-8 py-4">
                <i class="fas fa-car-side w-5 text-center"></i> Vehicle Management
            </a>
            <a href="../driver/manageDrivers.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 transition hover:bg-white/5 hover:text-white">
                <i class="fas fa-user-tie w-5 text-center"></i> Driver Management
            </a>
            <a href="../Admin/manageFeedback.jsp" class="text-gray-400 flex items-center gap-4 px-8 py-4 hover:text-white transition">
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
        
        <header class="mb-8 flex justify-between items-start">
            <div>
                <h1 class="text-2xl font-bold text-[#1a2a3a]">Vehicle Management</h1>
                <p class="text-sm text-gray-500 italic">Manage and monitor your university's fleet assets.</p>
            </div>
            <div class="bg-white px-4 py-2 rounded-xl shadow-sm border border-gray-100 flex items-center gap-2 mt-1">
                <i class="far fa-clock text-[#b8974d] text-xs"></i>
                <span class="text-xs font-bold text-[#1a2a3a] tracking-wide uppercase"><%= currentDateStr %></span>
            </div>
        </header>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10" style="display: grid !important; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)) !important;">
            <div class="bg-white p-6 rounded-xl shadow-sm border-l-4 border-blue-500">
                <p class="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Total Fleet</p>
                <h3 class="text-3xl font-bold text-gray-800"><%= total %> <span class="text-xs font-normal text-gray-400">Units</span></h3>
            </div>
            <div class="bg-white p-6 rounded-xl shadow-sm border-l-4 border-green-500">
                <p class="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Ready for Trip</p>
                <h3 class="text-3xl font-bold text-gray-800"><%= avail %> <span class="text-xs font-normal text-gray-400">Units</span></h3>
            </div>
            <div class="bg-white p-6 rounded-xl shadow-sm border-l-4 border-red-500">
                <p class="text-[10px] font-bold text-gray-400 uppercase tracking-widest">In Maintenance</p>
                <h3 class="text-3xl font-bold text-gray-800"><%= maint %> <span class="text-xs font-normal text-gray-400">Units</span></h3>
            </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-12 gap-8" style="display: grid !important;">
            
            <div class="lg:col-span-4 bg-white rounded-xl shadow-md border p-6 h-fit">
                <h3 class="text-xs font-bold text-blue-900 uppercase tracking-widest mb-6 border-b pb-4">
                    <i class="fas fa-plus-circle text-[#b8974d] mr-2"></i> Register New Asset
                </h3>
                <form action="processVehicle.jsp" method="POST" class="space-y-4">
                    <div>
                        <label class="text-[10px] font-bold uppercase text-gray-400">Vehicle Model</label>
                        <input type="text" name="model" placeholder="e.g. Proton Exora" required 
                               class="w-full bg-gray-50 border border-gray-200 rounded-lg p-2.5 text-sm outline-none">
                    </div>
                    <div class="grid grid-cols-2 gap-4" style="display: grid !important; grid-template-columns: 1fr 1fr !important;">
                        <div>
                            <label class="text-[10px] font-bold uppercase text-gray-400">Plate Number</label>
                            <input type="text" name="plate" id="plate_input" placeholder="WYY 1234" required 
                                   class="w-full bg-gray-50 border border-gray-200 rounded-lg p-2.5 text-sm font-mono uppercase outline-none">
                        </div>
                        <div>
                            <label class="text-[10px] font-bold uppercase text-gray-400">Type</label>
                            <select name="type" class="w-full bg-gray-50 border border-gray-200 rounded-lg p-2.5 text-sm outline-none">
                                <option>Bus</option>
                                <option>Van</option>
                                <option>Car</option>
                                <option>SUV</option>
                            </select>
                        </div>
                    </div>
                    <div class="grid grid-cols-2 gap-4" style="display: grid !important; grid-template-columns: 1fr 1fr !important;">
                        <div>
                            <label class="text-[10px] font-bold uppercase text-gray-400">Seating Capacity</label>
                            <input type="number" name="capacity" placeholder="7" required 
                                   class="w-full bg-gray-50 border border-gray-200 rounded-lg p-2.5 text-sm outline-none">
                        </div>
                        <div>
                            <label class="text-[10px] font-bold uppercase text-gray-400">Road Tax Expiry</label>
                            <input type="date" name="roadtax_expiry" required 
                                   class="w-full bg-gray-50 border border-gray-200 rounded-lg p-2 text-sm outline-none">
                        </div>
                    </div>
                    <button type="submit" class="w-full bg-[#1a2a3a] text-white py-3 rounded-lg font-bold text-xs uppercase hover:bg-black transition-all cursor-pointer">
                        Add to Inventory
                    </button>
                </form>
            </div>

            <div class="lg:col-span-8">
                <div class="bg-white rounded-xl shadow-md border overflow-hidden">
                    <div class="p-4 bg-gray-50 border-b flex flex-col md:flex-row justify-between gap-4" style="display: flex !important; justify-content: space-between !important; align-items: center !important;">
                        <h3 class="text-xs font-bold text-gray-700 uppercase tracking-widest mt-2">Fleet Inventory</h3>
                        <div class="relative">
                            <i class="fas fa-search absolute left-3 top-3 text-gray-400 text-xs"></i>
                            <input type="text" id="vehicleSearch" onkeyup="searchTable()" placeholder="Search Plate or Model..." 
                                   class="pl-9 pr-4 py-2 border rounded-lg text-xs focus:border-[#b8974d] outline-none w-full md:w-64">
                        </div>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="w-full text-left border-collapse" id="vehicleTable" style="width: 100% !important;">
                            <thead class="bg-white border-b text-[10px] uppercase font-bold text-gray-400">
                                <tr>
                                    <th class="px-6 py-4">Vehicle Details</th>
                                    <th class="px-6 py-4">Status</th>
                                    <th class="px-6 py-4 text-right" style="text-align: right !important;">Actions</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-100">
                                <%
                                    try {
                                        Class.forName("com.mysql.cj.jdbc.Driver");
                                        try (Connection c = DriverManager.getConnection(dbUrl, dbUser, dbPass);
                                             PreparedStatement pstmt = c.prepareStatement("SELECT * FROM vehicles ORDER BY vehicle_id DESC");
                                             ResultSet rs = pstmt.executeQuery()) {
                                                 
                                            while(rs.next()) {
                                                int vehicleId = rs.getInt("vehicle_id");
                                                String status = rs.getString("status");
                                                String sClass = "status-maintenance";
                                                
                                                if ("Available".equals(status)) {
                                                    sClass = "status-available";
                                                } else if ("In-Use".equals(status)) {
                                                    sClass = "status-inuse";
                                                }
                                                
                                                String expiryDate = rs.getString("roadtax_expiry") != null ? rs.getString("roadtax_expiry") : "N/A";
                                %>
                                <tr class="hover:bg-gray-50 transition">
                                    <td class="px-6 py-4">
                                        <p class="font-bold text-gray-800 uppercase" style="font-weight: 700 !important;"><%= rs.getString("model") %></p>
                                        <p class="text-[10px] text-blue-900 font-mono font-bold tracking-widest uppercase" style="font-weight: 700 !important;"><%= rs.getString("plate_number") %></p>
                                        <p class="text-[9px] text-gray-400 uppercase"><%= rs.getString("type") %> • <%= rs.getInt("capacity") %> Seater</p>
                                        <p class="text-[9px] text-amber-600 font-medium mt-1"><i class="far fa-calendar-alt mr-1"></i>Road Tax Due: <%= expiryDate %></p>
                                    </td>
                                    <td class="px-6 py-4">
                                        <% if("In-Use".equals(status) || "Maintenance".equals(status)) { %>
                                            <button type="button" onclick="viewMiniDetails(<%= vehicleId %>, '<%= status %>')" 
                                                    class="<%= sClass %> px-2 py-1 rounded text-[9px] font-bold uppercase flex items-center gap-1 hover:opacity-80 transition cursor-pointer" style="display: inline-flex !important; align-items: center !important;">
                                                <%= status %> <i class="fas fa-info-circle text-[10px]"></i>
                                            </button>
                                        <% } else { %>
                                            <span class="<%= sClass %> px-2 py-1 rounded text-[9px] font-bold uppercase" style="display: inline-block !important;">
                                                <%= status %>
                                            </span>
                                        <% } %>
                                    </td>
                                    <td class="px-6 py-4 text-right" style="text-align: right !important;">
                                        <form action="updateVehicleStatus.jsp" method="POST" class="flex justify-end items-center gap-2" style="display: flex !important; justify-content: flex-end !important; align-items: center !important;">
                                            <input type="hidden" name="vid" value="<%= vehicleId %>">
                                            <select name="newStatus" onchange="this.form.submit()" class="text-[9px] border rounded p-1 bg-white font-bold text-gray-600 outline-none cursor-pointer">
                                                <option value="Available" <%= "Available".equals(status)?"selected":"" %>>Available</option>
                                                <option value="In-Use" <%= "In-Use".equals(status)?"selected":"" %>>In-Use</option>
                                                <option value="Maintenance" <%= "Maintenance".equals(status)?"selected":"" %>>Maintenance</option>
                                            </select>
                                            <a href="deleteVehicle.jsp?id=<%= vehicleId %>" class="text-red-400 hover:text-red-600 ml-2 text-sm" onclick="return confirm('Delete this asset?')">
                                                <i class="fas fa-trash-alt"></i>
                                            </a>
                                        </form>
                                    </td>
                                </tr>
                                <% 
                                            } 
                                        } 
                                    } catch(Exception e) {
                                        e.printStackTrace();
                                    } 
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <div id="miniDetailsModal" class="fixed inset-0 bg-black/50 hidden justify-center items-center z-50 p-4 transition-all">
        <div class="bg-white rounded-xl shadow-xl w-full max-w-sm overflow-hidden border border-gray-200">
            <div id="modalHeader" class="p-4 text-white flex justify-between items-center bg-[#1a2a3a]" style="display: flex !important; justify-content: space-between !important; align-items: center !important;">
                <h4 class="text-xs font-bold uppercase tracking-wider flex items-center gap-2" style="display: flex !important; align-items: center !important;">
                    <i class="fas fa-info-circle text-[#b8974d]"></i> Asset Live Status
                </h4>
                <button onclick="closeMiniModal()" class="text-white/70 hover:text-white text-sm cursor-pointer">&times;</button>
            </div>
            <div class="p-6 space-y-4 text-gray-700 text-xs" id="modalBody">
                <div class="text-center py-4 text-gray-400 italic"><i class="fas fa-spinner fa-spin mr-2"></i>Loading details...</div>
            </div>
            <div class="p-3 bg-gray-50 border-t flex justify-end" style="display: flex !important; justify-content: flex-end !important;">
                <button onclick="closeMiniModal()" class="px-4 py-1.5 bg-[#1a2a3a] hover:bg-black text-white text-[10px] font-bold uppercase rounded transition cursor-pointer">
                    Close
                </button>
            </div>
        </div>
    </div>

    <script>
        function searchTable() {
            let input = document.getElementById("vehicleSearch").value.toUpperCase();
            let table = document.getElementById("vehicleTable");
            let tr = table.getElementsByTagName("tr");
            for (let i = 1; i < tr.length; i++) {
                let td = tr[i].getElementsByTagName("td")[0];
                if (td) {
                    let text = td.textContent || td.innerText;
                    tr[i].style.display = text.toUpperCase().indexOf(input) > -1 ? "" : "none";
                }
            }
        }
        
        document.getElementById('plate_input').addEventListener('input', function() {
            this.value = this.value.toUpperCase();
        });

        function viewMiniDetails(vehicleId, status) {
            const modal = document.getElementById('miniDetailsModal');
            const modalBody = document.getElementById('modalBody');
            const modalHeader = document.getElementById('modalHeader');
            
            if(status === 'In-Use') {
                modalHeader.className = "p-4 text-white flex justify-between items-center bg-blue-900";
            } else {
                modalHeader.className = "p-4 text-white flex justify-between items-center bg-red-900";
            }

            modalBody.innerHTML = '<div class="text-center py-4 text-gray-400 italic"><i class="fas fa-spinner fa-spin mr-2"></i>Loading details...</div>';
            modal.classList.remove('hidden');
            modal.classList.add('flex');

            fetch('getVehicleTripDetails.jsp?vid=' + vehicleId + '&status=' + status)
                .then(response => response.text())
                .then(html => {
                    modalBody.innerHTML = html;
                })
                .catch(err => {
                    modalBody.innerHTML = '<p class="text-red-500 text-center text-xs">❌ AJAX Error:<br>' + err.message + '</p>';
                });
        }

        function closeMiniModal() {
            const modal = document.getElementById('miniDetailsModal');
            modal.classList.remove('flex');
            modal.classList.add('hidden');
        }
    </script>
</body>
</html>