PUBLIC FUNCTION countLines(tbl STRING, wcl STRING)
  DEFINE
    qry STRING,
    nbl INTEGER

  LET qry = "Select Count(*) From "
  IF tbl IS NOT NULL THEN
    LET qry = qry.append(tbl)
    IF wcl IS NOT NULL THEN
      LET qry = qry.append(" Where ")
      LET qry = qry.append(" " || wcl)
    END IF
    PREPARE pCountTblRows FROM qry
    EXECUTE pCountTblRows INTO nbl
    FREE pCountTblRows
  ELSE
    LET nbl = -1
  END IF

  RETURN nbl
END FUNCTION

FUNCTION createDB()
  DEFINE
    i SMALLINT,
    s STRING

  CONNECT TO ":memory:+driver='dbmsqt'"
  --CONNECT TO "firstapp" USER "user1" USING "password"
  --DATABASE firstapp

  EXECUTE IMMEDIATE "Create Table countries (
        country_id Integer,
        country_name Varchar(100),
        Constraint pkcountries Primary Key(country_id))"
  INSERT INTO countries VALUES(0, "Germany")
  INSERT INTO countries VALUES(1, "France")
  INSERT INTO countries VALUES(2, "United Kingdom")
  INSERT INTO countries VALUES(3, "Belguim")
  INSERT INTO countries VALUES(4, "Swiss")
  INSERT INTO countries VALUES(5, "Spain")
  INSERT INTO countries VALUES(6, "Portugal")
  INSERT INTO countries VALUES(7, "Italy")
  INSERT INTO countries VALUES(8, "Austria")
  EXECUTE IMMEDIATE "CREATE TABLE customers (
        customer_id INTEGER,
        customer_name VARCHAR(100),
        join_date DATE,
        img VARCHAR(100),
        customer_country INTEGER,
        CONSTRAINT pkcustomers PRIMARY KEY(customer_id),
        CONSTRAINT fkcustomerscountries FOREIGN KEY(customer_country)
            REFERENCES countries(country_id))"
  INSERT INTO customers VALUES(0, "Jane Doe", Today, "https://4js.com/wp-content/uploads/2021/09/eric_byrnes_b.jpg", 0)
  INSERT INTO customers VALUES(1, "John Doe", Today, "https://4js.com/wp-content/uploads/2021/09/Kirk_Cameron_b.jpg", 1)
  INSERT INTO customers VALUES(2, "Mike Doe", Today, "https://4js.com/wp-content/uploads/2021/09/Allan_Wilson2b.jpg", 2)
  INSERT INTO customers VALUES(3, "Jane Doe2", Today, "https://4js.com/wp-content/uploads/2021/09/eric_byrnes_b.jpg", 3)
  INSERT INTO customers VALUES(4, "John Doe2", Today, "https://4js.com/wp-content/uploads/2021/09/Kirk_Cameron_b.jpg", 4)
  INSERT INTO customers VALUES(5, "Mike Doe2", Today, "https://4js.com/wp-content/uploads/2021/09/Allan_Wilson2b.jpg", 5)
  INSERT INTO customers VALUES(6, "Jane Doe3", Today, "https://4js.com/wp-content/uploads/2021/09/eric_byrnes_b.jpg", 6)
  INSERT INTO customers VALUES(7, "John Doe4", Today, "https://4js.com/wp-content/uploads/2021/09/Kirk_Cameron_b.jpg", 7)
  INSERT INTO customers VALUES(8, "Mike Doe5", Today, "https://4js.com/wp-content/uploads/2021/09/Allan_Wilson2b.jpg", 8)
  EXECUTE IMMEDIATE "CREATE TABLE plates (
        plate_id INTEGER,
        plate_name VARCHAR(100),
        CONSTRAINT pkplates PRIMARY KEY(plate_id))"
  FOR i = 1 TO 1000
    LET s = SFMT("%1 Plate", i)
    INSERT INTO plates VALUES(i, s)
  END FOR
  EXECUTE IMMEDIATE "CREATE TABLE custplates (
        customer_id INTEGER,
        plate_id INTEGER,
        plate_rate INTEGER,
        CONSTRAINT pkcustplates PRIMARY KEY(customer_id, plate_id),
        CONSTRAINT fkcustplatesplates FOREIGN KEY(plate_id)
            REFERENCES plates(plate_id),
        CONSTRAINT fkcustplatescustomers FOREIGN KEY(customer_id)
            REFERENCES customers(customer_id))"
  FOR i = 1 TO 1000
    INSERT INTO custplates VALUES(0, i, 5)
  END FOR
  FOR i = 1 TO 500
    INSERT INTO custplates VALUES(1, i, 2)
  END FOR
  FOR i = 1 TO 800
    INSERT INTO custplates VALUES(2, i, 3)
  END FOR
  FOR i = 1 TO 200
    INSERT INTO custplates VALUES(3, i, 4)
  END FOR
  FOR i = 1 TO 12
    INSERT INTO custplates VALUES(5, i, 5)
  END FOR
END FUNCTION
