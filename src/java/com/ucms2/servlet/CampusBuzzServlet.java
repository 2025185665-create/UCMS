package com.ucms2.servlet;

import com.ucms2.db.CampusBuzzDAO;
import com.ucms2.db.DBConnection;
import com.ucms2.model.Student;
import java.io.IOException;
import java.sql.*;
import java.util.*;
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
        String message = "Action Processed";
        boolean createdAction = false;

        try {
            // 1. Admin: Clear Claimed Items
            if ("clearClaimed".equals(action) && "admin".equals(userRole)) {
                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();
                    PreparedStatement ps = conn.prepareStatement("DELETE FROM CAMPUS_BUZZ WHERE Status = 'claimed'");
                    ps.executeUpdate();
                    response.sendRedirect("CampusBuzzController?success=Claimed items cleared");
                    return;
                } finally { if(conn != null) conn.close(); }
            }
            // 2. Admin: Approve or Reject Posts
            else if (("approve".equals(action) || "reject".equals(action)) && "admin".equals(userRole)) {
                int bId = Integer.parseInt(request.getParameter("buzzId"));
                String newStatus = "approve".equals(action) ? "approved" : "rejected";
                buzzDAO.updateStatus(bId, newStatus);
                message = "Post " + newStatus;
            }
            // 3. Student: Create Post
            else if ("create".equals(action) && "student".equals(userRole)) {
                Student student = (Student) session.getAttribute("student");
                boolean isSuccess = buzzDAO.createPost(
                    student.getStudentId(), 
                    student.getStudentName(), 
                    request.getParameter("content"), 
                    request.getParameter("category"),
                    request.getParameter("venue"),
                    request.getParameter("eventDate")
                );
                
                if(isSuccess) {
                    // This matches your JSP's expectation for the popup
                    response.sendRedirect("CampusBuzzController?success=true");
                    return;
                }
            }
            // 4. Student: Claim Belonging
            else if ("claim".equals(action)) {
                int buzzId = Integer.parseInt(request.getParameter("buzzId"));
                buzzDAO.markAsClaimed(buzzId);
                message = "Item successfully marked as claimed";
            }
            
            response.sendRedirect("CampusBuzzController?success=" + java.net.URLEncoder.encode(message, "UTF-8"));
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("CampusBuzzController?error=Process failed");
        }
    }
}