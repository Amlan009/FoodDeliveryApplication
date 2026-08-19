package com.khaalo.dao;

import com.khaalo.model.FAQ;
import java.sql.SQLException;
import java.util.List;

public interface FAQDAO {
    // CRUD operations
    void addFAQ(FAQ faq) throws SQLException;
    FAQ getFAQById(int faqId) throws SQLException;
    List<FAQ> getFAQsByRestaurantId(String restaurantId) throws SQLException;
    void updateFAQ(FAQ faq) throws SQLException;
    void deleteFAQ(int faqId) throws SQLException;
    List<FAQ> getAllFAQs() throws SQLException;
}
