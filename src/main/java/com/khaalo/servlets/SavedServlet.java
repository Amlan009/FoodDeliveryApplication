package com.khaalo.servlets;

import com.khaalo.dao.FavoriteDAO;
import com.khaalo.daoimpl.FavoriteDAOImpl;
import com.khaalo.model.Restaurant;
import com.khaalo.model.User;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet({"/saved", "/SavedServlet"})
public class SavedServlet extends HttpServlet {
    private final FavoriteDAO favoriteDAO = new FavoriteDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        String action = request.getParameter("action");

        if (action != null && action.equalsIgnoreCase("toggle")) {
            String restaurantId = request.getParameter("restaurantId");
            if (restaurantId == null || restaurantId.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing restaurantId");
                return;
            }

            boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"));

            if (user == null) {
                if (isAjax) {
                    response.setContentType("application/json");
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    PrintWriter out = response.getWriter();
                    out.print("{\"status\":\"unauthorized\"}");
                    out.flush();
                } else {
                    response.sendRedirect("restaurants?loginRequired=true#signInModalOverlay");
                }
                return;
            }

            int userId = user.getId();
            synchronized (this) {
                if (favoriteDAO.isFavorite(userId, restaurantId)) {
                    favoriteDAO.removeFavorite(userId, restaurantId);
                } else {
                    favoriteDAO.addFavorite(userId, restaurantId);
                }
            }

            if (isAjax) {
                response.setContentType("application/json");
                PrintWriter out = response.getWriter();
                out.print("{\"status\":\"success\"}");
                out.flush();
            } else {
                response.sendRedirect("saved.jsp");
            }
            return;
        }

        // View Saved list
        if (user == null) {
            response.sendRedirect("restaurants?loginRequired=true#signInModalOverlay");
            return;
        }

        List<Restaurant> savedRestaurants = favoriteDAO.getFavoriteRestaurants(user.getId());
        request.setAttribute("savedRestaurants", savedRestaurants);

        RequestDispatcher rd = request.getRequestDispatcher("saved.jsp");
        rd.forward(request, response);
    }
}
