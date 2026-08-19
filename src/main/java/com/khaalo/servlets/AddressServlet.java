package com.khaalo.servlets;

import com.khaalo.dao.AddressDAO;
import com.khaalo.daoimpl.AddressDAOImpl;
import com.khaalo.model.Address;
import com.khaalo.model.User;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet({"/AddressServlet", "/addresses"})
public class AddressServlet extends HttpServlet {
    private final AddressDAO addressDAO = new AddressDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("restaurants.jsp?loginRequired=true#signInModalOverlay");
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            List<Address> list = addressDAO.getAddressesByUserId(user.getId());
            request.setAttribute("addresses", list);
            
            RequestDispatcher rd = request.getRequestDispatcher("address.jsp");
            rd.forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error in AddressServlet doGet", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("restaurants.jsp?loginRequired=true#signInModalOverlay");
            return;
        }

        User user = (User) session.getAttribute("user");
        
        String action = request.getParameter("action");
        String idStr = request.getParameter("id");
        String addressType = request.getParameter("addressType");
        String flatNo = request.getParameter("flatNo");
        String areaDetails = request.getParameter("areaDetails");
        String landmark = request.getParameter("landmark");
        String city = request.getParameter("city");
        String pincode = request.getParameter("pincode");

        try {
            if ("delete".equalsIgnoreCase(action)) {
                if (idStr != null) {
                    int id = Integer.parseInt(idStr);
                    addressDAO.deleteAddress(id, user.getId());
                }
            } else {
                // Add or update address
                if (addressType != null && flatNo != null && areaDetails != null && city != null && pincode != null) {
                    Address address = new Address(
                        idStr != null && !idStr.trim().isEmpty() ? Integer.parseInt(idStr) : 0,
                        user.getId(),
                        addressType,
                        flatNo,
                        areaDetails,
                        landmark,
                        city,
                        pincode
                    );

                    if (address.getId() > 0) {
                        addressDAO.updateAddress(address);
                    } else {
                        addressDAO.addAddress(address);
                    }
                }
            }
            
            response.sendRedirect("user-details.jsp"); // Redirect to profile page showing saved addresses
            
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error saving address in AddressServlet doPost", e);
        }
    }
}

