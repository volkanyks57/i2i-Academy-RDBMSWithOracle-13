CREATE OR REPLACE PACKAGE BOOK_OPERATIONS AS

    FUNCTION RAW_TO_XML(
        p_raw_data IN VARCHAR2
    ) RETURN CLOB;


    FUNCTION RAW_TO_JSON(
        p_raw_data IN VARCHAR2
    ) RETURN CLOB;


    PROCEDURE INSERT_BOOKS(
        p_xml_data  IN CLOB,
        p_json_data IN CLOB
    );


    PROCEDURE GET_ALL_BOOKS(
        p_books_cursor OUT SYS_REFCURSOR
    );

END BOOK_OPERATIONS;
/