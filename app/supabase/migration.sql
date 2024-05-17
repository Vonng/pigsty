-- source: https://github.com/supabase/postgres/tree/develop/migrations/db/migrations
-- run with supabase_admin, idempotent (can be run multiple times)
-- psql -U supabase_admin -f migration.sql


----------------------------------------------------
-- 10000000000000_demote-postgres.sql
----------------------------------------------------
-- skip this because we don't want to demote postgres user in Pigsty's postgres instances

-- migrate:up

-- demote postgres user
-- GRANT ALL ON DATABASE postgres TO postgres;
-- GRANT ALL ON SCHEMA auth TO postgres;
-- GRANT ALL ON SCHEMA extensions TO postgres;
-- GRANT ALL ON SCHEMA storage TO postgres;
-- GRANT ALL ON ALL TABLES IN SCHEMA auth TO postgres;
-- GRANT ALL ON ALL TABLES IN SCHEMA storage TO postgres;
-- GRANT ALL ON ALL TABLES IN SCHEMA extensions TO postgres;
-- GRANT ALL ON ALL SEQUENCES IN SCHEMA auth TO postgres;
-- GRANT ALL ON ALL SEQUENCES IN SCHEMA storage TO postgres;
-- GRANT ALL ON ALL SEQUENCES IN SCHEMA extensions TO postgres;
-- GRANT ALL ON ALL ROUTINES IN SCHEMA auth TO postgres;
-- GRANT ALL ON ALL ROUTINES IN SCHEMA storage TO postgres;
-- GRANT ALL ON ALL ROUTINES IN SCHEMA extensions TO postgres;
-- ALTER ROLE postgres NOSUPERUSER CREATEDB CREATEROLE LOGIN REPLICATION BYPASSRLS;

-- migrate:down




----------------------------------------------------
-- 20211115181400_update-auth-permissions.sql
----------------------------------------------------
-- migrate:up

-- update auth schema permissions
GRANT ALL PRIVILEGES ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA auth TO supabase_auth_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA auth TO supabase_auth_admin;

ALTER table IF EXISTS "auth".users OWNER TO supabase_auth_admin;
ALTER table IF EXISTS "auth".refresh_tokens OWNER TO supabase_auth_admin;
ALTER table IF EXISTS "auth".audit_log_entries OWNER TO supabase_auth_admin;
ALTER table IF EXISTS "auth".instances OWNER TO supabase_auth_admin;
ALTER table IF EXISTS "auth".schema_migrations OWNER TO supabase_auth_admin;

GRANT USAGE ON SCHEMA auth TO postgres;
GRANT ALL ON ALL TABLES IN SCHEMA auth TO postgres, dashboard_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA auth TO postgres, dashboard_user;
GRANT ALL ON ALL ROUTINES IN SCHEMA auth TO postgres, dashboard_user;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO postgres, dashboard_user;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO postgres, dashboard_user;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON ROUTINES TO postgres, dashboard_user;

-- migrate:down





----------------------------------------------------
-- 20211118015519_create-realtime-schema.sql
----------------------------------------------------
-- migrate:up

-- create realtime schema for Realtime RLS (WALRUS)
CREATE SCHEMA IF NOT EXISTS realtime;

-- migrate:down





----------------------------------------------------
-- 20211122051245_update-realtime-permissions.sql
----------------------------------------------------
-- migrate:up

-- update realtime schema permissions
GRANT USAGE ON SCHEMA realtime TO postgres;
GRANT ALL ON ALL TABLES IN SCHEMA realtime TO postgres, dashboard_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA realtime TO postgres, dashboard_user;
GRANT ALL ON ALL ROUTINES IN SCHEMA realtime TO postgres, dashboard_user;

-- migrate:down





----------------------------------------------------
-- 20211124212715_update-auth-owner.sql
----------------------------------------------------
-- migrate:up

-- update owner for auth.uid, auth.role and auth.email functions
    ALTER FUNCTION auth.uid owner to supabase_auth_admin;
ALTER FUNCTION auth.role owner to supabase_auth_admin;
ALTER FUNCTION auth.email owner to supabase_auth_admin;

-- migrate:down





----------------------------------------------------
-- 20211130151719_update-realtime-permissions.sql
----------------------------------------------------
-- migrate:up

-- Update future objects' permissions
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO postgres, dashboard_user;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO postgres, dashboard_user;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON ROUTINES TO postgres, dashboard_user;

-- migrate:down





