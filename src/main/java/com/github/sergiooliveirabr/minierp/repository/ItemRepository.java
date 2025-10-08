package com.github.sergiooliveirabr.minierp.repository;

import com.github.sergiooliveirabr.minierp.entity.Item;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ItemRepository extends JpaRepository<Item, Long> {
}
