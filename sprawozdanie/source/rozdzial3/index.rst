Modele Bazy Danych
=========================================

:author: Grzegorz Szczepanek

Na podstawie analizy kodu w pliku `bazy.ipynb`, przygotowałem model konceptualny, logiczny i fizyczny dla bazy danych systemu sklepu z bronią.


Model Konceptualny
---------------------

model-konceptualny.png

Model konceptualny reprezentuje wysokopoziomowy widok struktury bazy danych, skupiający się na encjach i relacjach.

```
+-------------+              +-------------+              +-------------+
|             |              |             |              |             |
|  KATEGORIE  |<-------------+  PRODUKTY   |              | UŻYTKOWNICY |
|             |    posiada   |             |              |             |
+-------------+              +-------------+              +-------------+
```



### Opis encji:
- **KATEGORIE** - Klasyfikacja produktów (np. broń krótka, broń długa, akcesoria)
- **PRODUKTY** - Towary dostępne w sklepie (np. pistolety, karabiny, celowniki)
- **UŻYTKOWNICY** - Klienci systemu (tylko w PostgreSQL)

### Relacje:
- Jedna kategoria może zawierać wiele produktów (relacja jeden-do-wielu)
- Użytkownicy są niezależną encją bez bezpośrednich relacji w obecnym modelu


Model Logiczny
---------------------

model-logiczny.png


Model logiczny rozszerza model konceptualny przez zdefiniowanie atrybutów, typów danych i kluczy.

```
+-----------------+          +--------------------+          +--------------------+
| KATEGORIE       |          | PRODUKTY           |          | UŻYTKOWNICY        |
+-----------------+          +--------------------+          +--------------------+
| PK id           |<---------| FK kategoria_id    |          | PK pesel           |
| nazwa           |          | PK id              |          | imie               |
| opis            |          | nazwa              |          | nazwisko           |
+-----------------+          | opis               |          | kod_pocztowy       |
                            | cena               |          | data_aktualizacji  |
                            | stan_magazynowy    |          +--------------------+
                            +--------------------+
```

### Atrybuty:
- **KATEGORIE**:
  - id (klucz główny) - unikalny identyfikator kategorii
  - nazwa - nazwa kategorii (np. "Broń krótka")
  - opis - opis kategorii (np. "Pistolety i rewolwery")

- **PRODUKTY**:
  - id (klucz główny) - unikalny identyfikator produktu
  - nazwa - nazwa produktu (np. "Pistolet Glock 19")
  - opis - opis produktu (np. "9mm pistolet samopowtarzalny")
  - cena - cena produktu w złotych
  - stan_magazynowy - liczba sztuk dostępnych w magazynie
  - kategoria_id (klucz obcy) - odniesienie do tabeli KATEGORIE

- **UŻYTKOWNICY** (tylko PostgreSQL):
  - pesel (klucz główny) - unikalny identyfikator osobisty
  - imie - imię użytkownika
  - nazwisko - nazwisko użytkownika
  - kod_pocztowy - kod pocztowy adresu użytkownika
  - data_aktualizacji - data ostatniej aktualizacji danych

Model Fizyczny
---------------------

Model fizyczny definiuje konkretną implementację bazy danych w określonych systemach.

SQLite
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

```sql
-- Definicja tabeli Kategorie
CREATE TABLE IF NOT EXISTS kategorie (
    id INTEGER PRIMARY KEY,
    nazwa TEXT NOT NULL,
    opis TEXT
);

-- Definicja tabeli Produkty
CREATE TABLE IF NOT EXISTS produkty (
    id INTEGER PRIMARY KEY,
    nazwa TEXT NOT NULL,
    opis TEXT,
    cena REAL NOT NULL,
    stan_magazynowy INTEGER NOT NULL,
    kategoria_id INTEGER,
    FOREIGN KEY (kategoria_id) REFERENCES kategorie(id)
);
```

PostgreSQL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

```sql
-- Definicja tabeli Kategorie
CREATE TABLE IF NOT EXISTS kategorie (
    id SERIAL PRIMARY KEY,
    nazwa VARCHAR(100) NOT NULL,
    opis TEXT
);

-- Definicja tabeli Produkty
CREATE TABLE IF NOT EXISTS produkty (
    id SERIAL PRIMARY KEY,
    nazwa VARCHAR(100) NOT NULL,
    opis TEXT,
    cena DECIMAL(10,2) NOT NULL,
    stan_magazynowy INTEGER NOT NULL,
    kategoria_id INTEGER,
    FOREIGN KEY (kategoria_id) REFERENCES kategorie(id)
);

-- Definicja tabeli Użytkownicy (widoczna tylko w PostgreSQL)
CREATE TABLE IF NOT EXISTS uzytkownicy (
    pesel CHAR(11) PRIMARY KEY,
    imie VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL,
    kod_pocztowy VARCHAR(6),
    data_aktualizacji DATE
);
```

### Główne różnice między implementacjami

1. **Typy danych:**
   - SQLite używa ogólnych typów: `INTEGER`, `TEXT`, `REAL`
   - PostgreSQL używa bardziej specyficznych typów: `SERIAL`, `VARCHAR`, `DECIMAL(10,2)`

2. **Autoinkrementacja:**
   - SQLite wykorzystuje `INTEGER PRIMARY KEY` (alias dla ROWID)
   - PostgreSQL używa typu `SERIAL` do automatycznej inkrementacji

3. **Dodatkowa tabela:**
   - W PostgreSQL istnieje dodatkowa tabela `uzytkownicy` nieobecna w SQLite

4. **Precyzja danych liczbowych:**
   - SQLite używa `REAL` do przechowywania cen (typ zmiennoprzecinkowy)
   - PostgreSQL używa `DECIMAL(10,2)` zapewniającego dokładną precyzję z dwoma miejscami po przecinku

## Przykład danych

Przykładowe rekordy dla tabeli `kategorie`:
```
id | nazwa        | opis
---+-------------+------------------------
1  | Broń krótka | Pistolety i rewolwery
2  | Broń długa  | Karabiny i strzelby
3  | Akcesoria   | Akcesoria strzeleckie
```

Przykładowe rekordy dla tabeli `produkty`:
```
id | nazwa               | opis                          | cena    | stan_magazynowy | kategoria_id
---+--------------------+-------------------------------+---------+----------------+-------------
1  | Pistolet Glock 19  | 9mm pistolet samopowtarzalny  | 2999.99 | 15             | 1
2  | Karabin Sako 85    | Karabin myśliwski kaliber .308| 9999.99 | 8              | 2
3  | Celownik optyczny  | Celownik 3-9x40               | 1299.99 | 25             | 3
4  | Rewolwer S&W       | Revolver .357 Magnum          | 3999.99 | 12             | 1
5  | Strzelba Remington | Strzelba pump-action 12 kaliber| 4999.99 | 18             | 2
6  | Torba taktyczna    | Torba na sprzęt strzelecki    | 599.99  | 30             | 3
```

Przykładowe rekordy dla tabeli `uzytkownicy` (tylko PostgreSQL):
```
pesel        | imie      | nazwisko    | kod_pocztowy | data_aktualizacji
------------+-----------+------------+--------------+------------------
12345678901 | Anna      | Kowalska   | 00-001       | 2025-05-08
23456789012 | Jan       | Nowak      | 02-002       | 2025-05-08
34567890123 | Maria     | Wiśniewska | 03-003       | 2025-05-08
```