----------------------------------------------------
-- 20220118070449_enable-safeupdate-postgrest.sql
----------------------------------------------------
-- migrate:up
ALTER ROLE authenticator SET session_preload_libraries = 'safeupdate';

-- migrate:down





----------------------------------------------------
-- 20220126121436_finer-postgrest-triggers.sql
----------------------------------------------------
-- migrate:up

drop event trigger if exists api_restart;
drop function if exists extensions.notify_api_restart();

-- https://postgrest.org/en/latest/schema_cache.html#finer-grained-event-trigger
-- watch create and alter
CREATE OR REPLACE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger AS $$
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
                , 'CREATE TYPE'
                , 'CREATE RULE'
                , 'COMMENT'
                )
                -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
                AND cmd.schema_name is distinct from 'pg_temp'
            THEN
                NOTIFY pgrst, 'reload schema';
            END IF;
        END LOOP;
END; $$ LANGUAGE plpgsql;

-- watch drop
CREATE OR REPLACE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger AS $$
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
END; $$ LANGUAGE plpgsql;

DROP EVENT TRIGGER IF EXISTS pgrst_ddl_watch;
CREATE EVENT TRIGGER pgrst_ddl_watch
    ON ddl_command_end
EXECUTE PROCEDURE extensions.pgrst_ddl_watch();

DROP EVENT TRIGGER IF EXISTS pgrst_drop_watch;
CREATE EVENT TRIGGER pgrst_drop_watch
    ON sql_drop
EXECUTE PROCEDURE extensions.pgrst_drop_watch();


-- migrate:down





----------------------------------------------------
-- 20220224211803_fix-postgrest-supautils.sql
----------------------------------------------------
-- migrate:up

-- Note: supatils extension is not installed in docker image.

DO $$
    DECLARE
        supautils_exists boolean;
    BEGIN
        supautils_exists = (
            select count(*) = 1
            from pg_available_extensions
            where name = 'supautils'
        );

        IF supautils_exists
        THEN
            ALTER ROLE authenticator SET session_preload_libraries = supautils, safeupdate;
        END IF;
    END $$;

-- migrate:down





----------------------------------------------------
-- 20220317095840_pg_graphql.sql
----------------------------------------------------
-- migrate:up
create schema if not exists graphql_public;

-- GraphQL Placeholder Entrypoint
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
                'data', null::jsonb,
                'errors', array['pg_graphql extension is not enabled.']
            );
    ELSE
        RETURN jsonb_build_object(
                'data', null::jsonb,
                'errors', array['pg_graphql is only available on projects running Postgres 14 onwards.']
            );
    END IF;
END;
$$;

grant usage on schema graphql_public to postgres, anon, authenticated, service_role;
alter default privileges in schema graphql_public grant all on tables to postgres, anon, authenticated, service_role;
alter default privileges in schema graphql_public grant all on functions to postgres, anon, authenticated, service_role;
alter default privileges in schema graphql_public grant all on sequences to postgres, anon, authenticated, service_role;

alter default privileges for user supabase_admin in schema graphql_public grant all
    on sequences to postgres, anon, authenticated, service_role;
alter default privileges for user supabase_admin in schema graphql_public grant all
    on tables to postgres, anon, authenticated, service_role;
alter default privileges for user supabase_admin in schema graphql_public grant all
    on functions to postgres, anon, authenticated, service_role;

-- Trigger upon enabling pg_graphql
CREATE OR REPLACE FUNCTION extensions.grant_pg_graphql_access()
    RETURNS event_trigger
    LANGUAGE plpgsql
AS $func$
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
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant all on function graphql.resolve to postgres, anon, authenticated, service_role;

        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

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
        SELECT graphql.resolve(query, coalesce(variables, '{}'));
        $$;

        grant execute on function graphql.resolve to postgres, anon, authenticated, service_role;
    END IF;

END;
$func$;

DROP EVENT TRIGGER IF EXISTS issue_pg_graphql_access;
CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end WHEN TAG in ('CREATE FUNCTION')
EXECUTE PROCEDURE extensions.grant_pg_graphql_access();
COMMENT ON FUNCTION extensions.grant_pg_graphql_access IS 'Grants access to pg_graphql';

-- Trigger upon dropping the pg_graphql extension
CREATE OR REPLACE FUNCTION extensions.set_graphql_placeholder()
    RETURNS event_trigger
    LANGUAGE plpgsql
