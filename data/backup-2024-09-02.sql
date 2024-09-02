--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Debian 16.3-1.pgdg120+1)
-- Dumped by pg_dump version 16.4 (Ubuntu 16.4-1.pgdg22.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA extensions;


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql;


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql_public;


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgbouncer;


--
-- Name: pgsodium; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgsodium;


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA realtime;


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA storage;


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA vault;


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

    REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
    REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

    GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    RAISE WARNING 'PgBouncer auth request: %', p_usename;

    RETURN QUERY
    SELECT usename::TEXT, passwd::TEXT FROM pg_catalog.pg_shadow
    WHERE usename = p_usename;
END;
$$;


--
-- Name: hello_world(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.hello_world() RETURNS text
    LANGUAGE sql
    AS $$
  select 'hello world';
$$;


--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or action = 'DELETE'
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
_filename text;
BEGIN
	select string_to_array(name, '/') into _parts;
	select _parts[array_length(_parts,1)] into _filename;
	-- @todo return the last part instead of 2
	return reverse(split_part(reverse(_filename), '.', 1));
END
$$;


--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[1:array_length(_parts,1)-1];
END
$$;


--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::int) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
  v_order_by text;
  v_sort_order text;
begin
  case
    when sortcolumn = 'name' then
      v_order_by = 'name';
    when sortcolumn = 'updated_at' then
      v_order_by = 'updated_at';
    when sortcolumn = 'created_at' then
      v_order_by = 'created_at';
    when sortcolumn = 'last_accessed_at' then
      v_order_by = 'last_accessed_at';
    else
      v_order_by = 'name';
  end case;

  case
    when sortorder = 'asc' then
      v_sort_order = 'asc';
    when sortorder = 'desc' then
      v_sort_order = 'desc';
    else
      v_sort_order = 'asc';
  end case;

  v_order_by = v_order_by || ' ' || v_sort_order;

  return query execute
    'with folders as (
       select path_tokens[$1] as folder
       from storage.objects
         where objects.name ilike $2 || $3 || ''%''
           and bucket_id = $4
           and array_length(objects.path_tokens, 1) <> $1
       group by folder
       order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


--
-- Name: secrets_encrypt_secret_secret(); Type: FUNCTION; Schema: vault; Owner: -
--

CREATE FUNCTION vault.secrets_encrypt_secret_secret() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
		BEGIN
		        new.secret = CASE WHEN new.secret IS NULL THEN NULL ELSE
			CASE WHEN new.key_id IS NULL THEN NULL ELSE pg_catalog.encode(
			  pgsodium.crypto_aead_det_encrypt(
				pg_catalog.convert_to(new.secret, 'utf8'),
				pg_catalog.convert_to((new.id::text || new.description::text || new.created_at::text || new.updated_at::text)::text, 'utf8'),
				new.key_id::uuid,
				new.nonce
			  ),
				'base64') END END;
		RETURN new;
		END;
		$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text
);


--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone
);


--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text
);


--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: books; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.books (
    name text,
    url text,
    id integer NOT NULL
);


--
-- Name: books_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.books_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: books_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.books_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: books_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.books_id_seq1 OWNED BY public.books.id;


--
-- Name: feeds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feeds (
    rss text,
    url text,
    description text,
    title text,
    id integer NOT NULL
);


--
-- Name: feeds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.feeds_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feeds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.feeds_id_seq OWNED BY public.feeds.id;


--
-- Name: movies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.movies (
    name text,
    review text,
    id integer NOT NULL
);


--
-- Name: movies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.movies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: movies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.movies_id_seq OWNED BY public.movies.id;


--
-- Name: music; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.music (
    name text,
    url text,
    id integer NOT NULL
);


--
-- Name: music_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.music_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: music_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.music_id_seq OWNED BY public.music.id;


--
-- Name: musicals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.musicals (
    name text,
    review text,
    id integer NOT NULL
);


--
-- Name: musicals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.musicals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: musicals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.musicals_id_seq OWNED BY public.musicals.id;


--
-- Name: series; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.series (
    name text,
    review text,
    id integer NOT NULL
);


--
-- Name: series_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.series_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: series_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.series_id_seq OWNED BY public.series.id;


--
-- Name: words; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.words (
    content text,
    id integer NOT NULL
);


--
-- Name: words_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.words_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: words_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.words_id_seq OWNED BY public.words.id;


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages (
    id bigint NOT NULL,
    topic text NOT NULL,
    extension text NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

CREATE SEQUENCE realtime.messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: realtime; Owner: -
--

ALTER SEQUENCE realtime.messages_id_seq OWNED BY realtime.messages.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text
);


--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb
);


--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: books id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.books ALTER COLUMN id SET DEFAULT nextval('public.books_id_seq1'::regclass);


--
-- Name: feeds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feeds ALTER COLUMN id SET DEFAULT nextval('public.feeds_id_seq'::regclass);


--
-- Name: movies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movies ALTER COLUMN id SET DEFAULT nextval('public.movies_id_seq'::regclass);


--
-- Name: music id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.music ALTER COLUMN id SET DEFAULT nextval('public.music_id_seq'::regclass);


--
-- Name: musicals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.musicals ALTER COLUMN id SET DEFAULT nextval('public.musicals_id_seq'::regclass);


--
-- Name: series id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.series ALTER COLUMN id SET DEFAULT nextval('public.series_id_seq'::regclass);


--
-- Name: words id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.words ALTER COLUMN id SET DEFAULT nextval('public.words_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ALTER COLUMN id SET DEFAULT nextval('realtime.messages_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag) FROM stdin;
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
\.


--
-- Data for Name: books; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.books (name, url, id) FROM stdin;
永生的操练	https://read.tianheg.org/divine-comedy-comment-by-canxue	2
神曲	https://read.tianheg.org/divine-comedy	3
刘擎现代思想讲义	https://read.tianheg.org/liuqing-xiandai-sixiang-jiangyi	5
创新者	https://read.tianheg.org/the-innovators	6
追忆似水年华	https://read.tianheg.org/in-search-of-lost-time	7
Eloquent JavaScript	https://read.tianheg.org/eloquent-javascript	8
RESTful Best Practices	https://read.tianheg.org/restful-best-practices	9
Refactoring UI	https://read.tianheg.org/refactoring-ui	10
Resilient web design	https://read.tianheg.org/resilient-web-design	11
亲爱的三毛	https://read.tianheg.org/qinaide-sanmao	12
CSS: The Definitive Guide	https://read.tianheg.org/css-the-definitive-guide	13
CSS设计的禅意	https://read.tianheg.org/the-zen-of-css-design	14
The Definitive Guide to HTML5	https://read.tianheg.org/the-definitive-guide-html5	15
图解 HTTP	https://read.tianheg.org/tujie-http	16
如何成为一名程序员	https://read.tianheg.org/how-to-be-a-programmer	17
程序员修炼之道	https://read.tianheg.org/the-pragmatic-programmer	18
蒙田随笔全集	https://read.tianheg.org/essays-montaigne	19
美学、心理学和宗教信仰的演讲与对话集(1938—1946)	https://read.tianheg.org/lectures-and-conversations-on-aesthetics-psychology-and-religious-belief	20
吉米·哈利索引	https://read.tianheg.org/james-herriot	21
你是你吃出来的	https://read.tianheg.org/ni-shini-chichulai-de	22
格（杂志）	https://read.tianheg.org/ge-magazine	23
癌症密码	https://read.tianheg.org/cancer-code	24
MAKE：独立创客手册	https://read.tianheg.org/make-the-indie-maker-handbook	25
人的自我寻求	https://read.tianheg.org/mans-search-for-himself	26
芒格之道	https://read.tianheg.org/tao-of-munger	27
穷查理宝典	https://read.tianheg.org/poor-charlies-almanack	28
哑舍	https://read.tianheg.org/yashe	29
雪崩	https://read.tianheg.org/snow-crash	30
狂热分子	https://read.tianheg.org/true-believer	31
操作系统概念	https://read.tianheg.org/operating-system-concepts	32
操作系统导论	https://read.tianheg.org/operating-system-three-easy-pieces	33
挽救计划	https://read.tianheg.org/project-hail-mary	34
小偷家族	https://read.tianheg.org/xiaotou-jiazu	35
献给阿尔吉侬的花束	https://read.tianheg.org/flowers-for-algernon	36
只是为了好玩	https://read.tianheg.org/just-for-fun	37
索拉里斯星	https://read.tianheg.org/solaris	38
以鸟兽之名	https://read.tianheg.org/yiniaoshou-zhi-ming	39
寂寞的游戏	https://read.tianheg.org/jimo-de-youxi	40
钢铁是怎样炼成的	https://read.tianheg.org/how-the-steel-was-tempered	41
心理学与生活	https://read.tianheg.org/psychology-and-life	42
哲学的故事	https://read.tianheg.org/story-of-philosophy	43
窗边的小豆豆	https://read.tianheg.org/chuangbian-de-xiaodoudou	44
高效能人士的七个习惯	https://read.tianheg.org/the-7-habits-of-highly-effective-people	45
阿西莫夫索引	https://read.tianheg.org/asimov	46
如何阅读一本书	https://read.tianheg.org/how-to-read-a-book	47
史蒂夫·乔布斯传	https://read.tianheg.org/steve-jobs	48
黑客与画家	https://read.tianheg.org/hackers-and-painters	49
谈美	https://read.tianheg.org/tan-mei	50
那些忧伤的年轻人	https://read.tianheg.org/naxie-youshangde-nianqingren	51
查拉图斯特拉如是说	https://read.tianheg.org/thus-spoke-zarathustra	52
社会心理学	https://read.tianheg.org/social-psychology	53
道德经	https://read.tianheg.org/dao-de-jing	54
文化苦旅	https://read.tianheg.org/wenhua-kulv	55
借我一生	https://read.tianheg.org/jiewo-yisheng	56
心经	https://read.tianheg.org/xinjing	57
醉步男	https://read.tianheg.org/zui-bu-nan	58
看海的人	https://read.tianheg.org/kanhaide-ren	59
朝花夕拾	https://read.tianheg.org/zhaohua-xishi	60
毛姆索引	https://read.tianheg.org/maugham	61
爱你就像爱生命	https://read.tianheg.org/aini-jiuxiang-aishengming	62
天生有罪	https://read.tianheg.org/born-a-crime	63
读书随想录	https://read.tianheg.org/the-summing-up	64
极简个性心理学	https://read.tianheg.org/making-sence-of-people	65
牧羊少年奇幻之旅	https://read.tianheg.org/o-alquimista	66
爱因斯坦自述	https://read.tianheg.org/einstein-himself	67
克拉拉与太阳	https://read.tianheg.org/klara-and-the-sun	68
什锦拼盘	https://read.tianheg.org/shijin-pinpan	69
拉多之星	https://read.tianheg.org/la-duo-zhi-xing	70
我生有涯愿无尽	https://read.tianheg.org/wo-shengyouya-yuanwujin	71
时间之书	https://read.tianheg.org/shijian-zhi-shu	72
未来世界的幸存者	https://read.tianheg.org/weilai-shijie-de-xingcunzhe	73
刘慈欣索引	https://read.tianheg.org/liucixin	74
一九八四	https://read.tianheg.org/nineteen-eighty-four	75
看见	https://read.tianheg.org/kanjian	76
不迷茫手册	https://read.tianheg.org/bumimang-shouce	77
过于喧嚣的孤独	https://read.tianheg.org/too-loud-a-solitude	78
你的第一本哲学书	https://read.tianheg.org/what-does-it-all-mean	79
遥远的救世主	https://read.tianheg.org/yaoyuande-jiushizhu	80
网络小说	https://read.tianheg.org/wangluo-novels	81
New Book: Wh	http://example.xyz	83
Techno Feudalism	https://read.tianheg.org/techno-feudalism	1
The Little Prince	https://read.tianheg.org/the-little-prince	4
呼啸山庄	http://localhost:3001/books	84
\.


--
-- Data for Name: feeds; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.feeds (rss, url, description, title, id) FROM stdin;
	http://whyes.org/	肝癌	whyes 的博客	1
