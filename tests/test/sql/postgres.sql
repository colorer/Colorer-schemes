CREATE FUNCTION add(a int, b int) RETURNS int
LANGUAGE sql AS $$
  SELECT $1 + $2;
$$;

CREATE FUNCTION hi() RETURNS text AS $body$
  SELECT 'x';
$body$ LANGUAGE sql;

SELECT $1;

INSERT INTO t (a) VALUES (1) RETURNING id;

COPY public.actor (actor_id, first_name) FROM stdin;
1	PENELOPE
2	NICK
\.