AS $func$
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
                        'data', null::jsonb,
                        'errors', array['pg_graphql extension is not enabled.']
                    );
            ELSE
                RETURN jsonb_build_object(
                        'data', null::jsonb,
                        'errors', array['pg_graphql is only available on projects running Postgres 14 onwards.']
                    );
            END IF;
        END;
        $$;
    END IF;

END;
$func$;

DROP EVENT TRIGGER IF EXISTS issue_graphql_placeholder;
CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop WHEN TAG in ('DROP EXTENSION')
EXECUTE PROCEDURE extensions.set_graphql_placeholder();
COMMENT ON FUNCTION extensions.set_graphql_placeholder IS 'Reintroduces placeholder function for graphql_public.graphql';

-- migrate:down





-------------------------------------------------------
-- 20220321174452_fix-postgrest-alter-type-event-triger.sql
------------------------------------------------------
-- migrate:up

drop event trigger if exists api_restart;
drop function if exists extensions.notify_api_restart();

-- https://postgrest.org/en/latest/schema_cache.html#finer-grained-event-trigger
-- watch create and alter
CREATE OR REPLACE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger AS $$
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
END; $$ LANGUAGE plpgsql;

-- watch drop
CREATE OR REPLACE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger AS $$
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
END; $$ LANGUAGE plpgsql;

DROP EVENT TRIGGER IF EXISTS pgrst_ddl_watch;
CREATE EVENT TRIGGER pgrst_ddl_watch
    ON ddl_command_end
EXECUTE PROCEDURE extensions.pgrst_ddl_watch();

DROP EVENT TRIGGER IF EXISTS pgrst_drop_watch;
CREATE EVENT TRIGGER pgrst_drop_watch
    ON sql_drop
EXECUTE PROCEDURE extensions.pgrst_drop_watch();


-- migrate:down



----------------------------------------------------
-- 20220322085208_gotrue-session-limit.sql
----------------------------------------------------
-- migrate:up
ALTER ROLE supabase_auth_admin SET idle_in_transaction_session_timeout TO 60000;

-- migrate:down





----------------------------------------------------
-- 20220404205710_pg_graphql-on-by-default.sql
----------------------------------------------------
-- migrate:up

-- Update Trigger upon enabling pg_graphql
create or replace function extensions.grant_pg_graphql_access()
    returns event_trigger
    language plpgsql
AS $func$
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
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant all on function graphql.resolve to postgres, anon, authenticated, service_role;

        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

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
            -- This changed
        select graphql.resolve(
                       query := query,
                       variables := coalesce(variables, '{}'),
                       "operationName" := "operationName",
                       extensions := extensions
                   );
        $$;

        grant execute on function graphql.resolve to postgres, anon, authenticated, service_role;
    END IF;

END;
$func$;

CREATE OR REPLACE FUNCTION extensions.set_graphql_placeholder()
    RETURNS event_trigger
    LANGUAGE plpgsql
AS $func$
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
$func$;

-- GraphQL Placeholder Entrypoint
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


drop extension if exists pg_graphql;
-- Avoids limitation of only being able to load the extension via dashboard
-- Only install as well if the extension is actually installed
DO $$
    DECLARE
        graphql_exists boolean;
    BEGIN
        graphql_exists = (
            select count(*) = 1
            from pg_available_extensions
            where name = 'pg_graphql'
        );

        IF graphql_exists
        THEN
            create extension if not exists pg_graphql;
        END IF;
    END $$;

-- migrate:down





------------------------------------------------------
-- 20220609081115_grant-supabase-auth-admin-and-supabase-storage-admin-to-postgres.sql
-- ----------------------------------------------------
-- migrate:up

-- This is done so that the `postgres` role can manage auth tables triggers,
-- storage tables policies, etc. which unblocks the revocation of superuser
-- access.
--
-- More context: https://www.notion.so/supabase/RFC-Postgres-Permissions-I-40cb4f61bd4145fd9e75ce657c0e31dd#bf5d853436384e6e8e339d0a2e684cbb
grant supabase_auth_admin, supabase_storage_admin to postgres;

-- migrate:down






----------------------------------------------------
-- 20220613123923_pg_graphql-pg-dump-perms.sql
----------------------------------------------------
-- migrate:up

create or replace function extensions.grant_pg_graphql_access()
    returns event_trigger
    language plpgsql
AS $func$
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
    END IF;

END;
$func$;

-- Cycle the extension off and back on to apply the permissions update.

