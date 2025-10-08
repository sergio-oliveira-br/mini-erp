package com.github.sergiooliveirabr.minierp.exceptions;

import com.github.sergiooliveirabr.minierp.entity.Item;
import com.github.sergiooliveirabr.minierp.service.ItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.ModelAndView;

@ControllerAdvice
public class GlobalExceptionHandler {

    private final ItemService itemService;

    @Autowired
    public GlobalExceptionHandler(ItemService itemService) {
        this.itemService = itemService;
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ModelAndView handleIllegalArgumentException(IllegalArgumentException ex) {

        ModelAndView modelAndView = new ModelAndView("inventory");

        modelAndView.addObject("errorMsg", ex.getMessage());
        modelAndView.addObject("item", new Item());
        modelAndView.addObject("items", itemService.findAll());

        return modelAndView;
    }
}
