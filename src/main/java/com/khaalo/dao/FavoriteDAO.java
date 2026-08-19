package com.khaalo.dao;

import java.util.List;
import java.util.Set;
import com.khaalo.model.Restaurant;

public interface FavoriteDAO {
    boolean isFavorite(int userId, String restaurantId);
    boolean addFavorite(int userId, String restaurantId);
    boolean removeFavorite(int userId, String restaurantId);
    Set<String> getFavoriteRestaurantIds(int userId);
    List<Restaurant> getFavoriteRestaurants(int userId);
}