drop extension if exists pg_graphql;
-- Avoids limitation of only being able to load the extension via dashboard
-- Only install as well if the extension is actually installed
DO $$
    DECLARE
        graphql_exists boolean;
    BEGIN
        graphql_exists = (
            select count(*) = 1
            from pg_available_extensions
            where name = 'pg_graphql'
        );

        IF graphql_exists
        THEN
            create extension if not exists pg_graphql;
        END IF;
    END $$;

-- migrate:down





----------------------------------------------------
-- 20220713082019_pg_cron-pg_net-temp-perms-fix.sql
----------------------------------------------------
-- migrate:up
DO $$
    DECLARE
        pg_cron_installed boolean;
    BEGIN
        -- checks if pg_cron is enabled
        pg_cron_installed = (
            select count(*) = 1
            from pg_available_extensions
            where name = 'pg_cron'
              and installed_version is not null
        );

        IF pg_cron_installed
        THEN
            grant usage on schema cron to postgres with grant option;
            grant all on all functions in schema cron to postgres with grant option;

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
        END IF;
    END $$;

DO $$
    DECLARE
        pg_net_installed boolean;
    BEGIN
        -- checks if pg_net is enabled
        pg_net_installed = (
            select count(*) = 1
            from pg_available_extensions
            where name = 'pg_net'
              and installed_version is not null

        );

        IF pg_net_installed
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
    END $$;

-- migrate:down





----------------------------------------------------
-- 20221028101028_set_authenticator_timeout.sql
----------------------------------------------------
-- migrate:up
alter role authenticator set statement_timeout = '8s';

-- migrate:down






----------------------------------------------------
-- 20221103090837_revoke_admin.sql
----------------------------------------------------
-- migrate:up
revoke supabase_admin from authenticator;

-- migrate:down






----------------------------------------------------
-- 20221207154255_create_pgsodium_and_vault.sql
----------------------------------------------------
-- migrate:up

DO $$
    DECLARE
        pgsodium_exists boolean;
        vault_exists boolean;
    BEGIN
        pgsodium_exists = (
            select count(*) = 1
            from pg_available_extensions
            where name = 'pgsodium'
        );

        vault_exists = (
            select count(*) = 1
            from pg_available_extensions
            where name = 'supabase_vault'
        );

        IF pgsodium_exists
        THEN
            create extension if not exists pgsodium;

            grant pgsodium_keyiduser to postgres with admin option;
            grant pgsodium_keyholder to postgres with admin option;
            grant pgsodium_keymaker  to postgres with admin option;

            grant execute on function pgsodium.crypto_aead_det_decrypt(bytea, bytea, uuid, bytea) to service_role;
            grant execute on function pgsodium.crypto_aead_det_encrypt(bytea, bytea, uuid, bytea) to service_role;
            grant execute on function pgsodium.crypto_aead_det_keygen to service_role;

            IF vault_exists
            THEN
                create extension if not exists supabase_vault;
            END IF;
        END IF;
    END $$;

-- migrate:down





----------------------------------------------------
-- 20230201083204_grant_auth_roles_to_postgres.sql
----------------------------------------------------
-- migrate:up
grant anon, authenticated, service_role to postgres;

-- migrate:down






-------------------------------------------------------
-- 20230224042246_grant_extensions_perms_for_postgres.sql
------------------------------------------------------
-- migrate:up
grant all privileges on all tables in schema extensions to postgres with grant option;
grant all privileges on all routines in schema extensions to postgres with grant option;
grant all privileges on all sequences in schema extensions to postgres with grant option;
alter default privileges in schema extensions grant all on tables to postgres with grant option;
alter default privileges in schema extensions grant all on routines to postgres with grant option;
alter default privileges in schema extensions grant all on sequences to postgres with grant option;

-- migrate:down






----------------------------------------------------
-- 20230306081037_grant_pg_monitor_to_postgres.sql
----------------------------------------------------
-- migrate:up
grant pg_monitor to postgres;

-- migrate:down






------------------------------------------------------
-- 20230327032006_grant_auth_roles_to_supabase_storage_admin.sql
------------------------------------------------------
-- migrate:up
grant anon, authenticated, service_role to supabase_storage_admin;

-- migrate:down




----------------------------------------------------
-- 20230529180330_alter_api_roles_for_inherit.sql
----------------------------------------------------
-- migrate:up

ALTER ROLE authenticated inherit;
ALTER ROLE anon inherit;
ALTER ROLE service_role inherit;

GRANT pgsodium_keyholder to service_role;

-- migrate:down



