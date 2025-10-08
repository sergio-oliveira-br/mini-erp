package com.github.sergiooliveirabr.minierp.controller;

import com.github.sergiooliveirabr.minierp.entity.Item;
import com.github.sergiooliveirabr.minierp.service.ItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/inventory")
public class InventoryController {

    private final ItemService itemService;

    @Autowired
    public InventoryController(ItemService itemService) {
        this.itemService = itemService;
    }

    @GetMapping
    public String inventoryView(Model model) {

        // Adds the empty Item object to the CREATE form (th:object="${item}")
        model.addAttribute("item", new Item());

        // Fillup the table
        model.addAttribute("items", itemService.findAll());
        return "inventory";
    }

    @PostMapping("/insert")
    public String insertItem(@ModelAttribute("item") Item item) {
        itemService.save(item);
        return "redirect:/inventory";
    }


}
