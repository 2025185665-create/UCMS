package com.ucms2.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Get the current session
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            // 2. Clear all session data
            session.invalidate();
        }
        
        // 3. Redirect to login page with a success message
        response.sendRedirect("login.jsp?success=You have logged out successfully");
    }
}