package com.khaalo.servlets;

import com.khaalo.daoimpl.UserDAOImpl;
import com.khaalo.model.User;
import org.mindrot.jbcrypt.BCrypt;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Timestamp;

@WebServlet({"/register", "/RegisterServlet"})
public class RegisterServlet extends HttpServlet {
    private final UserDAOImpl userDAOImpl = new UserDAOImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String role = request.getParameter("role");
        String password = request.getParameter("password");
        String redirectTarget = request.getParameter("redirectTarget");

        if (redirectTarget == null || redirectTarget.trim().isEmpty() || redirectTarget.contains("register") || redirectTarget.contains("login")) {
            String sourcePage = request.getParameter("sourcePage");
            if ("cart.jsp".equalsIgnoreCase(sourcePage) || "cart".equalsIgnoreCase(sourcePage)) {
                redirectTarget = "cart.jsp";
            } else {
                redirectTarget = "restaurants.jsp";
            }
        }

        if (fullName == null || email == null || password == null || fullName.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty()) {
            String sep = redirectTarget.contains("?") ? "&" : "?";
            response.sendRedirect(redirectTarget + sep + "error=signup#signUpModalOverlay");
            return;
        }

        // Check if user is trying to register as admin
        boolean isAdminRole = (role != null && role.toLowerCase().contains("admin"));

        // If registering as admin, check if email already exists with a different role
        if (isAdminRole) {
            User existingUser = userDAOImpl.getUserByEmail(email);
            if (existingUser != null) {
                // Email already registered — block admin registration
                String sep = redirectTarget.contains("?") ? "&" : "?";
                response.sendRedirect(redirectTarget + sep + "error=admin_blocked#signUpModalOverlay");
                return;
            }
        } else {
            // For non-admin roles, check if email already exists
            User existingUser = userDAOImpl.getUserByEmail(email);
            if (existingUser != null) {
                String sep = redirectTarget.contains("?") ? "&" : "?";
                response.sendRedirect(redirectTarget + sep + "error=signup#signUpModalOverlay");
                return;
            }
        }

        // Hash password using BCrypt
        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12));

        User user = new User();
        user.setFullName(fullName);
        user.setEmail(email);
        user.setPhone(phone);
        user.setRole(role != null ? role : "customer");
        user.setPasswordHash(hashedPassword);
        user.setCreatedAt(new Timestamp(System.currentTimeMillis()));

        // Save user via UserDAO
        userDAOImpl.addUser(user);

        // Verification check: retrieve to check if successfully inserted
        User registeredUser = userDAOImpl.getUserByEmail(email);
        if (registeredUser != null) {
            // Success -> Auto-login user and redirect
            request.getSession().setAttribute("user", registeredUser);
            // Redirect admin to admin panel, owner to owner panel, others to target page
            if ("Administrator".equals(registeredUser.getRole())) {
                response.sendRedirect("admin.jsp");
            } else if ("Restaurant Owner".equals(registeredUser.getRole())) {
                response.sendRedirect("owner.jsp");
            } else if ("Delivery Partner".equals(registeredUser.getRole())) {
                response.sendRedirect("delivery.jsp");
            } else {
                response.sendRedirect(redirectTarget);
            }
        } else {
            // Failure -> redirect back to signup modal on target page
            String sep = redirectTarget.contains("?") ? "&" : "?";
            response.sendRedirect(redirectTarget + sep + "error=signup#signUpModalOverlay");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}

