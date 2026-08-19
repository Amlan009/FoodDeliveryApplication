package com.khaalo.servlets;

import com.khaalo.model.User;
import com.util.connection.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/delete-account")
public class DeleteAccountServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("restaurants");
            return;
        }

        User user = (User) session.getAttribute("user");
        int userId = user.getId();

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            // Delete cart_items if any
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM `cart_items` WHERE `cart_id` IN (SELECT `id` FROM `carts` WHERE `user_id` = ?)")) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            } catch (SQLException e) {
                // Table might not exist, proceed
            }

            // Delete order_items if any
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM `order_items` WHERE `order_id` IN (SELECT `id` FROM `orders` WHERE `user_id` = ?)")) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            } catch (SQLException e) {
                // Table might not exist, proceed
            }

            // Delete orders
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM `orders` WHERE `user_id` = ?")) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }

            // Delete user (cascades to user_favorites, addresses, carts, reviews)
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM `users` WHERE `id` = ?")) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }

            conn.commit();
            session.invalidate();

            // Redirect back to restaurants page with the sign up modal open
            response.sendRedirect("restaurants#signUpModalOverlay");

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("user-details.jsp?error=delete_failed");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}
