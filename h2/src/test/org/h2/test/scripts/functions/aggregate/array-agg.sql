-- Copyright 2004-2018 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (http://h2database.com/html/license.html).
-- Initial Developer: Alex Nordlund
--

-- with filter condition

create table test(v varchar);
> ok

insert into test values ('1'), ('2'), ('3'), ('4'), ('5'), ('6'), ('7'), ('8'), ('9');
> update count: 9

select array_agg(v order by v asc),
    array_agg(v order by v desc) filter (where v >= '4')
    from test where v >= '2';
> ARRAY_AGG(V ORDER BY V)  ARRAY_AGG(V ORDER BY V DESC) FILTER (WHERE (V >= '4'))
> ------------------------ ------------------------------------------------------
> (2, 3, 4, 5, 6, 7, 8, 9) (9, 8, 7, 6, 5, 4)
> rows (ordered): 1

create index test_idx on test(v);
> ok

select ARRAY_AGG(v order by v asc),
    ARRAY_AGG(v order by v desc) filter (where v >= '4')
    from test where v >= '2';
> ARRAY_AGG(V ORDER BY V)  ARRAY_AGG(V ORDER BY V DESC) FILTER (WHERE (V >= '4'))
> ------------------------ ------------------------------------------------------
> (2, 3, 4, 5, 6, 7, 8, 9) (9, 8, 7, 6, 5, 4)
> rows (ordered): 1

select ARRAY_AGG(v order by v asc),
    ARRAY_AGG(v order by v desc) filter (where v >= '4')
    from test;
> ARRAY_AGG(V ORDER BY V)     ARRAY_AGG(V ORDER BY V DESC) FILTER (WHERE (V >= '4'))
> --------------------------- ------------------------------------------------------
> (1, 2, 3, 4, 5, 6, 7, 8, 9) (9, 8, 7, 6, 5, 4)
> rows (ordered): 1

drop table test;
> ok

create table test (id int auto_increment primary key, v int);
> ok

insert into test(v) values (7), (2), (8), (3), (7), (3), (9), (-1);
> update count: 8

select array_agg(v) from test;
> ARRAY_AGG(V)
> -------------------------
> (7, 2, 8, 3, 7, 3, 9, -1)
> rows: 1

select array_agg(distinct v) from test;
> ARRAY_AGG(DISTINCT V)
> ---------------------
> (-1, 2, 3, 7, 8, 9)
> rows: 1

select array_agg(distinct v order by v desc) from test;
> ARRAY_AGG(DISTINCT V ORDER BY V DESC)
> -------------------------------------
> (9, 8, 7, 3, 2, -1)
> rows (ordered): 1

drop table test;
> ok

CREATE TABLE TEST (ID INT PRIMARY KEY, NAME VARCHAR);
> ok

INSERT INTO TEST VALUES (1, 'a'), (2, 'a'), (3, 'b'), (4, 'c'), (5, 'c'), (6, 'c');
> update count: 6

SELECT ARRAY_AGG(ID), NAME FROM TEST;
> exception MUST_GROUP_BY_COLUMN_1

SELECT ARRAY_AGG(ID ORDER /**/ BY ID), NAME FROM TEST GROUP BY NAME;
> ARRAY_AGG(ID ORDER BY ID) NAME
> ------------------------- ----
> (1, 2)                    a
> (3)                       b
> (4, 5, 6)                 c
> rows: 3

SELECT ARRAY_AGG(ID ORDER /**/ BY ID) OVER (), NAME FROM TEST;
> ARRAY_AGG(ID ORDER BY ID) OVER () NAME
> --------------------------------- ----
> (1, 2, 3, 4, 5, 6)                a
> (1, 2, 3, 4, 5, 6)                a
> (1, 2, 3, 4, 5, 6)                b
> (1, 2, 3, 4, 5, 6)                c
> (1, 2, 3, 4, 5, 6)                c
> (1, 2, 3, 4, 5, 6)                c
> rows: 6

SELECT ARRAY_AGG(ID ORDER /**/ BY ID) OVER (PARTITION BY NAME), NAME FROM TEST;
> ARRAY_AGG(ID ORDER BY ID) OVER (PARTITION BY NAME) NAME
> -------------------------------------------------- ----
> (1, 2)                                             a
> (1, 2)                                             a
> (3)                                                b
> (4, 5, 6)                                          c
> (4, 5, 6)                                          c
> (4, 5, 6)                                          c
> rows: 6

SELECT ARRAY_AGG(ID ORDER /**/ BY ID) FILTER (WHERE ID < 3 OR ID > 4) OVER (PARTITION BY NAME), NAME FROM TEST ORDER BY NAME;
> ARRAY_AGG(ID ORDER BY ID) FILTER (WHERE ((ID < 3) OR (ID > 4))) OVER (PARTITION BY NAME) NAME
> ---------------------------------------------------------------------------------------- ----
> (1, 2)                                                                                   a
> (1, 2)                                                                                   a
> null                                                                                     b
> (5, 6)                                                                                   c
> (5, 6)                                                                                   c
> (5, 6)                                                                                   c
> rows (ordered): 6

SELECT ARRAY_AGG(SUM(ID)) OVER () FROM TEST;
> ARRAY_AGG(SUM(ID)) OVER ()
> --------------------------
> (21)
> rows: 1

SELECT ARRAY_AGG(ID ORDER /**/ BY ID) OVER() FROM TEST GROUP BY ID ORDER /**/ BY ID;
> ARRAY_AGG(ID ORDER BY ID) OVER ()
> ---------------------------------
> (1, 2, 3, 4, 5, 6)
> (1, 2, 3, 4, 5, 6)
> (1, 2, 3, 4, 5, 6)
> (1, 2, 3, 4, 5, 6)
> (1, 2, 3, 4, 5, 6)
> (1, 2, 3, 4, 5, 6)
> rows: 6

SELECT ARRAY_AGG(NAME) OVER(PARTITION BY NAME) FROM TEST GROUP BY NAME;
> ARRAY_AGG(NAME) OVER (PARTITION BY NAME)
> ----------------------------------------
> (a)
> (b)
> (c)
> rows: 3

SELECT ARRAY_AGG(ARRAY_AGG(ID ORDER /**/ BY ID)) OVER (PARTITION BY NAME), NAME FROM TEST GROUP BY NAME;
> ARRAY_AGG(ARRAY_AGG(ID ORDER BY ID)) OVER (PARTITION BY NAME) NAME
> ------------------------------------------------------------- ----
> ((1, 2))                                                      a
> ((3))                                                         b
> ((4, 5, 6))                                                   c
> rows: 3

SELECT ARRAY_AGG(ARRAY_AGG(ID ORDER /**/ BY ID)) OVER (PARTITION BY NAME), NAME FROM TEST
    GROUP BY NAME ORDER /**/ BY NAME OFFSET 1 ROW;
> ARRAY_AGG(ARRAY_AGG(ID ORDER BY ID)) OVER (PARTITION BY NAME) NAME
> ------------------------------------------------------------- ----
> ((3))                                                         b
> ((4, 5, 6))                                                   c
> rows: 2

SELECT ARRAY_AGG(ARRAY_AGG(ID ORDER BY ID)) FILTER (WHERE NAME > 'b') OVER (PARTITION BY NAME), NAME FROM TEST
    GROUP BY NAME ORDER BY NAME;
> ARRAY_AGG(ARRAY_AGG(ID ORDER BY ID)) FILTER (WHERE (NAME > 'b')) OVER (PARTITION BY NAME) NAME
> ----------------------------------------------------------------------------------------- ----
> null                                                                                      a
> null                                                                                      b
> ((4, 5, 6))                                                                               c
> rows (ordered): 3

SELECT ARRAY_AGG(ARRAY_AGG(ID ORDER BY ID)) FILTER (WHERE NAME > 'c') OVER (PARTITION BY NAME), NAME FROM TEST
    GROUP BY NAME ORDER BY NAME;
> ARRAY_AGG(ARRAY_AGG(ID ORDER BY ID)) FILTER (WHERE (NAME > 'c')) OVER (PARTITION BY NAME) NAME
> ----------------------------------------------------------------------------------------- ----
> null                                                                                      a
> null                                                                                      b
> null                                                                                      c
> rows (ordered): 3

SELECT ARRAY_AGG(ARRAY_AGG(ID ORDER BY ID)) FILTER (WHERE NAME > 'b') OVER () FROM TEST GROUP BY NAME ORDER BY NAME;
> ARRAY_AGG(ARRAY_AGG(ID ORDER BY ID)) FILTER (WHERE (NAME > 'b')) OVER ()
> ------------------------------------------------------------------------
> ((4, 5, 6))
> ((4, 5, 6))
> ((4, 5, 6))
> rows (ordered): 3

SELECT ARRAY_AGG(ARRAY_AGG(ID ORDER BY ID)) FILTER (WHERE NAME > 'c') OVER () FROM TEST GROUP BY NAME ORDER BY NAME;
> ARRAY_AGG(ARRAY_AGG(ID ORDER BY ID)) FILTER (WHERE (NAME > 'c')) OVER ()
> ------------------------------------------------------------------------
> null
> null
> null
> rows (ordered): 3

SELECT ARRAY_AGG(ID) OVER() FROM TEST GROUP BY NAME;
> exception MUST_GROUP_BY_COLUMN_1

SELECT ARRAY_AGG(ID) OVER(PARTITION BY NAME ORDER /**/ BY ID), NAME FROM TEST;
> ARRAY_AGG(ID) OVER (PARTITION BY NAME ORDER BY ID) NAME
> -------------------------------------------------- ----
> (1)                                                a
> (1, 2)                                             a
> (3)                                                b
> (4)                                                c
> (4, 5)                                             c
> (4, 5, 6)                                          c
> rows: 6

SELECT ARRAY_AGG(ID) OVER(PARTITION BY NAME ORDER /**/ BY ID DESC), NAME FROM TEST;
> ARRAY_AGG(ID) OVER (PARTITION BY NAME ORDER BY ID DESC) NAME
> ------------------------------------------------------- ----
> (2)                                                     a
> (2, 1)                                                  a
> (3)                                                     b
> (6)                                                     c
> (6, 5)                                                  c
> (6, 5, 4)                                               c
> rows: 6

SELECT
    ARRAY_AGG(ID ORDER /**/ BY ID) OVER(PARTITION BY NAME ORDER /**/ BY ID DESC) A,
    ARRAY_AGG(ID) OVER(PARTITION BY NAME ORDER /**/ BY ID DESC) D,
    NAME FROM TEST;
> A         D         NAME
> --------- --------- ----
> (1, 2)    (2, 1)    a
> (2)       (2)       a
> (3)       (3)       b
> (4, 5, 6) (6, 5, 4) c
> (5, 6)    (6, 5)    c
> (6)       (6)       c
> rows: 6

SELECT ARRAY_AGG(SUM(ID)) OVER(ORDER /**/ BY ID) FROM TEST GROUP BY ID;
> ARRAY_AGG(SUM(ID)) OVER (ORDER BY ID)
> -------------------------------------
> (1)
> (1, 2)
> (1, 2, 3)
> (1, 2, 3, 4)
> (1, 2, 3, 4, 5)
> (1, 2, 3, 4, 5, 6)
> rows: 6

DROP TABLE TEST;
> ok

CREATE TABLE TEST(ID INT, G INT);
> ok

INSERT INTO TEST VALUES
    (1, 1),
    (2, 2),
    (3, 2),
    (4, 2),
    (5, 3);
> update count: 5

SELECT
    ARRAY_AGG(ID) OVER (ORDER BY G RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) D,
    ARRAY_AGG(ID) OVER (ORDER BY G RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING EXCLUDE CURRENT ROW) R,
    ARRAY_AGG(ID) OVER (ORDER BY G RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING EXCLUDE GROUP) G,
    ARRAY_AGG(ID) OVER (ORDER BY G RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING EXCLUDE TIES) T,
    ARRAY_AGG(ID) OVER (ORDER BY G RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING EXCLUDE NO OTHERS) N
    FROM TEST;
> D               R            G            T               N
> --------------- ------------ ------------ --------------- ---------------
> (1, 2, 3, 4, 5) (2, 3, 4, 5) (2, 3, 4, 5) (1, 2, 3, 4, 5) (1, 2, 3, 4, 5)
> (1, 2, 3, 4, 5) (1, 3, 4, 5) (1, 5)       (1, 2, 5)       (1, 2, 3, 4, 5)
> (1, 2, 3, 4, 5) (1, 2, 4, 5) (1, 5)       (1, 3, 5)       (1, 2, 3, 4, 5)
> (1, 2, 3, 4, 5) (1, 2, 3, 5) (1, 5)       (1, 4, 5)       (1, 2, 3, 4, 5)
> (1, 2, 3, 4, 5) (1, 2, 3, 4) (1, 2, 3, 4) (1, 2, 3, 4, 5) (1, 2, 3, 4, 5)
> rows (ordered): 5

DROP TABLE TEST;
> ok

CREATE TABLE TEST(ID INT, VALUE INT);
> ok

INSERT INTO TEST VALUES
    (1, 1),
    (2, 1),
    (3, 5),
    (4, 8),
    (5, 8),
    (6, 8),
    (7, 9),
    (8, 9);
> update count: 8

SELECT *,
    ARRAY_AGG(ID) OVER (ORDER BY VALUE ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) R_ID,
    ARRAY_AGG(VALUE) OVER (ORDER BY VALUE ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) R_V,
    ARRAY_AGG(ID) OVER (ORDER BY VALUE RANGE BETWEEN 1 PRECEDING AND 1 FOLLOWING) V_ID,
    ARRAY_AGG(VALUE) OVER (ORDER BY VALUE RANGE BETWEEN 1 PRECEDING AND 1 FOLLOWING) V_V,
    ARRAY_AGG(VALUE) OVER (ORDER BY VALUE DESC RANGE BETWEEN 1 PRECEDING AND 1 FOLLOWING) V_V_R,
    ARRAY_AGG(ID) OVER (ORDER BY VALUE GROUPS BETWEEN 1 PRECEDING AND 1 FOLLOWING) G_ID,
    ARRAY_AGG(VALUE) OVER (ORDER BY VALUE GROUPS BETWEEN 1 PRECEDING AND 1 FOLLOWING) G_V
    FROM TEST;
> ID VALUE R_ID      R_V       V_ID            V_V             V_V_R           G_ID               G_V
> -- ----- --------- --------- --------------- --------------- --------------- ------------------ ------------------
> 1  1     (1, 2)    (1, 1)    (1, 2)          (1, 1)          (1, 1)          (1, 2, 3)          (1, 1, 5)
> 2  1     (1, 2, 3) (1, 1, 5) (1, 2)          (1, 1)          (1, 1)          (1, 2, 3)          (1, 1, 5)
> 3  5     (2, 3, 4) (1, 5, 8) (3)             (5)             (5)             (1, 2, 3, 4, 5, 6) (1, 1, 5, 8, 8, 8)
> 4  8     (3, 4, 5) (5, 8, 8) (4, 5, 6, 7, 8) (8, 8, 8, 9, 9) (9, 9, 8, 8, 8) (3, 4, 5, 6, 7, 8) (5, 8, 8, 8, 9, 9)
> 5  8     (4, 5, 6) (8, 8, 8) (4, 5, 6, 7, 8) (8, 8, 8, 9, 9) (9, 9, 8, 8, 8) (3, 4, 5, 6, 7, 8) (5, 8, 8, 8, 9, 9)
> 6  8     (5, 6, 7) (8, 8, 9) (4, 5, 6, 7, 8) (8, 8, 8, 9, 9) (9, 9, 8, 8, 8) (3, 4, 5, 6, 7, 8) (5, 8, 8, 8, 9, 9)
> 7  9     (6, 7, 8) (8, 9, 9) (4, 5, 6, 7, 8) (8, 8, 8, 9, 9) (9, 9, 8, 8, 8) (4, 5, 6, 7, 8)    (8, 8, 8, 9, 9)
> 8  9     (7, 8)    (9, 9)    (4, 5, 6, 7, 8) (8, 8, 8, 9, 9) (9, 9, 8, 8, 8) (4, 5, 6, 7, 8)    (8, 8, 8, 9, 9)
> rows (ordered): 8

SELECT *, ARRAY_AGG(ID) OVER (ORDER BY VALUE ROWS -1 PRECEDING) FROM TEST;
> exception INVALID_VALUE_2

SELECT *, ARRAY_AGG(ID) OVER (ORDER BY ID ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING) FROM TEST FETCH FIRST 4 ROWS ONLY;
> ID VALUE ARRAY_AGG(ID) OVER (ORDER BY ID ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING)
> -- ----- -------------------------------------------------------------------------
> 1  1     null
> 2  1     (1)
> 3  5     (1, 2)
> 4  8     (2, 3)
> rows (ordered): 4

SELECT *, ARRAY_AGG(ID) OVER (ORDER BY ID ROWS BETWEEN 1 FOLLOWING AND 2 FOLLOWING) FROM TEST OFFSET 4 ROWS;
> ID VALUE ARRAY_AGG(ID) OVER (ORDER BY ID ROWS BETWEEN 1 FOLLOWING AND 2 FOLLOWING)
> -- ----- -------------------------------------------------------------------------
> 5  8     (6, 7)
> 6  8     (7, 8)
> 7  9     (8)
> 8  9     null
> rows (ordered): 4

SELECT *, ARRAY_AGG(ID) OVER (ORDER BY ID RANGE BETWEEN 2 PRECEDING AND 1 PRECEDING) FROM TEST FETCH FIRST 4 ROWS ONLY;
> ID VALUE ARRAY_AGG(ID) OVER (ORDER BY ID RANGE BETWEEN 2 PRECEDING AND 1 PRECEDING)
> -- ----- --------------------------------------------------------------------------
> 1  1     null
> 2  1     (1)
> 3  5     (1, 2)
> 4  8     (2, 3)
> rows (ordered): 4

SELECT *, ARRAY_AGG(ID) OVER (ORDER BY ID RANGE BETWEEN 1 FOLLOWING AND 2 FOLLOWING) FROM TEST OFFSET 4 ROWS;
> ID VALUE ARRAY_AGG(ID) OVER (ORDER BY ID RANGE BETWEEN 1 FOLLOWING AND 2 FOLLOWING)
> -- ----- --------------------------------------------------------------------------
> 5  8     (6, 7)
> 6  8     (7, 8)
> 7  9     (8)
> 8  9     null
> rows (ordered): 4

SELECT *,
    ARRAY_AGG(ID) OVER (ORDER BY VALUE GROUPS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) U_P,
    ARRAY_AGG(ID) OVER (ORDER BY VALUE GROUPS BETWEEN 2 PRECEDING AND 1 PRECEDING) P,
    ARRAY_AGG(ID) OVER (ORDER BY VALUE GROUPS BETWEEN 1 FOLLOWING AND 2 FOLLOWING) F,
    ARRAY_AGG(ID) OVER (ORDER BY VALUE GROUPS BETWEEN 1 FOLLOWING AND UNBOUNDED FOLLOWING) U_F
    FROM TEST;
> ID VALUE U_P                P            F               U_F
> -- ----- ------------------ ------------ --------------- ------------------
> 1  1     null               null         (3, 4, 5, 6)    (3, 4, 5, 6, 7, 8)
> 2  1     null               null         (3, 4, 5, 6)    (3, 4, 5, 6, 7, 8)
> 3  5     (1, 2)             (1, 2)       (4, 5, 6, 7, 8) (4, 5, 6, 7, 8)
> 4  8     (1, 2, 3)          (1, 2, 3)    (7, 8)          (7, 8)
> 5  8     (1, 2, 3)          (1, 2, 3)    (7, 8)          (7, 8)
> 6  8     (1, 2, 3)          (1, 2, 3)    (7, 8)          (7, 8)
> 7  9     (1, 2, 3, 4, 5, 6) (3, 4, 5, 6) null            null
> 8  9     (1, 2, 3, 4, 5, 6) (3, 4, 5, 6) null            null
> rows (ordered): 8

SELECT *,
    ARRAY_AGG(ID) OVER (ORDER BY VALUE GROUPS BETWEEN 1 PRECEDING AND 0 PRECEDING) P,
    ARRAY_AGG(ID) OVER (ORDER BY VALUE GROUPS BETWEEN 0 FOLLOWING AND 1 FOLLOWING) F
    FROM TEST;
> ID VALUE P               F
> -- ----- --------------- ---------------
> 1  1     (1, 2)          (1, 2, 3)
> 2  1     (1, 2)          (1, 2, 3)
> 3  5     (1, 2, 3)       (3, 4, 5, 6)
> 4  8     (3, 4, 5, 6)    (4, 5, 6, 7, 8)
> 5  8     (3, 4, 5, 6)    (4, 5, 6, 7, 8)
> 6  8     (3, 4, 5, 6)    (4, 5, 6, 7, 8)
> 7  9     (4, 5, 6, 7, 8) (7, 8)
> 8  9     (4, 5, 6, 7, 8) (7, 8)
> rows (ordered): 8

SELECT *, ARRAY_AGG(ID) OVER (ORDER BY ID RANGE BETWEEN CURRENT ROW AND 1 PRECEDING) FROM TEST;
> exception SYNTAX_ERROR_1

DROP TABLE TEST;
> ok

CREATE TABLE TEST (ID INT, VALUE INT);
> ok

INSERT INTO TEST VALUES
    (1, 1),
    (2, 1),
    (3, 2),
    (4, 2),
    (5, 3),
    (6, 3),
    (7, 4),
    (8, 4);
> update count: 8

SELECT *, ARRAY_AGG(ID) OVER (ORDER BY VALUE RANGE BETWEEN 2 PRECEDING AND 1 PRECEDING) FROM TEST;
> ID VALUE ARRAY_AGG(ID) OVER (ORDER BY VALUE RANGE BETWEEN 2 PRECEDING AND 1 PRECEDING)
> -- ----- -----------------------------------------------------------------------------
> 1  1     null
> 2  1     null
> 3  2     (1, 2)
> 4  2     (1, 2)
> 5  3     (1, 2, 3, 4)
> 6  3     (1, 2, 3, 4)
> 7  4     (3, 4, 5, 6)
> 8  4     (3, 4, 5, 6)
> rows (ordered): 8

SELECT *, ARRAY_AGG(ID) OVER (ORDER BY VALUE RANGE BETWEEN 1 FOLLOWING AND 2 FOLLOWING) FROM TEST;
> ID VALUE ARRAY_AGG(ID) OVER (ORDER BY VALUE RANGE BETWEEN 1 FOLLOWING AND 2 FOLLOWING)
> -- ----- -----------------------------------------------------------------------------
> 1  1     (3, 4, 5, 6)
> 2  1     (3, 4, 5, 6)
> 3  2     (5, 6, 7, 8)
> 4  2     (5, 6, 7, 8)
> 5  3     (7, 8)
> 6  3     (7, 8)
> 7  4     null
> 8  4     null
> rows (ordered): 8

DROP TABLE TEST;
> ok
