package com.github.sergiooliveirabr.minierp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/sales")
public class SaleController {

    @GetMapping
    public String salesView() {
        return "sales";
    }
}