https://mvread.blog/feed	https://mvread.blog/	这个人和评论尸一样喜欢写长文，很喜欢。读了他的《互联网公司变平庸的原因：不够爱国》	最小可读 - 基本无害，可能有用	2
https://1q43.blog/feed	https://1q43.blog/	这个人写文章写得长又好，他写的《互联网与中国后现代性呓语》、《垄断的困境》都读过	虹线 - 评论尸的自留地	3
	https://juntao-qiu.medium.com/	这个人是个React专家，他写的关于前端开发的文章值得一读，他的NewsLetter：https://juntao.substack.com/	Juntao Qiu	4
https://idlewords.com/index.xml	https://idlewords.com/	这个人写了篇对NASA新登月计划——Artemis campaign（阿耳忒弥斯计划）的文章	Idle Words - brevity is for the weak	5
	https://www.mewho.com/	这个人做了好几个关于太空的项目，有Star Trek，DoctorWho，还有 NASA 相关的	meWho	6
https://world.hey.com/dhh/feed.atom	https://world.hey.com/dhh	知道这个人很久了，是 Ruby on Rails 的作者	DHH	7
https://sive.rs/en.atom	https://sive.rs/	一位学习的榜样，学习他对生活、技术的态度，学习他思考世界的方法。他建立了/now页面 https://nownownow.com/	Derek Sivers	8
https://changelog.com/podcast/feed	https://changelog.com/podcast/	唯一常听的技术博客，《软件那些事儿》栋哥推荐	Changelog podcast	9
https://scottaaronson.blog/?feed=rss2	https://scottaaronson.blog/	The Blog of Scott Aaronson	Shtetl-Optimized	10
https://www.scotthyoung.com/blog/feed/	https://www.scotthyoung.com/	学习如何学习	Scott H. Young	11
https://3blue1brown.substack.com/feed	https://www.3blue1brown.com/	Mathematics with a distinct visual perspective. Linear algebra calculus neural networks topology and more.	3Blue1Brown	12
https://liuyandong.com/feed	https://liuyandong.com/	《软件那些事儿》播客主播，很喜欢他讲的关于软件的故事	栋哥的赛博空间 – 成一家之言，毕竟有言胜于无	13
	https://www.hubermanlab.com/	第一印象是关于科学与生活健康的	Huberman Lab	14
	https://lexfridman.com/	这个人会和很多人进行长时间的对谈，听说很有价值，但因为太长不太有动力听完更不用说理解了	Lex Fridman	15
	https://www.stephenwolfram.com/	数学	Stephen Wolfram: Official Website	16
	https://ruanyf-weekly.plantree.me/	不错的使用vitepress的方法	科技爱好者周刊（Vitepress version）	17
https://github.blog/changelog/label/copilot/feed/	https://github.blog/changelog/label/copilot/	GitHub blog上和Copilot相关的内容	copilot Archives - The GitHub Blog	18
	https://www.oaktreecapital.com/insights/memos	读过他的这篇 https://www.oaktreecapital.com/insights/memo/the-illusion-of-knowledge 做了些笔记	Memos from Howard Marks	19
https://wanqian.blog/feed/	https://wanqian.blog/	这个人用最朴实的文字记录自己的日常，喜欢！	万千笔记	20
https://pointieststick.com/feed/	https://pointieststick.com/	这个人是KDE的开发者，对2024-02-28发布的KDEv6很激动！	Adventures in Linux and KDE	21
	https://mtlynch.io/	这个人一开始认识他，是因为他发了一篇文章，讲述自己花了很多时间金钱升级网站，结果没有令他满意 https://mtlynch.io/tinypilot-redesign/	mtlynch.io	22
https://xlrocket.blog/feed/	https://xlrocket.blog/	最近买了iPad，读Ta的文章学到很多使用iPad的技巧	效率火箭，火箭君的新博客 – 高效搞定事情，尽情享受生活	23
	https://cn.govopendata.com/	新闻联播、人民日报、参考消息、裁判文书	公共数据开放平台	24
https://www.vincentntang.com/rss.xml	https://www.vincentntang.com/	喜欢这个人的思考的话语，能给我带来些许启发：世界并不总是黑白分明	Vincent Tang – Web developer & writer	25
	https://scz.617.cn/	有意思，用txt文件写博客，而且还用frame嵌入，无论点击哪篇博文，地址栏的地址都不会改变	青衣十三楼	26
	https://immersivetranslate.com/docs/sites/	一些高质量内容的索引	探索互联网上高质量的内容	27
	https://ourworldindata.org/	Data	Our World in Data	28
http://feeds.feedburner.com/collabfund	https://collabfund.com/blog/	If you find something that is true in more than one field you’ve probably uncovered something particularly important.	Little Ways The World Works · Collab Fund	29
https://bearblog.dev/discover/feed/?type=rss	https://bearblog.dev/discover/	Discover articles and blogs on Bear	Trending | Bear Blog	30
	https://www.readsomethinginteresting.com/	随机展示文章	Read Something Interesting	31
	https://readsomethingwonderful.com/	随机	Read Something Wonderful	32
	https://muqix.github.io/	读到《<致埃文汉森>，致隐形人》	木槭 | immuqi	33
https://mengru.space/data/full-rss.xml	https://mengru.space/	很喜欢她的每周记录，喜欢这样的记录生活	Mengru的空间	34
https://gregueria.icu/index.xml	https://gregueria.icu/	Hope my veins will bleed out of beautiful words.	再會，謝謝所有的魚 — Thanks for all the fish	35
https://tianxianzi.me/atom.xml	https://tianxianzi.me/	灵性; 自我	天仙子	36
	https://www.sashatran.com/	CSS	Sasha Tran	37
https://stephenleng.com/feed/	https://stephenleng.com/	心理学; 爱情	心的道理 — “心自有其道理，非理智所能知晓……我们不仅通过理智，而且通过心来认识真理。”——帕斯卡	38
https://4311346.com/index.xml	https://4311346.com/	生活	Andy烧麦 - 成熟，聪明，豁达的人什么也不问 过去，现在，将来…	39
https://www.mhcf.net/rss.php	https://www.mhcf.net/	生活; 恋爱	梦幻辰风 - 壹个永恒的部落格	40
https://hayami.typlog.io/feed.xml	https://hayami.typlog.io/	爱情	hayami's blog	41
https://blog.nightly.mozilla.org/feed/	https://blog.nightly.mozilla.org/	Firefox nightly	Firefox Nightly News	42
https://sogola.com/index.xml	https://sogola.com/	哲学思考	王小嗨的不老歌	43
https://qydzz.cn/feed/	https://qydzz.cn/	生活	七月的栀子	44
https://elizen.me/index.xml	https://elizen.me/	生活	Elizen	45
	https://slykiten.com/	生活; 出国	狡猫三窝 – “美”不是一种外部标准，它是一种内在情感。那是爱。	46
http://mindhacks.cn/feed/	http://mindhacks.cn/	成长; 思考	刘未鹏 | Mind Hacks – 思维改变生活	47
http://iyoubo.com:800/feed/	http://iyoubo.com:800/	生活	青木的博客 – 青木和安妮的生活感悟和记录	48
https://2cat.net/feed/	https://2cat.net/	生活	猫鱼的小窝 – 2Cat.Net	49
https://www.juroku.net/feed	https://www.juroku.net/	生活	致郁系	50
https://www.zhuiyibai.cn/blog/feed/	https://www.zhuiyibai.cn/blog/	生活	追忆白	51
https://feng.pub/feed	https://feng.pub/	阅读	阿锋的小宇宙	52
https://lhcy.org/feed	https://lhcy.org/	苦难	林海草原 – 愿我经历的苦难你不要经历，愿我已有的幸福你触手可及	53
https://hiwannz.com/feed	https://hiwannz.com/	产品	见字如面 - 抽离自我，冷眼旁观	54
https://tumutanzi.com/feed	https://tumutanzi.com/	生活	土木坛子 – 和光同尘，与时舒卷	55
https://catcoding.me/atom.xml	https://catcoding.me/	技术成长	程序员的喵	56
https://limboy.me/index.xml	https://limboy.me/	创造	Limboy	57
https://blog.gotocoding.com/feed	https://blog.gotocoding.com/	技术	重归混沌的BLOG	58
https://mercurychong.blogspot.com/feeds/posts/default	https://mercurychong.blogspot.com/	生活思考	知足常乐-水星投资理财的基本意念	59
https://www.ixiqin.com/feed/	https://www.ixiqin.com/	开源社	白宦成	60
	http://blog.farmostwood.net	文章动人	木遥	61
https://fxdx.dev/feed/	https://fxdx.dev/	技术	Firefox Developer Experience	62
https://ciechanow.ski/atom.xml	https://ciechanow.ski/	3D bike	Bartosz Ciechanowski	63
https://chinadigitaltimes.net/chinese/feed	https://chinadigitaltimes.net/chinese/	新闻; 真相	中国数字时代	64
https://planet.kde.org/index.xml	https://planet.kde.org/	KDE	Planet KDE	65
https://developer.mozilla.org/en-US/blog/rss.xml	https://developer.mozilla.org/en-US/blog/	Web	MDN blog	66
https://weekly.tw93.fun/rss.xml	https://weekly.tw93.fun/	工具; 讯息	潮流周刊	67
https://lea.verou.me/feed/	https://lea.verou.me/	Web; 厉害的女程序员	Lea Verou	68
http://www.qncd.com/?feed=rss2	http://www.qncd.com/	生活	尺宅杂记	69
https://www.joshwcomeau.com/rss.xml	https://www.joshwcomeau.com/	CSS	Josh W Comeau	70
https://blog.jim-nielsen.com/feed.xml	https://blog.jim-nielsen.com/	CSS	Jim Nielsen	71
https://jakearchibald.com/posts.rss	https://jakearchibald.com/	Web	Jake Archibald	72
https://chriscoyier.net/feed/	https://chriscoyier.net/	CSS	Chris Coyier	73
https://css-irl.info/rss.xml	https://css-irl.info/	CSS	CSS{ In Real Life}	74
http://ishadeed.com/feed.xml	https://ishadeed.com/	CSS	Ahmad Shadeed	75
https://css.oddbird.net/feed.xml	https://css.oddbird.net/	CSS notes	Miriam Suzanne's notes(CSS Working Group and Sass language)	76
https://una.im/rss.xml	https://una.im/	CSS; Design	Una Kravets	77
	https://www.newsminimalist.com/	News by AI	News Minimalist	78
	https://stevejobsarchive.com/	Steve Jobs	Steve Jobs Archive	79
https://www.taoweng.site/rss.xml	https://www.taoweng.site/	浏览器渲染	桃翁	80
https://shoptalkshow.com/feed/podcast	https://shoptalkshow.com/	Podcast; Website	ShopTalk Show	81
	https://mathiasbynens.be/	JavaScript	Mathias	82
	https://www.samanthaming.com/	CSS; JavaScript	Samantha	83
https://lynnandtonic.com/feed.xml	https://lynnandtonic.com/	CSS; Design	Lynn Fisher	84
	https://github.com/521xueweihan/HelloGitHub	项目	HelloGitHub|月刊	85
https://zenhabits.net/feed/	https://zenhabits.net/	生活; 冥想	Zen Habits	86
https://nav.al/archive/feed/	https://nav.al/	投资; 思考	Naval	87
https://soulteary.com/feed/	https://soulteary.com/	Programmer	苏洋博客	88
https://emacstalk.codeberg.page/podcast/index.xml	https://emacstalk.codeberg.page/	Emacs	Emacs Talk	89
https://waitbutwhy.com/feed	https://waitbutwhy.com/	Life; Stories	Wait But Why	90
https://yuanchuan.dev/feed.xml	https://yuanchuan.dev/	Art; <css-doodle />	yuanchuan	91
https://litterhougelangley.club/blog/feed/	https://litterhougelangley.club/blog/	Linux	LitterHouge	92
	https://chuan.us/	投资; 科技	硅谷王川	93
