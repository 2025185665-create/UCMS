package com.ucms2.servlet;

import com.ucms2.db.EventDAO;
import com.ucms2.model.Student;
import com.ucms2.model.Event;
import java.io.*;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/EventController")
public class EventRegistrationServlet extends HttpServlet { 

    private EventDAO eventDAO = new EventDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String userRole = (String) session.getAttribute("userRole");
        String action = request.getParameter("action");

        // Logic for Admin to see who is attending
        if ("viewAttendance".equals(action) && "admin".equals(userRole)) {
            try {
                int eventId = Integer.parseInt(request.getParameter("eventId"));
                List attendance = eventDAO.getAttendance(eventId); // Ensure this returns Student objects
                request.setAttribute("attendanceList", attendance);
            } catch (Exception e) {
                e.printStackTrace();
            }
        } 
        
        // Always reload the main event list if not in 'add' mode
        if (!"add".equals(action)) {
            request.setAttribute("eventList", eventDAO.getAllEvents());
        }
        
        request.getRequestDispatcher("events.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String userRole = (String) session.getAttribute("userRole");
        String action = request.getParameter("action");

        if ("downloadCertificate".equals(action)) {
            handleCertificateDownload(request, response, session);
            return; 
        }

        String msg = "Action Successful";

        if ("create".equals(action) && "admin".equals(userRole)) {
            int targetGoal = Integer.parseInt(request.getParameter("targetGoal"));
            boolean success = eventDAO.createEvent(
                request.getParameter("eventName"), 
                request.getParameter("eventVenue"), 
                request.getParameter("eventDate"),
                targetGoal
            );
            if(!success) msg = "Failed to create event";
        } else {
            Student s = (Student) session.getAttribute("student");
            String eIdParam = request.getParameter("eventId");
            
            if (s != null && eIdParam != null) {
                int eventId = Integer.parseInt(eIdParam);
                if ("register".equals(action)) {
                    Event e = eventDAO.getEventById(eventId);
                    if (e != null && e.getAttendanceCount() >= e.getTargetGoal()) {
                        msg = "Event is already full!";
                    } else {
                        boolean success = eventDAO.registerStudent(eventId, s.getStudentId(), s.getStudentName());
                        if(!success) msg = "Registration failed";
                    }
                } else if ("unregister".equals(action)) {
                    eventDAO.unregisterStudent(eventId, s.getStudentId());
                }
            }
        }
        
        response.sendRedirect("EventController?success=" + java.net.URLEncoder.encode(msg, "UTF-8"));
    }

    private void handleCertificateDownload(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws IOException {
        Student student = (Student) session.getAttribute("student");
        String eventName = request.getParameter("eventName");
        String eventDate = request.getParameter("eventDate");

        if (student == null) return;

        String serial = "UCMS-" + System.currentTimeMillis() % 100000;
        response.setContentType("text/plain");
        response.setHeader("Content-Disposition", "attachment;filename=Certificate.txt");

        PrintWriter out = response.getWriter();
        out.println("****************************************************");
        out.println("       UNIVERSITY CLUB MANAGEMENT SOCIETY (UCMS)    ");
        out.println("****************************************************");
        out.println("\n               CERTIFICATE OF ATTENDANCE              ");
        out.println("\nThis is to certify that " + student.getStudentName().toUpperCase());
        out.println("Student ID: " + student.getStudentId());
        out.println("\nHas successfully participated in the event:");
        out.println("TITLE: " + eventName);
        out.println("DATE : " + eventDate);
        out.println("\nSerial No: " + serial);
        out.println("Verification: UCMS Official System Generated");
        out.println("\n****************************************************");
        out.close();
    }
}