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
            v_book := REGEXP_SUBSTR(
                p_raw_data,
                '[^;]+',
                1,
                v_index
            );

            EXIT WHEN v_book IS NULL;

            v_title := TRIM(
                REGEXP_SUBSTR(v_book, '[^|]+', 1, 1)
            );

            v_author := TRIM(
                REGEXP_SUBSTR(v_book, '[^|]+', 1, 2)
            );

            v_publisher := TRIM(
                REGEXP_SUBSTR(v_book, '[^|]+', 1, 3)
            );

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

        DBMS_LOB.WRITEAPPEND(
            v_json,
            1,
            '['
        );


        LOOP

            v_book := REGEXP_SUBSTR(
                p_raw_data,
                '[^;]+',
                1,
                v_index
            );


            EXIT WHEN v_book IS NULL;


            v_title := TRIM(
                REGEXP_SUBSTR(v_book, '[^|]+', 1, 1)
            );

            v_author := TRIM(
                REGEXP_SUBSTR(v_book, '[^|]+', 1, 2)
            );

            v_publisher := TRIM(
                REGEXP_SUBSTR(v_book, '[^|]+', 1, 3)
            );


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

                DBMS_LOB.WRITEAPPEND(
                    v_json,
                    1,
                    ','
                );

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


        DBMS_LOB.WRITEAPPEND(

            v_json,

            1,

            ']'

        );


        RETURN v_json;


    END RAW_TO_JSON;



    PROCEDURE INSERT_BOOKS(

        p_xml_data  IN CLOB,

        p_json_data IN CLOB

    )

    IS

    BEGIN

        NULL;

    END INSERT_BOOKS;



    PROCEDURE GET_ALL_BOOKS(

        p_books_cursor OUT SYS_REFCURSOR

    )

    IS

    BEGIN

        OPEN p_books_cursor FOR

            SELECT 1

            FROM dual;

    END GET_ALL_BOOKS;


END BOOK_OPERATIONS;
/