package com.khaalo.dao;

import com.khaalo.model.Cart;

public interface CartDAO {
    void saveCart(Cart cart);
    Cart getCartByUserId(int userId);
    void clearCart(int userId);
    void deleteCartItem(int cartItemId);
}
