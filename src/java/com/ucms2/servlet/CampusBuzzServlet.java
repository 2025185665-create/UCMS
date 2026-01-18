package com.ucms2.servlet;

import com.ucms2.db.CampusBuzzDAO;
import com.ucms2.model.Student;
import java.io.IOException;
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

        try {

            // ================= ADMIN =================
            if ("admin".equals(userRole)) {

                if ("approve".equals(action) || "reject".equals(action)) {
                    int buzzId = Integer.parseInt(request.getParameter("buzzId"));
                    String status = "approve".equals(action) ? "approved" : "rejected";
                    buzzDAO.updateStatus(buzzId, status);
                }

            // ================= STUDENT =================
            } else if ("student".equals(userRole)) {

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

                    if (success) {
                        response.sendRedirect("CampusBuzzController?success=true");
                        return;
                    }
                }

                if ("claim".equals(action)) {
                    int buzzId = Integer.parseInt(request.getParameter("buzzId"));
                    buzzDAO.markAsClaimed(buzzId);
                }
            }

            response.sendRedirect("campus-buzz.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("CampusBuzzController?error=true");
        }
    }
}
