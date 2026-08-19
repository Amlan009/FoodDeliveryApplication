package com.khaalo.dao;

import com.khaalo.model.Restaurant;
import java.util.List;

public interface RestaurantDAO {
    Restaurant getRestaurantById(String id);
    List<Restaurant> getAllRestaurants();
}
