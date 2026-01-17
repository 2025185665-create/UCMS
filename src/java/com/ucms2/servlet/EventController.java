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
        String action = request.getParameter("action");
        String search = request.getParameter("search");
        String viewMode = request.getParameter("viewMode");

        if ("viewAttendance".equals(action) && "admin".equals(userRole)) {
            try {
                int eventId = Integer.parseInt(request.getParameter("eventId"));
                request.setAttribute("attendanceList", eventDAO.getAttendance(eventId));
            } catch (Exception e) {
                e.printStackTrace();
            }
        } 
        
        if (!"add".equals(action)) {
            request.setAttribute("eventList", getEventsWithSearch(search));
            request.setAttribute("isSearchActive", (search != null && !search.trim().isEmpty()));
        }
        
        // Default to grid if no viewMode is specified
        request.setAttribute("viewMode", (viewMode != null) ? viewMode : "grid");
        request.getRequestDispatcher("events.jsp").forward(request, response);
    }

    private List getEventsWithSearch(String search) {
        List list = new ArrayList();
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT * FROM EVENT";
            if (search != null && !search.trim().isEmpty()) {
                sql += " WHERE UPPER(EventName) LIKE ? OR UPPER(EventVenue) LIKE ?";
            }
            sql += " ORDER BY EventDate ASC"; // ASC is better for Calendar flow

            PreparedStatement ps = conn.prepareStatement(sql);
            if (search != null && !search.trim().isEmpty()) {
                String pattern = "%" + search.toUpperCase() + "%";
                ps.setString(1, pattern);
                ps.setString(2, pattern);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Event e = new Event();
                e.setEventId(rs.getInt("EventID"));
                e.setEventName(rs.getString("EventName"));
                e.setEventVenue(rs.getString("EventVenue"));
                e.setEventDate(rs.getDate("EventDate"));
                e.setTargetGoal(rs.getInt("TargetGoal"));
                e.setAttendanceCount(getRegCount(rs.getInt("EventID")));
                list.add(e);
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { if(conn != null) try { conn.close(); } catch(Exception e) {} }
        return list;
    }

    private int getRegCount(int eventId) {
        int count = 0;
        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM EVENT_REGISTRATION WHERE EventID = ?");
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            if(rs.next()) count = rs.getInt(1);
        } catch (Exception e) {}
        return count;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String userRole = (String) session.getAttribute("userRole");
        String action = request.getParameter("action");
        String msg = "Action Successful";

        try {
            if ("downloadCertificate".equals(action)) {
                handleCertificateDownload(request, response, session);
                return; 
            }

            if ("create".equals(action) && "admin".equals(userRole)) {
                int targetGoal = Integer.parseInt(request.getParameter("targetGoal"));
                boolean success = eventDAO.createEvent(
                    request.getParameter("eventName"), 
                    request.getParameter("eventVenue"), 
                    request.getParameter("eventDate"),
                    targetGoal
                );
                if(!success) msg = "Failed to create event";
            } 
            else if ("delete".equals(action) && "admin".equals(userRole)) {
                int eventId = Integer.parseInt(request.getParameter("eventId"));
                if (getRegCount(eventId) > 0) {
                    msg = "Error: Cannot delete event with registrations.";
                } else {
                    deleteEventWithRegistrations(eventId);
                    msg = "Event successfully deleted.";
                }
            }
            else {
                Student s = (Student) session.getAttribute("student");
                String eIdParam = request.getParameter("eventId");
                if (s != null && eIdParam != null) {
                    int eventId = Integer.parseInt(eIdParam);
                    if ("register".equals(action)) {
                        Event e = eventDAO.getEventById(eventId);
                        if (e != null && getRegCount(eventId) >= e.getTargetGoal()) {
                            msg = "Error: Event is already full!";
                        } else {
                            eventDAO.registerStudent(eventId, s.getStudentId(), s.getStudentName());
                        }
                    } else if ("unregister".equals(action) || "withdraw".equals(action)) {
                        eventDAO.unregisterStudent(eventId, s.getStudentId());
                        msg = "Withdrawn from event";
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            msg = "Error: " + e.getMessage();
        }
        response.sendRedirect("EventController?success=" + java.net.URLEncoder.encode(msg, "UTF-8"));
    }

    private void deleteEventWithRegistrations(int eventId) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps1 = conn.prepareStatement("DELETE FROM EVENT_REGISTRATION WHERE EventID = ?");
            ps1.setInt(1, eventId);
            ps1.executeUpdate();
            PreparedStatement ps2 = conn.prepareStatement("DELETE FROM EVENT WHERE EventID = ?");
            ps2.setInt(1, eventId);
            ps2.executeUpdate();
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
        out.println("       UNIVERSITY CLUB MANAGEMENT SOCIETY (UCMS)    ");
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