package com.ucms2.servlet;

import com.ucms2.db.CampusBuzzDAO;
import com.ucms2.db.DBConnection;
import com.ucms2.model.Student;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/CampusBuzzController")
public class CampusBuzzServlet extends HttpServlet {

    private CampusBuzzDAO buzzDAO = new CampusBuzzDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String userRole = (String) session.getAttribute("userRole");

        if ("admin".equals(userRole)) {
            request.setAttribute("pendingBuzz", buzzDAO.getBuzzByStatus("pending"));
        }
        request.setAttribute("approvedBuzz", buzzDAO.getBuzzByStatus("approved"));
        
        request.getRequestDispatcher("campus-buzz.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String userRole = (String) session.getAttribute("userRole");
        String action = request.getParameter("action");
        boolean isSuccess = false;

        // --- NEW ACTION: CLEAR CLAIMED ITEMS ---
        if ("clearClaimed".equals(action) && "admin".equals(userRole)) {
            Connection conn = null;
            PreparedStatement ps = null;
            try {
                conn = DBConnection.getConnection();
                // Clear all lost and found items that have been claimed
                ps = conn.prepareStatement("DELETE FROM CAMPUS_BUZZ WHERE Status = 'claimed'");
                ps.executeUpdate();
                response.sendRedirect("campus-buzz.jsp?success=Claimed items cleared");
                return; // Prevents further execution and double-redirects
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("campus-buzz.jsp?error=Clear failed");
                return;
            } finally {
                try { if(ps != null) ps.close(); if(conn != null) conn.close(); } catch(SQLException ex) {}
            }
        }

        try {
            if ("claim".equals(action)) {
                int postId = Integer.parseInt(request.getParameter("postId"));
                isSuccess = buzzDAO.markAsClaimed(postId);
            } 
            else if ("admin".equals(userRole)) {
                int postId = Integer.parseInt(request.getParameter("postId"));
                String newStatus = "approve".equals(action) ? "approved" : "rejected";
                isSuccess = buzzDAO.updateStatus(postId, newStatus);
            } 
            else if ("student".equals(userRole)) {
                Student student = (Student) session.getAttribute("student");
                isSuccess = buzzDAO.createPost(
                    student.getStudentId(), 
                    student.getStudentName(), 
                    request.getParameter("content"), 
                    request.getParameter("category"),
                    request.getParameter("venue"),
                    request.getParameter("eventDate")
                );
            }
            
            response.sendRedirect("campus-buzz.jsp?success=" + (isSuccess ? "Action processed" : "Failed"));
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("campus-buzz.jsp?error=Action failed");
        }
    }
}