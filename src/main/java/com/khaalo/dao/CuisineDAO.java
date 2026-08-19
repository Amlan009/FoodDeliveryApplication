package com.khaalo.dao;

import com.khaalo.model.Cuisine;
import java.sql.SQLException;
import java.util.List;

public interface CuisineDAO {
    List<Cuisine> getAllCuisines() throws SQLException;
    Cuisine getCuisineById(int cuisineId) throws SQLException;
    Cuisine getCuisineByName(String cuisineName) throws SQLException;
    void addCuisine(Cuisine cuisine) throws SQLException;
    void updateCuisine(Cuisine cuisine) throws SQLException;
    void deleteCuisine(int cuisineId) throws SQLException;
    
    // Restaurant-Cuisine Linking
    void linkRestaurantCuisine(String restaurantId, int cuisineId) throws SQLException;
    void unlinkRestaurantCuisine(String restaurantId, int cuisineId) throws SQLException;
}
