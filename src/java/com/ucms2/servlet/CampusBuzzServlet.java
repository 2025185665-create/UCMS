package com.ucms2.servlet;

import com.ucms2.db.CampusBuzzDAO;
import com.ucms2.model.Student;
import java.net.URLEncoder;
import com.ucms2.db.DBConnection;
import java.io.IOException;
import javax.servlet.ServletException;
import java.sql.Connection;
import java.sql.PreparedStatement;
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
        Student student = (Student) session.getAttribute("student");

        // Admin moderation queue
        if ("admin".equals(userRole)) {
            request.setAttribute("pendingBuzz", buzzDAO.getBuzzByStatus("pending"));
        }

        // Public feed
        request.setAttribute("approvedBuzz", buzzDAO.getBuzzByStatus("approved"));

        // Student: my submissions
        if ("student".equals(userRole) && student != null) {
            request.setAttribute(
                "myBuzz",
                buzzDAO.getBuzzByStudent(student.getStudentId())
            );
        }

        request.getRequestDispatcher("campus-buzz.jsp").forward(request, response);
    }

 @Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    HttpSession session = request.getSession();
    String userRole = (String) session.getAttribute("userRole");
    String action = request.getParameter("action");
    String msg = ""; // Store the custom message here

    try {
        if ("admin".equals(userRole)) {
            if ("approve".equals(action) || "reject".equals(action)) {
                int buzzId = Integer.parseInt(request.getParameter("buzzId"));
                String status = "approve".equals(action) ? "approved" : "rejected";
                buzzDAO.updateStatus(buzzId, status);
                msg = "Post has been " + status + " successfully.";
            }
            else if ("delete".equals(action)) {
                int buzzId = Integer.parseInt(request.getParameter("buzzId"));
                Connection conn = null;
                PreparedStatement ps = null;
                try {
                    conn = DBConnection.getConnection();
                    ps = conn.prepareStatement("DELETE FROM CAMPUS_BUZZ WHERE PostID = ?");
                    ps.setInt(1, buzzId);
                    int rows = ps.executeUpdate();
                    // Custom message for Admin Delete
                    msg = (rows > 0) ? "Post successfully deleted from campus feed." : "Error: Post could not be found.";
                } finally {
                    if(ps != null) ps.close();
                    if(conn != null) conn.close();
                }
            }
        } 
        else if ("student".equals(userRole)) {
            if ("create".equals(action)) {
                Student student = (Student) session.getAttribute("student");
                boolean success = buzzDAO.createPost(
                    student.getStudentId(),
                    student.getStudentName(),
                    request.getParameter("content"),
                    request.getParameter("category"),
                    request.getParameter("venue"),
                    request.getParameter("eventDate")
                );
                msg = success ? "Your post has been submitted for approval." : "Error: Submission failed.";
            }
            else if ("claim".equals(action)) {
                int buzzId = Integer.parseInt(request.getParameter("buzzId"));
                buzzDAO.markAsClaimed(buzzId);
                msg = "Item marked as claimed!";
            }
        }

        // Redirect back to controller with the encoded message
        response.sendRedirect("CampusBuzzController?success=true&msg=" + URLEncoder.encode(msg, "UTF-8"));

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("CampusBuzzController?error=true&msg=" + URLEncoder.encode("An internal error occurred.", "UTF-8"));
    }
}
}