package com.khaalo.dao;

import com.khaalo.model.CartItem;
import java.util.List;

public interface CartItemDAO {
    void addCartItem(CartItem item);
    CartItem getCartItemById(int itemId);
    List<CartItem> getCartItemsByCartId(int cartId);
    void updateCartItem(CartItem item);
    void deleteCartItem(int itemId);
}
