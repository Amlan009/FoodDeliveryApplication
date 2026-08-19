package com.khaalo.servlets;

import com.khaalo.daoimpl.UserDAOImpl;
import com.khaalo.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import org.mindrot.jbcrypt.BCrypt;


@WebServlet({"/login", "/LoginServlet"})
public class LoginServlet extends HttpServlet {
    private final UserDAOImpl userDAOImpl = new UserDAOImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String redirectTarget = request.getParameter("redirectTarget");

        if (redirectTarget == null || redirectTarget.trim().isEmpty() || redirectTarget.contains("login") || redirectTarget.contains("register")) {
            String sourcePage = request.getParameter("sourcePage");
            if ("cart.jsp".equalsIgnoreCase(sourcePage) || "cart".equalsIgnoreCase(sourcePage)) {
                redirectTarget = "cart.jsp";
            } else {
                redirectTarget = "restaurants.jsp";
            }
        }

        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            String sep = redirectTarget.contains("?") ? "&" : "?";
            response.sendRedirect(redirectTarget + sep + "error=missing#signInModalOverlay");
            return;
        }

        // Retrieve user from database by email
        User user = userDAOImpl.getUserByEmail(email);

        if (user != null) {
            // Verify BCrypt password
            boolean isPasswordMatch = BCrypt.checkpw(password, user.getPasswordHash());

            if (isPasswordMatch) {
                // Create a session and store user details
                HttpSession session = request.getSession();
                session.setAttribute("user", user);

                // Redirect admin users to admin panel
                if ("Administrator".equals(user.getRole())) {
                    response.sendRedirect("admin.jsp");
                } else if ("Restaurant Owner".equals(user.getRole())) {
                    response.sendRedirect("owner.jsp");
                } else if ("Delivery Partner".equals(user.getRole())) {
                    response.sendRedirect("delivery.jsp");
                } else {
                    // Redirect to target page (e.g., cart.jsp, restaurants.jsp, or menu.jsp)
                    response.sendRedirect(redirectTarget);
                }
                return;
            } else {
                // Wrong password
                String sep = redirectTarget.contains("?") ? "&" : "?";
                response.sendRedirect(redirectTarget + sep + "error=password#signInModalOverlay");
                return;
            }
        }

        // Email does not exist
        String sep = redirectTarget.contains("?") ? "&" : "?";
        response.sendRedirect(redirectTarget + sep + "error=email#signInModalOverlay");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}

