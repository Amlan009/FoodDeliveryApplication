package com.khaalo.servlets;

import com.khaalo.dao.RestaurantDAO;
import com.khaalo.daoimpl.RestaurantDAOImpl;
import com.khaalo.model.Restaurant;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet({"/restaurants", "/RestaurantServlet"})
public class RestaurantServlet extends HttpServlet {
    private final RestaurantDAO restaurantDAO = new RestaurantDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Restaurant> restaurantList = restaurantDAO.getAllRestaurants();
        request.setAttribute("restaurantList", restaurantList);
        
        RequestDispatcher rd = request.getRequestDispatcher("restaurants.jsp");
        rd.forward(request, response);
    }
}

