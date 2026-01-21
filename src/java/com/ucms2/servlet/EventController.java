package com.ucms2.servlet;

import com.ucms2.db.DBConnection;
import com.ucms2.db.EventDAO;
import com.ucms2.model.Student;
import com.ucms2.model.Event;
import java.io.*;
import java.net.URLEncoder;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/EventController")
public class EventController extends HttpServlet { 

    private EventDAO eventDAO = new EventDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userRole = (String) session.getAttribute("userRole");
        Student student = (Student) session.getAttribute("student");
        String action = request.getParameter("action");
        String search = request.getParameter("search");
        String viewMode = request.getParameter("viewMode");

        // --- Logic for Participants List ---
        if ("viewAttendance".equals(action) && "admin".equals(userRole)) {
            try {
                int eventId = Integer.parseInt(request.getParameter("eventId"));
                request.setAttribute("attendanceList", eventDAO.getAttendance(eventId));
            } catch (Exception e) { e.printStackTrace(); }
        } 

        List events;
        if (search != null && !search.trim().isEmpty()) {
            events = eventDAO.getEventsWithSearch(search);
            request.setAttribute("isSearchActive", Boolean.TRUE);
        } else {
            events = eventDAO.getAllEvents();
            request.setAttribute("isSearchActive", Boolean.FALSE);
        }

        request.setAttribute("eventList", events);
        request.setAttribute("viewMode", (viewMode != null) ? viewMode : "grid");
        request.getRequestDispatcher("events.jsp").forward(request, response);
    }

@Override
protected void doPost(HttpServletRequest request, HttpServletResponse response) 
        throws ServletException, IOException {
    
    HttpSession session = request.getSession();
    String userRole = (String) session.getAttribute("userRole");
    String action = request.getParameter("action");
    
    // Capture viewMode to ensure the user stays where they were
    String viewMode = request.getParameter("viewMode");
    if (viewMode == null) viewMode = "grid"; 
    
    String msg = "Action Successful"; // Default success message

    try {
        if ("downloadCertificate".equals(action)) {
            handleCertificateDownload(request, response, session);
            return; 
        }

        // --- ADMIN ACTIONS BLOCK ---
        if ("admin".equals(userRole)) {
            if ("create".equals(action)) {
                String name = request.getParameter("eventName");
                String date = request.getParameter("eventDate");
                String venue = request.getParameter("eventVenue");
                String goal = request.getParameter("targetGoal"); 

                int goalInt = (goal != null && !goal.trim().isEmpty()) ? Integer.parseInt(goal.trim()) : 50;
                String combinedVenue = venue + " | " + goalInt;

                eventDAO.createEvent(name, combinedVenue, date, goalInt); 
                msg = "Event Created Successfully!";
            } 
            else if ("delete".equals(action)) {
                int eventId = Integer.parseInt(request.getParameter("eventId"));
                deleteEventWithRegistrations(eventId); 
                msg = "Event and associated records deleted.";
                List updatedEvents = eventDAO.getAllEvents();
                session.setAttribute("totalEvents", updatedEvents.size());
            }
        } 
        // --- STUDENT ACTIONS BLOCK ---
        else {
            Student s = (Student) session.getAttribute("student");
            String eIdParam = request.getParameter("eventId");
            
            if (s != null && eIdParam != null) {
                int eventId = Integer.parseInt(eIdParam);
                
                if ("register".equals(action)) {
                    Event e = eventDAO.getEventById(eventId); 
                    
                    if (e != null && e.getAttendanceCount() >= e.getTargetGoal()) {
                        msg = "Error: This event is already full!"; // This will trigger RED
                    } else {
                        boolean success = eventDAO.registerStudent(eventId, s.getStudentId(), s.getStudentName());
                        if(success) {
                            msg = "Registration Successful!"; // GREEN
                        } else {
                            msg = "Error: You are already registered for this event."; // RED
                        }
                    }
                } 
                else if ("unregister".equals(action) || "withdraw".equals(action)) {
                    eventDAO.unregisterStudent(eventId, s.getStudentId());
                    msg = "Withdrawn from event successfully."; // GREEN
                }

                // Refresh session data for progress bars and counts
                List updatedEvents = eventDAO.getEventsByStudent(s.getStudentId());
                session.setAttribute("myEvents", updatedEvents);
                session.setAttribute("eventCount", new Integer(updatedEvents.size()));
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        msg = "Error: " + e.getMessage(); // RED
    }
    
    // REDIRECT with viewMode persistence and encoded message
    response.sendRedirect("EventController?viewMode=" + viewMode + "&success=" + URLEncoder.encode(msg, "UTF-8"));
}

    private void deleteEventWithRegistrations(int eventId) throws SQLException {
        Connection conn = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        try {
            conn = DBConnection.getConnection();
            // Step 1: Delete Registrations first (Child records)
            ps1 = conn.prepareStatement("DELETE FROM EVENT_REGISTRATION WHERE EventID = ?");
            ps1.setInt(1, eventId);
            ps1.executeUpdate();

            // Step 2: Delete Event (Parent record)
            ps2 = conn.prepareStatement("DELETE FROM EVENT WHERE EventID = ?");
            ps2.setInt(1, eventId);
            ps2.executeUpdate();
        } finally {
            if(ps1 != null) ps1.close();
            if(ps2 != null) ps2.close();
            if(conn != null) conn.close();
        }
    }

    private void handleCertificateDownload(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws IOException {
        Student student = (Student) session.getAttribute("student");
        String eventName = request.getParameter("eventName");
        String eventDate = request.getParameter("eventDate");
        if (student == null) return;
        
        response.setContentType("text/plain");
        response.setHeader("Content-Disposition", "attachment;filename=Certificate.txt");
        PrintWriter out = response.getWriter();
        out.println("****************************************************");
        out.println("       UNIVERSITY CLUB MANAGEMENT SYSTEM (UCMS)    ");
        out.println("****************************************************");
        out.println("\n                CERTIFICATE OF ATTENDANCE              ");
        out.println("\nThis is to certify that " + student.getStudentName().toUpperCase());
        out.println("Student ID: " + student.getStudentId());
        out.println("\nHas successfully participated in the event: " + eventName);
        out.println("Date: " + eventDate);
        out.println("\n****************************************************");
        out.close();
    }
}