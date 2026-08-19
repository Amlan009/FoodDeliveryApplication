package com.khaalo.servlets;

import com.khaalo.daoimpl.MenuDAOImpl;
import com.khaalo.model.Cart;
import com.khaalo.model.CartItem;
import com.khaalo.model.Dish;
import com.khaalo.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;

@WebServlet({"/cart", "/CartServlet"})
public class CartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(true);
        User user = (User) session.getAttribute("user");
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null) {
            if (user != null) {
                try {
                    cart = new com.khaalo.daoimpl.CartDAOImpl().getCartByUserId(user.getId());
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            if (cart == null) {
                cart = new Cart();
                cart.setUserId(user != null ? user.getId() : 0);
                cart.setItems(new ArrayList<>());
            }
            session.setAttribute("cart", cart);
        }

        response.sendRedirect("cart.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(true);
        User user = (User) session.getAttribute("user");
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null) {
            if (user != null) {
                try {
                    cart = new com.khaalo.daoimpl.CartDAOImpl().getCartByUserId(user.getId());
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            if (cart == null) {
                cart = new Cart();
                cart.setUserId(user != null ? user.getId() : 0);
                cart.setItems(new ArrayList<>());
            }
            session.setAttribute("cart", cart);
        }

        String action = request.getParameter("action");
        String dishIdStr = request.getParameter("dishId");
        String restaurantIdStr = request.getParameter("restaurantId");
        String quantityStr = request.getParameter("quantity");
        String cust = request.getParameter("customizations");
        String sourcePage = request.getParameter("sourcePage");

        boolean isAjax = "true".equalsIgnoreCase(request.getParameter("isAjax")) 
                || "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || (request.getHeader("Accept") != null && request.getHeader("Accept").contains("application/json"));

        // Logic for handling restaurant changes
        if (restaurantIdStr != null && !restaurantIdStr.trim().isEmpty()) {
            String sessionResId = (String) session.getAttribute("restaurantId");
            
            // Fallback: If sessionResId is null but cart has items, resolve restaurantId of existing cart items
            if ((sessionResId == null || sessionResId.trim().isEmpty()) && !cart.getItems().isEmpty()) {
                try {
                    int firstDishId = cart.getItems().get(0).getDishId();
                    Dish firstDish = new com.khaalo.daoimpl.MenuDAOImpl().getDishById(firstDishId);
                    if (firstDish != null) {
                        try (Connection conn = com.util.connection.DBConnection.getConnection();
                             PreparedStatement ps = conn.prepareStatement("SELECT `restaurant_id` FROM `menu_categories` WHERE `id` = ?")) {
                            ps.setInt(1, firstDish.getCategoryId());
                            try (ResultSet rs = ps.executeQuery()) {
                                if (rs.next()) {
                                    sessionResId = rs.getString("restaurant_id");
                                    session.setAttribute("restaurantId", sessionResId);
                                }
                            }
                        }
                    }
                } catch (Exception ignored) {}
            }

            if (sessionResId != null && !sessionResId.trim().isEmpty() && !sessionResId.equals(restaurantIdStr) && !cart.getItems().isEmpty()) {
                // Conflict detected! Check if they confirmed the replacement
                String confirmReplace = request.getParameter("confirmReplace");
                if (!"true".equalsIgnoreCase(confirmReplace)) {
                    if (isAjax) {
                        Dish newDish = null;
                        try {
                            newDish = new com.khaalo.daoimpl.MenuDAOImpl().getDishById(Integer.parseInt(dishIdStr));
                        } catch (Exception ignored){}
                        String dName = (newDish != null) ? newDish.getName() : "Selected Dish";

                        String existingDishName = "Item in Cart";
                        if (cart != null && !cart.getItems().isEmpty()) {
                            com.khaalo.model.CartItem firstItem = cart.getItems().get(0);
                            if (firstItem.getDishName() != null && !firstItem.getDishName().trim().isEmpty()) {
                                existingDishName = firstItem.getDishName();
                            } else {
                                try {
                                    Dish oldDish = new com.khaalo.daoimpl.MenuDAOImpl().getDishById(firstItem.getDishId());
                                    if (oldDish != null) existingDishName = oldDish.getName();
                                } catch (Exception ignored) {}
                            }
                            if (cart.getItems().size() > 1) {
                                existingDishName += " (+" + (cart.getItems().size() - 1) + " more)";
                            }
                        }

                        response.setContentType("application/json");
                        response.getWriter().print("{\"status\":\"conflict\", \"newDishId\":\"" + dishIdStr + "\", \"newRestaurantId\":\"" + restaurantIdStr + "\", \"dishName\":\"" + dName.replace("\"", "\\\"") + "\", \"existingDishName\":\"" + existingDishName.replace("\"", "\\\"") + "\"}");
                        return;
                    }
                    if ("restaurants.jsp".equalsIgnoreCase(sourcePage)) {
                        response.sendRedirect("restaurants.jsp?cartConflict=true&newDishId=" + dishIdStr 
                                + "&newRestaurantId=" + restaurantIdStr 
                                + "#cartConflictModalOverlay");
                    } else {
                        // Redirect to menu page with conflict modal overlay trigger
                        response.sendRedirect("menu?restaurantId=" + restaurantIdStr 
                                + "&cartConflict=true&newDishId=" + dishIdStr 
                                + "&newRestaurantId=" + restaurantIdStr 
                                + "#cartConflictModalOverlay");
                    }
                    return;
                } else {
                    // Confirmed -> clear cart and update restaurant ID
                    cart.getItems().clear();
                    session.setAttribute("restaurantId", restaurantIdStr);
                }
            } else {
                // First item or same restaurant -> update/set restaurant ID
                session.setAttribute("restaurantId", restaurantIdStr);
            }
        }

        if ("add".equalsIgnoreCase(action) && dishIdStr != null) {
            int dishId = Integer.parseInt(dishIdStr);
            int quantity = quantityStr != null ? Integer.parseInt(quantityStr) : 1;

            boolean found = false;
            CartItem toRemove = null;
            for (CartItem item : cart.getItems()) {
                if (item.getDishId() == dishId) {
                    int newQty = item.getQuantity() + quantity;
                    if (newQty <= 0) {
                        toRemove = item;
                    } else {
                        item.setQuantity(newQty);
                    }
                    found = true;
                    break;
                }
            }

            if (toRemove != null) {
                cart.getItems().remove(toRemove);
            } else if (!found && quantity > 0) {
                try {
                    Dish dish = new MenuDAOImpl().getDishById(dishId);
                    if (dish != null) {
                        CartItem newItem = new CartItem(0, 0, dishId, quantity, cust);
                        newItem.setDishName(dish.getName());
                        newItem.setDishPrice(dish.getPrice());
                        cart.getItems().add(newItem);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        } else if ("update".equalsIgnoreCase(action) && dishIdStr != null) {
            int dishId = Integer.parseInt(dishIdStr);
            for (CartItem item : cart.getItems()) {
                if (item.getDishId() == dishId) {
                    if (quantityStr != null) {
                        item.setQuantity(Integer.parseInt(quantityStr));
                    }
                    if (cust != null) {
                        if (cust.length() > 30) {
                            cust = cust.substring(0, 30);
                        }
                        item.setCustomizations(cust);
                    }
                    break;
                }
            }
        } else if ("delete".equalsIgnoreCase(action) && dishIdStr != null) {
            int dishId = Integer.parseInt(dishIdStr);
            cart.getItems().removeIf(item -> item.getDishId() == dishId);
        } else if ("clear".equalsIgnoreCase(action)) {
            cart.getItems().clear();
        }

        session.setAttribute("cart", cart);

        if (user != null) {
            cart.setUserId(user.getId());
            try {
                new com.khaalo.daoimpl.CartDAOImpl().saveCart(cart);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        if (isAjax) {
            int totalQty = 0;
            if (cart != null && cart.getItems() != null) {
                for (CartItem ci : cart.getItems()) {
                    totalQty += ci.getQuantity();
                }
            }
            response.setContentType("application/json");
            response.getWriter().print("{\"status\":\"success\", \"totalItems\":" + totalQty + "}");
            return;
        }

        if ("restaurants.jsp".equalsIgnoreCase(sourcePage)) {
            response.sendRedirect("restaurants.jsp#recommendedSection");
        } else if (restaurantIdStr != null && !restaurantIdStr.trim().isEmpty()) {
            response.sendRedirect("menu?restaurantId=" + restaurantIdStr);
        } else {
            response.sendRedirect("CartServlet");
        }
    }
}