https://www.owenyoung.com/atom.xml	https://www.owenyoung.com/	沉浸式双语网页翻译扩展 Immersive translate 作者	Owen的博客	94
https://shuiba.co/feed	https://shuiba.co/	生活	水八口的冥想盆	95
https://www.dailyartmagazine.com/feed/	https://www.dailyartmagazine.com/	艺术	DailyArt Magazine	96
https://guanqr.com/rss.xml	https://guanqr.com/	生活; 思想; 技术	荷戟独彷徨	97
https://www.freecodecamp.org/news/rss/	https://www.freecodecamp.org/news/	CSS; JavaScript	fCC news	98
https://hnrss.org/best	https://news.ycombinator.com/best	技术	Hacker News Best	99
https://anyway.fm/rss.xml	https://anyway.fm/	播客; 设计	Anyway.FM	100
https://yixiuer.me/atom.xml	https://yixiuer.me/	哲学; 思想	一休儿的哲学博客	101
https://io-oi.me/atom.xml	https://io-oi.me/	技术; 生活	reuixiy	102
https://yihui.org/cn/index.xml	https://yihui.org/cn/	读书笔记; 思想	谢益辉的中文日志	103
https://www.yangzhiping.com/feed.xml	https://www.yangzhiping.com/	认知科学	阳志平的网志	104
http://www.aaronsw.com/2002/feeds/pgessays.rss	https://www.paulgraham.com/	《黑客与画家》作者	Paul Graham	105
https://sachachua.com/blog/feed	https://sachachua.com/blog/	Emacs	Living an awesome life	106
	https://dirtysalt.github.io/html/blogs.html	Orgmode	An Amateur Programmer's Blogs	107
https://blog.binchen.org/rss.xml	https://blog.binchen.org/	Emacs	陈斌（Emacs）	108
https://lobste.rs/rss	https://lobste.rs/	Like HN; but focus on computing	Lobsters	109
https://css-tricks.com/feed/	https://css-tricks.com/	CSS; JavaScript	CSS-Tricks	110
https://www.smashingmagazine.com/feed/	https://www.smashingmagazine.com/	CSS; JavaScript; Vue; andsoon	Smashing Magazine	111
https://www.producthunt.com/feed	https://www.producthunt.com/	bestnewproducts	ProductHunt	112
https://silverrainz.me//blog/atom.xml	https://silverrainz.me/	向Ta学习; Sphinx笔记系统	银色子弹	113
https://pythonhunter.org/episodes/feed.xml	https://pythonhunter.org/episodes/	播客; Python	捕蛇者说	114
https://corecursive.com/feed	https://corecursive.com/	播客; 技术	CoRecursive	115
https://aeon.co/feed.rss	https://aeon.co/	思想	Aeon	116
https://nextdraft.com/feed/	https://nextdraft.com/	新闻	NextDraft	117
https://conge.livingwithfcs.org/feed.xml	https://conge.livingwithfcs.org/	生活	Conge	118
https://www.joelonsoftware.com/feed/	https://www.joelonsoftware.com/	推荐	Joel on Software(Joel Spolsky)	119
https://nautil.us/rss/all	https://nautil.us/	科技; 生物; 文化	Nautilus	120
https://v2ex.com/index.xml	https://v2ex.com/	技术论坛	v2ex	121
https://feeds.feedburner.com/2ality	https://2ality.com	JavaScript	Dr. Axel Rauschmayer	122
https://www.kawabangga.com/feed	https://www.kawabangga.com/	Python	卡瓦邦噶！	123
	https://when-then-zen.christine.website/	meditation	When Then Zen	124
	https://www.zhangjiee.com/	技术; 思考	JerryZhang's Blog	125
https://antfu.me/feed.xml	https://antfu.me/	Open Sourcer	Anthony Fu	126
https://raghu.cc/feed.xml	https://raghu.cc/	哲学	Knowledge Continuum	127
https://draveness.me/feed.xml	https://draveness.me/	系统设计; 思考	面向信仰编程	128
https://jhuo.ca/index.xml	https://jhuo.ca/	互联网历史	霍炬的网站	129
https://perell.com/feed/	https://perell.com/	写作	David Perell	130
https://blog.ryey.icu/feeds/atom.xml	https://me.ryey.icu/	Arch User	@renyuneyun - Rui Zhao	131
https://blog.t9t.io/atom.xml	https://blog.t9t.io	创业; 编程; 开源	透明创业实验	132
http://feeds.feedburner.com/ruanyifeng	https://www.ruanyifeng.com/blog/	创业; 编程; 前端	阮一峰的网络日志	133
http://coolshell.cn/feed	https://coolshell.cn	编程	酷 壳 – CoolShell	134
https://www.zhangxinxu.com/wordpress/feed/	https://www.zhangxinxu.com/	编程; 前端	张鑫旭-鑫空间-鑫生活	135
https://diygod.cc/feed	https://diygod.cc	编程; 开源	DIYGod - 写代码是热爱，写到世界充满爱!	136
http://blog.codingnow.com/atom.xml	https://blog.codingnow.com	编程	云风的 BLOG	137
https://www.phodal.com/blog/feeds/rss/	https://www.phodal.com	编程	全栈应用开发:精益实践	138
https://blog.lilydjwg.me/posts.rss	https://blog.lilydjwg.me	编程	依云's Blog	139
https://greatdk.com/feed	https://greatdk.com	编程; 创业（面包多）	王登科-DK博客	140
http://chinese.catchen.me/feeds/posts/default	https://chinese.catchen.me	编程	Cat in Chinese	141
https://lutaonan.com/rss.xml	https://lutaonan.com	编程	Randy's Blog	142
https://immmmm.com/atom.xml	https://immmmm.com	编程; 生活	林小沐	143
https://hfdavidyu.com/feed/	https://hfdavidyu.com	物理	余海峯 David 物理喵 phycat	144
https://feeds.feedburner.com/othree	https://blog.othree.net	编程; 那篇讲猫咪的故事打动了我	O3noBLOG	145
https://geekplux.com/feed.xml	https://geekplux.com	编程	GeekPlux	146
https://jysperm.me/atom.xml	https://jysperm.me	编程	王子亭的博客	147
https://personalexcellence.co/self-improvement/feed/	https://personalexcellence.co/	Self improvement	Personal Excellence	148
https://meyerweb.com/eric/thoughts/feed/	https://meyerweb.com/	CSS	Eric A. Meyer	149
https://www.bmpi.dev/index.xml	https://www.bmpi.dev/	Hugo; 编程; 写作	构建我的被动收入	150
https://1byte.io/rss.xml	https://1byte.io/	LeanCloud 的联合创始人和 CEO	1 Byte	151
	https://gwern.net/	网站给我一种纽约时报的感觉	Gwern Branwen	152
\N	https://itxiaozhang.com/	这个人会在博客里写日记，很喜欢阅读这样的生活文字	IT小章	153
\.


