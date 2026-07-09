# i2i-Academy-RDBMSWithOracle-13
Oracle veritabanı, PL/SQL ve Spring Boot ile geliştirilmiş kitap yönetim sistemi

# Özet
  Bu projede Oracle veritabanı kullanılarak uçtan uca bir kitap yönetim sistemi geliştirildi. 
  Docker Compose ile Oracle XE ve Spring Boot uygulaması aynı ağda iki container olarak çalıştırıldı, 
  veritabanı şeması Flyway ile otomatik oluşturuldu. Tüm veritabanı mantığı BOOK_OPERATIONS adlı bir 
  PL/SQL paketinde toplandı ve Spring Boot REST endpoint'leri ile bu paket kullanıldı.

# Tamamlanan Görevler
  - Docker Compose ile Oracle XE ve Spring Boot iki container olarak ayağa kaldırıldı.
  - Flyway ile AUTHORS, PUBLISHERS, BOOKS ve AUDIT_LOGS tabloları otomatik oluşturuldu.
  - BOOKS tablosuna kitap eklendiğinde çalışan Row-Level Trigger yazıldı (AUDIT_LOGS'a kayıt atar).
  - BOOK_OPERATIONS PL/SQL paketi oluşturuldu:
    - Ham metni XML'e çeviren fonksiyon
    - Ham metni JSON'a çeviren fonksiyon
    - XMLTABLE ve JSON_TABLE ile veriyi parse edip tablolara ekleyen prosedür
    - RAISE_APPLICATION_ERROR ile exception handling
    - Explicit cursor ile veri döndüren prosedür
  - POST /api/books/import endpoint'i yazıldı (ham veriyi PL/SQL'e işletir).
  - GET /api/books endpoint'i yazıldı (kitapları JSON listesi olarak döndürür).
  - Hatalı veride HTTP hata cevabı dönen global exception handling eklendi.
  - Swagger ile endpoint'ler test edildi.

# Kullanılan Teknolojiler
- Java 21
- Spring Boot
- Oracle Database XE
- PL/SQL
- Docker & Docker Compose
- Flyway
- Swagger / OpenAPI
