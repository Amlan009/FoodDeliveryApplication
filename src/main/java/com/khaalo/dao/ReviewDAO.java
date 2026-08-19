package com.khaalo.dao;

import com.khaalo.model.Review;
import java.sql.SQLException;
import java.util.List;

public interface ReviewDAO {
    void addReview(Review review) throws SQLException;
    Review getReviewById(int reviewId) throws SQLException;
    List<Review> getReviewsByRestaurantId(String restaurantId) throws SQLException;
    List<Review> getReviewsByUserId(int userId) throws SQLException;
    void updateReview(Review review) throws SQLException;
    void deleteReview(int reviewId) throws SQLException;
    List<Review> getAllReviews() throws SQLException;
}
