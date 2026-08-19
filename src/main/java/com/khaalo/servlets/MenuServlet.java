package com.khaalo.servlets;

import com.khaalo.dao.*;
import com.khaalo.daoimpl.*;
import com.khaalo.model.*;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet({"/menu", "/MenuServlet"})
public class MenuServlet extends HttpServlet {
    private final RestaurantDAO restaurantDAO = new RestaurantDAOImpl();
    private final MenuDAO menuDAO = new MenuDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String restaurantIdStr = request.getParameter("restaurantId");
        if (restaurantIdStr == null || restaurantIdStr.trim().isEmpty()) {
            restaurantIdStr = request.getParameter("id"); // fallback
        }

        if (restaurantIdStr == null || restaurantIdStr.trim().isEmpty()) {
            response.sendRedirect("restaurants.jsp");
            return;
        }

        Restaurant restaurant = restaurantDAO.getRestaurantById(restaurantIdStr);
        if (restaurant != null) {
            // Fetch categories and their child dishes for this restaurant
            List<MenuCategory> categories = menuDAO.getMenuByRestaurantId(restaurantIdStr);
            
            // Teacher's exact logic: get flat list of dishes (allMenusByRestaurant) and print
            List<Dish> allMenusByRestaurant = menuDAO.getAllMenusByRestaurant(restaurantIdStr);

            // Set request attributes to pass to menu.jsp
            request.setAttribute("restaurant", restaurant);
            request.setAttribute("categories", categories);
            request.setAttribute("allMenusByRestaurant", allMenusByRestaurant);

            // Forward request and response to menu.jsp
            RequestDispatcher rd = request.getRequestDispatcher("menu.jsp");
            rd.forward(request, response);
        } else {
            response.sendRedirect("restaurants.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}

