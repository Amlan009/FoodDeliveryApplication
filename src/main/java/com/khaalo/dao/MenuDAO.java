package com.khaalo.dao;

import com.khaalo.model.MenuCategory;
import com.khaalo.model.Dish;
import java.util.List;

public interface MenuDAO {
    // Menu Category CRUD
    void addMenuCategory(MenuCategory category);
    MenuCategory getMenuCategoryById(int categoryId);
    List<MenuCategory> getMenuByRestaurantId(String restaurantId);
    void updateMenuCategory(MenuCategory category);
    void deleteMenuCategory(int categoryId);

    List<Dish> getAllMenusByRestaurant(String restaurantId);

    // Dish CRUD
    void addDish(Dish dish);
    Dish getDishById(int dishId);
    Dish getDish(int id);
    List<Dish> getAllDishes();
    void updateDish(Dish dish);
    void deleteDish(int dishId);
}
