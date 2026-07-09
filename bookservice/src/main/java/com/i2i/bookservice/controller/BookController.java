package com.i2i.bookservice.controller;

import com.i2i.bookservice.dto.BookImportRequest;
import com.i2i.bookservice.dto.BookResponse;
import com.i2i.bookservice.service.BookService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/books")
public class BookController {

    private final BookService bookService;

    public BookController(BookService bookService) {
        this.bookService = bookService;
    }

    @PostMapping("/import")
    public ResponseEntity<Map<String, String>> importBooks(
            @RequestBody BookImportRequest request
    ) {
        bookService.importBooks(request.getRawData());

        return ResponseEntity.ok(
                Map.of("message", "Books imported successfully")
        );
    }

    @GetMapping
    public ResponseEntity<List<BookResponse>> getAllBooks() {
        return ResponseEntity.ok(bookService.getAllBooks());
    }
}