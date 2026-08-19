package com.khaalo.dao;

import com.khaalo.model.Order;
import java.util.List;

public interface OrderDAO {
    void placeOrder(Order order);
    List<Order> getOrdersByUserId(int userId);
    Order getOrderById(int orderId);
    void updateOrderStatus(int orderId, String status);
    void deleteOrder(int orderId);
    List<Order> getAllOrders();
}
