<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ucms2.model.Student, com.ucms2.model.Event, java.util.*, java.text.SimpleDateFormat" %>
<%
    if (session.getAttribute("myEvents") == null) {
        response.sendRedirect("MyProfileController");
        return;
    }

    Student student = (Student) session.getAttribute("student");
    List myClubs = (List) session.getAttribute("myClubs");
    List myEvents = (List) session.getAttribute("myEvents");
    Integer clubCount = (Integer) session.getAttribute("clubCount");
    Integer eventCount = (Integer) session.getAttribute("eventCount");
    Integer newBuzz = (Integer) session.getAttribute("newBuzzCount");
    Boolean hasPendingLeave = (Boolean) session.getAttribute("hasPendingLeave");
    String ticker = (String) session.getAttribute("ticker");

    int CLUB_GOAL = 5;
    int EVENT_GOAL = 10;
    int clubPercent = Math.min((clubCount * 100) / CLUB_GOAL, 100);
    int eventPercent = Math.min((eventCount * 100) / EVENT_GOAL, 100);
    int overallProgress = (clubPercent + eventPercent) / 2;
    String progressColor = (overallProgress >= 100) ? "#fbbf24" : "#3b82f6";

    Calendar cal = Calendar.getInstance();
    int hour = cal.get(Calendar.HOUR_OF_DAY);
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
        .ticker-wrap { width: 100%; overflow: hidden; }
        .ticker-move { display: inline-block; white-space: nowrap; padding-right: 100%; animation: ticker 50s linear infinite; }
        @keyframes ticker { 0% { transform: translate3d(0, 0, 0); } 100% { transform: translate3d(-100%, 0, 0); } }
        .nav-link.active { background: rgba(59, 130, 246, 0.15); border-right: 4px solid #3b82f6; color: #fff !important; }
        .interactive-card { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .interactive-card:hover { transform: translateY(-8px); border-color: #3b82f6; }
    </style>
</head>
<body class="bg-[#f8fafc]">
    <div class="dashboard-container">
        <nav class="sidebar">
            <a href="index.jsp" class="sidebar-brand">UCMS Student</a>
            <a href="student-dashboard.jsp" class="nav-link active">🏠 Dashboard</a>
            <a href="my-output.jsp" class="nav-link">📊 My Progress</a>
            <a href="clubs.jsp" class="nav-link">🔍 Explore Clubs</a>
            <a href="events.jsp" class="nav-link">📅 Upcoming Events</a>
            <a href="campus-buzz.jsp" class="nav-link">📢 Campus Buzz</a>
            <a href="report-view.jsp" target="_blank" class="inline-flex items-center gap-3 bg-[#eff6ff] text-[#2563eb] px-8 py-4 rounded-2xl font-bold hover:scale-105 transition">
            <span class="text-xl">📄</span> Download Activity Transcript
            </a>
            <div style="margin-top: auto;"><a href="logout" class="nav-link text-red-400">🚪 Logout</a></div>
        </nav>

        <main class="main-content">
            <div class="mb-8 bg-[#1e293b] text-white rounded-xl py-2 px-2 flex items-center shadow-lg">
                <div class="bg-[#3b82f6] px-4 py-1 font-black text-[11px] uppercase tracking-widest rounded-md mr-4">NEWS</div>
                <div class="ticker-wrap flex-1">
                    <div class="ticker-move text-sm font-medium italic opacity-90"><%= ticker %></div>
                </div>
            </div>

            <header class="mb-10">
                <h1 class="text-4xl font-black text-[#1e293b]"><%= greeting %>, <%= student.getStudentName() %> <%= greetingIcon %></h1>
                <p class="text-slate-500 mt-2 text-lg">Here is your campus roadmap summary.</p>
            </header>

            <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 mb-10">
                <div class="interactive-card lg:col-span-4 bg-white p-8 rounded-[2rem] shadow-sm border border-slate-100 flex items-center justify-between">
                    <div>
                        <p class="text-[11px] font-black text-slate-400 uppercase tracking-widest">Goal Status</p>
                        <h3 class="text-3xl font-black text-[#1e293b] mt-1">Roadmap</h3>
                        <a href="MyProfileController?view=profile" class="text-[#3b82f6] text-[11px] font-bold mt-3 block uppercase">View Details →</a>
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

                <div class="interactive-card lg:col-span-8 bg-gradient-to-r from-[#2563eb] to-[#4f46e5] p-10 rounded-[2rem] text-white shadow-xl relative overflow-hidden flex flex-col justify-center">
                    <p class="text-blue-100 font-bold uppercase text-[11px] tracking-widest">Involvement Level</p>
                    <h3 class="text-4xl font-black mt-2">Active Participant</h3>
                    <p class="text-blue-100 mt-2 opacity-90">You've joined <%= clubCount %> clubs and registered for <%= eventCount %> events.</p>
                    <span class="absolute right-[-2rem] bottom-[-2rem] text-[10rem] font-black opacity-10 select-none">UCMS</span>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-10">
                <div class="bg-white p-8 rounded-[2.5rem] shadow-sm border border-slate-100">
                    <h3 class="text-lg font-black text-slate-800 mb-4 flex items-center">
                        <span class="w-1.5 h-5 bg-blue-500 rounded-full mr-2"></span> My Active Clubs
                    </h3>
                    <div class="space-y-3">
                        <% if (myClubs != null && !myClubs.isEmpty()) { 
                            for (Object clubName : myClubs) { %>
                                <div class="p-4 bg-slate-50 rounded-2xl border border-slate-100 font-bold text-slate-700 text-sm">
                                    🏛️ <%= clubName %>
                                </div>
                        <% } } else { %>
                            <p class="text-slate-400 italic text-sm">No active club memberships found.</p>
                        <% } %>
                    </div>
                </div>

                <div class="bg-white p-8 rounded-[2.5rem] shadow-sm border border-slate-100">
                    <h3 class="text-lg font-black text-slate-800 mb-4 flex items-center">
                        <span class="w-1.5 h-5 bg-emerald-500 rounded-full mr-2"></span> Upcoming Events
                    </h3>
                    <div class="space-y-3">
                        <% if (myEvents != null && !myEvents.isEmpty()) { 
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

            <section class="bg-white p-8 rounded-[2.5rem] border border-slate-100 mb-10 shadow-sm">
                <h3 class="text-xl font-black mb-6 text-slate-800">My Schedule</h3>
                <div class="grid grid-cols-7 gap-2">
                    <% String[] dayHeaders = {"S", "M", "T", "W", "T", "F", "S"};
                       for(String d : dayHeaders) { %> <div class="text-center text-[10px] font-black text-slate-300 py-2"><%= d %></div> <% } %>
                    <% 
                        Map eventMap = new HashMap();
                        for(int j=0; j<myEvents.size(); j++) {
                            Event ev = (Event) myEvents.get(j);
                            eventMap.put(new SimpleDateFormat("yyyy-MM-dd").format(ev.getEventDate()), "active");
                        }
                        Calendar c = Calendar.getInstance();
                        c.set(Calendar.DAY_OF_MONTH, 1);
                        int start = c.get(Calendar.DAY_OF_WEEK) - 1;
                        int total = c.getActualMaximum(Calendar.DAY_OF_MONTH);
                        for(int i=0; i<start; i++) { %> <div></div> <% }
                        for(int d=1; d<=total; d++) {
                            String key = String.format("%04d-%02d-%02d", c.get(Calendar.YEAR), c.get(Calendar.MONTH)+1, d);
                            boolean isEv = eventMap.containsKey(key);
                    %>
                        <div class="h-12 flex items-center justify-center rounded-xl transition-all <%= isEv ? "bg-emerald-500 text-white font-black shadow-lg" : "text-slate-400 hover:bg-slate-50" %>">
                            <span class="text-xs"><%= d %></span>
                        </div>
                    <% } %>
                </div>
            </section>
        </main>
    </div>
</body>
</html>