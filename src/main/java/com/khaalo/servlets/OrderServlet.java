package com.khaalo.servlets;

import com.khaalo.dao.OrderDAO;
import com.khaalo.daoimpl.OrderDAOImpl;
import com.khaalo.dao.CartDAO;
import com.khaalo.daoimpl.CartDAOImpl;
import com.khaalo.model.Order;
import com.khaalo.model.OrderItem;
import com.khaalo.model.Cart;
import com.khaalo.model.CartItem;
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
import java.util.ArrayList;
import java.util.List;

@WebServlet({"/OrderServlet", "/orders"})
public class OrderServlet extends HttpServlet {
    private final OrderDAO orderDAO = new OrderDAOImpl();
    private final CartDAO cartDAO = new CartDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("restaurants.jsp?loginRequired=true#signInModalOverlay");
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            List<Order> orders = orderDAO.getOrdersByUserId(user.getId());
            request.setAttribute("orders", orders);
            
            RequestDispatcher rd = request.getRequestDispatcher("saved.jsp");
            rd.forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Database error in OrderServlet doGet", e);
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

        String restaurantId = request.getParameter("restaurantId");
        String addressIdStr = request.getParameter("addressId");
        String subtotalStr = request.getParameter("subtotal");
        String deliveryFeeStr = request.getParameter("deliveryFee");
        String taxesStr = request.getParameter("taxes");
        String grandTotalStr = request.getParameter("grandTotal");
        String paymentMethod = request.getParameter("paymentMethod");

        if (restaurantId == null || addressIdStr == null || grandTotalStr == null) {
            request.setAttribute("orderError", "Required fields are missing.");
            RequestDispatcher rd = request.getRequestDispatcher("cart");
            rd.forward(request, response);
            return;
        }

        try {
            int addressId = Integer.parseInt(addressIdStr);
            double subtotal = Double.parseDouble(subtotalStr != null ? subtotalStr : "0.0");
            double deliveryFee = Double.parseDouble(deliveryFeeStr != null ? deliveryFeeStr : "0.0");
            double taxes = Double.parseDouble(taxesStr != null ? taxesStr : "0.0");
            double grandTotal = Double.parseDouble(grandTotalStr);

            // Fetch current items in the session cart to populate order items
            Cart cart = (Cart) session.getAttribute("cart");
            if (cart == null || cart.getItems() == null || cart.getItems().isEmpty()) {
                response.sendRedirect("CartServlet?error=empty");
                return;
            }

            // Save cart to the database cart tables right before order placement
            cartDAO.saveCart(cart);

            List<OrderItem> orderItems = new ArrayList<>();
            for (CartItem ci : cart.getItems()) {
                // Price at purchase defaults to the current price of the dish
                orderItems.add(new OrderItem(
                    0, 0, ci.getDishId(), ci.getQuantity(), ci.getDishPrice(), ci.getCustomizations()
                ));
            }

            Order order = new Order(
                0, user.getId(), restaurantId, addressId, subtotal, deliveryFee, taxes, grandTotal, "Pending", paymentMethod, null
            );
            order.setOrderItems(orderItems);

            orderDAO.placeOrder(order);

            // Clear database cart upon successful checkout
            cartDAO.clearCart(user.getId());
            // Clear session cart upon successful checkout
            session.removeAttribute("cart");

            response.sendRedirect("order-success.jsp?orderId=" + order.getId());
            
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error processing checkout in OrderServlet", e);
        }
    }
}

