package com.khaalo.servlets;

import com.khaalo.dao.CouponDAO;
import com.khaalo.daoimpl.CouponDAOImpl;
import com.khaalo.model.Coupon;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet({"/CouponServlet", "/coupon"})
public class CouponServlet extends HttpServlet {
    private final CouponDAO couponDAO = new CouponDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        if ("remove".equalsIgnoreCase(action)) {
            session.removeAttribute("appliedCoupon");
            response.sendRedirect("cart?couponRemoved=true");
            return;
        }

        String code = request.getParameter("code");
        if (code == null || code.trim().isEmpty()) {
            response.sendRedirect("cart?couponError=Coupon code is required.");
            return;
        }

        String cleanCode = code.trim().toUpperCase();

        try {
            Coupon coupon = couponDAO.getCouponByCode(cleanCode);
            if (coupon != null || "WELCOME50".equalsIgnoreCase(cleanCode) || "KHAALO200".equalsIgnoreCase(cleanCode)) {
                session.setAttribute("appliedCoupon", cleanCode);
                response.sendRedirect("cart?couponSuccess=true");
            } else {
                response.sendRedirect("cart?couponError=Invalid or expired coupon code.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            if ("WELCOME50".equalsIgnoreCase(cleanCode) || "KHAALO200".equalsIgnoreCase(cleanCode)) {
                session.setAttribute("appliedCoupon", cleanCode);
                response.sendRedirect("cart?couponSuccess=true");
            } else {
                response.sendRedirect("cart?couponError=Invalid or expired coupon code.");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
