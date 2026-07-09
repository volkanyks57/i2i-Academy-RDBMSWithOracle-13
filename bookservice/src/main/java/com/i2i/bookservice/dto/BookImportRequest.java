package com.i2i.bookservice.dto;

public class BookImportRequest {

    private String rawData;

    public BookImportRequest() {
    }

    public String getRawData() {
        return rawData;
    }

    public void setRawData(String rawData) {
        this.rawData = rawData;
    }
}