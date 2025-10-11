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
        if (!model.containsAttribute("itemFoundById")) {
            model.addAttribute("item", new Item());
        }
        else {
            Item itemFound = (Item) model.getAttribute("itemFoundById");
            model.addAttribute("item", itemFound);
        }

        // Fillup the table
        model.addAttribute("items", itemService.findAll());

        return "inventory";
    }

    @PostMapping("/insert")
    public String insertItem(@ModelAttribute("item") Item item) {
        itemService.save(item);
        return "redirect:/inventory";
    }

    @GetMapping("/{id}")
    public String retrieveItemById(@PathVariable Long id, RedirectAttributes redirectAttributes) {

        Item itemFoundById = itemService.findById(id);

        redirectAttributes.addFlashAttribute("itemFoundById", itemFoundById);
        redirectAttributes.addFlashAttribute("openEditModal", true);

        return "redirect:/inventory";
    }

    @GetMapping("/confirm-delete/{id}")
    public String showDeleteConfirmation(@PathVariable Long id, RedirectAttributes redirectAttributes) {

        if(id == null){
            redirectAttributes.addFlashAttribute("message", "Item not found");
            return "redirect:/inventory";
        }
        Item itemFoundById = itemService.findById(id);

        redirectAttributes.addFlashAttribute("itemFoundById", itemFoundById);
        redirectAttributes.addFlashAttribute("openDeleteModal", true);

        return "redirect:/inventory";
    }

        return "redirect:/inventory";
    }
}
