<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ucms2.model.Student, com.ucms2.model.Event, java.util.*, java.sql.*, java.text.SimpleDateFormat" %>
<%
    if (session.getAttribute("student") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Student student = (Student) session.getAttribute("student");
    String ticker = (String) session.getAttribute("ticker");

    // --- 1. DIRECT DATABASE SYNC (Ensures instant updates) ---
    int liveEventCount = 0;
    int liveClubCount = 0;
    List liveEventsList = new ArrayList();
    List liveClubsList = new ArrayList();

    Connection connDash = null;
    try {
        connDash = com.ucms2.db.DBConnection.getConnection();
        
        // Live Event Count
        PreparedStatement psE = connDash.prepareStatement("SELECT COUNT(*) FROM EVENT_REGISTRATION WHERE StudentID = ?");
        psE.setString(1, student.getStudentId());
        ResultSet rsE = psE.executeQuery();
        if(rsE.next()) liveEventCount = rsE.getInt(1);
        rsE.close(); psE.close();

        // Live Club Count
        PreparedStatement psC = connDash.prepareStatement("SELECT COUNT(*) FROM CLUB_MEMBERSHIP WHERE StudentID = ? AND Status = 'active'");
        psC.setString(1, student.getStudentId());
        ResultSet rsC = psC.executeQuery();
        if(rsC.next()) liveClubCount = rsC.getInt(1);
        rsC.close(); psC.close();

        // Live Events List (Fix for empty "Upcoming Events")
        PreparedStatement psL = connDash.prepareStatement(
            "SELECT e.* FROM EVENT e JOIN EVENT_REGISTRATION r ON e.EventID = r.EventID " +
            "WHERE r.StudentID = ? AND e.EventDate >= CURRENT_DATE ORDER BY e.EventDate ASC");
        psL.setString(1, student.getStudentId());
        ResultSet rsL = psL.executeQuery();
        while(rsL.next()) {
            com.ucms2.model.Event ev = new com.ucms2.model.Event();
            ev.setEventName(rsL.getString("EventName"));
            ev.setEventDate(rsL.getDate("EventDate"));
            liveEventsList.add(ev);
        }
        rsL.close(); psL.close();

        // Live Clubs List
        PreparedStatement psCl = connDash.prepareStatement(
            "SELECT c.ClubName FROM CLUB c JOIN CLUB_MEMBERSHIP m ON c.ClubID = m.ClubID " +
            "WHERE m.StudentID = ? AND m.Status = 'active'");
        psCl.setString(1, student.getStudentId());
        ResultSet rsCl = psCl.executeQuery();
        while(rsCl.next()) {
            liveClubsList.add(rsCl.getString("ClubName"));
        }
        rsCl.close(); psCl.close();

    } catch(Exception e) { 
        e.printStackTrace(); 
    } finally {
        if(connDash != null) try { connDash.close(); } catch(Exception e){}
    }

    // 2.Ticker Logic
    StringBuilder tickerBuilder = new StringBuilder();
        if (liveEventsList != null && !liveEventsList.isEmpty()) {
            for (int i = 0; i < liveEventsList.size(); i++) {
                Event e = (Event) liveEventsList.get(i);
                String formattedDate = new SimpleDateFormat("MMM dd, yyyy").format(e.getEventDate());

                // This creates the format: | Name - Date |
                tickerBuilder.append("| ")
                             .append(e.getEventName())
                             .append(" - ")
                             .append(formattedDate)
                             .append(" | ");
            }
        } else {
            tickerBuilder.append("| Welcome to UCMS! No upcoming events registered yet. |");
        }
        String dynamicTicker = tickerBuilder.toString();

    // Assign variables for HTML
    List myEvents = liveEventsList;
    List myClubs = liveClubsList;

    int clubPercent = Math.min((liveClubCount * 100) / 5, 100);
    int eventPercent = Math.min((liveEventCount * 100) / 10, 100);
    int overallProgress = (clubPercent + eventPercent) / 2;
    String progressColor = (overallProgress >= 100) ? "#fbbf24" : "#3b82f6";

    // --- 3. CALENDAR & GREETING LOGIC ---
    Calendar baseTime = Calendar.getInstance();
    int currentMonth = baseTime.get(Calendar.MONTH);
    int currentYear = baseTime.get(Calendar.YEAR);
    int hour = baseTime.get(Calendar.HOUR_OF_DAY);

    String paramMonth = request.getParameter("month");
    String paramYear = request.getParameter("year");
    int displayMonth = (paramMonth != null) ? Integer.parseInt(paramMonth) : currentMonth;
    int displayYear = (paramYear != null) ? Integer.parseInt(paramYear) : currentYear;

    Calendar navCal = Calendar.getInstance();
    navCal.set(displayYear, displayMonth, 1);

    int nextMonth = displayMonth + 1; int nextYear = displayYear;
    if (nextMonth > 11) { nextMonth = 0; nextYear++; }
    int prevMonth = displayMonth - 1; int prevYear = displayYear;
    if (prevMonth < 0) { prevMonth = 11; prevYear--; }

    String monthName = new java.text.DateFormatSymbols().getMonths()[displayMonth];

    String greeting, greetingIcon;
    if (hour >= 5 && hour < 12) { greeting = "Good Morning"; greetingIcon = "🌅"; }
    else if (hour >= 12 && hour < 17) { greeting = "Good Afternoon"; greetingIcon = "☀️"; }
    else if (hour >= 17 && hour < 21) { greeting = "Good Evening"; greetingIcon = "🌆"; }
    else { greeting = "Good Night"; greetingIcon = "🌙"; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Dashboard | UCMS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="css/styles.css">
    <style>
        .ticker-wrap { width: 100%; overflow: hidden; background: transparent; }
        .ticker-move { display: inline-block; white-space: nowrap; padding-left: 100%; animation: ticker 40s linear infinite; }
        .ticker-wrap:hover .ticker-move { animation-play-state: paused; }
        @keyframes ticker { 0% { transform: translate3d(0, 0, 0); } 100% { transform: translate3d(-100%, 0, 0); } }
        .nav-link.active { background: rgba(59, 130, 246, 0.15); border-right: 4px solid #3b82f6; color: #fff !important; }
        .interactive-card { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .interactive-card:hover { transform: translateY(-8px); border-color: #3b82f6; }
    </style>
</head>
<body class="bg-[#f8fafc]">
    <div class="dashboard-container">
        <nav class="sidebar">
            <a href="index.jsp" class="sidebar-brand flex items-center gap-3">
                <img src="<%= request.getContextPath() %>/img/ucms_logo.png" alt="Logo" class="h-10 w-auto">
                <span class="text-2xl font-black tracking-tighter text-blue-400">Student</span>
            </a>
            <a href="student-dashboard.jsp" class="nav-link active">🏠 Dashboard</a>
            <a href="my-output.jsp" class="nav-link">📊 My Progress</a>
            <a href="clubs.jsp" class="nav-link">🔍 Explore Clubs</a>
            <a href="events.jsp" class="nav-link">📅 Campus Events</a>
            <a href="campus-buzz.jsp" class="nav-link">📢 Campus Buzz</a>
            <div style="margin-top: auto;"><a href="logout" class="nav-link text-red-400">🚪 Logout</a></div>
        </nav>

        <main class="main-content">
            <%-- Dynamic Ticker --%>
            <div class="mb-8 bg-[#1e293b] text-white rounded-xl py-2 px-2 flex items-center shadow-lg border border-blue-500/20">
                <div class="bg-[#3b82f6] px-4 py-1 font-black text-[11px] uppercase tracking-widest rounded-md mr-4 shadow-sm">NEWS</div>
                <div class="ticker-wrap flex-1">
                    <div class="ticker-move text-sm font-bold opacity-90 tracking-wide text-blue-100 uppercase">
                        <%= dynamicTicker %> <%= dynamicTicker %>
                    </div>
                </div>
            </div>

            <header class="mb-10">
                <h1 class="text-4xl font-black text-[#1e293b] tracking-tight"><%= greeting %>, <%= student.getStudentName() %> <%= greetingIcon %></h1>
                <p class="text-slate-500 mt-2 text-lg">Your live campus summary.</p>
            </header>

            <%-- Summary Cards --%>
            <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 mb-10">
                <div class="interactive-card lg:col-span-4 bg-white p-8 rounded-[2rem] shadow-sm border border-slate-100 flex items-center justify-between">
                    <div>
                        <p class="text-[11px] font-black text-slate-400 uppercase tracking-widest">Goal Status</p>
                        <h3 class="text-3xl font-black text-[#1e293b] mt-1">Roadmap</h3>
                        <a href="my-output.jsp" class="text-[#3b82f6] text-[11px] font-bold mt-3 block uppercase">Details →</a>
                    </div>
                    <div class="relative w-20 h-20 flex items-center justify-center">
                        <svg class="w-full h-full transform -rotate-90">
                            <circle cx="40" cy="40" r="34" stroke="#f1f5f9" stroke-width="6" fill="transparent" />
                            <circle cx="40" cy="40" r="34" stroke="<%= progressColor %>" stroke-width="6" fill="transparent" 
                                    stroke-dasharray="213.6" 
                                    stroke-dashoffset="<%= 213.6 - (213.6 * overallProgress / 100) %>" />
                        </svg>
                        <span class="absolute text-xs font-black text-[#1e293b]"><%= overallProgress %>%</span>
                    </div>
                </div>

                <div class="interactive-card lg:col-span-8 bg-gradient-to-r from-[#2563eb] to-[#4f46e5] p-10 rounded-[2rem] text-white shadow-xl relative overflow-hidden">
                    <p class="text-blue-100 font-bold uppercase text-[11px] tracking-widest">Involvement Level</p>
                    <h3 class="text-4xl font-black mt-2">Active Participant</h3>
                    <p class="text-blue-100 mt-2 opacity-90 text-lg">You've joined <strong><%= liveClubCount %></strong> clubs and registered for <strong><%= liveEventCount %></strong> events.</p>
                    <span class="absolute right-[-2rem] bottom-[-2rem] text-[10rem] font-black opacity-10 select-none">UCMS</span>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-10">
                <%-- Clubs --%>
                <div class="bg-white p-8 rounded-[2.5rem] shadow-sm border border-slate-100">
                    <h3 class="text-lg font-black text-slate-800 mb-4 flex items-center">
                        <span class="w-1.5 h-5 bg-blue-500 rounded-full mr-2"></span> My Active Clubs
                    </h3>
                    <div class="space-y-3">
                        <% if (!myClubs.isEmpty()) { 
                            for (int i=0; i<myClubs.size(); i++) { %>
                                <div class="p-4 bg-slate-50 rounded-2xl border border-slate-100 font-bold text-slate-700 text-sm">
                                    🏛️ <%= myClubs.get(i) %>
                                </div>
                        <% } } else { %>
                            <p class="text-slate-400 italic text-sm">No active memberships found.</p>
                        <% } %>
                    </div>
                </div>

                <%-- Events --%>
                <div class="bg-white p-8 rounded-[2.5rem] shadow-sm border border-slate-100">
                    <h3 class="text-lg font-black text-slate-800 mb-4 flex items-center">
                        <span class="w-1.5 h-5 bg-emerald-500 rounded-full mr-2"></span> Upcoming Events
                    </h3>
                    <div class="space-y-3">
                        <% if (!myEvents.isEmpty()) { 
                            for (int i=0; i < myEvents.size(); i++) { 
                                Event ev = (Event) myEvents.get(i); %>
                                <div class="p-4 bg-emerald-50/50 rounded-2xl border border-emerald-100">
                                    <p class="font-black text-emerald-800 text-sm uppercase"><%= ev.getEventName() %></p>
                                    <p class="text-[10px] text-emerald-600 font-bold mt-1">📅 <%= ev.getEventDate() %></p>
                                </div>
                        <% } } else { %>
                            <p class="text-slate-400 italic text-sm">No upcoming reservations.</p>
                        <% } %>
                    </div>
                </div>
            </div>

            <%-- Schedule Calendar --%>
            <section class="bg-white p-8 rounded-[2.5rem] border border-slate-100 mb-10 shadow-sm">
                <div class="flex justify-between items-center mb-6">
                    <h3 class="text-xl font-black text-slate-800 tracking-tight">My Schedule</h3>
                    <div class="flex items-center gap-4">
                        <span class="text-sm font-bold text-slate-600 uppercase tracking-tighter"><%= monthName %> <%= displayYear %></span>
                        <div class="flex bg-slate-100 p-1 rounded-lg">
                            <a href="student-dashboard.jsp?month=<%= prevMonth %>&year=<%= prevYear %>" class="p-1 hover:bg-white rounded transition-all">⬅️</a>
                            <a href="student-dashboard.jsp?month=<%= nextMonth %>&year=<%= nextYear %>" class="p-1 hover:bg-white rounded transition-all">➡️</a>
                        </div>
                    </div>
                </div>

                <div class="grid grid-cols-7 gap-2">
                    <% String[] dHeaders = {"S", "M", "T", "W", "T", "F", "S"};
                       for(int h=0; h<7; h++) { %><div class="text-center text-[10px] font-black text-slate-300 py-2"><%= dHeaders[h] %></div><% } %>
                    
                    <%  
                        Map dashEventMap = new HashMap();
                        for(int j=0; j<myEvents.size(); j++) {
                            Event ev = (Event) myEvents.get(j);
                            dashEventMap.put(new SimpleDateFormat("yyyy-MM-dd").format(ev.getEventDate()), "active");
                        }
                        
                        int startSlots = navCal.get(Calendar.DAY_OF_WEEK) - 1; 
                        int totalDays = navCal.getActualMaximum(Calendar.DAY_OF_MONTH);
                        
                        for(int i=0; i<startSlots; i++) { %> <div></div> <% }
                        for(int d=1; d<=totalDays; d++) {
                            String key = String.format("%04d-%02d-%02d", displayYear, displayMonth + 1, d);
                            boolean isEv = dashEventMap.containsKey(key);
                    %>
                        <div class="h-12 flex items-center justify-center rounded-xl transition-all 
                                    <%= isEv ? "bg-emerald-500 text-white font-black shadow-md scale-105" : "text-slate-400 hover:bg-slate-50" %>">
                            <span class="text-xs"><%= d %></span>
                        </div>
                    <% } %>
                </div>
            </section>
        </main>
    </div>
    <footer class="bg-white border-t border-gray-200 text-gray-500 text-sm text-center py-6">
        <div class="max-w-7xl mx-auto px-4">
            <p>
                &copy; <%= java.time.Year.now() %> University Club Management System. All rights reserved.
            </p>
            <p class="mt-1">Made with ❤️ for university students</p>
        </div>
    </footer>
</body>
</html>