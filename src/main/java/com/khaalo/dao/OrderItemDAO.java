package com.khaalo.dao;

import com.khaalo.model.OrderItem;
import java.util.List;

public interface OrderItemDAO {
    void addOrderItem(OrderItem item);
    OrderItem getOrderItemById(int itemId);
    List<OrderItem> getOrderItemsByOrderId(int orderId);
    void updateOrderItem(OrderItem item);
    void deleteOrderItem(int itemId);
}
