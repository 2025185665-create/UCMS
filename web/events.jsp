<%@page import="java.net.URLEncoder"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.sql.*, com.ucms2.db.DBConnection, com.ucms2.model.Event, com.ucms2.model.Admin, com.ucms2.model.Student" %>
<%
    // 1. Controller Forwarding Check
    if (request.getAttribute("eventList") == null && request.getAttribute("attendanceList") == null && !"add".equals(request.getParameter("action"))) {
        request.getRequestDispatcher("/EventController").forward(request, response);
        return;
    }
    
    // 2. Calendar logic for Navigation
    Calendar baseCal = Calendar.getInstance();
    int currentMonth = baseCal.get(Calendar.MONTH);
    int currentYear = baseCal.get(Calendar.YEAR);
    String paramMonth = request.getParameter("month");
    String paramYear = request.getParameter("year");
    int displayMonth = (paramMonth != null) ? Integer.parseInt(paramMonth) : currentMonth;
    int displayYear = (paramYear != null) ? Integer.parseInt(paramYear) : currentYear;
    Calendar cal = Calendar.getInstance();
    cal.set(displayYear, displayMonth, 1);
    int nextMonth = displayMonth + 1; int nextYear = displayYear;
    if (nextMonth > 11) { nextMonth = 0; nextYear++; }
    int prevMonth = displayMonth - 1; int prevYear = displayYear;
    if (prevMonth < 0) { prevMonth = 11; prevYear--; }
    String monthName = new java.text.DateFormatSymbols().getMonths()[displayMonth];
    
    // 3. Variable Initialization
    String userRole = (String) session.getAttribute("userRole");
    com.ucms2.model.Student student = (com.ucms2.model.Student) session.getAttribute("student");
    java.util.List events = (java.util.List) request.getAttribute("eventList");
    java.util.List attendance = (java.util.List) request.getAttribute("attendanceList");
    String action = request.getParameter("action");
    String searchVal = request.getParameter("search") != null ? request.getParameter("search") : "";
    String curView = (String) request.getAttribute("viewMode") != null ? (String) request.getAttribute("viewMode") : "grid";

    int pendingBuzzCount = 0;
    java.util.Set registeredEvents = new java.util.HashSet();
    java.util.Map liveAttendanceMap = new java.util.HashMap(); 

    // 4. DB Sync (Compatible with GlassFish 4.1.1 / Java 1.5+)
    java.sql.Connection connSync = null;
    try {
        connSync = com.ucms2.db.DBConnection.getConnection();
        if (student != null) {
            java.sql.PreparedStatement psReg = connSync.prepareStatement("SELECT EventID FROM EVENT_REGISTRATION WHERE StudentID = ?");
            psReg.setString(1, student.getStudentId());
            java.sql.ResultSet rsReg = psReg.executeQuery();
            while(rsReg.next()) { registeredEvents.add(new Integer(rsReg.getInt(1))); }
            rsReg.close(); psReg.close();
        }
        java.sql.Statement stmtCount = connSync.createStatement();
        java.sql.ResultSet rsCount = stmtCount.executeQuery("SELECT EventID, COUNT(*) as cnt FROM EVENT_REGISTRATION GROUP BY EventID");
        while(rsCount.next()) { liveAttendanceMap.put(new Integer(rsCount.getInt("EventID")), new Integer(rsCount.getInt("cnt"))); }
        rsCount.close();
        if ("admin".equals(userRole)) {
            java.sql.ResultSet rsBuzz = stmtCount.executeQuery("SELECT COUNT(*) FROM CAMPUS_BUZZ WHERE Status = 'pending'");
            if(rsBuzz.next()) { pendingBuzzCount = rsBuzz.getInt(1); }
            rsBuzz.close();
        }
        stmtCount.close();
    } catch(Exception e) { e.printStackTrace(); } finally {
        if(connSync != null) { try { connSync.close(); } catch(Exception e){} }
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
        @keyframes fadeInDown { from { opacity: 0; transform: translate(-50%, -20px); } to { opacity: 1; transform: translate(-50%, 0); } }
        .animate-pop { animation: fadeInDown 0.4s ease-out forwards; }
    </style>
</head>
<body class="bg-slate-50 font-['Inter']">

    <%-- 1. CENTERED TOAST POPUP --%>
<% if (request.getParameter("success") != null) { 
    String msg = request.getParameter("success");
boolean isError = msg.startsWith("Error"); 
%>
<div id="popup-notification" class="fixed top-10 left-1/2 -translate-x-1/2 z-[100] w-full max-w-md px-4 animate-pop">
    <div class="<%= isError ? "bg-red-600 shadow-red-200" : "bg-emerald-600 shadow-emerald-200" %> p-6 rounded-[2rem] shadow-2xl flex items-center gap-5 border-4 border-white">
        <div class="h-12 w-12 flex-shrink-0 bg-white/20 rounded-2xl flex items-center justify-center text-2xl text-white">
            <%= isError ? "🚫" : "✨" %>
        </div>
        <div class="flex-1 text-white">
            <h4 class="font-black text-xs uppercase tracking-widest opacity-70 mb-1">
                <%= isError ? "Alert" : "Success" %>
            </h4>
            <p class="font-bold text-lg leading-tight"><%= msg %></p>
        </div>
        <button onclick="this.parentElement.parentElement.remove()" class="text-white opacity-50 hover:opacity-100 text-xl">✕</button>
    </div>
</div>
<script>setTimeout(function() { var el = document.getElementById('popup-notification'); if(el) { el.style.opacity = '0'; el.style.transform = 'translate(-50%, -20px)'; el.style.transition='0.5s'; setTimeout(function() { el.remove(); }, 500); } }, 5000);</script>
<% } %>

    <div class="dashboard-container">
        <nav class="sidebar">
            <a href="index.jsp" class="sidebar-brand flex items-center gap-3">
                <img src="<%= request.getContextPath() %>/img/ucms_logo.png" alt="Logo" class="h-10 w-auto">
                <span class="text-2xl font-black tracking-tighter text-blue-400">Events</span>
            </a>
            <% if ("admin".equals(userRole)) { %>
                <a href="admin-dashboard.jsp" class="nav-link">🏠 Dashboard</a>
                <a href="ClubController" class="nav-link">🏛️ Manage Clubs</a>
                <a href="events.jsp" class="nav-link active">📅 Event Control </a>
                <a href="members.jsp" class="nav-link">👥 User Records</a>
                <a href="campus-buzz.jsp" class="nav-link relative flex items-center justify-between">
                    <span>📢 Campus Buzz</span>
                    <% if (pendingBuzzCount > 0) { %><span class="bg-red-500 text-white text-[10px] rounded-full h-5 w-5 flex items-center justify-center animate-pulse"><%= pendingBuzzCount %></span><% } %>
                </a>
            <% } else { %>
                <a href="student-dashboard.jsp" class="nav-link">🏠 Dashboard</a>
                <a href="my-output.jsp" class="nav-link">📊 My Progress</a>
                <a href="clubs.jsp" class="nav-link">🔍 Explore Clubs</a>
                <a href="events.jsp" class="nav-link active">📅 Campus Events</a>
                <a href="campus-buzz.jsp" class="nav-link">📢 Campus Buzz</a>
            <% } %>
            <div style="margin-top:auto"><a href="logout" class="nav-link text-red-400 font-bold">🚪 Logout</a></div>
        </nav>

        <main class="main-content p-10">
            <header class="flex flex-col md:flex-row justify-between items-center mb-10 gap-6">
                <h1 class="text-4xl font-black text-slate-800 tracking-tighter">
                    <% if ("add".equals(action)) { %> Create Event <% } else if (attendance != null) { %> Participants <% } else { %> Campus Events <% } %>
                </h1>
                
                <div class="flex items-center gap-2">
                    <form action="EventController" method="GET" class="flex items-center gap-2">
                        <input type="hidden" name="viewMode" value="<%= curView %>">
                        <div class="relative">
                            <input type="text" name="search" value="<%= searchVal %>" placeholder="Search..." class="bg-white border border-slate-200 pl-5 pr-12 py-3 rounded-2xl text-sm outline-none focus:ring-2 focus:ring-blue-500 w-64 shadow-sm font-medium">
                            <button type="submit" class="absolute right-4 top-3 text-slate-400">🔍</button>
                        </div>
                        <% if (!searchVal.isEmpty()) { %><a href="EventController?viewMode=<%= curView %>" class="bg-slate-200 hover:bg-slate-300 text-slate-600 px-4 py-3 rounded-2xl text-xs font-black uppercase transition-all shadow-sm">Clear</a><% } %>
                    </form>
                    <div class="bg-slate-200 p-1 rounded-xl flex ml-4 shadow-inner">
                        <a href="EventController?viewMode=grid" class="px-5 py-2 rounded-lg text-[10px] font-black uppercase transition-all <%= !"calendar".equals(curView) ? "bg-white shadow-sm text-blue-600" : "text-slate-400" %>">Grid</a>
                        <a href="EventController?viewMode=calendar" class="px-5 py-2 rounded-lg text-[10px] font-black uppercase transition-all <%= "calendar".equals(curView) ? "bg-white shadow-sm text-blue-600" : "text-slate-400" %>">Calendar</a>
                    </div>
                    <% if ("admin".equals(userRole)) { %><a href="events.jsp?action=add" class="bg-blue-600 text-white px-6 py-3 rounded-2xl font-black text-xs uppercase ml-2">+ New</a><% } %>
                </div>
            </header>

            <%-- CONTENT LOGIC --%>
            <% if ("add".equals(action)) { %>
                <div class="max-w-2xl mx-auto bg-white p-10 rounded-[2.5rem] border shadow-xl">
                    <form action="EventController" method="POST" class="space-y-6">
                        <input type="hidden" name="action" value="create">
                        <div><label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Activity Name</label><input type="text" name="eventName" required class="w-full p-4 bg-slate-50 border rounded-2xl outline-none font-bold"></div>
                        <div><label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Venue</label><input type="text" name="eventVenue" required class="w-full p-4 bg-slate-50 border rounded-2xl outline-none font-bold"></div>
                        <div class="grid grid-cols-2 gap-6">
                            <div><label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Date</label><input type="date" name="eventDate" required class="w-full p-4 border rounded-2xl outline-none"></div>
                            <div><label class="block text-xs font-bold text-slate-400 mb-2 uppercase">Capacity</label><input type="number" name="targetGoal" required class="w-full p-4 border rounded-2xl outline-none"></div>
                        </div>
                        <button type="submit" class="w-full bg-slate-900 text-white py-4 rounded-2xl font-black uppercase tracking-widest shadow-lg hover:scale-[1.02] transition">Publish Event</button>
                    </form>
                </div>

            <% } else if (attendance != null) { %>
                <div class="bg-white rounded-[3rem] border border-slate-100 shadow-2xl overflow-hidden">
                    <div class="p-8 border-b flex justify-between bg-slate-50/50 items-center"><p class="text-[11px] font-black text-slate-400 uppercase">Confirmed Registrations</p><a href="EventController" class="text-xs font-bold text-blue-600">← Back</a></div>
                    <table class="w-full text-left"><thead class="bg-slate-50"><tr class="text-[10px] font-black text-slate-400 uppercase"><th class="p-8">Identity</th><th class="p-8">Full Name</th><th class="p-8">Date</th></tr></thead>
                        <tbody class="divide-y divide-slate-50">
                            <% for (int k = 0; k < attendance.size(); k++) { String[] row = (String[]) attendance.get(k); %>
                                <tr><td class="p-8 font-black"><%= row[0] %></td><td class="p-8 font-bold text-slate-600"><%= row[1] %></td><td class="p-8 text-slate-400"><%= row[2] %></td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

            <% } else if ("calendar".equals(curView)) { %>
                <div class="bg-white rounded-[3rem] p-12 border shadow-2xl animate-pop" style="animation: none;">
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
                    %>
                    <div class="flex justify-between items-center mb-10">
                        <h2 class="text-3xl font-black text-slate-800"><%= monthName %> <span class="text-blue-600"><%= displayYear %></span></h2>
                        <div class="flex gap-2">
                            <a href="EventController?viewMode=calendar&month=<%= prevMonth %>&year=<%= prevYear %>" class="p-3 bg-slate-50 border rounded-xl hover:bg-slate-100 transition">⬅️ Prev</a>
                            <a href="EventController?viewMode=calendar" class="p-3 bg-blue-50 text-blue-600 font-bold rounded-xl hover:bg-blue-100 transition">Today</a>
                            <a href="EventController?viewMode=calendar&month=<%= nextMonth %>&year=<%= nextYear %>" class="p-3 bg-slate-50 border rounded-xl hover:bg-slate-100 transition">Next ➡️</a>
                        </div>
                    </div>
                    <div class="grid grid-cols-7 gap-4">
                        <% String[] dh = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}; for(int d=0; d<7; d++){ %><div class="text-center text-xs font-black text-slate-300 uppercase pb-6"><%= dh[d] %></div><% } %>
                        <% int startSlots = cal.get(Calendar.DAY_OF_WEEK) - 1; int totalDays = cal.getActualMaximum(Calendar.DAY_OF_MONTH); java.util.Date todayRef = new java.util.Date();
                           for(int i=0; i<startSlots; i++){ %><div class="h-32 bg-slate-50/30 rounded-3xl border border-dashed border-slate-100"></div><% }
                           for(int dayNum=1; dayNum<=totalDays; dayNum++){ 
                               String dKey = String.format("%04d-%02d-%02d", displayYear, displayMonth + 1, dayNum);
                               List dayEvents = (List) eventMap.get(dKey);
                        %>
                            <div class="h-32 p-4 bg-white border border-slate-100 rounded-3xl group relative overflow-hidden">
                                <span class="text-xs font-black text-slate-200 group-hover:text-blue-500 transition-colors"><%= dayNum %></span>
                                <div class="mt-2 space-y-1 overflow-y-auto max-h-20">
                                    <% if(dayEvents != null){ for(int j=0; j<dayEvents.size(); j++){ 
                                        Event e = (Event) dayEvents.get(j);
                                        int curCount = ((Integer)liveAttendanceMap.get(new Integer(e.getEventId())) != null) ? ((Integer)liveAttendanceMap.get(new Integer(e.getEventId()))).intValue() : 0;
                                        boolean isFull = curCount >= e.getTargetGoal(); boolean isReg = registeredEvents.contains(new Integer(e.getEventId())); boolean isPast = e.getEventDate().before(todayRef);
                                        String color = isFull ? "bg-red-500" : (isReg ? "bg-emerald-500" : (isPast ? "bg-slate-300" : "bg-blue-600"));
                                    %>
                                        <div class="<%= color %> p-1 text-white text-[7px] font-black uppercase rounded mt-1 truncate cursor-pointer hover:scale-105 transition" 
                                             onclick="location.href='EventController?search=<%= URLEncoder.encode(e.getEventName(), "UTF-8") %>&viewMode=grid'"><%= e.getEventName() %></div>
                                    <% } } %>
                                </div>
                            </div>
                        <% } %>
                    </div>
                </div>

            <% } else { %>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                    <% if(events.isEmpty()) { %><div class="col-span-full py-20 text-center"><p class="text-slate-400 font-bold italic text-lg">No events match your criteria.</p></div><% } %>
                    <% for (int i = 0; i < events.size(); i++) { 
                        Event e = (Event) events.get(i); 
                        int current = ((Integer)liveAttendanceMap.get(new Integer(e.getEventId())) != null) ? ((Integer)liveAttendanceMap.get(new Integer(e.getEventId()))).intValue() : 0;
                        int target = e.getTargetGoal(); int percent = (target > 0) ? Math.min((current * 100) / target, 100) : 0;
                        boolean isPast = e.getEventDate().before(new java.util.Date()); boolean isReg = registeredEvents.contains(new Integer(e.getEventId()));
                    %>
                        <div class="interactive-card bg-white p-8 rounded-[2.5rem] border border-slate-100 shadow-sm flex flex-col justify-between">
                            <div>
                                <div class="flex justify-between items-start mb-4">
                                    <span class="px-3 py-1 rounded-full text-[9px] font-black uppercase border <%= isPast ? "bg-slate-50 text-slate-400" : "bg-purple-50 text-purple-600 border-purple-100" %>"><%= isPast ? "Completed" : (current >= target ? "Full House" : "Open") %></span>
                                    <% if ("admin".equals(userRole)) { %>
                                        <form action="EventController" method="POST" onsubmit="return confirm('Permanently delete this event?')">
                                            <input type="hidden" name="action" value="delete"><input type="hidden" name="eventId" value="<%= e.getEventId() %>"><input type="hidden" name="viewMode" value="<%= curView %>">
                                            <button type="submit" class="text-slate-300 hover:text-red-500 transition-colors">🗑️</button>
                                        </form>
                                    <% } %>
                                </div>
                                <h3 class="font-black text-2xl text-slate-800 tracking-tight leading-tight"><%= e.getEventName() %></h3>
                                <p class="text-sm text-slate-400 font-medium mt-2">📍 <%= e.getEventVenue() %><br>📅 <%= e.getEventDate() %></p>
                            </div>
                            <div class="my-6">
                                <div class="flex justify-between text-[10px] font-black uppercase text-slate-400 mb-2 tracking-widest"><span>Booking Status</span><span><%= current %> / <%= target %> Seats</span></div>
                                <div class="w-full bg-slate-100 h-2 rounded-full overflow-hidden"><div class="h-full <%= percent >= 90 ? "bg-red-500" : "bg-blue-600" %> transition-all duration-1000" style="width: <%= percent %>%"></div></div>
                            </div>
                            <div class="pt-4 border-t border-slate-50">
                                <% if ("admin".equals(userRole)) { %>
                                    <a href="EventController?action=viewAttendance&eventId=<%= e.getEventId() %>" class="block text-center py-3 bg-slate-50 text-slate-600 text-[10px] font-black uppercase rounded-2xl border border-slate-100 hover:bg-blue-600 hover:text-white transition">View Participants</a>
                                <% } else if (isPast) { %>
                                    <% if (isReg) { %>
                                        <form action="EventController" method="POST" target="_blank"><input type="hidden" name="action" value="downloadCertificate"><input type="hidden" name="eventName" value="<%= e.getEventName() %>"><input type="hidden" name="eventDate" value="<%= e.getEventDate() %>"><button type="submit" class="w-full bg-emerald-600 text-white py-3 rounded-2xl font-black text-xs uppercase shadow-lg hover:scale-105 transition">Claim Certificate</button></form>
                                    <% } else { %><div class="w-full bg-slate-100 text-slate-400 py-3 rounded-2xl font-black text-xs text-center border-dashed border border-slate-200">No Record Found</div><% } %>
                                <% } else { %>
                                    <% if (isReg) { %><div class="w-full bg-slate-100 text-slate-400 py-3 rounded-2xl font-black text-xs text-center border border-slate-200">Registered ✅</div>
                                    <% } else { %>
                                        <form action="EventController" method="POST" onsubmit="return confirm('Confirm registration for: <%= e.getEventName() %>?')">
                                            <input type="hidden" name="eventId" value="<%= e.getEventId() %>"><input type="hidden" name="action" value="register"><input type="hidden" name="viewMode" value="<%= curView %>">
                                            <button type="submit" class="w-full bg-blue-600 text-white py-3 rounded-2xl font-black text-xs shadow-lg hover:bg-blue-700 hover:scale-[1.02] transition">Register Now</button>
                                        </form>
                                    <% } %>
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
            <p>
                &copy; <%= java.time.Year.now() %> University Club Management System. 
                All rights reserved.
            </p>
            <p class="mt-1">Made with ❤️ for university students</p>
        </div>
    </footer>
</body>
</html>