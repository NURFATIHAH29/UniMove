<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    if (session.getAttribute("userName") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String fullName = (String) session.getAttribute("userName");
    String userRole = (String) session.getAttribute("userRole");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vehicle Booking | UVBS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #f3f4f6; }
        #map { height: 250px; border-radius: 12px; z-index: 1; width: 100%; }
        .nav-link { color: #9ca3af; transition: all 0.3s; display: flex; align-items: center; gap: 1rem; padding: 1rem 2rem; font-size: 0.875rem; }
        .nav-link:hover { color: white; background-color: rgba(255,255,255,0.05); }
        .nav-active { color: white; background-color: rgba(255,255,255,0.1); border-right: 4px solid white; }
    </style>
</head>
<body class="flex flex-col md:flex-row min-h-screen">

    <header class="md:hidden bg-[#1a2a3a] text-white p-4 flex justify-between items-center sticky top-0 z-[100] shadow-md">
        <span class="font-bold text-sm tracking-wider">UVBS BOOKING</span>
        <button id="menuBtn" class="text-white text-xl focus:outline-none">
            <i class="fas fa-bars"></i>
        </button>
    </header>

    <aside id="sidebar" class="hidden md:flex w-64 bg-[#1a2a3a] flex-col text-white fixed top-0 bottom-0 left-0 z-50 transition-transform duration-300 md:translate-x-0 -translate-x-full">
        <div class="p-8 text-center border-b border-gray-700/50 relative">
            <button id="closeMenuBtn" class="md:hidden absolute top-4 right-4 text-gray-400 hover:text-white">
                <i class="fas fa-times text-lg"></i>
            </button>
            <img src="https://ui-avatars.com/api/?name=<%= fullName %>&background=b8974d&color=fff" class="w-16 h-16 rounded-full border-2 border-gray-600 mx-auto mb-4">
            <h2 class="font-bold text-xs uppercase tracking-widest"><%= fullName %></h2>
            <p class="text-[10px] text-gray-400 mt-1 uppercase">Role: <%= userRole %></p>
        </div>
        <nav class="flex-grow flex flex-col justify-between py-4 overflow-y-auto">
            <div>
                <a href="${pageContext.request.contextPath}/Staff/staffDashboard.jsp" class="nav-link">
                    <i class="fas fa-th-large w-5 text-center"></i> Dashboard
                </a>
                <a href="${pageContext.request.contextPath}/Staff/newBooking.jsp" class="nav-link nav-active">
                    <i class="fas fa-plus w-5 text-center"></i> New Booking
                </a>
                <a href="${pageContext.request.contextPath}/Staff/feedback.jsp" class="nav-link">
                    <i class="fas fa-comment-dots w-5 text-center"></i> Feedback
                </a>
                <a href="${pageContext.request.contextPath}/Staff/notifications.jsp" class="nav-link">
                    <i class="fas fa-bell w-5 text-center"></i> Notifications
                </a>
                <a href="${pageContext.request.contextPath}/Staff/profile.jsp" class="nav-link">
                    <i class="fas fa-user-circle w-5 text-center"></i> Profile
                </a>
            </div>
            <div class="border-t border-gray-700/50 pt-4">
                <a href="${pageContext.request.contextPath}/LogoutServlet" class="nav-link text-red-400 hover:bg-red-500/10 transition">
                    <i class="fas fa-sign-out-alt w-5 text-center"></i> Logout
                </a>
            </div>
        </nav>
    </aside>

    <main class="flex-grow md:ml-64 p-4 md:p-10 w-full overflow-x-hidden">
        <div class="max-w-4xl mx-auto">
            <header class="mb-6 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <div>
                    <h1 class="text-2xl font-bold text-gray-800">Vehicle Fleet Booking</h1>
                    <p class="text-xs text-gray-500 mt-0.5">Please specify the travel dates to check the availability of the university's fleet units.</p>
                </div>
                <button type="button" onclick="openProblemModal()" class="bg-amber-500 hover:bg-amber-600 text-white font-bold text-xs uppercase tracking-widest px-4 py-2.5 rounded-xl shadow-sm transition flex items-center gap-2 w-full sm:w-auto justify-center">
                    <i class="fas fa-question-circle"></i> Having Issues?
                </button>
            </header>

            <% if (session.getAttribute("errorMessage") != null) { %>
                <div class="mb-6 p-4 bg-red-100 border border-red-300 text-red-700 rounded-xl text-xs font-bold flex items-center gap-2">
                    <i class="fas fa-exclamation-circle text-sm"></i>
                    <%= session.getAttribute("errorMessage") %>
                </div>
            <% 
                    session.removeAttribute("errorMessage");
               } 
            %>

            <form action="${pageContext.request.contextPath}/BookingServlet" method="POST" onsubmit="return validateForm()" class="space-y-6">
                <input type="hidden" name="bookingType" id="bookingType" value="NORMAL">
                <input type="hidden" name="mapLink" id="mapLink">

                <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
                    <h3 class="text-sm font-bold text-blue-600 mb-4 flex items-center gap-2">
                        <span class="w-5 h-5 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center text-[11px]">1</span>
                        APPLICANT INFORMATION & DATES
                    </h3>
                    
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4 border-b border-gray-100 pb-4">
                        <div>
                            <label class="block text-[11px] font-bold text-gray-500 uppercase mb-1">Applicant Name</label>
                            <input type="text" name="staff_name" value="<%= fullName %>" readonly class="w-full border border-gray-200 bg-gray-50 text-gray-500 rounded-xl px-4 py-2.5 text-sm focus:outline-none cursor-not-allowed font-medium">
                        </div>
                        <div>
                            <label class="block text-[11px] font-bold text-gray-500 uppercase mb-1">Mobile Phone No.</label>
                            <input type="tel" name="phone_number" placeholder="Example: 0123456789" class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-blue-500" required>
                        </div>
                        <div>
                            <label class="block text-[11px] font-bold text-gray-500 uppercase mb-1">Passengers</label>
                            <input type="number" name="passengers" id="passengers" placeholder="Quantity" min="1" onchange="checkInputsAndFetch()" class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-blue-500 font-bold text-blue-600" required>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-[11px] font-bold text-gray-500 uppercase mb-1">Start Date</label>
                            <input type="date" name="startDate" id="startDate" onchange="checkInputsAndFetch()" class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-blue-500" required>
                        </div>
                        <div>
                            <label class="block text-[11px] font-bold text-gray-500 uppercase mb-1">End Date</label>
                            <input type="date" name="endDate" id="endDate" onchange="checkInputsAndFetch()" class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-blue-500" required>
                        </div>
                    </div>
                </div>

                <div id="dropdownVehicleSection" class="bg-white p-6 rounded-2xl shadow-sm border border-gray-200" style="display: none;">
                    <h3 class="text-sm font-bold text-blue-600 mb-4 flex items-center gap-2">
                        <span class="w-5 h-5 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center text-[11px]">2</span>
                        VEHICLE SELECTION & SEATING CAPACITY
                    </h3>
                    
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <div class="md:col-span-2">
                            <label class="block text-[11px] font-bold text-gray-500 uppercase mb-1">Select Vehicle Type</label>
                            <select name="vehicleType" id="vehicleDropdown" onchange="handleVehicleSelection()" class="w-full bg-white border border-gray-200 rounded-xl px-4 py-2.5 text-sm font-medium text-gray-700 focus:outline-none focus:border-blue-500 transition cursor-pointer">
                                <option value="">-- Please Select Vehicle Type --</option>
                            </select>
                        </div>

                        <div id="quantitySection" style="visibility: hidden; opacity: 0; transition: all 0.3s ease;">
                            <label class="block text-[11px] font-bold text-blue-600 uppercase mb-1">Vehicle Quantity</label>
                            <input type="number" name="vehicleQuantity" id="vehicleQuantity" value="1" min="1" class="w-full border-2 border-blue-400 rounded-xl px-4 py-2 text-sm font-bold text-blue-700 focus:outline-none focus:border-blue-600 bg-blue-50/50">
                            <p id="stockHint" class="text-[10px] text-gray-500 mt-1 font-medium"></p>
                        </div>
                    </div>

                    <div id="noVehicleAlert" class="mt-4 p-4 border border-dashed border-red-300 rounded-xl bg-red-50 text-center" style="display: none;">
                        <p class="text-xs text-red-600 font-bold mb-1">
                            <i class="fas fa-exclamation-triangle mr-1"></i> Insufficient vehicles available for this category on the selected dates.
                        </p>
                        <button type="button" onclick="openProblemModal()" class="mt-2 bg-amber-500 text-white text-[10px] font-bold px-3 py-1.5 rounded-lg hover:bg-amber-600 transition">
                            Contact External Fleet Administrator
                        </button>
                    </div>
                </div>

                <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
                    <h3 class="text-sm font-bold text-blue-600 mb-4 flex items-center gap-2">
                        <span class="w-5 h-5 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center text-[11px]">3</span>
                        TRIP DETAILS & GEOLOCATION
                    </h3>
                     
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                        <div>
                            <label class="block text-[11px] font-bold text-gray-500 uppercase mb-1">Pickup Location</label>
                            <input type="text" name="pickup" placeholder="Example: Complex Foyer" class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-blue-500" required>
                        </div>
                        <div>
                            <label class="block text-[11px] font-bold text-gray-500 uppercase mb-1">Destination Name</label>
                            <input type="text" name="destination" id="destination" placeholder="Type destination name..." class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-blue-500 font-medium" required>
                            <div id="driverWarningContainer"></div>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                        <div>
                            <label class="block text-[11px] font-bold text-gray-500 uppercase mb-1">Search Map Coordinates</label>
                            <div class="flex flex-col sm:flex-row gap-2">
                                <input type="text" id="searchAddress" placeholder="Type address to pin map..." class="flex-grow border border-gray-200 rounded-xl px-4 py-2 text-sm focus:outline-none focus:border-blue-500">
                                <button type="button" onclick="searchLocation()" class="bg-blue-600 text-white text-xs uppercase tracking-wider font-bold px-4 py-2.5 rounded-xl hover:bg-blue-700 transition whitespace-nowrap">Find Location</button>
                            </div>
                        </div>
                    </div>

                    <div class="mb-4">
                        <div id="map"></div>
                        <p class="text-[10px] text-gray-400 mt-1 italic">*You can also click directly on the map to change the destination pin position.</p>
                    </div>

                    <div>
                        <label class="block text-[11px] font-bold text-gray-500 uppercase mb-1">Purpose of Trip</label>
                        <textarea name="purpose" id="purpose" rows="2" placeholder="State the detailed purpose of the travel request..." class="w-full border border-gray-200 rounded-xl px-4 py-2 text-sm focus:outline-none focus:border-blue-500" required></textarea>
                    </div>
                </div>

                <div class="flex items-center justify-end gap-4">
                    <button type="reset" onclick="window.location.reload()" class="text-xs uppercase tracking-wider font-bold text-gray-400 hover:text-gray-600 px-4 py-2 transition">Clear</button>
                    <button type="submit" id="btnSubmit" class="bg-[#1a2a3a] text-white font-bold text-xs uppercase tracking-widest px-8 py-3.5 rounded-xl shadow-md hover:bg-slate-800 transition">
                        <i class="fas fa-paper-plane mr-1"></i> Submit Booking
                    </button>
                </div>
            </form>
        </div>
    </main>

    <div id="problemModal" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm hidden flex items-center justify-center p-4 z-[9999]">
        <div class="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl border border-amber-100">
            <div class="flex items-start gap-4">
                <div class="w-10 h-10 rounded-full bg-amber-100 flex items-center justify-center text-amber-600 shrink-0">
                    <i class="fas fa-info-circle text-lg"></i>
                </div>
                <div>
                    <h3 class="text-base font-bold text-slate-800">Vehicle System Support (UVBS)</h3>
                    <p class="text-xs text-gray-600 mt-2 leading-relaxed">
                        If you encounter shortage of university vehicles, please contact the administrator, Encik Muizzudin: 017-9300848 (PPH).
                    </p>
                </div>
            </div>
            <div class="mt-6 flex justify-end">
                <button type="button" onclick="closeProblemModal()" class="bg-slate-800 text-white text-xs font-bold uppercase tracking-wider px-4 py-2.5 rounded-xl transition">Close</button>
            </div>
        </div>
    </div>

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        var isLocationInsideTerengganu = true; 
        let destInput, searchInput, container, vehicleDropdown;

        document.addEventListener("DOMContentLoaded", function() {
            // Logik Mobile Menu
            const menuBtn = document.getElementById('menuBtn');
            const closeMenuBtn = document.getElementById('closeMenuBtn');
            const sidebar = document.getElementById('sidebar');

            if(menuBtn && sidebar) {
                menuBtn.addEventListener('click', () => {
                    sidebar.classList.remove('hidden', '-translate-x-full');
                    sidebar.classList.add('flex', 'translate-x-0');
                });
            }
            if(closeMenuBtn && sidebar) {
                closeMenuBtn.addEventListener('click', () => {
                    sidebar.classList.remove('flex', 'translate-x-0');
                    sidebar.classList.add('hidden', '-translate-x-full');
                });
            }

            // Set tarikh minimum hari ini
            const today = new Date().toISOString().split('T')[0];
            const startInput = document.getElementById('startDate');
            const endInput = document.getElementById('endDate');
            if(startInput) startInput.setAttribute('min', today);
            if(endInput) endInput.setAttribute('min', today);

            destInput = document.getElementById('destination');
            searchInput = document.getElementById('searchAddress');
            container = document.getElementById('driverWarningContainer');
            vehicleDropdown = document.getElementById('vehicleDropdown');

            if (destInput) destInput.addEventListener('input', validateTerengganuLocation);
            if (searchInput) searchInput.addEventListener('input', validateTerengganuLocation);
        });

        function validateTerengganuLocation() {
            if (!destInput || !container || !vehicleDropdown) return;

            const selectedVehicle = vehicleDropdown.value.trim().toLowerCase();
            const isBus = selectedVehicle.includes('bus');
            
            const destValue = destInput.value.trim().toLowerCase();
            const searchValue = searchInput ? searchInput.value.trim().toLowerCase() : '';
            const combinedText = destValue + " " + searchValue;

            const localKeywords = ['terengganu', 'unisza', 'umt', 'uitm dungun', 'kuala nerus', 'kuala terengganu', 'besut', 'kemaman', 'dungun', 'marang', 'hulu terengganu', 'setiu'];
            const textMentahMengandungiTerengganu = localKeywords.some(keyword => combinedText.includes(keyword));

            let paparanAmaran = false;
            
            if (isBus && combinedText.length > 2) {
                if (searchValue.length > 2) {
                    if (!isLocationInsideTerengganu) paparanAmaran = true;
                } else {
                    if (!textMentahMengandungiTerengganu) paparanAmaran = true;
                }
            }

            if (paparanAmaran) {
                container.innerHTML = `
                    <p class="text-[11px] text-amber-600 font-bold mt-1.5 bg-amber-50 border border-amber-200 px-3 py-1.5 rounded-lg flex items-center gap-1.5 animate-pulse">
                        <i class="fas fa-exclamation-triangle"></i> Outstation Note: Bus trips outside Terengganu automatically require 2 drivers per vehicle unit.
                    </p>
                `;
            } else {
                container.innerHTML = ''; 
            }
        }

        function openProblemModal() { document.getElementById('problemModal').classList.remove('hidden'); }
        function closeProblemModal() { document.getElementById('problemModal').classList.add('hidden'); }

        function checkInputsAndFetch() {
            const start = document.getElementById('startDate').value;
            const end = document.getElementById('endDate').value;
            const paxInput = document.getElementById('passengers').value;
            
            if (start && end && end < start) {
                alert("Error: End Date cannot be earlier than Start Date!");
                document.getElementById('endDate').value = '';
                return;
            }

            if (start && end && paxInput) {
                document.getElementById('dropdownVehicleSection').style.display = 'block';
                
                const dropdown = document.getElementById('vehicleDropdown');
                const alertBox = document.getElementById('noVehicleAlert');
                
                dropdown.innerHTML = '<option value="">-- Loading Vehicle List... --</option>';
                dropdown.disabled = false;
                if(alertBox) alertBox.style.display = 'none';

                let finalUrl = window.location.origin + "${pageContext.request.contextPath}" 
                    + "/GetAvailableVehiclesServlet?passengers=" + encodeURIComponent(paxInput)
                    + "&startDate=" + encodeURIComponent(start)
                    + "&endDate=" + encodeURIComponent(end);

                fetch(finalUrl)
                    .then(res => {
                        if (!res.ok) throw new Error("HTTP Error! Status: " + res.status);
                        return res.json();
                    })
                    .then(availableList => {
                        dropdown.innerHTML = '<option value="">-- Please Select Vehicle Type --</option>';
                        
                        if (availableList.length > 0 && availableList[0].error) {
                            dropdown.innerHTML = '<option value="">Failed to load system data</option>';
                            alert(availableList[0].error);
                            return;
                        }
                        
                        if (availableList.length === 0) {
                            dropdown.innerHTML = '<option value="">No available vehicle types at the moment.</option>';
                            dropdown.disabled = true;
                            if(alertBox) alertBox.style.display = 'block';
                        } else {
                            availableList.forEach(v => {
                                let opt = document.createElement('option');
                                opt.value = v.type;
                                opt.setAttribute('data-max-qty', v.available_qty);
                                
                                let typeLabel = v.type === 'Lorry' ? 'Lorry' : v.type;
                                opt.text = typeLabel + " (Capacity: " + v.capacity + " Pax)";
                                dropdown.appendChild(opt);
                            });
                        }
                        validateTerengganuLocation();
                    })
                    .catch(err => {
                        console.error("Fetch Error Details:", err);
                        dropdown.innerHTML = '<option value="">Failed to load system data</option>';
                    });
            }
        }

        function handleVehicleSelection() {
            const dropdown = document.getElementById('vehicleDropdown');
            const qtySection = document.getElementById('quantitySection');
            const qtyInput = document.getElementById('vehicleQuantity');
            const stockHint = document.getElementById('stockHint');
            
            if (dropdown.value !== "") {
                const selectedOpt = dropdown.options[dropdown.selectedIndex];
                const maxQty = parseInt(selectedOpt.getAttribute('data-max-qty'), 10);
                
                qtySection.style.visibility = 'visible';
                qtySection.style.opacity = '1';
                qtyInput.value = "1";
                qtyInput.setAttribute("max", maxQty); 
                
                stockHint.innerText = `*Available vehicles remaining: ${maxQty} units`;
            } else {
                qtySection.style.visibility = 'hidden';
                qtySection.style.opacity = '0';
                stockHint.innerText = "";
            }

            validateTerengganuLocation();
        }

        function validateForm() {
            const dropdown = document.getElementById('vehicleDropdown');
            if(!dropdown.value) {
                alert("Please select a vehicle type first before submitting the request.");
                return false;
            }
            
            const selectedOpt = dropdown.options[dropdown.selectedIndex];
            const maxQty = parseInt(selectedOpt.getAttribute('data-max-qty'), 10);
            const requestedQty = parseInt(document.getElementById('vehicleQuantity').value, 10);
            
            if (requestedQty > maxQty) {
                alert(`Oops, sorry! The requested vehicle quantity (${requestedQty}) exceeds the remaining stock (${maxQty}) for your selected dates.\n\nPlease reduce the quantity or change the dates.`);
                return false;
            }

            if (requestedQty <= 0 || isNaN(requestedQty)) {
                alert("Please enter a valid vehicle quantity (minimum 1)!");
                return false;
            }
            
            if(!document.getElementById('destination').value.trim()) {
                alert('Please specify your trip destination name!');
                return false;
            }

            if(!document.getElementById('mapLink').value) {
                alert('Please search for your destination on the map or click on the map to drop a coordinate pin.');
                return false;
            }

            return true;
        }

        var map, marker;
        setTimeout(function() {
            try {
                map = L.map('map').setView([5.4062, 103.0871], 12);
                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    attribution: '© OpenStreetMap contributors'
                }).addTo(map);

                map.on('click', function(e) {
                    var lat = e.latlng.lat;
                    var lng = e.latlng.lng;
                    updateMarkerAndLink(lat, lng);
                    isLocationInsideTerengganu = true; 
                    validateTerengganuLocation();
                });

            } catch(e) {
                console.error("Failed to initialize Leaflet map: ", e);
            }
        }, 400);

        function updateMarkerAndLink(lat, lng) {
            if (marker) { 
                marker.setLatLng([lat, lng]); 
            } else { 
                marker = L.marker([lat, lng]).addTo(map); 
            }
            // Diubah suai ke format link Google Maps standard yang sah
            document.getElementById('mapLink').value = "https://www.google.com/maps?q=" + lat + "," + lng;
        }

        function searchLocation() {
            var query = document.getElementById('searchAddress').value;
            if (query.trim() === "") return;
            
            var url = "https://nominatim.openstreetmap.org/search?format=json&q=" + encodeURIComponent(query) + "&countrycodes=my&addressdetails=1";
            
            fetch(url, {
                headers: {
                    'User-Agent': 'UVBS-University-Vehicle-Booking-System'
                }
            })
            .then(res => res.json())
            .then(data => {
                if (data.length > 0) {
                    var lat = parseFloat(data[0].lat);
                    var lng = parseFloat(data[0].lon);
                    map.setView([lat, lng], 15);
                    updateMarkerAndLink(lat, lng);

                    var address = data[0].address;
                    var displayName = data[0].display_name.toLowerCase();
                    
                    if ((address && address.state && address.state.toLowerCase().includes('terengganu')) || displayName.includes('terengganu')) {
                        isLocationInsideTerengganu = true;
                    } else {
                        isLocationInsideTerengganu = false;
                    }

                    validateTerengganuLocation();

                } else { 
                    alert("Location not found. Please try a more specific street/building name keyword or pin manually on the map."); 
                }
            })
            .catch(err => {
                console.error("Nominatim API Error:", err);
                alert("The system failed to connect to the coordinate server. You can still manually click/pin on the map.");
            });
        }
    </script>
</body>
</html>