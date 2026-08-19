package com.khaalo.dao;

import com.khaalo.model.Dish;
import java.sql.SQLException;
import java.util.List;

public interface DishDAO {
    void addDish(Dish dish) throws SQLException;
    Dish getDishById(int dishId) throws SQLException;
    Dish getDish(int id) throws SQLException;
    List<Dish> getAllDishes() throws SQLException;
    List<Dish> getDishesByCategoryId(int categoryId) throws SQLException;
    void updateDish(Dish dish) throws SQLException;
    void deleteDish(int dishId) throws SQLException;
}
