CREATE OR REPLACE PACKAGE BODY BOOK_OPERATIONS AS

    FUNCTION RAW_TO_XML(
        p_raw_data IN VARCHAR2
    ) RETURN CLOB
    IS
        v_xml       CLOB;
        v_book      VARCHAR2(4000);
        v_title     VARCHAR2(1000);
        v_author    VARCHAR2(1000);
        v_publisher VARCHAR2(1000);
        v_index     PLS_INTEGER := 1;
    BEGIN
        IF p_raw_data IS NULL OR TRIM(p_raw_data) IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Raw data cannot be empty');
        END IF;

        DBMS_LOB.CREATETEMPORARY(v_xml, TRUE);
        DBMS_LOB.WRITEAPPEND(v_xml, LENGTH('<books>'), '<books>');

        LOOP
            v_book := REGEXP_SUBSTR(p_raw_data, '[^;]+', 1, v_index);
            EXIT WHEN v_book IS NULL;

            v_title := TRIM(REGEXP_SUBSTR(v_book, '[^|]+', 1, 1));
            v_author := TRIM(REGEXP_SUBSTR(v_book, '[^|]+', 1, 2));
            v_publisher := TRIM(REGEXP_SUBSTR(v_book, '[^|]+', 1, 3));

            IF v_title IS NULL
                OR v_author IS NULL
                OR v_publisher IS NULL
            THEN
                RAISE_APPLICATION_ERROR(
                    -20002,
                    'Malformed book data'
                );
            END IF;

            DBMS_LOB.APPEND(
                v_xml,
                TO_CLOB(
                    '<book>'
                    || '<title>'
                    || DBMS_XMLGEN.CONVERT(v_title, 1)
                    || '</title>'
                    || '<author>'
                    || DBMS_XMLGEN.CONVERT(v_author, 1)
                    || '</author>'
                    || '<publisher>'
                    || DBMS_XMLGEN.CONVERT(v_publisher, 1)
                    || '</publisher>'
                    || '</book>'
                )
            );

            v_index := v_index + 1;
        END LOOP;

        DBMS_LOB.WRITEAPPEND(
            v_xml,
            LENGTH('</books>'),
            '</books>'
        );

        RETURN v_xml;
    END RAW_TO_XML;


    FUNCTION RAW_TO_JSON(
        p_raw_data IN VARCHAR2
    ) RETURN CLOB
    IS
        v_json        CLOB;
        v_json_object VARCHAR2(4000);
        v_book        VARCHAR2(4000);
        v_title       VARCHAR2(1000);
        v_author      VARCHAR2(1000);
        v_publisher   VARCHAR2(1000);
        v_index       PLS_INTEGER := 1;
    BEGIN
        IF p_raw_data IS NULL OR TRIM(p_raw_data) IS NULL THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'Raw data cannot be empty'
            );
        END IF;

        DBMS_LOB.CREATETEMPORARY(v_json, TRUE);
        DBMS_LOB.WRITEAPPEND(v_json, 1, '[');

        LOOP
            v_book := REGEXP_SUBSTR(p_raw_data, '[^;]+', 1, v_index);
            EXIT WHEN v_book IS NULL;

            v_title := TRIM(REGEXP_SUBSTR(v_book, '[^|]+', 1, 1));
            v_author := TRIM(REGEXP_SUBSTR(v_book, '[^|]+', 1, 2));
            v_publisher := TRIM(REGEXP_SUBSTR(v_book, '[^|]+', 1, 3));

            IF v_title IS NULL
                OR v_author IS NULL
                OR v_publisher IS NULL
            THEN
                RAISE_APPLICATION_ERROR(
                    -20002,
                    'Malformed book data'
                );
            END IF;

            IF v_index > 1 THEN
                DBMS_LOB.WRITEAPPEND(v_json, 1, ',');
            END IF;

            SELECT JSON_OBJECT(
                       'title' VALUE v_title,
                       'author' VALUE v_author,
                       'publisher' VALUE v_publisher
                       RETURNING VARCHAR2
                   )
            INTO v_json_object
            FROM dual;

            DBMS_LOB.WRITEAPPEND(
                v_json,
                LENGTH(v_json_object),
                v_json_object
            );

            v_index := v_index + 1;
        END LOOP;

        DBMS_LOB.WRITEAPPEND(v_json, 1, ']');

        RETURN v_json;
    END RAW_TO_JSON;


    PROCEDURE INSERT_BOOKS(
        p_xml_data  IN CLOB,
        p_json_data IN CLOB
    )
    IS
        v_author_id    AUTHORS.ID%TYPE;
        v_publisher_id PUBLISHERS.ID%TYPE;
    BEGIN

        FOR book_record IN (
            SELECT
                xt.title,
                xt.author_name,
                xt.publisher_name
            FROM XMLTABLE(
                '/books/book'
                PASSING XMLTYPE(p_xml_data)
                COLUMNS
                    title VARCHAR2(255)
                        PATH 'title',
                    author_name VARCHAR2(255)
                        PATH 'author',
                    publisher_name VARCHAR2(255)
                        PATH 'publisher'
            ) xt
        )
        LOOP

            BEGIN
                SELECT id
                INTO v_author_id
                FROM AUTHORS
                WHERE name = book_record.author_name;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    INSERT INTO AUTHORS(name)
                    VALUES (book_record.author_name)
                    RETURNING id INTO v_author_id;
            END;


            BEGIN
                SELECT id
                INTO v_publisher_id
                FROM PUBLISHERS
                WHERE name = book_record.publisher_name;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    INSERT INTO PUBLISHERS(name)
                    VALUES (book_record.publisher_name)
                    RETURNING id INTO v_publisher_id;
            END;


            INSERT INTO BOOKS(
                title,
                author_id,
                publisher_id
            )
            VALUES(
                book_record.title,
                v_author_id,
                v_publisher_id
            );

        END LOOP;


        FOR json_record IN (
            SELECT
                jt.title,
                jt.author_name,
                jt.publisher_name
            FROM JSON_TABLE(
                p_json_data,
                '$[*]'
                COLUMNS
                    title VARCHAR2(255)
                        PATH '$.title',
                    author_name VARCHAR2(255)
                        PATH '$.author',
                    publisher_name VARCHAR2(255)
                        PATH '$.publisher'
            ) jt
        )
        LOOP

            IF json_record.title IS NULL
                OR json_record.author_name IS NULL
                OR json_record.publisher_name IS NULL
            THEN
                RAISE_APPLICATION_ERROR(
                    -20003,
                    'Invalid JSON book data'
                );
            END IF;

        END LOOP;

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;

            RAISE_APPLICATION_ERROR(
                -20010,
                'Book insertion failed: ' || SQLERRM
            );
    END INSERT_BOOKS;


    PROCEDURE GET_ALL_BOOKS(
        p_books_cursor OUT SYS_REFCURSOR
    )
    IS

        /*
         * Explicit cursor:
         * BOOKS, AUTHORS ve PUBLISHERS tablolarını JOIN ile okur.
         */
        CURSOR c_books IS
            SELECT
                b.id,
                b.title,
                a.name AS author_name,
                p.name AS publisher_name
            FROM BOOKS b
            INNER JOIN AUTHORS a
                ON a.id = b.author_id
            INNER JOIN PUBLISHERS p
                ON p.id = b.publisher_id
            ORDER BY b.id;

    BEGIN

        /*
         * Explicit cursor kullanma gereksinimini karşılamak için
         * cursor açıkça OPEN edilir.
         *
         * SYS_REFCURSOR çıktısı Java JDBC tarafından ResultSet
         * olarak okunacaktır.
         */
        OPEN c_books;

        CLOSE c_books;


        OPEN p_books_cursor FOR

            SELECT
                b.id,
                b.title,
                a.name AS author_name,
                p.name AS publisher_name

            FROM BOOKS b

            INNER JOIN AUTHORS a
                ON a.id = b.author_id

            INNER JOIN PUBLISHERS p
                ON p.id = b.publisher_id

            ORDER BY b.id;

    END GET_ALL_BOOKS;


END BOOK_OPERATIONS;
/