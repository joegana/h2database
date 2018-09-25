-- Copyright 2004-2018 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (http://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

SELECT NTILE(1) OVER (ORDER BY X) FROM (SELECT * FROM SYSTEM_RANGE(1, 1));
>> 1

SELECT NTILE(2) OVER (ORDER BY X) FROM (SELECT * FROM SYSTEM_RANGE(1, 1));
>> 1

SELECT NTILE(3) OVER (ORDER BY X) FROM (SELECT * FROM SYSTEM_RANGE(1, 1));
>> 1

SELECT NTILE(1) OVER (ORDER BY X) FROM (SELECT * FROM SYSTEM_RANGE(1, 2));
> NTILE(1) OVER (ORDER BY X)
> --------------------------
> 1
> 1
> rows (ordered): 2

SELECT NTILE(2) OVER (ORDER BY X) FROM (SELECT * FROM SYSTEM_RANGE(1, 2));
> NTILE(2) OVER (ORDER BY X)
> --------------------------
> 1
> 2
> rows (ordered): 2

SELECT NTILE(2) OVER (ORDER BY X) FROM (SELECT * FROM SYSTEM_RANGE(1, 3));
> NTILE(2) OVER (ORDER BY X)
> --------------------------
> 1
> 1
> 2
> rows (ordered): 3

SELECT NTILE(2) OVER (ORDER BY X) FROM (SELECT * FROM SYSTEM_RANGE(1, 4));
> NTILE(2) OVER (ORDER BY X)
> --------------------------
> 1
> 1
> 2
> 2
> rows (ordered): 4

SELECT NTILE(2) OVER (ORDER BY X) FROM (SELECT * FROM SYSTEM_RANGE(1, 5));
> NTILE(2) OVER (ORDER BY X)
> --------------------------
> 1
> 1
> 1
> 2
> 2
> rows (ordered): 5

SELECT NTILE(2) OVER (ORDER BY X) FROM (SELECT * FROM SYSTEM_RANGE(1, 6));
> NTILE(2) OVER (ORDER BY X)
> --------------------------
> 1
> 1
> 1
> 2
> 2
> 2
> rows (ordered): 6

SELECT NTILE(10) OVER (ORDER BY X) FROM (SELECT * FROM SYSTEM_RANGE(1, 3));
> NTILE(10) OVER (ORDER BY X)
> ---------------------------
> 1
> 2
> 3
> rows (ordered): 3

SELECT NTILE(10) OVER (ORDER BY X) FROM (SELECT * FROM SYSTEM_RANGE(1, 22));
> NTILE(10) OVER (ORDER BY X)
> ---------------------------
> 1
> 1
> 1
> 2
> 2
> 2
> 3
> 3
> 4
> 4
> 5
> 5
> 6
> 6
> 7
> 7
> 8
> 8
> 9
> 9
> 10
> 10
> rows (ordered): 22

SELECT NTILE(0) OVER (ORDER BY X) FROM (SELECT * FROM SYSTEM_RANGE(1, 1));
> exception INVALID_VALUE_2

SELECT NTILE(X) OVER (ORDER BY X) FROM (SELECT * FROM SYSTEM_RANGE(1, 6));
> NTILE(X) OVER (ORDER BY X)
> --------------------------
> 1
> 1
> 2
> 2
> 4
> 6
> rows (ordered): 6

SELECT NTILE(X) OVER () FROM (SELECT * FROM SYSTEM_RANGE(1, 1));
> exception SYNTAX_ERROR_2

SELECT NTILE(X) OVER (ORDER BY X RANGE CURRENT ROW) FROM (SELECT * FROM SYSTEM_RANGE(1, 1));
> exception SYNTAX_ERROR_1
