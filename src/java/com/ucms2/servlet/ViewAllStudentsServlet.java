package com.ucms2.servlet;

import com.ucms2.db.StudentDAO;
import com.ucms2.model.Admin;
import com.ucms2.model.Student;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/view-all-students")
public class ViewAllStudentsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Admin admin = (Admin) session.getAttribute("admin");
        
        if (admin == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        StudentDAO dao = new StudentDAO();
        List<Student> students = dao.getAllStudents();
        
        request.setAttribute("studentList", students);
        request.getRequestDispatcher("view-students.jsp").forward(request, response);
    }
}