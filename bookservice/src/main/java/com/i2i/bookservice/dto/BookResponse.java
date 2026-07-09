package com.i2i.bookservice.dto;

public class BookResponse {

    private Long id;
    private String title;
    private String authorName;
    private String publisherName;

    public BookResponse() {
    }

    public BookResponse(
            Long id,
            String title,
            String authorName,
            String publisherName
    ) {
        this.id = id;
        this.title = title;
        this.authorName = authorName;
        this.publisherName = publisherName;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getAuthorName() {
        return authorName;
    }

    public void setAuthorName(String authorName) {
        this.authorName = authorName;
    }

    public String getPublisherName() {
        return publisherName;
    }

    public void setPublisherName(String publisherName) {
        this.publisherName = publisherName;
    }
}