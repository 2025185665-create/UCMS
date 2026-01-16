<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ucms2.model.Student, java.util.*, java.sql.*, com.ucms2.db.DBConnection" %>
<%
    Student student = (Student) session.getAttribute("student");
    if (student == null || !"student".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("login.jsp?error=Session Expired");
        return;
    }

    // --- DYNAMIC GREETING ---
    Calendar cal = Calendar.getInstance();
    int hour = cal.get(Calendar.HOUR_OF_DAY);
    String greeting, greetingIcon;
    if (hour >= 5 && hour < 12) { greeting = "Good Morning"; greetingIcon = "🌅"; }
    else if (hour >= 12 && hour < 17) { greeting = "Good Afternoon"; greetingIcon = "☀️"; }
    else if (hour >= 17 && hour < 21) { greeting = "Good Evening"; greetingIcon = "🌆"; }
    else { greeting = "Good Night"; greetingIcon = "🌙"; }

    // --- DATABASE FETCH (JAVA 1.5 COMPATIBLE) ---
    int clubCount = 0;
    int eventCount = 0;
    StringBuilder tickerContent = new StringBuilder();
    
    Connection conn = null;
    PreparedStatement ps1 = null; PreparedStatement ps2 = null; PreparedStatement ps3 = null;
    ResultSet rs1 = null; ResultSet rs2 = null; ResultSet rs3 = null;

    try {
        conn = DBConnection.getConnection();
        
        ps1 = conn.prepareStatement("SELECT COUNT(*) FROM CLUB_MEMBERSHIP WHERE StudentID = ?");
        ps1.setString(1, student.getStudentId());
        rs1 = ps1.executeQuery();
        if(rs1.next()) clubCount = rs1.getInt(1);

        ps2 = conn.prepareStatement("SELECT COUNT(*) FROM EVENT_REGISTRATION WHERE StudentID = ?");
        ps2.setString(1, student.getStudentId());
        rs2 = ps2.executeQuery();
        if(rs2.next()) eventCount = rs2.getInt(1);

        // Fetching Multi-Event for Ticker
        ps3 = conn.prepareStatement("SELECT EventName, EventVenue, EventDate FROM EVENT WHERE EventDate >= CURRENT_DATE ORDER BY EventDate ASC");
        rs3 = ps3.executeQuery();
        while(rs3.next()) {
            tickerContent.append(rs3.getString("EventName"))
                         .append(" | ").append(rs3.getString("EventVenue"))
                         .append(" | ").append(rs3.getDate("EventDate"))
                         .append("      •      ");
        }
        if (tickerContent.length() == 0) tickerContent.append("Welcome! Stay tuned for upcoming campus updates.");
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs1 != null) rs1.close(); if (ps1 != null) ps1.close();
            if (rs2 != null) rs2.close(); if (ps2 != null) ps2.close();
            if (rs3 != null) rs3.close(); if (ps3 != null) ps3.close();
            if (conn != null) conn.close();
        } catch (SQLException ex) { ex.printStackTrace(); }
    }

    // --- UNIFIED PROGRESS MATH ---
    int CLUB_GOAL = 5;
    int EVENT_GOAL = 10;
    int clubPercent = Math.min((clubCount * 100) / CLUB_GOAL, 100);
    int eventPercent = Math.min((eventCount * 100) / EVENT_GOAL, 100);
    int overallProgress = (clubPercent + eventPercent) / 2;
    String progressColor = (overallProgress >= 100) ? "#fbbf24" : "#3b82f6";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Dashboard | UCMS</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="css/styles.css">
    <style>
        /* NEWS TICKER - Slowed to 50s */
        .ticker-wrap { width: 100%; overflow: hidden; }
        .ticker-move { 
            display: inline-block; white-space: nowrap; padding-right: 100%; 
            animation: ticker 50s linear infinite; 
        }
        .ticker-move:hover { animation-play-state: paused; }
        @keyframes ticker { 0% { transform: translate3d(0, 0, 0); } 100% { transform: translate3d(-100%, 0, 0); } }

        /* SIDEBAR ACTIVE GLOW */
        .nav-link.active {
            background: rgba(59, 130, 246, 0.15);
            border-right: 4px solid #3b82f6;
            box-shadow: inset 0 0 10px rgba(59, 130, 246, 0.2);
            color: #fff !important;
        }

        /* INTERACTIVE CARD MOTION */
        .interactive-card { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .interactive-card:hover { transform: translateY(-8px); border-color: #3b82f6; }
    </style>
</head>
<body class="bg-[#f8fafc]">
    <div class="dashboard-container">
        <nav class="sidebar">
            <a href="index.jsp" class="sidebar-brand">UCMS Student</a>
            <a href="student-dashboard.jsp" class="nav-link active">🏠 Dashboard</a>
            <a href="MyProfileController" class="nav-link">📊 My Progress</a>
            <a href="clubs.jsp" class="nav-link">🔍 Explore Clubs</a>
            <a href="events.jsp" class="nav-link">📅 Upcoming Events</a>
            <a href="campus-buzz.jsp" class="nav-link">📢 Campus Buzz</a>
            
            <div style="margin-top: auto; padding-top: 2rem; border-top: 1px solid #334155;">
                <p class="text-sm font-bold text-white mb-4"><%= student.getStudentName() %></p>
                <a href="logout" class="nav-link" style="color: #ef4444; background: rgba(239, 68, 68, 0.1);">🚪 Logout</a>
            </div>
        </nav>

        <main class="main-content">
            <div class="mb-8 bg-[#1e293b] text-white rounded-xl py-2 px-2 flex items-center shadow-lg">
                <div class="bg-[#3b82f6] px-4 py-1 font-black text-[11px] uppercase tracking-widest rounded-md mr-4 z-10">NEWS</div>
                <div class="ticker-wrap flex-1">
                    <div class="ticker-move text-sm font-medium italic opacity-90"><%= tickerContent.toString() %></div>
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
                        <a href="MyProfileController" class="text-[#3b82f6] text-[11px] font-bold mt-3 block">VIEW DETAILS →</a>
                    </div>
                    <div class="relative w-20 h-20 flex items-center justify-center">
                        <svg class="w-full h-full transform -rotate-90">
                            <circle cx="40" cy="40" r="34" stroke="#f1f5f9" stroke-width="6" fill="transparent" />
                            <circle cx="40" cy="40" r="34" stroke="<%= progressColor %>" stroke-width="6" fill="transparent" 
                                    stroke-dasharray="213.6" 
                                    stroke-dashoffset="<%= 213.6 - (213.6 * overallProgress / 100) %>" 
                                    class="transition-all duration-1000" />
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

            <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div class="interactive-card bg-white p-10 rounded-[2.5rem] shadow-sm border border-slate-50">
                    <h2 class="text-3xl font-black text-[#1e293b]">Explore Campus</h2>
                    <p class="text-slate-500 mt-2 mb-8">Join societies or sign up for workshops.</p>
                    <div class="flex gap-4">
                        <a href="events.jsp" class="bg-[#2563eb] text-white px-10 py-3 rounded-2xl font-bold hover:scale-105 transition shadow-lg">Events</a>
                        <a href="clubs.jsp" class="bg-[#f1f5f9] text-[#1e293b] px-10 py-3 rounded-2xl font-bold hover:scale-105 transition">Clubs</a>
                    </div>
                </div>

                <div class="interactive-card bg-white p-10 rounded-[2.5rem] shadow-sm border border-slate-50">
                    <h2 class="text-3xl font-black text-[#1e293b]">Activity Log</h2>
                    <div class="mt-8">
                        <a href="ReportController" class="inline-flex items-center gap-3 bg-[#eff6ff] text-[#2563eb] px-8 py-4 rounded-2xl font-bold hover:scale-105 transition">
                            <span class="text-xl">📄</span> Download Report
                        </a>
                    </div>
                </div>
            </div>
        </main>
    </div>
</body>
</html>