--
-- Data for Name: movies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.movies (name, review, id) FROM stdin;
醉拳 1978	黄飞鸿青年不好学，受辱后奋发，向苏乞儿学武，感其心诚，教其醉拳	1
风雨双流星 1976	武打动作很精彩，不错	2
“炼”爱	this is the review	3
周处除三害 in 2023	一个想要出名的杀人犯，先后杀了两个通缉犯，杀人与被杀界限在哪里？死了没人记得也挺好，不然死了都不安生:)	4
Jack Reacher & Jack Reacher: Never Go Back 侠探杰克 in 2012&2016	挺喜欢这种破解谜题的，不过看的是新鲜感，如果反复看就没有乐趣了	5
Waterworld 未来水世界 in 1995	拍得不错，男女主生活在帆船上竟然有种《猩球崛起》的感觉。这种水淹没陆地的幻想，在刘慈欣的小说《超新星爆发》里见过	6
Con Air 空中监狱 by Nicolas Cage	this is the review	7
Oliver Twist 雾都孤儿	this is the review	8
Indiana Jones and the Dial of Destiny 夺宝奇兵5：命运转盘	this is the review	9
たまこラブストーリー 玉子爱情故事	this is the review	10
キャロル&チューズデイ Carole & Tuesday	this is the review	11
ゆるキャン△ SEASON 2 摇曳露营△ 第二季	this is the review	12
ゆるキャン△ 摇曳露营△ Yuru Camp / Laid-Back Camp	this is the review	13
ぼっち・ざ・ろっく！ 孤独摇滚！ Bocchi the Rock!	this is the review	14
Pantheon 万神殿 Season 1	this is the review	15
四月は君の嘘 四月是你的谎言 Your Lie in April	this is the review	16
けいおん! 轻音少女 第一，二季 K-On!	this is the review	17
リーガル・ハイ 胜者即是正义1&2	this is the review	18
俺の話は長い 我的事说来话长	this is the review	19
八角笼中	this is the review	20
다음 소희 下一个素熙	this is the review	21
John Wick: Chapter 4 疾速追杀4	this is the review	22
波よ聞いてくれ 听我的电波吧2023    很棒的电视剧，这个主角很有意思，发现自己喜欢上了这种说话速度很快的日剧	this is the review	23
アンナチュラル 非自然死亡	this is the review	24
John Wick 疾速追杀	this is the review	25
Ice Age: Collision Course 冰川时代5：星际碰撞	this is the review	26
Ice Age: Continental Drift 冰川时代4：大陆漂移	this is the review	27
Ice Age: Dawn of the Dinosaurs 冰川时代3：恐龙的黎明	this is the review	28
Ice Age: The Meltdown 冰川时代2：融冰之灾	this is the review	29
Ice Age 冰川时代1	this is the review	30
The Hitchhiker's Guide to the Galaxy	this is the review	31
Sense8 Season 2(10 episodes)	this is the review	32
Sense8 Season 1(12 episodes)	this is the review	33
家庭教师 家庭教師ヒットマンREBORN!	this is the review	34
Ant-Man and the Wasp: Quantumania	this is the review	35
Star Trek: Picard 3	this is the review	36
Star Wars: The Mandalorian 3 曼达洛人第三季	this is the review	37
Sherlock Season 4   Amanda Abbington 饰演的华生妻子Mary令我印象深刻	this is the review	38
Sherlock Season 3	this is the review	39
Sherlock Season 2	this is the review	40
Sherlock Season 1	this is the review	41
2020	this is the review	42
Avatar: The Way of Water 阿凡达2：水之道	this is the review	43
ブラッシュアップライフ 重启人生 Brush Up Life	this is the review	44
Black Panther: Wakanda Forever 黑豹2：瓦坎达永存	this is the review	45
Puss in Boots: The Last Wish 穿靴子的猫2：最后的愿望	this is the review	46
The Last of Us	this is the review	47
深海动画	this is the review	48
2022	this is the review	49
Top Gun	this is the review	50
轻音少女 剧场版	this is the review	51
TARI TARI	this is the review	52
食戟之灵 第 1,2,3,4,5 季 + OAD	this is the review	53
天才不能承受之重 The Unbearable Weight of Massive Talent	this is the review	54
西部世界 第四季 Westworld Season 4	this is the review	55
心理测量者 PSYCHO-PASS サイコパス 第一季	this is the review	56
Cloud Atlas 云图	this is the review	57
轻松小熊和小薰 电影	this is the review	58
希尔达 第二季 Hilda Season 2	this is the review	59
希尔达 第一季 Hilda Season 1	this is the review	60
神奇侠侣 小时候看过，挺不错	this is the review	61
摩登如来神掌 王祖贤很美	this is the review	62
千王之王2000 电影不好看，“初恋”挺漂亮	this is the review	63
扬名立万	this is the review	64
圣刃＋全开者 超级英雄战记 セイバー＋ゼンカイジャー スーパーヒーロー戦記	this is the review	65
北好莱坞 North Hollywood	this is the review	66
假偶天成 电影版 เพราะเราคู่กัน 第一次看的时候立刻劝退，第二次终于看完，惊讶于父母对儿子喜欢同性的平淡	this is the review	67
Jungle 丛林	this is the review	68
A Son(Original title: Bik Eneich: Un fils	this is the review	69
RRR (Rise Roar Revolt)	this is the review	70
神盾局特工 第六七季(未看视频，仅读文字简介)	this is the review	71
神盾局特工 第五季	this is the review	72
神盾局特工 第四季	this is the review	73
神盾局特工 第三季	this is the review	74
神盾局特工 第二季	this is the review	75
拉瑞·克劳 Larry Crowne	this is the review	76
极地特快 The Polar Express 圣诞老人的故事！	this is the review	77
菲利普船长 Captain Phillips	this is the review	78
特别响，非常近 Extremely Loud and Incredibly Close	this is the review	79
圆圈 The Circle	this is the review	80
天使与魔鬼 Angels & Demons	this is the review	81
达·芬奇密码 The Da Vinci Code	this is the review	82
荒岛余生 Cast Away	this is the review	83
幸福终点站 The Terminal	this is the review	84
拯救大兵瑞恩 Saving Private Ryan	this is the review	85
芬奇 Finch	this is the review	86
侏罗纪世界3 Jurassic World: Dominion	this is the review	87
海兽猎人 The Sea Beast	this is the review	88
黑袍纠察队 第三季	this is the review	89
奇奇与蒂蒂：救援突击队 Chip 'n' Dale: Rescue Rangers	this is the review	90
天气预报员 The Weather Man	this is the review	91
楼上的外星人	this is the review	92
地心历险记	this is the review	93
预见未来 Next at 2007	有意思的设定，没想到最后竟然揭示：可以预测那么长时间	94
黑袍纠察队 第二季	this is the review	95
黑袍纠察队 第一季	this is the review	96
曼达洛人 第二季	this is the review	97
人生切割术 第一季	this is the review	98
星际迷航：奇异新世界	this is the review	99
初恋这件小事	this is the review	100
互联网之子：亚伦·斯沃兹的故事	this is the review	101
操作系统革命	this is the review	102
瑞克和莫蒂 第五季	this is the review	103
瑞克和莫蒂 第四季	this is the review	104
瑞克和莫蒂 第三季	this is the review	105
瑞克和莫蒂 第二季	this is the review	106
瑞克和莫蒂 第一季	this is the review	107
快餐车	this is the review	108
命硬仔西罗 The Immortal	this is the review	109
替身演员 The Valet	this is the review	110
Hello！树先生	this is the review	111
伞学院 第二季	this is the review	112
伞学院 第一季	this is the review	113
像素大战	this is the review	114
西游记之大圣归来	this is the review	115
海滩游侠 挺好的娱乐电影，剧情简单	this is the review	116
爱，死亡和机器人第三季 吉巴罗血水震撼	this is the review	117
爱，死亡和机器人第二季	this is the review	118
爱，死亡和机器人第一季 冰河时代不错（时间、战争）	this is the review	119
冲向天外天 Explorers 很不错，激发孩子关于宇宙的想象力	this is the review	120
机动战士高达 THE ORIGIN Ⅵ 赤色彗星诞生 機動戦士ガンダム THE ORIGIN Ⅵ 誕生 赤い彗星	this is the review	121
机动战士高达 THE ORIGIN Ⅴ 激战 鲁姆会战 機動戦士ガンダム THE ORIGIN Ⅴ 激突 ルウム会戦	this is the review	122
机动战士高达 THE ORIGIN Ⅳ 命运前夜 機動戦士ガンダム THE ORIGIN Ⅳ 運命の前夜	this is the review	123
机动战士高达 THE ORIGIN Ⅲ 破晓起义 機動戦士ガンダム THE ORIGIN Ⅲ 暁の蜂起	this is the review	124
机动战士高达 THE ORIGIN Ⅱ 悲伤的阿尔黛西亚 機動戦士ガンダム THE ORIGIN Ⅱ 哀しみのアルテイシア	this is the review	125
机动战士高达 THE ORIGIN Ⅰ 青瞳的卡斯巴尔 機動戦士ガンダム THE ORIGIN Ⅰ 青い瞳のキャスバル 以前看过	this is the review	126
55步 改变医院对病人的治疗方式	this is the review	127
猫狗大战 讲到人类与狗的关系	this is the review	128
快乐的大脚2 挺好玩的	this is the review	129
奇迹·笨小孩	this is the review	130
第二十二条军规	this is the review	131
月球旅行记	this is the review	132
傲慢与偏见与僵尸	this is the review	133
美少女特工队	this is the review	134
猫（音乐剧）	this is the review	135
老友记重聚特辑	this is the review	136
老友记 第十季	this is the review	137
老友记 第九季	this is the review	138
老友记 第八季	this is the review	139
老友记 第七季	this is the review	140
老友记 第六季	this is the review	141
老友记 第五季	this is the review	142
老友记 第四季	this is the review	143
老友记 第三季	this is the review	144
黑客帝国 4：矩阵重启	this is the review	145
老友记 第二季	this is the review	146
帝国的毁灭	this is the review	147
蒂凡尼的早餐 Breakfast at Tiffany's	this is the review	148
潘神的迷宫 El laberinto del fauno	this is the review	149
神秘博士第十二季	this is the review	150
神秘博士：戴立克的前夜	this is the review	151
神秘博士元旦特辑：戴立克的革命	this is the review	152
神秘博士第十一季	this is the review	153
最后的城堡	this is the review	154
穿靴子的猫	this is the review	155
Bordertown 女性被男性强奸，杀害，华尔兹	this is the review	156
无人看护	this is the review	157
灵笼第一季	this is the review	158
烟花（日本动漫）	this is the review	159
无间道 3	this is the review	160
无间道 2	this is the review	161
古墓丽影 2	this is the review	162
古墓丽影	this is the review	163
思维空间	this is the review	164
史密斯夫妇	this is the review	165
帕丁顿熊 2	this is the review	166
警察学校	this is the review	167
时空急转弯	this is the review	168
三个老枪手	this is the review	169
扎克·施奈德版正义联盟	this is the review	170
老友记 第一季	this is the review	171
西部往事	this is the review	172
黄昏双镖客	this is the review	173
黄金三镖客	this is the review	174
荒野大镖客	this is the review	175
太空牛仔 Space Cowboys	this is the review	176
无罪谋杀：科林尼案 Der Fall Collini	this is the review	177
狼行者 Wolfwalkers	this is the review	178
贱女孩 Mean Girls	this is the review	179
失控玩家	this is the review	180
亚当斯一家 The Addams Family	this is the review	181
007：无暇赴死 No Time to Die（爽片就是如此，这届 007 该退休了）	this is the review	182
四海（很一般）	this is the review	183
半个喜剧	this is the review	184
挪威的森林 ノルウェイの森（音乐的戛然而止）	this is the review	185
动物园看守 Zookeeper	this is the review	186
钢之炼金术师	this is the review	187
2021	this is the review	188
穿条纹睡衣的男孩 The Boy in the Striped Pajamas	this is the review	189
崖上的波妞 崖の上のポニョ	this is the review	190
疯狂的麦克斯 3 Mad Max Beyond Thunderdome	this is the review	191
疯狂的麦克斯 2 Mad Max2	this is the review	192
疯狂的麦克斯 Mad Max	this is the review	193
夺宝奇兵 4 Indiana Jones and the Kingdom of the Crystal Skull	this is the review	194
夺宝奇兵 3 Indiana Jones and the Last Crusade	this is the review	195
夺宝奇兵 2 Indiana Jones and the Temple of Doom	this is the review	196
夺宝奇兵 Raiders of the Lost Ark	this is the review	197
超时空要塞：可曾记得爱	this is the review	198
新神榜：哪吒重生	this is the review	199
白蛇 2：青蛇劫起	this is the review	200
雪人奇缘	this is the review	201
触不可及（美版）The Upside	this is the review	202
遗愿清单 The Bucket List	this is the review	203
鸟人 Birdman or (The Unexpected Virtue of Ignorance)	this is the review	204
起风了 風立ちぬ	this is the review	205
007：俄罗斯之恋 From Russia with Love	this is the review	206
007：霹雳弹 Thunderball	this is the review	207
007：雷霆谷 You Only Live Twice	this is the review	208
007：女王密使 On Her Majesty's Secret Service	this is the review	209
007：永远的钻石 Diamonds Are Forever	this is the review	210
007：你死我活 Live and Let Die	this is the review	211
007：金枪人 The Man with the Golden Gun	this is the review	212
007: 海底城 The Spy Who Loved Me	this is the review	213
007: Moonraker	this is the review	214
007: For Your Eyes Only	this is the review	215
007: Octopussy	this is the review	216
007: A View to a Kill	this is the review	217
007: The Living Daylights	this is the review	218
007: Licence to Kill	this is the review	219
007: GoldenEye	this is the review	220
007: Tomorrow Never Dies	this is the review	221
007: The World Is Not Enough	this is the review	222
007: Casino Royale	this is the review	223
007: Spectre	this is the review	224
007: Skyfall	this is the review	225
赌神 2	this is the review	226
赌神	this is the review	227
Ghost in the Shell: Stand Alone Complex 攻壳机动队 2nd	this is the review	228
Ghost in the Shell: Stand Alone Complex 攻壳机动队 1st	this is the review	229
ノラガミ 野良神	this is the review	230
ノラガミ ARAGOTO 野良神第 2 季	this is the review	231
Tom and Jerry: The Movie 猫和老鼠 1992 电影版	this is the review	232
Wonder Woman 神奇女侠	this is the review	233
太阳照常升起	this is the review	234
Tout en haut du monde 漫漫北寻路	this is the review	235
魁拔之大战元泱界 2	this is the review	236
夜明け告げるルーのうた 宣告黎明的露之歌	this is the review	237
名探偵コナン 瞳の中の暗殺者 名侦探柯南：瞳孔中的暗杀者	this is the review	238
海角七号	this is the review	239
The Island 逃出克隆岛	this is the review	240
夏目友人帳 石起こしと怪しき来訪者 夏目友人帐：唤石者与怪异的访客	this is the review	241
The Divergent Series: Allegiant 分歧者 3：忠诚世界	this is the review	242
Insurgent 分歧者 2：绝地反击	this is the review	243
Divergent 分歧者：异类觉醒	this is the review	244
大腕	this is the review	245
USS Indianapolis: Men of Courage 印第安纳波利斯号：勇者无惧	this is the review	246
不能说的秘密	this is the review	247
Young Goethe in Love 少年歌德之烦恼	this is the review	248
Jerry Seinfeld: 23 Hours to Kill 杰里·宋飞：23 小时找乐子	this is the review	249
Fantastic Beasts: The Crimes of Grindelwald 神奇动物：格林德沃之罪	this is the review	250
Dr. Strangelove 奇爱博士	this is the review	251
The Shining 闪灵	this is the review	252
生生	this is the review	253
84 Charing Cross Road 查令十字街 84 号	this is the review	254
头文字 D	this is the review	255
Chef Flynn 少年厨神	this is the review	256
Apollo 11 阿波罗 11 号	this is the review	257
李米的猜想	this is the review	258
Westworld Season 3	this is the review	259
Westworld Season 2	this is the review	260
Westworld Season 1	this is the review	261
拆弹专家 2	this is the review	262
Shortwave 短波	this is the review	263
扫黑·决战	this is the review	264
Gone with the Wind 乱世佳人	this is the review	265
Detachment 超脱	this is the review	266
Fantasia 2000 幻想曲 2000	this is the review	267
妙先生	this is the review	268
Wild Wild West 飙风战警	this is the review	269
Fantastic Beasts and Where to Find Them 神奇动物在哪里	this is the review	270
算死草	this is the review	271
天下无贼	this is the review	272
劇場版 あの日見た花の名前を僕達はまだ知らない。 未闻花名剧场版	this is the review	273
孤独のグルメ孤独的美食家 Season2	this is the review	274
10 Cloverfield Lane 科洛弗道 10 号	this is the review	275
Birds of Prey: And the Fantabulous Emancipation of One Harley Quinn	this is the review	276
Suicide Squad	this is the review	277
唐人街探案 3	this is the review	278
La La Land 爱乐之城	this is the review	279
囧妈	this is the review	280
风中有朵雨做的云	this is the review	281
名探偵コナン 世紀末の魔術師	this is the review	282
妖猫传	this is the review	283
Watchmen 守望者	this is the review	284
名探偵コナン 紺青の拳	this is the review	285
唐人街探案 2	this is the review	286
Fantastic Beasts and Where to Find Them	this is the review	287
夏目友人帳 いつかゆきのひに 曾几何时下雪之日	this is the review	288
夏目友人帳 ニャンコ先生とはじめてのおつかい 猫咪老师与初次跑腿	this is the review	289
The Great Train Robbery 火车大劫案	this is the review	290
猫の恩返し 猫的报恩	this is the review	291
はたらく細胞!! 工作细胞 第二季	this is the review	292
Shaun of the Dead 僵尸肖恩	this is the review	293
はたらく細胞 工作细胞	this is the review	294
Soul 心灵奇旅	this is the review	295
The Conjuring 招魂	this is the review	296
邪不压正	this is the review	297
呪術廻戦 咒术回战	this is the review	298
To Be or Not to Be 你逃我也逃	this is the review	299
The Curious Case of Benjamin Button 本杰明·巴顿奇事	this is the review	300
ReLIFE 完結編 重生计划完结篇	this is the review	301
海よりもまだ深く 比海更深	this is the review	302
你好，李焕英	this is the review	303
Bill & Ted's Excellent Adventure 比尔和泰德历险记	this is the review	304
Constantine 康斯坦丁	this is the review	305
Assassin's Creed 刺客信条	this is the review	306
Twilight Zone: The Movie 阴阳魔界	this is the review	307
The Croods: A New Age 疯狂原始人 2	this is the review	308
The King's Speech 国王的演讲	this is the review	309
未来のミライ 未来的未来	this is the review	310
夏目友人帳 うつせみに結ぶ 剧场版结缘空蝉	this is the review	311
开心鬼撞鬼	this is the review	312
Stargate: Continuum 星际之门：时空连续	this is the review	313
Stargate: The Ark of Truth 星际之门：真理之盒	this is the review	314
Stargate 星际之门	this is the review	315
RoboCop 3 机器战警 3	this is the review	316
Robocop 2 机器战警 2	this is the review	317
RoboCop 机器战警	this is the review	318
ブランカとギター弾き 布兰卡和弹吉他的人	this is the review	319
Treasure Island 金银岛	this is the review	320
Front of the Class 叫我第一名	this is the review	321
大佛普拉斯	this is the review	322
Synchronicity 同步	this is the review	323
進撃の巨人 进击的巨人 最终季/第四季	this is the review	324
進撃の巨人 进击的巨人 第三季	this is the review	325
進撃の巨人 进击的巨人 第二季	this is the review	326
進撃の巨人 进击的巨人	this is the review	327
小男孩 Little Boy	this is the review	328
リラックマとカオルさん 轻松小熊和小薰 第一季	this is the review	329
钢的琴	this is the review	330
我不是王毛	this is the review	331
Tenet 信条	this is the review	332
射雕英雄传之东成西就	this is the review	333
驴得水	this is the review	334
姜子牙	this is the review	335
Tales from the Loop 环形物语	this is the review	336
ウサビッチ 越狱兔第一季	this is the review	337
Sully 萨利机长	this is the review	338
蛋炒饭	this is the review	339
黄金大劫案	this is the review	340
我在故宫修文物	this is the review	341
Tais-toi! 你丫闭嘴！	this is the review	342
追凶者也	this is the review	343
Like Sunday Like Rain 如晴天，似雨天	this is the review	344
Begin Again 再次出发之纽约遇见你	this is the review	345
Tiché doteky 某种寂静	this is the review	346
你会在 20 岁时死去	this is the review	347
Upload 上载新生	this is the review	348
Space Force 太空部队	this is the review	349
Continuum Season 1 超越时间线 第一季	this is the review	350
Dead Poets Society 死亡诗社	this is the review	351
阳光普照	this is the review	352
鬼子来了	this is the review	353
Catch Me If You Can 猫鼠游戏	this is the review	354
Formula 1: Drive to Survive S1 & S2 一级方程式：疾速争胜	this is the review	355
少年的你	this is the review	356
The Half of It 真心半解	this is the review	357
Never Have I Ever S1 好想做一次	this is the review	358
3 Idiots 三傻大闹宝莱坞	this is the review	359
Taylor Swift: Miss Americana 美利坚女士	this is the review	360
长江七号	this is the review	546
Fast & Furious Presents: Hobbs & Shaw 速度与激情：特别行动	this is the review	361
Sex Education S1 & S2 性爱自修室	this is the review	362
Annihilation 湮灭	this is the review	363
Metropolis 大都会	this is the review	364
七月与安生	this is the review	365
The Prestige 致命魔术	this is the review	366
烈日灼心	this is the review	367
借りぐらしのアリエッティ 借东西的小人阿莉埃蒂	this is the review	368
Alien: Resurrection 异形 4	this is the review	369
Alien³ 异形 3	this is the review	370
Aliens 异形 2	this is the review	371
Minority Report 少数派报告	this is the review	372
心花路放	this is the review	373
囧妈	this is the review	374
كفرناحوم Capernaum 何以为家	this is the review	375
Joker 小丑	this is the review	376
bilibili 晚会二零一九最美的夜	this is the review	377
Forrest Gump 阿甘正传	this is the review	378
써니 阳光姐妹淘	this is the review	379
2019	this is the review	380
中国机长	this is the review	381
Alita: Battle Angel 阿丽塔战斗天使	this is the review	382
君の名は。 你的名字。	this is the review	383
Ready Player One 头号玩家	this is the review	384
부산행 釜山行	this is the review	385
The End of the F***ing World Season 2 去他*的世界 第二季	this is the review	386
The Lord of the Rings: The Return of the King 指环王 3：王者无敌	this is the review	387
The Lord of the Rings: The Two Towers 指环王 2：双塔奇兵	this is the review	388
The Lord of the Rings: The Fellowship of the Ring 指环王 1：魔戒再现	this is the review	389
Whiplash 爆裂鼓手	this is the review	390
喜剧之王	this is the review	391
Alien 异形	this is the review	392
新世紀エヴァンゲリオン劇場版 Air-まごころを、君に 新世纪福音战士剧场版：Air-真心为你	this is the review	393
Blade Runner 银翼杀手	this is the review	394
Sense8 Finale Special 超感猎杀：完结特别篇	this is the review	395
Doctor Who: Planet of the Dead 神秘博士：死亡星球	this is the review	396
Jurassic Park III 侏罗纪公园 3	this is the review	397
Jurassic Park: The Lost World 侏罗纪公园 2：失落的世界	this is the review	398
キッズ・リターン 坏孩子的天空	this is the review	399
The Core 地心抢险记	this is the review	400
War of the Worlds 世界之战	this is the review	401
あの夏、いちばん静かな海。 那年夏天，宁静的海	this is the review	402
The End of the F***ing World Season 1 去他*的世界 第一季	this is the review	403
夏目友人帐 第五季 特别篇 一夜酒杯	this is the review	404
夏目友人帐 第六季 特别篇 铃响的残株	this is the review	405
夏目友人帐 第六季 特别篇 梦幻的碎片	this is the review	406
夏目友人帐 第五季	this is the review	407
夏目友人帐 第六季	this is the review	408
Identity 致命 ID	this is the review	409
夏目友人帐 第三季	this is the review	410
夏目友人帐 第四季	this is the review	411
夏目友人帐 第二季	this is the review	412
夏目友人帐	this is the review	413
夏目友人帐 第五季 特别篇 游戏盛宴	this is the review	414
クレヨンしんちゃん 嵐を呼ぶ モーレツ!オトナ帝国の逆襲 蜡笔小新：呼风唤雨！猛烈！大人帝国的反击	this is the review	415
Fantastic 4: Rise of the Silver Surfer 神奇四侠 2	this is the review	416
Fantastic 4 神奇四侠	this is the review	417
Predestination 前目的地	this is the review	418
Pirates of the Caribbean: At World's End 加勒比海盗 3：世界的尽头	this is the review	419
X-Men: Dark Phoenix X 战警：黑凤凰	this is the review	420
我在未来等你	this is the review	421
从你的全世界路过	this is the review	422
Ghost Rider 灵魂战车	this is the review	423
攀登者	this is the review	424
我和我的祖国	this is the review	425
Harry Potter and the Deathly Hallows: Part 2 哈利·波特与死亡圣器(下)	this is the review	426
Harry Potter and the Deathly Hallows: Part 1 哈利·波特与死亡圣器(上)	this is the review	427
Harry Potter and the Half-Blood Prince 哈利·波特与混血王子	this is the review	428
Harry Potter and the Order of the Phoenix 哈利·波特与凤凰社	this is the review	429
Harry Potter and the Goblet of Fire 哈利·波特与火焰杯	this is the review	430
Harry Potter and the Prisoner of Azkaban 哈利·波特与阿兹卡班的囚徒	this is the review	431
Harry Potter and the Chamber of Secrets 哈利·波特与密室	this is the review	432
Harry Potter and the Sorcerer's Stone 哈利·波特与魔法石	this is the review	433
飞驰人生	this is the review	434
Léon 这个杀手不太冷	this is the review	435
千と千尋の神隠し 千与千寻	this is the review	436
Moon 月球	this is the review	437
Ant-Man and the Wasp 蚁人 2：黄蜂女现身	this is the review	438
The Terminal 幸福终点站	this is the review	439
Venom 毒液：致命守护者	this is the review	440
Total Recall 全面回忆	this is the review	441
Star Trek Beyond 星际迷航 3：超越星辰	this is the review	442
Death Race 死亡飞车	this is the review	443
英雄本色	this is the review	444
2001: A Space Odyssey 2001 太空漫游	this is the review	445
Maze Runner: The Death Cure 移动迷宫 3：死亡解药	this is the review	446
无人区	this is the review	658
Maze Runner: The Scorch Trials 移动迷宫 2	this is the review	447
The Maze Runner 移动迷宫	this is the review	448
Jurassic World 侏罗纪世界	this is the review	449
Alien: Covenant 异形：契约	this is the review	450
Arrival 降临	this is the review	451
Spy Kids 非常小特务	this is the review	452
Batman 蝙蝠侠	this is the review	453
Justice League 正义联盟	this is the review	454
I. Robot 我，机器人	this is the review	455
Oblivion 遗落战境	this is the review	456
Jurassic World: Fallen Kingdom 侏罗纪世界 2	this is the review	457
The Truman Show 楚门的世界	this is the review	458
大灌篮	this is the review	459
一九四二	this is the review	460
非诚勿扰	this is the review	461
无双	this is the review	462
疯狂的赛车	this is the review	463
神话	this is the review	464
Star Trek Into Darkness 星际迷航 2：暗黑无界	this is the review	465
人在囧途	this is the review	466
狗十三	this is the review	467
无问西东	this is the review	468
魁拔之十万火急 1	this is the review	469
Jurassic Park 侏罗纪公园	this is the review	470
Star Trek 星际迷航	this is the review	471
X-Men2 X 战警 2	this is the review	472
绿皮书	this is the review	473
流浪地球	this is the review	474
The Great Gatsby 了不起的盖茨比	this is the review	475
The Pursuit of Happyness 当幸福来敲门	this is the review	476
Resident Evil: The Final Chapter 生化危机：终章	this is the review	477
李茶的姑妈	this is the review	478
Resident Evil: Retribution 生化危机 5：惩罚	this is the review	479
Resident Evil: Afterlife 生化危机 4：战神再生	this is the review	480
Resident Evil: Extinction 生化危机 3：灭绝	this is the review	481
Resident Evil: Apocalypse 生化危机 2：启示录	this is the review	482
Resident Evil 生化危机	this is the review	483
Pirates of the Caribbean: The Curse of the Black Pearl 加勒比海盗	this is the review	484
X-Men: Apocalypse X 战警：天启	this is the review	485
X-Men: Days of Future Past X 战警：逆转未来	this is the review	486
X-Men: First Class X 战警：第一战	this is the review	487
X-Men: The Last Stand X 战警 3：背水一战	this is the review	488
X-Men X 战警	this is the review	489
Hachi: A Dog's Tale 忠犬八公的故事	this is the review	490
Interstellar 星际穿越	this is the review	491
疯狂的石头	this is the review	492
让子弹飞	this is the review	493
无间道	this is the review	494
夏洛特烦恼	this is the review	495
Bumblebee 大黄蜂	this is the review	496
WALL·E 机器人总动员	this is the review	497
Inception 盗梦空间	this is the review	498
Avengers: Endgame 复仇者联盟 4：终局之战	this is the review	499
La leggenda del pianista sull'oceano 海上钢琴师	this is the review	500
Guardians of the Galaxy: Inferno 银河护卫队：地狱	this is the review	501
The Amazing Spider-Man 2 超凡蜘蛛侠 2	this is the review	502
The Amazing Spider-Man 超凡蜘蛛侠	this is the review	503
The Incredible Hulk 无敌浩克	this is the review	504
Captain America: Civil War 美国队长 3	this is the review	505
Captain America: The Winter Soldier 美国队长 2	this is the review	506
Captain America: The First Avenger 美国队长	this is the review	507
Ant-Man 蚁人	this is the review	508
In Time 时间规划局	this is the review	509
Black Panther 黑豹	this is the review	510
Thor: Ragnarok 雷神 3：诸神黄昏	this is the review	511
Thor: The Dark World 雷神 2：黑暗世界	this is the review	512
Thor 雷神	this is the review	513
Avengers: Age of Ultron 复仇者联盟 2：奥创纪元	this is the review	514
The Avengers 复仇者联盟	this is the review	515
Iron Man 3 钢铁侠 3	this is the review	516
Iron Man 2 钢铁侠 2	this is the review	517
Iron Man 钢铁侠	this is the review	518
新喜剧之王	this is the review	519
となりのトトロ 龙猫	this is the review	520
你好，疯子！	this is the review	521
无名之辈	this is the review	522
我不是药神	this is the review	523
Searching 网络谜踪	this is the review	524
西虹市首富	this is the review	525
Mr. Bean's Holiday 憨豆的黄金周	this is the review	526
The Last Emperor 末代皇帝	this is the review	527
Edward Scissorhands 剪刀手爱德华	this is the review	528
Roman Holiday 罗马假日	this is the review	529
Titanic 泰坦尼克号	this is the review	530
Coco 寻梦环游记	this is the review	531
Zootopia 疯狂动物城	this is the review	532
The Shawshank Redemption 肖申克的救赎	this is the review	533
悲伤逆流成河	this is the review	534
2018	this is the review	535
集结号	this is the review	536
洛杉矶捣蛋计划	this is the review	537
Avatar 阿凡达	this is the review	538
Avengers: Infinity War 复仇者联盟 3：无限战争	this is the review	539
老炮儿	this is the review	540
2016	this is the review	541
左耳	this is the review	542
2013	this is the review	543
恶作剧之吻	this is the review	544
2008	this is the review	545
魁拔 3 战神崛起	this is the review	547
蜘蛛侠：英雄远征	this is the review	548
碟中谍 5：神秘国度	this is the review	549
神秘博士：博士、寡妇和衣橱	this is the review	550
博物馆奇妙夜 3	this is the review	551
美国丽人	this is the review	552
澳门风云 3	this is the review	553
星际旅行 4：抢救未来	this is the review	554
玩具总动员	this is the review	555
美丽人生	this is the review	556
蜘蛛侠 2	this is the review	557
神偷奶爸	this is the review	558
狮子王	this is the review	559
帕丁顿熊	this is the review	560
发条橙	this is the review	561
敢死队 3	this is the review	562
奇葩说 第五季	this is the review	563
圆梦巨人	this is the review	564
功夫熊猫 3	this is the review	565
美人鱼	this is the review	566
全球风暴	this is the review	567
深夜食堂电影版	this is the review	568
洛奇	this is the review	569
卡萨布兰卡	this is the review	570
奇幻森林	this is the review	571
回到未来 2	this is the review	572
深海圆疑	this is the review	573
忍者神龟：变种时代	this is the review	574
冰川时代 2：融冰之灾	this is the review	575
猩球崛起 2：黎明之战	this is the review	576
蝙蝠侠：黑暗骑士	this is the review	577
神秘博士：诅咒之旅	this is the review	578
哆啦 A 梦：大雄的月球探险记	this is the review	579
新世纪福音战士 第 0:0 话 诞生之始	this is the review	580
心灵捕手	this is the review	581
鼠来宝 4：萌在囧途	this is the review	582
垫底辣妹	this is the review	583
终结者	this is the review	584
我是谁	this is the review	585
神秘博士特别篇：时间尽头(下)	this is the review	586
愤怒的小鸟	this is the review	587
憨豆特工 2	this is the review	588
西游记	this is the review	589
嫌疑人 X 的献身	this is the review	590
K 星异客	this is the review	591
逃学威龙	this is the review	592
贫民窟的百万富翁	this is the review	593
暴力街区	this is the review	594
蜘蛛侠 3	this is the review	595
驯龙高手	this is the review	596
阿凡达	this is the review	597
攻壳机动队 2：无罪	this is the review	598
侧耳倾听	this is the review	599
神秘博士：博士之时	this is the review	600
特种部队 2：全面反击	this is the review	601
金刚狼	this is the review	602
钢铁侠 3	this is the review	603
马达加斯加 2：逃往非洲	this is the review	604
独立日 2：卷土重来	this is the review	605
冰川时代 3	this is the review	606
源代码	this is the review	607
星球大战外传：侠盗一号	this is the review	608
泰坦尼克号	this is the review	609
精灵旅社	this is the review	610
狄仁杰之通天帝国	this is the review	611
环太平洋	this is the review	612
地质灾难	this is the review	613
蝙蝠侠：侠影之谜	this is the review	614
美国工厂	this is the review	615
天兆	this is the review	616
神秘博士：瑞芙·桑恩的丈夫们	this is the review	617
冰川时代	this is the review	618
头号玩家	this is the review	619
大内密探零零发	this is the review	620
变形金刚 3	this is the review	621
年鉴计划	this is the review	622
她比烟花寂寞	this is the review	623
守护者联盟	this is the review	624
哪吒之魔童降世	this is the review	625
小时代	this is the review	626
普罗米修斯	this is the review	627
超能陆战队	this is the review	628
这个男人来自地球	this is the review	629
九品芝麻官	this is the review	630
饥饿游戏	this is the review	631
快乐的大脚	this is the review	632
大独裁者	this is the review	633
功夫熊猫	this is the review	634
神偷奶爸 3	this is the review	635
窃听风暴	this is the review	636
太空旅客	this is the review	637
红猪	this is the review	638
回到未来 3	this is the review	639
风雨哈佛路	this is the review	640
麦兜，菠萝油王子	this is the review	641
黑客帝国 2：重装上阵	this is the review	642
新世纪福音战士剧场版：复兴	this is the review	643
鼠来宝 3	this is the review	644
速度与激情 6	this is the review	645
神秘博士特别篇：时间尽头(上)	this is the review	646
唐伯虎点秋香	this is the review	647
湮灭	this is the review	648
宇宙的构造	this is the review	649
快乐星球 第一部	this is the review	650
狄仁杰之四大天王	this is the review	651
硬核亨利	this is the review	652
终结者 3	this is the review	653
人猿星球	this is the review	654
火星救援	this is the review	655
超人总动员	this is the review	656
我是谁：没有绝对安全的系统	this is the review	657
独立日	this is the review	659
马达加斯加 3	this is the review	660
机械师 2：复活	this is the review	661
虚幻勇士	this is the review	662
红辣椒	this is the review	663
狗十三	this is the review	664
银河补习班	this is the review	665
疯狂约会美丽都	this is the review	666
我是传奇	this is the review	667
彗星来的那一夜	this is the review	668
铁甲钢拳	this is the review	669
审死官	this is the review	670
地心引力	this is the review	671
机械师	this is the review	672
人再囧途之泰囧	this is the review	673
神秘博士：最后的圣诞	this is the review	674
银河守卫队	this is the review	675
好莱坞往事	this is the review	676
流浪地球	this is the review	677
变形金刚	this is the review	678
博物馆奇妙夜	this is the review	679
第九区	this is the review	680
波拉特	this is the review	681
玩命速递：重启之战	this is the review	682
爱在黎明破晓前	this is the review	683
马达加斯加企鹅：行动	this is the review	684
超能查派	this is the review	685
金蝉脱壳	this is the review	686
黑洞表面	this is the review	687
银河护卫队	this is the review	688
回到未来	this is the review	689
千钧一发	this is the review	690
福音战士新剧场版：破	this is the review	691
终结者：创世纪	this is the review	692
宝莱坞机器人 2.0：重生归来	this is the review	693
公牛历险记	this is the review	694
白蛇：缘起	this is the review	695
三十二	this is the review	696
尖峰时刻 2	this is the review	697
超人：钢铁之躯	this is the review	698
玛丽和马克思	this is the review	699
勇敢传说	this is the review	700
怪兽大学	this is the review	701
麦兜故事	this is the review	702
风语咒	this is the review	703
中国合伙人	this is the review	704
小门神	this is the review	705
人生果实	this is the review	706
变形金刚 4：绝迹重生	this is the review	707
雷霆沙赞！	this is the review	708
海王	this is the review	709
第三类接触	this is the review	710
战栗空间	this is the review	711
人生一串 第二季	this is the review	712
阿尔忒弥斯酒店	this is the review	713
食神	this is the review	714
长安十二时辰	this is the review	715
雪国列车	this is the review	716
机器人 9 号	this is the review	717
雷雨	this is the review	718
深夜食堂 2	this is the review	719
哥斯拉	this is the review	720
精武风云·陈真	this is the review	721
阿丽塔：战斗天使	this is the review	722
惊变 28 天	this is the review	723
波西米亚狂想曲	this is the review	724
不期而遇	this is the review	725
少年派的奇幻漂流	this is the review	726
摆渡人	this is the review	727
V 字仇杀队	this is the review	728
玩具总动员 3	this is the review	729
碟中谍 4	this is the review	730
催眠大师	this is the review	731
我们与恶的距离	this is the review	732
黑暗心灵	this is the review	733
扫毒	this is the review	734
无敌破坏王 2：大闹互联网	this is the review	735
绝命海拔	this is the review	736
少林足球	this is the review	737
宇宙追缉令	this is the review	738
里约大冒险	this is the review	739
飞向太空	this is the review	740
红海行动	this is the review	741
终结者 2018	this is the review	742
神盾局特工 第一季	this is the review	743
倩女幽魂	this is the review	744
灵笼：研发记录	this is the review	745
玩命快递 3	this is the review	746
新世纪福音战士剧场版：死与新生	this is the review	747
马达加斯加	this is the review	748
神秘博士：逃跑新娘	this is the review	749
哥斯拉	this is the review	750
速度与激情 4	this is the review	751
猩球崛起	this is the review	752
钢铁巨人	this is the review	753
企鹅群里有特务	this is the review	754
福音战士新剧场版：Q	this is the review	755
罗小黑战记	this is the review	756
非正式会谈 第一季	this is the review	757
变形金刚 2	this is the review	758
阿波罗 13 号	this is the review	759
拆弹专家	this is the review	760
摩登年代	this is the review	761
变脸	this is the review	762
千与千寻	this is the review	763
大话西游之大圣娶亲	this is the review	764
死侍	this is the review	765
速度与激情 3：东京漂移	this is the review	766
幻体：续命游戏	this is the review	767
小马王	this is the review	768
凌晨四点的上海	this is the review	769
小丑	this is the review	770
蜘蛛侠：平行宇宙	this is the review	771
超时空接触	this is the review	772
飞屋环游记	this is the review	773
星际旅行 1：无限太空	this is the review	774
王牌保镖	this is the review	775
西游降魔篇	this is the review	776
星球大战 8：最后的绝地武士	this is the review	777
大侦探皮卡丘	this is the review	778
狂暴巨兽	this is the review	779
寻梦环游记	this is the review	780
福音战士新剧场版：序	this is the review	781
湄公河行动	this is the review	782
疯狂的麦克斯 4：狂暴之路	this is the review	783
功夫熊猫 2	this is the review	784
缝纫机乐队	this is the review	785
惊天魔盗团	this is the review	786
唐人街探案	this is the review	787
惊奇队长	this is the review	788
妈妈咪鸭	this is the review	789
特种部队：眼镜蛇的崛起	this is the review	790
英伦对决	this is the review	791
敢死队 2	this is the review	792
大闹天宫	this is the review	793
魔卡少女樱 透明牌篇 序章 小樱与两只小熊	this is the review	794
超验骇客	this is the review	795
黑客帝国	this is the review	796
鼠来宝	this is the review	797
异次元骇客	this is the review	798
鼠来宝 2：明星俱乐部	this is the review	799
霍元甲	this is the review	800
穿越时空的少女	this is the review	801
E.T. 外星人	this is the review	802
哆啦 A 梦：伴我同行	this is the review	803
冲出亚马逊	this is the review	804
道士下山	this is the review	805
绝种好男人	this is the review	806
羞羞的铁拳	this is the review	807
人民的名义	this is the review	808
火星任务	this is the review	809
深渊	this is the review	810
天地大冲撞	this is the review	811
百变星君	this is the review	812
恐龙	this is the review	813
2012	this is the review	814
飞鹰艾迪	this is the review	815
疯狂原始人	this is the review	816
大话西游之月光宝盒	this is the review	817
蜘蛛侠	this is the review	818
少年泰坦出击电影版	this is the review	819
摩登时代	this is the review	820
霸王别姬	this is the review	821
森林战士	this is the review	822
辩护人	this is the review	823
一个都不能少	this is the review	824
疯狂外星人	this is the review	825
金蝉脱壳 3：恶魔车站	this is the review	826
谍影重重 5	this is the review	827
黑衣人 2	this is the review	828
怪兽电力公司	this is the review	829
寻龙诀	this is the review	830
宝莲灯	this is the review	831
风云	this is the review	832
冰川时代 5：星际碰撞	this is the review	833
少年时代	this is the review	834
铁甲战神	this is the review	835
非诚勿扰	this is the review	836
怪物史瑞克	this is the review	837
超体	this is the review	838
敢死队	this is the review	839
星际特工：千星之城	this is the review	840
喜剧之王	this is the review	841
奇异博士	this is the review	842
尖峰时刻	this is the review	843
狼图腾	this is the review	844
忍者神龟 2：破影而出	this is the review	845
时间机器	this is the review	846
神秘博士：圣诞颂歌	this is the review	847
蝴蝶效应	this is the review	848
蝙蝠侠：黑暗骑士崛起	this is the review	849
异星觉醒	this is the review	850
摩天营救	this is the review	851
幽灵公主	this is the review	852
速度与激情 5	this is the review	853
调音师	this is the review	854
黑客帝国 3：矩阵革命	this is the review	855
新世纪福音战士 第 0:0'话 来自黑暗之光	this is the review	856
超人归来	this is the review	857
十二生肖	this is the review	858
速度与激情 7	this is the review	859
最强囍事	this is the review	860
神秘博士：下一位博士	this is the review	861
玩命快递	this is the review	862
金刚狼 3：殊死一战	this is the review	863
末代皇帝	this is the review	864
赛车总动员 3：极速挑战	this is the review	865
大黄蜂	this is the review	866
龙猫	this is the review	867
人工智能	this is the review	868
老师·好	this is the review	869
新世纪福音战士	this is the review	870
猩球崛起 3：终极之战	this is the review	871
萤火之森	this is the review	872
龙虎门	this is the review	873
神秘博士：圣诞入侵	this is the review	874
神秘博士：火星之水	this is the review	875
马达加斯加的企鹅	this is the review	876
港囧	this is the review	877
辛普森一家	this is the review	878
解救吾先生	this is the review	879
了不起的盖茨比	this is the review	880
三傻大闹宝莱坞	this is the review	881
猫和老鼠	this is the review	882
木星上行	this is the review	883
机械师	this is the review	884
冰雪奇缘	this is the review	885
环太平洋：雷霆再起	this is the review	886
速度与激情	this is the review	887
银河护卫队 2	this is the review	888
亚特兰蒂斯：失落的帝国	this is the review	889
速度与激情 2	this is the review	890
绝命反击	this is the review	891
烈火英雄	this is the review	892
惊天魔盗团 2	this is the review	893
正义联盟：闪点悖论	this is the review	894
赛文奥特曼 我是地球人	this is the review	895
大鱼海棠	this is the review	896
后天	this is the review	897
终结者 2：审判日	this is the review	898
速度与激情 8	this is the review	899
新警察故事	this is the review	900
情深深雨濛濛	this is the review	901
金刚狼 2	this is the review	902
攻壳机动队	this is the review	903
银翼杀手 2049	this is the review	904
上海堡垒	this is the review	905
黑衣人	this is the review	906
记忆大师	this is the review	907
中央舞台	this is the review	908
灵魂战车 2：复仇时刻	this is the review	909
阿甘正传	this is the review	910
青蜂侠	this is the review	911
海市蜃楼	this is the review	912
绿巨人浩克	this is the review	913
中途岛之战	this is the review	914
时间规划局	this is the review	915
玩具总动员 2	this is the review	916
死侍 2：我爱我家	this is the review	917
宝葫芦的秘密	this is the review	918
疯狂的外星人	this is the review	919
明日边缘	this is the review	920
战狼 2	this is the review	921
功夫	this is the review	922
安德的游戏	this is the review	923
品牌的奥秘	this is the review	924
一条狗的使命	this is the review	925
放牛班的春天	this is the review	926
星际传奇	this is the review	927
博士之日	this is the review	928
美丽密令	this is the review	929
黑衣人 3	this is the review	930
乘风破浪	this is the review	931
玩命快递 2	this is the review	932
杀生	this is the review	933
天空之城	this is the review	934
哈尔的移动城堡	this is the review	935
疯狂动物城	this is the review	936
变形金刚 5：最后的骑士	this is the review	937
冰川时代 4	this is the review	938
蜘蛛侠：英雄归来	this is the review	939
宝贝计划	this is the review	940
天才眼镜狗	this is the review	941
年会不能停！	揭露了大公司办年会的习惯，背后涉及买卖职位、尸位素餐等不好的职场风气	944
热辣滚烫	贾玲导演和主演的一部电影，模仿安藤樱演的百元之恋。在电影院看了两遍，和你好李焕英比差一些，但保持了一贯的搞笑风格，把减肥的整个过程描绘得很好	945
君たちはどう生きるか 你想活出怎样的人生	电影告诉我的就是：向自己提问：你想活出怎样的人生？通过主角的故事主角的选择，启发自己思考个人抉择	946
\.


--
-- Data for Name: music; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.music (name, url, id) FROM stdin;
明天会更好 - 群星	https://tianheg.co/posts/mingtian-huigenghao-qunxing/	1
光 - 王三溥	https://tianheg.co/posts/light-wang-sanpu/	2
最好的时光 - 安溥 anpu	https://tianheg.co/posts/best-of-times-anpu/	3
幸福的芝麻 - 张浅潜	https://tianheg.co/posts/happy-sesame-zhang-qianqian/	4
八九点钟的太阳 - 熊熊作业	https://tianheg.co/posts/eight-or-nine-oclock-sun-xiongxiong-zuoye/	5
后海大鲨鱼 - 心要野	https://tianheg.co/posts/houhai-big-shark-xin-yaoye/	6
薇小薇 - 半途而废的花	https://tianheg.co/posts/wei-xiaowei-half-bloomed-flower/	7
王菀之 - 画意	https://tianheg.co/posts/wang-wanzhi-huayi/	8
万能青年旅店 - 杀死那个石家庄人	https://tianheg.co/posts/omnipotent-youth-society-kill-that-person-from-shijiazhuang/	9
达达乐队 - 南方	https://tianheg.co/posts/dada-band-south/	10
Memory	https://tianheg.co/posts/memory/	11
Roniit - Fade to Blue (Acoustic) (Acoustic) (Acoustic)	https://tianheg.co/posts/roniit-fade-to-blue-acoustic/	12
邓丽君 - 月亮代表我的心	https://tianheg.co/posts/deng-lijun-moon-represents-my-heart/	13
周云蓬 - 不会说话的爱情	https://tianheg.co/posts/zhou-yunpeng-love-without-words/	14
崔跃文 - 时光旅行车	https://tianheg.co/posts/cui-yuewen-time-travel-vehicle/	15
梁博 - 我不知道2020	https://tianheg.co/posts/liangbo-i-donot-know-2020/	16
胡德夫 - 一幅画	https://tianheg.co/posts/hu-defu-a-painting/	17
Jason Mraz - Life Is Wonderful (Live in Amsterdam)	https://tianheg.co/posts/jason-mraz-life-is-wonderful/	18
Ed Sheeran - Perfect	https://tianheg.co/posts/ed-sheeran-perfect/	19
比莉 - Dear John	https://tianheg.co/posts/bili-dear-john/	20
张佺 - 四季歌	https://tianheg.co/posts/zhangquan-four-seasons-song/	21
小娟&山谷里的居民 - 我的家	https://tianheg.co/posts/xiaojuan-my-home/	22
李志 - 你离开了南京，从此没有人和我说话	https://tianheg.co/posts/lizhi-you-left-nanjing/	23
周璇 - 永远的微笑	https://tianheg.co/posts/zhou-xuan-yong-yuan-de-wei-xiao/	24
刺猬 - 火车驶向云外，梦安魂于九霄	https://tianheg.co/posts/hedgehog-train-went-out-of-clouds-dream-died-in-sky/	25
李志《人民不需要自由》	https://tianheg.co/posts/lizhi-people-do-not-need-freedom/	26
Berlin - Take My Breath Away	https://tianheg.co/posts/berlin-take-my-breath-away/	27
五月天《温柔》	https://tianheg.co/posts/mayday-tenderness/	28
周云蓬专辑《瓦尔登湖》	https://tianheg.co/posts/zhou-yun-peng-walden/	29
瓦格纳：歌剧帷幕下的爱	https://tianheg.co/posts/wagner-love-behind-the-curtain-of-opera/	30
看《初恋那件小事》	https://tianheg.co/posts/first-love/	31
Kishi Bashi-I Am The Antichrist To You	https://tianheg.co/posts/kishi-bashi-i-am-the-antichrist-to-you/	32
You Will Be Found	https://tianheg.co/posts/you-will-be-found/	33
李志《寻找》	https://tianheg.co/posts/lizhi-seek/	34
One more time, One more chance	https://tianheg.co/posts/one-more-time-one-more-chance/	35
只要平凡	https://tianheg.co/posts/just-ordinary/	36
Ethan Hawke - Ryan's Song	https://tianheg.co/posts/ethan-hawke-ryans-song/	37
赵英俊	https://tianheg.co/posts/zhao-ying-jun/	38
人间	https://tianheg.co/posts/wangfei-world/	39
来自深渊：启程的黎明	https://tianheg.co/posts/made-in-abyss-journeys-dawn/	40
脆莓 - 十七岁少女金色心	\N	43
钟立风 - 爱情万岁	\N	44
钟立风 - 雨中曲	\N	45
April Rain - One Is Glad To Be Of Service	\N	46
Vivaldi - The Four Seasons	\N	47
Jane Birkin - Je T'aime...Moi Non Plus	\N	48
\.


--
-- Data for Name: musicals; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.musicals (name, review, id) FROM stdin;
Hamilton 汉密尔顿		1
Cats 猫		2
Dear Evan Hansen 亲爱的埃文·汉森		3
The Phantom of the Opera 剧院魅影		4
The Little Prince 小王子		5
Elisabeth 伊丽莎白		6
Six The Musical 六位王后		7
Les Misérables 悲惨世界		8
Rebecca 丽贝卡		9
\.


--
-- Data for Name: series; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.series (name, review, id) FROM stdin;
響け！ユーフォニアム 吹响吧！上低音号1&2&3	喜欢听黄前的上低音号，佩服黄前从高一到高三，经过那么多事情，终于一步步达成大家当初的目标——全国大赛金奖。久石奏刚登场的时候我好讨厌她，心机那么重，后来经过她的挣扎，终于发现了隐情，也为这部番剧增加了更复杂的感情而高兴。剧场版3高一生的表现，很讨厌啊。S3E12：本以为黄前会被选中作为上低音号独奏，没想到还是黑江被选上了。为了真正的正确，黄前说了那番话，之后和丽奈在山上的痛苦不甘。人的情感变化曲折	1
Doctor Who S8E7	Clara 哭着告诉doctor，她差点就没能够拯救这个月球生命，哭着和doctor说再见，让她这样害怕，害怕自己做出错误的决定。这或许就是作为doctor伙伴的坏处之一：你有机会见识到人类命运转折的时刻，小人物看那些英雄力挽狂澜拯救人类命运于水火之中，觉得很羡慕，如果自己设身处地又会怎样勇敢。但如果一个普通人，真的被放在那样一个位置，恐怕也会和Clara一样惊慌失措ba	2
比宇宙更远的地方	三人成团挑战去南极	3
飞翔的魔女	魔幻小故事	4
妖精森林的小不点	很惬意的精灵故事	5
三体（Netflix）S1	改变很多，依旧喜欢	6
The Mandalorian 曼达洛人 S1&S2&S3	星球大战相关的剧集，很喜欢	8
家庭教師ヒットマン	超燃的动漫，看完这两百多集费了我不断的时间	9
工作细胞BLACK はたらく細胞BLACK	生动描绘了人的恶习在细胞层面的影响	10
工作细胞 はたらく細胞 S1&S2	形象地介绍了人体的各种细胞层面的活动，很有教育意义	11
Foundation 基地 S1&S2	很喜欢小说银河帝国系列，快速看完了剧集，期待新一季的到来	7
Humans 真实的人类 S1&S2&S3	在机器人的刺激下，展示了人性中的一些恶	12
比宇宙更遥远的地方 宇宙よりも遠い場所 	去南极诶，我也想去看看	13
\.


--
-- Data for Name: words; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.words (content, id) FROM stdin;
"There's no thought crimes and no thought heroisms" is honestly such a good piece of life advice. You could be having the most fucked up problematic thoughts 24/7 but if you treat people with kindness, the good you do is the only thing that matters. But if you have only the purest thoughts and all the correct beliefs, it doesn't matter one bit if you spend most of your time being an asshole to people.	1
In the end, it's about what you want to be, not what you want to have. When you sign up to run a marathon, you don't want a taxi to take you to the finish line.	2
野心很脆弱，容易被各种困难摧毁	3
做一个清醒的人，在保证自己和家人生活的情况下，不再过度追求财富	4
死亡可能是好事。我们做事要快些，否则会一事无成。——神秘博士S14E3	5
Loneliness does not come from having no people around you, but from being unable to communicate the things that seem important to you. 孤独的本质，是无法把自己觉得重要的事情，深入与外界沟通。所以勉强和一群不同频的人凑热闹，只是暂时麻醉钝化孤独带来的痛感，但散场后发现问题没有解决，痛感就会以更大的强度卷土重来。	6
如果你不喜欢社交，感到自己举止不自然，你开始想自己看起来是不是很蠢，这点非常不好，你应该把注意力集中在对方身上，如果你紧张了，不要想着“我不要再紧张了”，这不管用。别告诉自己“别紧张”，因为你反而会紧张，如果你紧张了就多关注一下别人，认真聆听别人，观察别人，然后你天生的社交能力就会挥发出来，要精通这本领可能需要三四年，不过很值得，所以：走出去，多练习，相信我，你会回来感谢我的。你应该把更多注意力放在对方身上，你得把注意力向外发散，问对方问题，倾听对方的回答，当对方说了什么有意思的或你听不懂的，就问对方问题，人们非常喜欢被问问题，因为这样他们就知道：你有认真在听，人们喜欢被倾听。	7
费曼算法：写下问题；非常努力思考；写下解法	8
https://x.com/Svwang1/status/1784703690890183133 不断提高自己的机会成本，就是说，一旦发现有效率明显更高的新东西和新价值观，就要毫不犹豫，六亲不认的，抛弃之前的低效率的体系和价值观。因为之前在低效率体系之下会形成一些较为根深蒂固的，但实际已经落伍的情绪记忆和直觉，抛弃起来会暂时有些不习惯不舒服。但不这样做，迟早遭到客观规律的严厉惩罚，这种惩罚甚至可能是毁灭性的。 必须要训练自己把定期断舍离，和落后的习惯，低效率的人事果断切割，变成一种不假思索的身体习惯。虚拟化程度更高的体系，效率更高；有丰富长期记忆的体系，效率更高；信息很难被篡改的体系，效率更高；长期记忆对于效率的重要性，体现于对于事物周期，真实历史纪录，潜在收益，和复杂风险的全面丰富理解。没有长期记忆，别人给一点甜头，放一点诱饵，就搭上身家性命着急上钩，拦也拦不住。	9
缺少image（这个image，来自《葬送的芙莉莲》，对成功开发出软件的自我想象	10
当然，如果一颗钻石是令人愉快的，但通过享受它，你就搞砸了你未来的钻石（即时满足猴子的专长），那就不是那么好了。同样，如果你用一颗又一颗的钻石来为你的未来建造一些东西，但它并没有让你快乐，而且似乎是一件看不到尽头的长期事情，那也不是很好。	11
游泳横渡英吉利海峡的人说，最困难的部分之一是最后阶段，你已经可以看到前方的海岸，但实际上还有很长一段距离	12
不管你多么聪明或多么有经验，你的大多数想法根本行不通。成功的想法需要花费时间和辛勤的工作，才能成为被市场广泛采用的真实产品	13
不以恶意度人，恶意会传染，让自己情绪低落	14
人们表达对其他人的感激之情，有一种方式就是创造一些美好的东西。在你精心制作这个东西的过程中，你会把爱包含在里面，不知不觉传递出去。	15
我经常看到人们不断寻找最好的笔记 App、最好的 Linux 发行版、提高生产力的最佳 AI 软件、最好的游戏引擎……这样做并不会提高你的效率，你永远找不到最好或最完美的设置。我的建议是，只要一样东西足够好、能完成工作，你就不妨坚持用下去。不要盯着工具，而要盯着你要完成的工作。	16
你可以做的比你想象的更多。我们被无形的正统观念所束缚。物理定律是唯一的限制。	17
我们知道的比我们想象的要少。复制危机（replication crisis）并非偶然。我们认为的许多事情都是错误的。我们常常甚至没有提出正确的问题。	18
做事情快速是很重要的。因为你更频繁地与现实接触，所以每单位时间学到的东西更多。快速前进使你专注于重要的事情；没有时间废话。慢就是虚假的。一周占据一年的2%。时间是决定因素。	19
热情是很重要的！对你而言，从事令人兴奋的事情要容易得多。因此，做大事可能比做小事更容易。能量是进步的必要输入。	20
作为人类，重新塑造宇宙以符合我们的偏好是我们的权利（也许是我们的道德责任）：真正的知识——技术使这成为可能；你应该努力提高天花板，而不是地板。	21
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages (id, topic, extension, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2024-06-24 06:43:43
20211116045059	2024-06-24 06:43:43
20211116050929	2024-06-24 06:43:43
20211116051442	2024-06-24 06:43:43
20211116212300	2024-06-24 06:43:43
20211116213355	2024-06-24 06:43:43
20211116213934	2024-06-24 06:43:43
20211116214523	2024-06-24 06:43:43
20211122062447	2024-06-24 06:43:43
20211124070109	2024-06-24 06:43:43
20211202204204	2024-06-24 06:43:43
20211202204605	2024-06-24 06:43:43
20211210212804	2024-06-24 06:43:43
20211228014915	2024-06-24 06:43:43
20220107221237	2024-06-24 06:43:43
20220228202821	2024-06-24 06:43:43
20220312004840	2024-06-24 06:43:43
20220603231003	2024-06-24 06:43:44
20220603232444	2024-06-24 06:43:44
20220615214548	2024-06-24 06:43:44
20220712093339	2024-06-24 06:43:44
20220908172859	2024-06-24 06:43:44
20220916233421	2024-06-24 06:43:44
20230119133233	2024-06-24 06:43:44
20230128025114	2024-06-24 06:43:44
20230128025212	2024-06-24 06:43:44
20230227211149	2024-06-24 06:43:44
20230228184745	2024-06-24 06:43:44
20230308225145	2024-06-24 06:43:44
20230328144023	2024-06-24 06:43:44
20231018144023	2024-06-24 06:43:44
20231204144023	2024-06-24 06:43:44
20231204144024	2024-06-24 06:43:44
20231204144025	2024-06-24 06:43:44
20240108234812	2024-06-24 06:43:44
20240109165339	2024-06-24 06:43:44
20240227174441	2024-06-24 06:43:44
20240311171622	2024-06-24 06:43:44
20240321100241	2024-06-24 06:43:44
20240401105812	2024-06-24 06:43:44
20240418121054	2024-06-24 06:43:44
20240523004032	2024-06-24 06:43:44
20240618124746	2024-06-24 06:43:44
20240801235015	2024-08-08 07:31:08
20240805133720	2024-08-08 07:31:08
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2024-06-24 06:43:45.522823
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2024-06-24 06:43:45.582306
2	storage-schema	5c7968fd083fcea04050c1b7f6253c9771b99011	2024-06-24 06:43:45.638173
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2024-06-24 06:43:45.706609
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2024-06-24 06:43:45.784091
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2024-06-24 06:43:45.797794
6	change-column-name-in-get-size	f93f62afdf6613ee5e7e815b30d02dc990201044	2024-06-24 06:43:45.811919
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2024-06-24 06:43:45.867171
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2024-06-24 06:43:45.92342
9	fix-search-function	3a0af29f42e35a4d101c259ed955b67e1bee6825	2024-06-24 06:43:45.936502
10	search-files-search-function	68dc14822daad0ffac3746a502234f486182ef6e	2024-06-24 06:43:45.994613
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2024-06-24 06:43:46.010252
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2024-06-24 06:43:46.06649
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2024-06-24 06:43:46.122768
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2024-06-24 06:43:46.136287
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2024-06-24 06:43:46.173409
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2024-06-24 06:43:46.230717
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2024-06-24 06:43:46.286397
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2024-06-24 06:43:46.342152
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2024-06-24 06:43:46.398554
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2024-06-24 06:43:46.454371
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2024-06-24 06:43:46.473655
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2024-06-24 06:43:46.51198
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2024-06-24 06:43:46.545746
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2024-06-24 06:43:46.602777
25	custom-metadata	67eb93b7e8d401cafcdc97f9ac779e71a79bfe03	2024-08-18 06:30:13.267288
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 1, false);


--
-- Name: books_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.books_id_seq', 83, true);


--
-- Name: books_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.books_id_seq1', 84, true);


--
-- Name: feeds_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.feeds_id_seq', 153, true);


--
-- Name: movies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.movies_id_seq', 946, true);


--
-- Name: music_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.music_id_seq', 48, true);


--
-- Name: musicals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.musicals_id_seq', 9, true);


--
-- Name: series_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.series_id_seq', 13, true);


--
-- Name: words_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.words_id_seq', 21, true);


--
-- Name: messages_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: -
--

SELECT pg_catalog.setval('realtime.messages_id_seq', 1, false);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: -
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_phone_key UNIQUE (phone);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: books books_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_pkey PRIMARY KEY (id);


--
-- Name: feeds feeds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feeds
    ADD CONSTRAINT feeds_pkey PRIMARY KEY (id);


--
-- Name: movies movies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movies
    ADD CONSTRAINT movies_pkey PRIMARY KEY (id);


--
-- Name: music music_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.music
    ADD CONSTRAINT music_pkey PRIMARY KEY (id);


--
-- Name: musicals musicals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.musicals
    ADD CONSTRAINT musicals_pkey PRIMARY KEY (id);


--
-- Name: series series_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT series_pkey PRIMARY KEY (id);


--
-- Name: words words_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.words
    ADD CONSTRAINT words_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: unique_verified_phone_factor; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX unique_verified_phone_factor ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING hash (entity);


--
-- Name: messages_topic_index; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_topic_index ON realtime.messages USING btree (topic);


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: books; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.books ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: ACL; Schema: extensions; Owner: -
--

REVOKE ALL ON FUNCTION extensions.grant_pg_graphql_access() FROM postgres;
GRANT ALL ON FUNCTION extensions.grant_pg_graphql_access() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgrst_ddl_watch(); Type: ACL; Schema: extensions; Owner: -
--

REVOKE ALL ON FUNCTION extensions.pgrst_ddl_watch() FROM postgres;
GRANT ALL ON FUNCTION extensions.pgrst_ddl_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgrst_drop_watch(); Type: ACL; Schema: extensions; Owner: -
--

REVOKE ALL ON FUNCTION extensions.pgrst_drop_watch() FROM postgres;
GRANT ALL ON FUNCTION extensions.pgrst_drop_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: ACL; Schema: extensions; Owner: -
--

REVOKE ALL ON FUNCTION extensions.set_graphql_placeholder() FROM postgres;
GRANT ALL ON FUNCTION extensions.set_graphql_placeholder() TO postgres WITH GRANT OPTION;


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


--
-- PostgreSQL database dump complete
--

