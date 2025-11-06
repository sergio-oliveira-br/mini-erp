package com.github.sergiooliveirabr.minierp.controller;

import com.github.sergiooliveirabr.minierp.entity.Item;
import com.github.sergiooliveirabr.minierp.service.ItemService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/inventory")
public class InventoryController {

    private final ItemService itemService;

    private static final String ITEM_FOUND_BY_ID = "itemFoundById";
    private static final String SUCCESS_MESSAGE = "successMessage";
    private static final String ERROR_MESSAGE = "errorMessage";
    private static final String REDIRECT_TO_INVENTORY_PAGE= "redirect:/inventory";


    @Autowired
    public InventoryController(ItemService itemService) {
        this.itemService = itemService;
    }

    @ModelAttribute
    public void addCsrfToken(Model model, CsrfToken token) {
        model.addAttribute("_csrf", token);
    }

    @GetMapping
    public String inventoryView(Model model) {

        // Adds the empty Item object to the CREATE form (th:object="${item}")
        if (!model.containsAttribute(ITEM_FOUND_BY_ID)) {
            model.addAttribute("item", new Item());
        }
        else {
            Item itemFound = (Item) model.getAttribute(ITEM_FOUND_BY_ID);
            model.addAttribute("item", itemFound);
        }

        // Fillup the table
        model.addAttribute("items", itemService.findAll());

        //Output messages
        model.addAttribute(SUCCESS_MESSAGE);
        model.addAttribute(ERROR_MESSAGE);

        return "inventory";
    }

    @PostMapping("/insert")
    public String insertItem(@ModelAttribute("item") Item item) {
        itemService.save(item);
        return REDIRECT_TO_INVENTORY_PAGE;
    }

    @GetMapping("/{id}")
    public String retrieveItemById(@PathVariable Long id, RedirectAttributes redirectAttributes) {

        Item itemFoundById = itemService.findById(id);

        redirectAttributes.addFlashAttribute(ITEM_FOUND_BY_ID, itemFoundById);
        redirectAttributes.addFlashAttribute("openEditModal", true);

        return REDIRECT_TO_INVENTORY_PAGE;
    }

    @GetMapping("/confirm-delete/{id}")
    public String showDeleteConfirmation(@PathVariable Long id, RedirectAttributes redirectAttributes) {

        if(id == null){
            redirectAttributes.addFlashAttribute(ERROR_MESSAGE, "Item not found");
            return REDIRECT_TO_INVENTORY_PAGE;
        }
        Item itemFoundById = itemService.findById(id);

        redirectAttributes.addFlashAttribute(ITEM_FOUND_BY_ID, itemFoundById);
        redirectAttributes.addFlashAttribute("openDeleteModal", true);

        return REDIRECT_TO_INVENTORY_PAGE;
    }

    @PostMapping("/delete/{id}")
    public String deleteItemById(@PathVariable @Positive @Valid Long id,
                                 RedirectAttributes redirectAttributes) {

        if(id <= 0){
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid ID");
        }

        itemService.delete(id);
        redirectAttributes.addFlashAttribute(SUCCESS_MESSAGE, "Item successfully deleted!");
        return REDIRECT_TO_INVENTORY_PAGE;
    }

    @PostMapping("/update/{id}")
    public String updateItemById(@PathVariable @Positive @Valid Long id,
                                 @Valid @ModelAttribute Item itemToUpdate,
                                 RedirectAttributes redirectAttributes) {

        if(id <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid ID");
        }

        Item itemFoundById = itemService.findById(id);

        if(itemFoundById == null){
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Item not found");
        }

        itemToUpdate.setId(id);

        itemService.updatedItem(itemToUpdate);
        redirectAttributes.addFlashAttribute(SUCCESS_MESSAGE,
                 itemToUpdate.getDescription() + " successfully updated!");
        return REDIRECT_TO_INVENTORY_PAGE;
    }
}
