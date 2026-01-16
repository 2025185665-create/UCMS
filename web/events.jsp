<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.ucms2.model.Event, com.ucms2.model.Admin, com.ucms2.model.Student" %>
<%
    if (request.getAttribute("eventList") == null && request.getAttribute("attendanceList") == null && !"add".equals(request.getParameter("action"))) {
        request.getRequestDispatcher("/EventController").forward(request, response);
        return;
    }

    String userRole = (String) session.getAttribute("userRole");
    List events = (List) request.getAttribute("eventList");
    List attendance = (List) request.getAttribute("attendanceList");
    String action = request.getParameter("action");
    String view = request.getParameter("view"); 
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Event Management | UCMS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="css/styles.css">
    <style>
        /* ADDED: Sidebar Active Glow */
        .nav-link.active {
            background: rgba(59, 130, 246, 0.15);
            border-right: 4px solid #3b82f6;
            box-shadow: inset 0 0 10px rgba(59, 130, 246, 0.2);
            color: #fff !important;
        }
        /* ADDED: Interactive Card Motion */
        .interactive-card { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .interactive-card:hover { transform: translateY(-8px); border-color: #3b82f6; }
    </style>
</head>
<body class="bg-slate-50">
    <div class="dashboard-container">
        <nav class="sidebar">
            <a href="index.jsp" class="sidebar-brand">UCMS</a>
            <a href="<%= "admin".equals(userRole) ? "admin-dashboard-data" : "student-dashboard.jsp" %>" class="nav-link">🏠 Dashboard</a>
            <a href="events.jsp" class="nav-link active">📅 Events</a>
            <a href="campus-buzz.jsp" class="nav-link">📢 Campus Buzz</a>
            <div style="margin-top: auto;"><a href="logout" class="nav-link" style="color: #ef4444;">🚪 Logout</a></div>
        </nav>

        <main class="main-content">
            <header class="flex justify-between items-center mb-10">
                <h1 class="text-3xl font-black text-slate-800">
                    <% if ("add".equals(action)) { %> Create Event <% } else if (attendance != null) { %> Attendance <% } else { %> Campus Events <% } %>
                </h1>
                <div class="flex gap-2">
                    <% if (action == null && attendance == null) { %>
                        <a href="events.jsp?view=<%= "calendar".equals(view) ? "list" : "calendar" %>" class="px-4 py-2 bg-slate-200 rounded-xl font-bold text-xs uppercase">
                            <%= "calendar".equals(view) ? "📄 List" : "🗓️ Calendar" %>
                        </a>
                    <% } %>
                    <% if ("admin".equals(userRole)) { %>
                        <a href="events.jsp?action=add" class="bg-blue-600 text-white px-6 py-2 rounded-xl font-bold">+ New Event</a>
                    <% } %>
                </div>
            </header>

            <% if ("add".equals(action)) { %>
                <form action="EventController" method="POST" class="bg-white p-8 rounded-3xl border border-slate-200 max-w-lg mx-auto shadow-sm">
                    <input type="hidden" name="action" value="create">
                    <label class="block text-[10px] font-black text-slate-400 uppercase mb-2">Event Title</label>
                    <input type="text" name="eventName" required class="w-full p-3 mb-4 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500">
                    <label class="block text-[10px] font-black text-slate-400 uppercase mb-2">Venue</label>
                    <input type="text" name="eventVenue" required class="w-full p-3 mb-4 border rounded-xl outline-none">
                    <div class="grid grid-cols-2 gap-4 mb-6">
                        <div><label class="block text-[10px] font-black text-slate-400 uppercase mb-2">Date</label><input type="date" name="eventDate" required class="w-full p-3 border rounded-xl outline-none"></div>
                        <div><label class="block text-[10px] font-black text-slate-400 uppercase mb-2">Capacity</label><input type="number" name="targetGoal" required class="w-full p-3 border rounded-xl outline-none"></div>
                    </div>
                    <button type="submit" class="w-full bg-slate-800 text-white py-4 rounded-2xl font-bold">Publish Event</button>
                </form>
            <% } else if (events != null && !"calendar".equals(view)) { %>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <% 
                        java.util.Date today = new java.util.Date();
                        for (int i = 0; i < events.size(); i++) { 
                            Event e = (Event) events.get(i); 
                            int current = e.getAttendanceCount();
                            int target = e.getTargetGoal();
                            int percent = (target > 0) ? Math.min((current * 100) / target, 100) : 0;
                            boolean isPast = e.getEventDate().before(today);
                    %>
                    <div class="interactive-card bg-white p-6 rounded-3xl border border-slate-100 shadow-sm flex flex-col justify-between">
                        <div>
                            <span class="inline-block px-2 py-0.5 rounded text-[10px] font-black uppercase border mb-3 <%= isPast ? "bg-slate-100 text-slate-400" : "bg-purple-100 text-purple-700" %>">
                                <%= isPast ? "Ended" : "Upcoming" %>
                            </span>
                            <h3 class="font-black text-xl text-slate-800 leading-tight"><%= e.getEventName() %></h3>
                            <p class="text-xs text-slate-500 mt-1">📍 <%= e.getEventVenue() %> • 📅 <%= e.getEventDate() %></p>
                        </div>

                        <div class="mt-4 mb-6">
                            <div class="w-full bg-slate-100 h-1.5 rounded-full overflow-hidden">
                                <div class="h-full <%= percent >= 90 ? "bg-red-500" : "bg-emerald-500" %>" style="width: <%= percent %>%"></div>
                            </div>
                        </div>

                        <div>
                            <% if (isPast && !"admin".equals(userRole)) { %>
                                <form action="EventController" method="POST">
                                    <input type="hidden" name="action" value="downloadCertificate">
                                    <input type="hidden" name="eventName" value="<%= e.getEventName() %>">
                                    <input type="hidden" name="eventDate" value="<%= e.getEventDate() %>">
                                    <button type="submit" class="w-full bg-emerald-600 text-white py-2 rounded-xl font-bold text-sm">🎓 Certificate</button>
                                </form>
                            <% } else if (!isPast && !"admin".equals(userRole)) { %>
                                <form action="EventController" method="POST">
                                    <input type="hidden" name="eventId" value="<%= e.getEventId() %>">
                                    <input type="hidden" name="action" value="register">
                                    <button type="submit" class="w-full bg-blue-600 text-white py-2 rounded-xl font-bold text-sm">Join Event</button>
                                </form>
                            <% } else if ("admin".equals(userRole)) { %>
                                <a href="EventController?action=viewAttendance&eventId=<%= e.getEventId() %>" class="block text-center py-2 bg-slate-100 text-slate-600 text-xs font-black rounded-xl">Manage Attendance</a>
                            <% } %>
                        </div>
                    </div>
                    <% } %>
                </div>
            <% } else if ("calendar".equals(view)) { %>
                <div class="bg-white p-8 rounded-3xl border shadow-sm">
                    <h2 class="text-xs font-black text-slate-400 uppercase tracking-widest mb-6">Upcoming Schedule</h2>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <% for (int i = 0; i < events.size(); i++) { 
                            Event e = (Event) events.get(i); %>
                            <div class="p-4 bg-slate-50 border border-slate-200 rounded-2xl">
                                <p class="text-[10px] font-black text-blue-500 uppercase"><%= e.getEventDate() %></p>
                                <p class="text-sm font-bold text-slate-800 mt-1"><%= e.getEventName() %></p>
                                <p class="text-[10px] text-slate-400 mt-1">📍 <%= e.getEventVenue() %></p>
                            </div>
                        <% } %>
                    </div>
                </div>
            <% } %>
        </main>
    </div>
</body>
</html>