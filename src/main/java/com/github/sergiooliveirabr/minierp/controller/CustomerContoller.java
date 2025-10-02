package com.github.sergiooliveirabr.minierp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/customers")
public class CustomerContoller {

    @GetMapping()
    public String customerView() {
        return "customers";
    }
}
