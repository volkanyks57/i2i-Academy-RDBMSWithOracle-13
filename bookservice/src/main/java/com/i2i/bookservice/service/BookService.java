package com.i2i.bookservice.service;

import com.i2i.bookservice.dto.BookResponse;
import com.i2i.bookservice.repository.BookProcedureRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class BookService {

    private final BookProcedureRepository bookProcedureRepository;

    public BookService(
            BookProcedureRepository bookProcedureRepository
    ) {
        this.bookProcedureRepository = bookProcedureRepository;
    }

    public void importBooks(String rawData) {

        if (rawData == null || rawData.isBlank()) {
            throw new IllegalArgumentException(
                    "Raw data cannot be empty"
            );
        }

        String xmlData =
                bookProcedureRepository.rawToXml(rawData);

        String jsonData =
                bookProcedureRepository.rawToJson(rawData);

        bookProcedureRepository.insertBooks(
                xmlData,
                jsonData
        );
    }

    public List<BookResponse> getAllBooks() {
        return bookProcedureRepository.getAllBooks();
    }
}