----------------------------------------------------
-- 20231013070755_grant_authenticator_to_supabase_storage_admin.sql
----------------------------------------------------
-- migrate:up
grant authenticator to supabase_storage_admin;
revoke anon, authenticated, service_role from supabase_storage_admin;

-- migrate:down



----------------------------------------------------
-- 20231017062225_grant_pg_graphql_permissions_for_custom_roles.sql
----------------------------------------------------
-- migrate:up

create or replace function extensions.grant_pg_graphql_access()
    returns event_trigger
    language plpgsql
AS $func$
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
$func$;

-- Cycle the extension off and back on to apply the permissions update.

drop extension if exists pg_graphql;
-- Avoids limitation of only being able to load the extension via dashboard
-- Only install as well if the extension is actually installed
DO $$
    DECLARE
        graphql_exists boolean;
    BEGIN
        graphql_exists = (
            select count(*) = 1
            from pg_available_extensions
            where name = 'pg_graphql'
        );

        IF graphql_exists
        THEN
            create extension if not exists pg_graphql;
        END IF;
    END $$;

-- migrate:down


----------------------------------------------------
-- 20231020085357_revoke_writes_on_cron_job_from_postgres.sql
----------------------------------------------------
-- migrate:up
do $$
    begin
        if exists (select from pg_extension where extname = 'pg_cron') then
            revoke all on table cron.job from postgres;
            grant select on table cron.job to postgres with grant option;
        end if;
    end $$;

CREATE OR REPLACE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
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

drop event trigger if exists issue_pg_cron_access;
CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
    WHEN TAG IN ('CREATE EXTENSION')
EXECUTE FUNCTION extensions.grant_pg_cron_access();

-- migrate:down

----------------------------------------------------
-- 20231130133139_set_lock_timeout_to_authenticator_role.sql
----------------------------------------------------
-- migrate:up
ALTER ROLE authenticator set lock_timeout to '8s';

-- migrate:down


----------------------------------------------------
-- 20240124080435_alter_lo_export_lo_import_owner.sql
----------------------------------------------------
-- migrate:up
    alter function pg_catalog.lo_export owner to supabase_admin;
alter function pg_catalog.lo_import(text) owner to supabase_admin;
alter function pg_catalog.lo_import(text, oid) owner to supabase_admin;

-- migrate:down



