<%@page import="java.net.URLEncoder"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.sql.*, com.ucms2.db.DBConnection, com.ucms2.model.Event, com.ucms2.model.Admin, com.ucms2.model.Student" %>
<%
    // 1. Controller Forwarding Check
    if (request.getAttribute("eventList") == null && request.getAttribute("attendanceList") == null && !"add".equals(request.getParameter("action"))) {
        request.getRequestDispatcher("/EventController").forward(request, response);
        return;
    }

    // 2. Variable Initialization
    String userRole = (String) session.getAttribute("userRole");
    com.ucms2.model.Student student = (com.ucms2.model.Student) session.getAttribute("student");
    java.util.List events = (java.util.List) request.getAttribute("eventList");
    java.util.List attendance = (java.util.List) request.getAttribute("attendanceList");
    String action = request.getParameter("action");
    String searchVal = request.getParameter("search") != null ? request.getParameter("search") : "";
    String curView = (String) request.getAttribute("viewMode");

    // 3. Direct DB Sync (Classic Java 1.5 Compatible)
    java.util.Set registeredEvents = new java.util.HashSet();
    java.util.Map liveAttendanceMap = new java.util.HashMap(); 

    java.sql.Connection connSync = null;
    try {
        connSync = com.ucms2.db.DBConnection.getConnection();
        if (student != null) {
            java.sql.PreparedStatement psReg = connSync.prepareStatement("SELECT EventID FROM EVENT_REGISTRATION WHERE StudentID = ?");
            psReg.setString(1, student.getStudentId());
            java.sql.ResultSet rsReg = psReg.executeQuery();
            while(rsReg.next()) { 
                registeredEvents.add(new Integer(rsReg.getInt(1))); 
            }
            rsReg.close(); psReg.close();
        }

        java.sql.Statement stmtCount = connSync.createStatement();
        java.sql.ResultSet rsCount = stmtCount.executeQuery("SELECT EventID, COUNT(*) as cnt FROM EVENT_REGISTRATION GROUP BY EventID");
        while(rsCount.next()) { 
            liveAttendanceMap.put(new Integer(rsCount.getInt("EventID")), new Integer(rsCount.getInt("cnt"))); 
        }
        rsCount.close(); stmtCount.close();
    } catch(Exception e) { 
        e.printStackTrace(); 
    } finally {
        if(connSync != null) try { connSync.close(); } catch(Exception e){}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Event Management | UCMS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="css/styles.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif !important; }
        .nav-link.active { background: rgba(59, 130, 246, 0.15); border-right: 4px solid #3b82f6; color: #fff !important; }
        .interactive-card { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .interactive-card:hover { transform: translateY(-8px); border-color: #3b82f6; }
        #toast { transition: opacity 0.5s ease-out; }
    </style>
</head>
<body class="bg-slate-50 font-['Inter']">

    <% if (request.getParameter("success") != null) { 
        String msg = request.getParameter("success");
        boolean isError = msg.startsWith("Error");
    %>
    <div id="toast" class="fixed top-5 right-5 z-50 <%= isError ? "bg-red-500" : "bg-emerald-500" %> text-white px-6 py-4 rounded-2xl shadow-xl flex items-center animate-bounce">
        <span class="mr-3"><%= isError ? "⚠️" : "✅" %></span>
        <p class="font-bold text-sm text-white"><%= msg %></p>
    </div>
    <script>setTimeout(function(){ var t = document.getElementById('toast'); if(t){ t.style.opacity='0'; setTimeout(function(){t.remove()}, 500); }}, 5000);</script>
    <% } %>

    <div class="dashboard-container">
        <nav class="sidebar">
            <a href="index.jsp" class="sidebar-brand text-2xl font-black tracking-tighter italic">UCMS</a>
            <a href="<%= "admin".equals(userRole) ? "admin-dashboard.jsp" : "student-dashboard.jsp" %>" class="nav-link">🏠 Dashboard</a>
            <a href="events.jsp" class="nav-link active">📅 Events</a>
            <a href="campus-buzz.jsp" class="nav-link">📢 Campus Buzz</a>
            <div style="margin-top: auto;"><a href="logout" class="nav-link text-red-400 font-bold">🚪 Logout</a></div>
        </nav>

        <main class="main-content p-10">
            <header class="flex flex-col md:flex-row justify-between items-center mb-10 gap-6">
                <h1 class="text-4xl font-black text-slate-800 tracking-tighter">
                    <% if ("add".equals(action)) { %> Create Activity <% } else if (attendance != null) { %> Participants <% } else { %> Campus Events <% } %>
                </h1>
                
                <div class="flex flex-wrap gap-4 items-center">
                    <% if (action == null && attendance == null) { %>
                        <div class="flex flex-col items-end gap-1">
                            <form action="EventController" method="GET" class="relative group">
                                <input type="text" name="search" value="<%= searchVal %>" placeholder="Search events..." class="bg-white border border-slate-200 pl-5 pr-12 py-3 rounded-2xl text-sm outline-none focus:ring-2 focus:ring-blue-500 w-64 shadow-sm font-medium">
                                <button type="submit" class="absolute right-4 top-3 text-slate-400">🔍</button>
                            </form>
                        </div>

                        <div class="bg-slate-200 p-1 rounded-xl flex">
                            <a href="EventController?viewMode=grid" class="px-5 py-2 rounded-lg text-[10px] font-black uppercase transition-all <%= !"calendar".equals(curView) ? "bg-white shadow-sm text-blue-600" : "text-slate-50" %>">Grid</a>
                            <a href="EventController?viewMode=calendar" class="px-5 py-2 rounded-lg text-[10px] font-black uppercase transition-all <%= "calendar".equals(curView) ? "bg-white shadow-sm text-blue-600" : "text-slate-50" %>">Calendar</a>
                        </div>
                    <% } %>

                    <% if ("admin".equals(userRole)) { %>
                        <a href="events.jsp?action=add" class="bg-blue-600 text-white px-8 py-3.5 rounded-2xl font-black shadow-lg text-xs uppercase tracking-widest hover:scale-105 transition">+ New Event</a>
                    <% } %>
                </div>
            </header>

            <%-- Case: Add Event --%>
            <% if ("add".equals(action)) { %>
                <div class="max-w-2xl mx-auto bg-white p-10 rounded-[2.5rem] border shadow-xl">
                    <form action="EventController" method="POST" class="space-y-6">
                        <input type="hidden" name="action" value="create">
                        <div><label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Activity Name</label><input type="text" name="eventName" required class="w-full p-4 bg-slate-50 border border-slate-200 rounded-2xl outline-none font-bold text-slate-700"></div>
                        <div><label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Venue</label><input type="text" name="eventVenue" required class="w-full p-4 bg-slate-50 border border-slate-200 rounded-2xl outline-none font-bold text-slate-700"></div>
                        <div class="grid grid-cols-2 gap-6">
                            <div><label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Date</label><input type="date" name="eventDate" required class="w-full p-4 border rounded-2xl outline-none"></div>
                            <div><label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Capacity</label><input type="number" name="targetGoal" required class="w-full p-4 border rounded-2xl outline-none"></div>
                        </div>
                        <button type="submit" class="w-full bg-slate-900 text-white py-4 rounded-2xl font-black uppercase tracking-widest shadow-lg">Publish Event</button>
                    </form>
                </div>

            <%-- Case: Participants Table --%>
            <% } else if (attendance != null) { %>
                <div class="bg-white rounded-[3rem] border border-slate-100 shadow-2xl overflow-hidden">
                    <div class="p-8 border-b flex justify-between items-center bg-slate-50/50">
                        <p class="text-[11px] font-black text-slate-400 uppercase tracking-[0.2em]">Confirmed Registrations</p>
                        <a href="events.jsp" class="text-xs font-bold text-blue-600 hover:underline">← Back to Events</a>
                    </div>
                    <table class="w-full text-left">
                        <thead class="bg-slate-50">
                            <tr class="text-[10px] font-black text-slate-400 uppercase tracking-widest">
                                <th class="p-8">Identity</th><th class="p-8">Full Name</th><th class="p-8 text-center">Registration Date</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-50">
                            <% if (attendance.isEmpty()) { %>
                                <tr><td colspan="3" class="p-20 text-center text-slate-400 font-bold italic">No students registered yet.</td></tr>
                            <% } else { %>
                                <% for (int k = 0; k < attendance.size(); k++) { String[] row = (String[]) attendance.get(k); %>
                                <tr class="hover:bg-slate-50/50">
                                    <td class="p-8 font-black text-slate-700 tracking-tighter"><%= row[0] %></td>
                                    <td class="p-8 font-bold text-slate-600"><%= row[1] %></td>
                                    <td class="p-8 text-center font-mono text-xs text-slate-400"><%= (row.length > 2 && row[2] != null) ? row[2] : "N/A" %></td>
                                </tr>
                                <% } %>
                            <% } %>
                        </tbody>
                    </table>
                </div>

            <%-- Case: Calendar --%>
            <% } else if ("calendar".equals(curView)) { %>
                <%-- Calendar logic remains identical to your previous version but includes the capacity split --%>
                <div class="bg-white rounded-[3rem] p-12 border border-slate-100 shadow-2xl animate-fadeIn">
                    <div class="grid grid-cols-7 gap-4">
                        <% String[] dayHead = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
                           for(String dh : dayHead) { %> <div class="text-center text-[11px] font-black text-slate-300 uppercase tracking-widest pb-6"><%= dh %></div> <% } %>
                        <% 
                            Map eventMap = new HashMap();
                            if(events != null) {
                                for(int eI=0; eI<events.size(); eI++) {
                                    Event ev = (Event) events.get(eI);
                                    String key = new java.text.SimpleDateFormat("yyyy-MM-dd").format(ev.getEventDate());
                                    if(!eventMap.containsKey(key)) eventMap.put(key, new ArrayList());
                                    ((List)eventMap.get(key)).add(ev);
                                }
                            }
                            Calendar cal = Calendar.getInstance(); cal.set(Calendar.DAY_OF_MONTH, 1);
                            int start = cal.get(Calendar.DAY_OF_WEEK) - 1; int total = cal.getActualMaximum(Calendar.DAY_OF_MONTH);
                            java.util.Date today = new java.util.Date();
                            for(int i=0; i<start; i++) { %> <div class="h-32 bg-slate-50/30 rounded-3xl border border-dashed border-slate-100"></div> <% }
                            for(int dayNum=1; dayNum<=total; dayNum++) {
                                String dKey = String.format("%04d-%02d-%02d", cal.get(Calendar.YEAR), cal.get(Calendar.MONTH)+1, dayNum);
                                List dayEvents = (List) eventMap.get(dKey);
                        %>
                            <div class="h-32 p-4 bg-white border border-slate-100 rounded-3xl group relative overflow-hidden">
                                <span class="text-xs font-black text-slate-200 group-hover:text-blue-500 transition-colors"><%= dayNum %></span>
                                <div class="mt-2 space-y-1.5 overflow-y-auto max-h-20">
                                    <% if(dayEvents != null) { 
                                        for(int j=0; j<dayEvents.size(); j++) { 
                                            Event e = (Event) dayEvents.get(j);
                                            Integer liveCntObj = (Integer) liveAttendanceMap.get(new Integer(e.getEventId()));
                                            int currentCnt = (liveCntObj != null) ? liveCntObj.intValue() : 0;
                                            String vRaw = e.getEventVenue();
                                            int calGoal = (e.getTargetGoal() > 0) ? e.getTargetGoal() : 50;
                                            if (vRaw != null && vRaw.contains("|")) { try { calGoal = Integer.parseInt(vRaw.split("\\|")[1].trim()); } catch(Exception ex){} }
                                            boolean isFull = currentCnt >= calGoal;
                                            boolean isReg = registeredEvents.contains(new Integer(e.getEventId()));
                                            boolean isPast = e.getEventDate().before(today);
                                            String color = isReg ? "bg-emerald-500" : (isPast ? "bg-slate-300" : (isFull ? "bg-red-500" : "bg-blue-600"));
                                    %>
                                        <div class="<%= color %> p-2 rounded-xl cursor-pointer hover:scale-105 transition-transform" onclick="location.href='EventController?search=<%= URLEncoder.encode(e.getEventName(), "UTF-8") %>&viewMode=grid'">
                                            <p class="text-[7px] font-black text-white truncate uppercase"><%= e.getEventName() %></p>
                                        </div>
                                    <% } } %>
                                </div>
                            </div>
                        <% } %>
                    </div>
                </div>

            <%-- Case: Grid Loop --%>
            <% } else if (events != null) { %>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                    <% 
                        java.util.Date todayDt = new java.util.Date();
                        for (int i = 0; i < events.size(); i++) { 
                            com.ucms2.model.Event e = (com.ucms2.model.Event) events.get(i); 
                            
                            String venueDisplay = e.getEventVenue();
                            int finalGoal = (e.getTargetGoal() > 0) ? e.getTargetGoal() : 50; 
                            if (venueDisplay != null && venueDisplay.contains("|")) {
                                String[] parts = venueDisplay.split("\\|");
                                venueDisplay = parts[0].trim();
                                try { finalGoal = Integer.parseInt(parts[1].trim()); } catch(Exception ex){ finalGoal = 50; }
                            }

                            Integer liveCntObj = (Integer) liveAttendanceMap.get(new Integer(e.getEventId()));
                            int current = (liveCntObj != null) ? liveCntObj.intValue() : 0;
                            int percent = (finalGoal > 0) ? Math.min((current * 100) / finalGoal, 100) : 0;
                            boolean isPast = e.getEventDate().before(todayDt);
                            boolean isAlreadyReg = registeredEvents.contains(new Integer(e.getEventId()));
                    %>
                    <div class="interactive-card bg-white p-8 rounded-[2.5rem] border border-slate-100 shadow-sm flex flex-col justify-between">
                        <div>
                            <div class="flex justify-between items-start mb-4">
                                <span class="px-3 py-1 rounded-full text-[9px] font-black uppercase border <%= isPast ? "bg-slate-50 text-slate-400" : "bg-purple-50 text-purple-600 border-purple-100" %>">
                                    <%= isPast ? "Completed" : (current >= finalGoal ? "Full House" : "Registration Open") %>
                                </span>
                                <% if ("admin".equals(userRole)) { %>
                                    <%-- Corrected Delete Action --%>
                                    <form action="EventController" method="POST" onsubmit="return confirm('Archive record?')">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="eventId" value="<%= e.getEventId() %>">
                                        <button type="submit" class="text-slate-300 hover:text-red-500 transition-colors">🗑️</button>
                                    </form>
                                <% } %>
                            </div>
                            <h3 class="font-black text-2xl text-slate-800 tracking-tight leading-tight"><%= e.getEventName() %></h3>
                            <p class="text-sm text-slate-400 font-medium mt-2">📍 <%= venueDisplay %><br>📅 <%= e.getEventDate() %></p>
                        </div>
                        <div class="my-6">
                            <div class="flex justify-between text-[10px] font-black uppercase text-slate-400 mb-2 tracking-widest">
                                <span>Booking Status</span>
                                <span><%= current %> / <%= finalGoal %> Seats</span>
                            </div>
                            <div class="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                                <div class="h-full <%= percent >= 90 ? "bg-red-500" : "bg-blue-600" %> transition-all duration-1000" style="width: <%= percent %>%"></div>
                            </div>
                        </div>
                        <div class="pt-4 border-t border-slate-50">
                            <% if (isPast && !"admin".equals(userRole)) { %>
                                <%-- Student Past logic --%>
                                <% if (isAlreadyReg) { %>
                                    <form action="EventController" method="POST">
                                        <input type="hidden" name="action" value="downloadCertificate">
                                        <input type="hidden" name="eventName" value="<%= e.getEventName() %>">
                                        <input type="hidden" name="eventDate" value="<%= e.getEventDate().toString() %>">
                                        <button type="submit" class="w-full bg-emerald-600 text-white py-3 rounded-2xl font-black text-xs uppercase tracking-widest shadow-lg">Claim Certificate</button>
                                    </form>
                                <% } else { %>
                                    <div class="w-full bg-slate-100 text-slate-400 py-3 rounded-2xl font-black text-xs text-center border border-slate-200 border-dashed">No record</div>
                                <% } %>
                            <% } else if (!isPast && !"admin".equals(userRole)) { %>
                                <%-- Student Active logic --%>
                                <% if (isAlreadyReg) { %>
                                    <div class="w-full bg-slate-100 text-slate-400 py-3 rounded-2xl font-black text-xs text-center border border-slate-200">Registered ✅</div>
                                <% } else { %>
                                    <form action="EventController" method="POST">
                                        <input type="hidden" name="eventId" value="<%= e.getEventId() %>"><input type="hidden" name="action" value="register">
                                        <button type="submit" class="w-full bg-blue-600 text-white py-3 rounded-2xl font-black text-xs shadow-lg hover:bg-blue-700 transition">Register Now</button>
                                    </form>
                                <% } %>
                            <% } else if ("admin".equals(userRole)) { %>
                                <%-- Corrected Participant Link --%>
                                <a href="EventController?action=viewAttendance&eventId=<%= e.getEventId() %>" class="block text-center py-3 bg-slate-50 text-slate-600 text-[10px] font-black uppercase rounded-2xl border border-slate-100 hover:bg-blue-600 hover:text-white transition">View Participants</a>
                            <% } %>
                        </div>
                    </div>
                    <% } %>
                </div>
            <% } %>
        </main>
    </div>
    
    <footer class="bg-white border-t border-gray-200 text-gray-500 text-sm text-center py-6">
        <div class="max-w-7xl mx-auto px-4">
            <p>&copy; <%= java.time.Year.now() %> University Club Management System. All rights reserved.</p>
            <p class="mt-1">Made with ❤️ for university students</p>
        </div>
    </footer>
</body>
</html>