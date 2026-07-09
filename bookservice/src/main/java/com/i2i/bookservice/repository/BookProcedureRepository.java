package com.i2i.bookservice.repository;

import com.i2i.bookservice.dto.BookResponse;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.io.Reader;
import java.io.StringReader;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

@Repository
public class BookProcedureRepository {

    private final DataSource dataSource;

    public BookProcedureRepository(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public String rawToXml(String rawData) {

        String sql =
                "BEGIN ? := BOOK_OPERATIONS.RAW_TO_XML(?); END;";

        try (
                Connection connection =
                        dataSource.getConnection();

                CallableStatement statement =
                        connection.prepareCall(sql)
        ) {

            statement.registerOutParameter(
                    1,
                    Types.CLOB
            );

            statement.setString(
                    2,
                    rawData
            );

            statement.execute();

            return readClob(
                    statement.getCharacterStream(1)
            );

        } catch (Exception e) {

            throw new RuntimeException(
                    "RAW_TO_XML function call failed",
                    e
            );
        }
    }


    public String rawToJson(String rawData) {

        String sql =
                "BEGIN ? := BOOK_OPERATIONS.RAW_TO_JSON(?); END;";

        try (
                Connection connection =
                        dataSource.getConnection();

                CallableStatement statement =
                        connection.prepareCall(sql)
        ) {

            statement.registerOutParameter(
                    1,
                    Types.CLOB
            );

            statement.setString(
                    2,
                    rawData
            );

            statement.execute();

            return readClob(
                    statement.getCharacterStream(1)
            );

        } catch (Exception e) {

            throw new RuntimeException(
                    "RAW_TO_JSON function call failed",
                    e
            );
        }
    }


    public void insertBooks(
            String xmlData,
            String jsonData
    ) {

        String sql =
                "BEGIN BOOK_OPERATIONS.INSERT_BOOKS(?, ?); END;";

        try (
                Connection connection =
                        dataSource.getConnection();

                CallableStatement statement =
                        connection.prepareCall(sql)
        ) {

            statement.setCharacterStream(
                    1,
                    new StringReader(xmlData)
            );

            statement.setCharacterStream(
                    2,
                    new StringReader(jsonData)
            );

            statement.execute();

        } catch (Exception e) {

            throw new RuntimeException(
                    "INSERT_BOOKS procedure call failed",
                    e
            );
        }
    }


    public List<BookResponse> getAllBooks() {

        String sql =
                "BEGIN BOOK_OPERATIONS.GET_ALL_BOOKS(?); END;";

        List<BookResponse> books =
                new ArrayList<>();

        try (
                Connection connection =
                        dataSource.getConnection();

                CallableStatement statement =
                        connection.prepareCall(sql)
        ) {

            statement.registerOutParameter(
                    1,
                    Types.REF_CURSOR
            );

            statement.execute();

            try (
                    ResultSet resultSet =
                            (ResultSet) statement.getObject(1)
            ) {

                while (resultSet.next()) {

                    books.add(
                            new BookResponse(
                                    resultSet.getLong("id"),
                                    resultSet.getString("title"),
                                    resultSet.getString("author_name"),
                                    resultSet.getString("publisher_name")
                            )
                    );
                }
            }

            return books;

        } catch (Exception e) {

            throw new RuntimeException(
                    "GET_ALL_BOOKS procedure call failed",
                    e
            );
        }
    }


    private String readClob(Reader reader)
            throws Exception {

        if (reader == null) {
            return null;
        }

        StringBuilder result =
                new StringBuilder();

        char[] buffer =
                new char[2048];

        int length;

        try (reader) {

            while (
                    (length = reader.read(buffer)) != -1
            ) {

                result.append(
                        buffer,
                        0,
                        length
                );
            }
        }

        return result.toString();
    }
}