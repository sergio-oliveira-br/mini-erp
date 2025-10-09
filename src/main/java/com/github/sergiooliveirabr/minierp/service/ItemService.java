package com.github.sergiooliveirabr.minierp.service;

import com.github.sergiooliveirabr.minierp.entity.Item;
import com.github.sergiooliveirabr.minierp.repository.ItemRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ItemService {

    private final ItemRepository itemRepository;

    @Autowired
    public ItemService(ItemRepository itemRepository) {
        this.itemRepository = itemRepository;
    }

    public Item save(Item item) {

        if (item.getDescription() == null || item.getPrice() == null || item.getQuantity() == null ) {
            throw new IllegalArgumentException("All fields are required");
        }
        return itemRepository.save(item);
    }

    public List<Item> findAll() {
        return itemRepository.findAll();
    }

    public Item findById(Long id) {
        return itemRepository.findById(id).orElse(null);
    }
}
