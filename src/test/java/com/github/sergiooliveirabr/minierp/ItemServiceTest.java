package com.github.sergiooliveirabr.minierp;

import com.github.sergiooliveirabr.minierp.entity.Item;
import com.github.sergiooliveirabr.minierp.repository.ItemRepository;
import com.github.sergiooliveirabr.minierp.service.ItemService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

@SpringBootTest
@ActiveProfiles
@Transactional // Ensures that each test will be reversed at the end (automatic cleaning)
public class ItemServiceTest {

    @Autowired
    private ItemService itemService;

    @Autowired
    private ItemRepository itemRepository;

    // Auxiliary method to create a valid item
    private Item createanValidItem() {
        Item item = new Item();

        item.setDescription("My Item Test");
        item.setPrice(new BigDecimal("0.01"));
        item.setQuantity(999);

        return item;
    }

    @Test
    void shouldSaveNewItemAndSetAuditFields() {

        Item itemTest = createanValidItem();

        Item savedItem = itemService.save(itemTest);

        // ASSERT
        // Check if the item was added within DB
        assertNotNull(savedItem.getId(), "The item 'ID' should not be null after saving.");

        assertNotNull(savedItem.getCreated(), "The 'created' should not be null after saving.");
        assertNotNull(savedItem.getUpdated(), "The 'updated' should not be null after saving.");
    }

    @Test
    void shoudlFindAllItems() {

        // ARRANGE: Save the item 2x
        itemService.save(createanValidItem());
        itemService.save(createanValidItem());

        // Action: invoke the method that I'm testing
        List<Item> items = itemService.findAll();

        // ASSERT
        assertEquals(2, items.size(), "The list should contain exactly two items.");
    }

    @Test
    void shouldFindItemById() {

        // ARRANGE
        itemService.save(createanValidItem());

        // ACT
        Item item = itemService.findById(1L);

        // ASSERT
        assertNotNull(item, "The item should not be null, OR is out of bounds");
    }
}
