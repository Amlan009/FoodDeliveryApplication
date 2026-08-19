package com.khaalo.daoimpl;
import com.khaalo.dao.*;

import com.khaalo.model.MenuCategory;
import com.khaalo.model.Dish;
import com.util.connection.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MenuDAOImpl implements MenuDAO {

    private List<Dish> getDishesByCategoryId(int categoryId, Connection conn) {
        String sql = "SELECT * FROM `dishes` WHERE `category_id` = ?";
        List<Dish> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapDishRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Dish mapDishRow(ResultSet rs) throws SQLException {
        int id = rs.getInt("id");
        int categoryId = rs.getInt("category_id");
        String name = rs.getString("name");
        double price = rs.getDouble("price");
        boolean isVeg = rs.getInt("is_veg") == 1;
        boolean isBestseller = rs.getInt("is_bestseller") == 1;
        
        boolean isChefPick = false;
        try {
            isChefPick = rs.getInt("is_chef_pick") == 1;
        } catch (SQLException e) {
            // ignore
        }
        
        double rating = rs.getDouble("rating");
        
        int ratingCount = 120;
        try {
            ratingCount = rs.getInt("rating_count");
        } catch (SQLException e) {
            // ignore
        }
        
        String description = rs.getString("description");
        String imageUrl = rs.getString("image_url");
        
        return new Dish(id, categoryId, name, price, isVeg, isBestseller, isChefPick, rating, ratingCount, description, imageUrl);
    }

    @Override
    public void addMenuCategory(MenuCategory category) {
        String sql = "INSERT INTO `menu_categories` (`restaurant_id`, `category_name`, `sort_order`) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, category.getRestaurantId());
            ps.setString(2, category.getCategoryName());
            ps.setInt(3, category.getSortOrder());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    category.setId(rs.getInt(1));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public MenuCategory getMenuCategoryById(int categoryId) {
        String sql = "SELECT * FROM `menu_categories` WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    MenuCategory cat = new MenuCategory(
                        rs.getInt("id"),
                        rs.getString("restaurant_id"),
                        rs.getString("category_name"),
                        rs.getInt("sort_order")
                    );
                    cat.setDishes(getDishesByCategoryId(cat.getId(), conn));
                    return cat;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<MenuCategory> getMenuByRestaurantId(String restaurantId) {
        String sql = "SELECT * FROM `menu_categories` WHERE `restaurant_id` = ? ORDER BY `sort_order` ASC";
        List<MenuCategory> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MenuCategory cat = new MenuCategory(
                        rs.getInt("id"),
                        rs.getString("restaurant_id"),
                        rs.getString("category_name"),
                        rs.getInt("sort_order")
                    );
                    cat.setDishes(getDishesByCategoryId(cat.getId(), conn));
                    list.add(cat);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public void updateMenuCategory(MenuCategory category) {
        String sql = "UPDATE `menu_categories` SET `category_name` = ?, `sort_order` = ? WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category.getCategoryName());
            ps.setInt(2, category.getSortOrder());
            ps.setInt(3, category.getId());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void deleteMenuCategory(int categoryId) {
        String sql = "DELETE FROM `menu_categories` WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public List<Dish> getAllMenusByRestaurant(String restaurantId) {
        String sql = "SELECT d.* FROM `dishes` d JOIN `menu_categories` c ON d.`category_id` = c.`id` WHERE c.`restaurant_id` = ?";
        List<Dish> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapDishRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public void addDish(Dish dish) {
        String sql = "INSERT INTO `dishes` (`category_id`, `name`, `price`, `is_veg`, `is_bestseller`, `rating`, `description`, `image_url`) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, dish.getCategoryId());
            ps.setString(2, dish.getName());
            ps.setDouble(3, dish.getPrice());
            ps.setInt(4, dish.isVeg() ? 1 : 0);
            ps.setInt(5, dish.isBestseller() ? 1 : 0);
            ps.setDouble(6, dish.getRating());
            ps.setString(7, dish.getDescription());
            ps.setString(8, dish.getImageUrl());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    dish.setId(rs.getInt(1));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public Dish getDishById(int dishId) {
        String sql = "SELECT * FROM `dishes` WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, dishId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapDishRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public Dish getDish(int id) {
        return getDishById(id);
    }

    @Override
    public List<Dish> getAllDishes() {
        String sql = "SELECT * FROM `dishes`";
        List<Dish> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapDishRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public void updateDish(Dish dish) {
        String sql = "UPDATE `dishes` SET `name` = ?, `price` = ?, `is_veg` = ?, `is_bestseller` = ?, `rating` = ?, `description` = ?, `image_url` = ? WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dish.getName());
            ps.setDouble(2, dish.getPrice());
            ps.setInt(3, dish.isVeg() ? 1 : 0);
            ps.setInt(4, dish.isBestseller() ? 1 : 0);
            ps.setDouble(5, dish.getRating());
            ps.setString(6, dish.getDescription());
            ps.setString(7, dish.getImageUrl());
            ps.setInt(8, dish.getId());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void deleteDish(int dishId) {
        String sql = "DELETE FROM `dishes` WHERE `id` = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, dishId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}