----------------------------------------------------
-- post migration: webhooks:
-- https://github.com/supabase/supabase/blob/master/docker/volumes/db/webhooks.sql
----------------------------------------------------
BEGIN;
  -- Create pg_net extension
  CREATE EXTENSION IF NOT EXISTS pg_net SCHEMA extensions;
  -- Create supabase_functions schema
  CREATE SCHEMA IF NOT EXISTS supabase_functions AUTHORIZATION supabase_admin;
  GRANT USAGE ON SCHEMA supabase_functions TO postgres, anon, authenticated, service_role;
  ALTER DEFAULT PRIVILEGES IN SCHEMA supabase_functions GRANT ALL ON TABLES TO postgres, anon, authenticated, service_role;
  ALTER DEFAULT PRIVILEGES IN SCHEMA supabase_functions GRANT ALL ON FUNCTIONS TO postgres, anon, authenticated, service_role;
  ALTER DEFAULT PRIVILEGES IN SCHEMA supabase_functions GRANT ALL ON SEQUENCES TO postgres, anon, authenticated, service_role;
  -- supabase_functions.migrations definition
  CREATE TABLE supabase_functions.migrations (
    version text PRIMARY KEY,
    inserted_at timestamptz NOT NULL DEFAULT NOW()
  );
  -- Initial supabase_functions migration
  INSERT INTO supabase_functions.migrations (version) VALUES ('initial');
  -- supabase_functions.hooks definition
  CREATE TABLE supabase_functions.hooks (
    id bigserial PRIMARY KEY,
    hook_table_id integer NOT NULL,
    hook_name text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT NOW(),
    request_id bigint
  );
  CREATE INDEX supabase_functions_hooks_request_id_idx ON supabase_functions.hooks USING btree (request_id);
  CREATE INDEX supabase_functions_hooks_h_table_id_h_name_idx ON supabase_functions.hooks USING btree (hook_table_id, hook_name);
  COMMENT ON TABLE supabase_functions.hooks IS 'Supabase Functions Hooks: Audit trail for triggered hooks.';
  CREATE FUNCTION supabase_functions.http_request()
    RETURNS trigger
    LANGUAGE plpgsql
    AS $function$
    DECLARE
      request_id bigint;
      payload jsonb;
      url text := TG_ARGV[0]::text;
      method text := TG_ARGV[1]::text;
      headers jsonb DEFAULT '{}'::jsonb;
      params jsonb DEFAULT '{}'::jsonb;
      timeout_ms integer DEFAULT 1000;
    BEGIN
      IF url IS NULL OR url = 'null' THEN
        RAISE EXCEPTION 'url argument is missing';
      END IF;

      IF method IS NULL OR method = 'null' THEN
        RAISE EXCEPTION 'method argument is missing';
      END IF;

      IF TG_ARGV[2] IS NULL OR TG_ARGV[2] = 'null' THEN
        headers = '{"Content-Type": "application/json"}'::jsonb;
      ELSE
        headers = TG_ARGV[2]::jsonb;
      END IF;

      IF TG_ARGV[3] IS NULL OR TG_ARGV[3] = 'null' THEN
        params = '{}'::jsonb;
      ELSE
        params = TG_ARGV[3]::jsonb;
      END IF;

      IF TG_ARGV[4] IS NULL OR TG_ARGV[4] = 'null' THEN
        timeout_ms = 1000;
      ELSE
        timeout_ms = TG_ARGV[4]::integer;
      END IF;

      CASE
        WHEN method = 'GET' THEN
          SELECT http_get INTO request_id FROM net.http_get(
            url,
            params,
            headers,
            timeout_ms
          );
        WHEN method = 'POST' THEN
          payload = jsonb_build_object(
            'old_record', OLD,
            'record', NEW,
            'type', TG_OP,
            'table', TG_TABLE_NAME,
            'schema', TG_TABLE_SCHEMA
          );

          SELECT http_post INTO request_id FROM net.http_post(
            url,
            payload,
            params,
            headers,
            timeout_ms
          );
        ELSE
          RAISE EXCEPTION 'method argument % is invalid', method;
      END CASE;

      INSERT INTO supabase_functions.hooks
        (hook_table_id, hook_name, request_id)
      VALUES
        (TG_RELID, TG_NAME, request_id);

      RETURN NEW;
    END
  $function$;
  -- Supabase super admin
  DO
  $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;
  END
  $$;
  GRANT ALL PRIVILEGES ON SCHEMA supabase_functions TO supabase_functions_admin;
  GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA supabase_functions TO supabase_functions_admin;
  GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA supabase_functions TO supabase_functions_admin;
  ALTER USER supabase_functions_admin SET search_path = "supabase_functions";
  ALTER table "supabase_functions".migrations OWNER TO supabase_functions_admin;
  ALTER table "supabase_functions".hooks OWNER TO supabase_functions_admin;
  ALTER function "supabase_functions".http_request() OWNER TO supabase_functions_admin;
  GRANT supabase_functions_admin TO postgres;
  -- Remove unused supabase_pg_net_admin role
  DO
  $$
  BEGIN
    IF EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_pg_net_admin'
    )
    THEN
      REASSIGN OWNED BY supabase_pg_net_admin TO supabase_admin;
      DROP OWNED BY supabase_pg_net_admin;
      DROP ROLE supabase_pg_net_admin;
    END IF;
  END
  $$;
  -- pg_net grants when extension is already enabled
  DO
  $$
  BEGIN
    IF EXISTS (
      SELECT 1
      FROM pg_extension
      WHERE extname = 'pg_net'
    )
    THEN
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
  END
  $$;
  -- Event trigger for pg_net
  CREATE OR REPLACE FUNCTION extensions.grant_pg_net_access()
  RETURNS event_trigger
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
  COMMENT ON FUNCTION extensions.grant_pg_net_access IS 'Grants access to pg_net';
  DO
  $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_event_trigger
      WHERE evtname = 'issue_pg_net_access'
    ) THEN
      CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end WHEN TAG IN ('CREATE EXTENSION')
      EXECUTE PROCEDURE extensions.grant_pg_net_access();
    END IF;
  END
  $$;
  INSERT INTO supabase_functions.migrations (version) VALUES ('20210809183423_update_grants');
  ALTER function supabase_functions.http_request() SECURITY DEFINER;
  ALTER function supabase_functions.http_request() SET search_path = supabase_functions;
  REVOKE ALL ON FUNCTION supabase_functions.http_request() FROM PUBLIC;
  GRANT EXECUTE ON FUNCTION supabase_functions.http_request() TO postgres, anon, authenticated, service_role;
COMMIT;