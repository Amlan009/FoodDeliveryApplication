package com.khaalo.model;

public class FAQ {
    private int id;
    private String restaurantId;
    private String question;
    private String answer;

    // Constructors
    public FAQ() {}

    public FAQ(int id, String restaurantId, String question, String answer) {
        this.id = id;
        this.restaurantId = restaurantId;
        this.question = question;
        this.answer = answer;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getRestaurantId() { return restaurantId; }
    public void setRestaurantId(String restaurantId) { this.restaurantId = restaurantId; }

    public String getQuestion() { return question; }
    public void setQuestion(String question) { this.question = question; }

    public String getAnswer() { return answer; }
    public void setAnswer(String answer) { this.answer = answer; }
}
