-- supabase init schema baseline, run this as postgres the dbsu
--
-- Tutorial: https://github.com/Vonng/pigsty/tree/master/app/supabase
--
-- # supabase example cluster: pg-meta
--
-- pg-meta:
--   hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary } }
--   vars:
--     pg_cluster: pg-meta
--
--     pg_users:
--       # supabase roles: anon, authenticated, dashboard_user
--       - { name: anon           ,login: false }
--       - { name: authenticated  ,login: false }
--       - { name: dashboard_user ,login: false ,replication: true ,createdb: true ,createrole: true }
--       - { name: service_role   ,login: false ,bypassrls: true }
--       # supabase users: please use the same password
--       - { name: supabase_admin             ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: true   ,superuser: true ,replication: true ,createdb: true ,createrole: true ,bypassrls: true }
--       - { name: authenticator              ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: false  ,roles: [ authenticated ,anon ,service_role ] }
--       - { name: supabase_auth_admin        ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: false  ,createrole: true }
--       - { name: supabase_storage_admin     ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: false  ,createrole: true ,roles: [ authenticated ,anon ,service_role ] }
--       - { name: supabase_functions_admin   ,password: 'DBUser.Supa' ,pgbouncer: true ,inherit: false  ,createrole: true }
--       - { name: supabase_replication_admin ,password: 'DBUser.Supa' ,replication: true }
--       - { name: supabase_read_only_user    ,password: 'DBUser.Supa' ,bypassrls: true ,roles: [ pg_read_all_data ] }
--
--     pg_databases:
--       - { name: meta ,baseline: cmdb.sql ,comment: pigsty meta database ,schemas: [ pigsty ]} # the optional pigsty cmdb
--
--       # the supabase database (pg_cron should be installed in this database after bootstrap)
--       - name: supa
--         baseline: supa.sql    # the init-scripts: https://github.com/supabase/postgres/tree/develop/migrations/db/init-scripts
--         owner: supabase_admin
--         comment: supabase postgres database
--         schemas: [ extensions ,auth ,realtime ,storage ,graphql_public ,supabase_functions ,_analytics ,_realtime ]
--         extensions:
--           - { name: pgcrypto  ,schema: extensions  } # 1.3   : cryptographic functions
--           - { name: pg_net    ,schema: extensions  } # 0.9.1 : async HTTP
--           - { name: pgjwt     ,schema: extensions  } # 0.2.0 : json web token API for postgres
--           - { name: uuid-ossp ,schema: extensions  } # 1.1   : generate universally unique identifiers (UUIDs)
--           - { name: pgsodium        }                # 3.1.9 : pgsodium is a modern cryptography library for Postgres.
--           - { name: supabase_vault  }                # 0.2.8 : Supabase Vault Extension
--           - { name: pg_graphql      }                # 1.5.4 : pg_graphql: GraphQL support
--           - { name: pg_jsonschema   }                # 0.3.1 : pg_jsonschema: Validate json schema
--           - { name: wrappers        }                # 0.3.1 : wrappers: FDW collections
--           - { name: http            }                # 1.6   : http: allows web page retrieval inside the database.
--
--     # supabase required extensions
--     pg_libs: 'pg_net, pg_cron, pg_stat_statements, auto_explain'    # add pg_net to shared_preload_libraries
--     pg_extensions:                                         # supabase required extensions
--       - pg_repack_16* wal2json_16* pgvector_16* pg_cron_16* pgsodium_16*
--       - pg_graphql_16 pg_jsonschema_16 wrappers_16 vault_16* pgjwt_16* pg_net_16* pgsql_http_16*
--
--     # supabase hba rules, require access from docker network
--     pg_hba_rules:
--       - { user: all ,db: supa ,addr: intra       ,auth: pwd ,title: 'allow supa database access from intranet'      }
--       - { user: all ,db: supa ,addr: 172.0.0.0/8 ,auth: pwd ,title: 'allow supa database access from docker network'}
--       - { user: all ,db: supa ,addr: all         ,auth: pwd ,title: 'allow supa database access from entire world'  }  # not safe!


-----------------------------------------
--- name: 01-initial-schema
-----------------------------------------
CREATE PUBLICATION supabase_realtime;

-- setup schema owner
ALTER SCHEMA _analytics         OWNER TO supabase_admin;
ALTER SCHEMA _realtime          OWNER TO supabase_admin;
ALTER SCHEMA auth               OWNER TO supabase_admin;
ALTER SCHEMA extensions         OWNER TO supabase_admin;
ALTER SCHEMA graphql_public     OWNER TO supabase_admin;
ALTER SCHEMA realtime           OWNER TO supabase_admin;
ALTER SCHEMA storage            OWNER TO supabase_admin;
ALTER SCHEMA supabase_functions OWNER TO supabase_admin;

GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT USAGE ON SCHEMA extensions TO anon, authenticated, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;

ALTER USER supabase_admin SET search_path TO public, extensions;
ALTER DEFAULT PRIVILEGES FOR USER supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES FOR USER supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES FOR USER supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;

ALTER ROLE anon SET statement_timeout = '3s';
ALTER ROLE authenticated SET statement_timeout = '8s';


-----------------------------------------
--- name: 02-auth-schema
-----------------------------------------

CREATE SCHEMA IF NOT EXISTS auth AUTHORIZATION supabase_admin;

-- auth.users definition

CREATE TABLE auth.users
(
    instance_id          uuid         NULL,
    id                   uuid         NOT NULL UNIQUE,
    aud                  varchar(255) NULL,
    "role"               varchar(255) NULL,
    email                varchar(255) NULL UNIQUE,
    encrypted_password   varchar(255) NULL,
    confirmed_at         timestamptz  NULL,
    invited_at           timestamptz  NULL,
    confirmation_token   varchar(255) NULL,
    confirmation_sent_at timestamptz  NULL,
    recovery_token       varchar(255) NULL,
    recovery_sent_at     timestamptz  NULL,
    email_change_token   varchar(255) NULL,
    email_change         varchar(255) NULL,
    email_change_sent_at timestamptz  NULL,
    last_sign_in_at      timestamptz  NULL,
    raw_app_meta_data    jsonb        NULL,
    raw_user_meta_data   jsonb        NULL,
    is_super_admin       bool         NULL,
    created_at           timestamptz  NULL,
    updated_at           timestamptz  NULL,
    CONSTRAINT users_pkey PRIMARY KEY (id)
);
CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, email);
CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);
COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';

-- auth.refresh_tokens definition

CREATE TABLE auth.refresh_tokens
(
    instance_id uuid         NULL,
    id          bigserial    NOT NULL,
    "token"     varchar(255) NULL,
    user_id     varchar(255) NULL,
    revoked     bool         NULL,
    created_at  timestamptz  NULL,
    updated_at  timestamptz  NULL,
    CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id)
);
CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);
CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);
CREATE INDEX refresh_tokens_token_idx ON auth.refresh_tokens USING btree (token);
COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';

-- auth.instances definition

CREATE TABLE auth.instances
(
    id              uuid        NOT NULL,
    uuid            uuid        NULL,
    raw_base_config text        NULL,
    created_at      timestamptz NULL,
    updated_at      timestamptz NULL,
    CONSTRAINT instances_pkey PRIMARY KEY (id)
);
COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';

-- auth.audit_log_entries definition

CREATE TABLE auth.audit_log_entries
(
    instance_id uuid        NULL,
    id          uuid        NOT NULL,
    payload     json        NULL,
    created_at  timestamptz NULL,
    CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id)
);
CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);
COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';

-- auth.schema_migrations definition

CREATE TABLE auth.schema_migrations
(
    "version" varchar(255) NOT NULL,
    CONSTRAINT schema_migrations_pkey PRIMARY KEY ("version")
);
COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';

INSERT INTO auth.schema_migrations (version)
VALUES ('20171026211738'),
       ('20171026211808'),
       ('20171026211834'),
       ('20180103212743'),
       ('20180108183307'),
       ('20180119214651'),
       ('20180125194653');

CREATE OR REPLACE FUNCTION auth.uid() RETURNS UUID LANGUAGE SQL STABLE AS
$$SELECT coalesce(current_setting('request.jwt.claim.sub', true),(current_setting('request.jwt.claims', true)::jsonb ->> 'sub'))::UUID$$;

CREATE OR REPLACE FUNCTION auth.role() RETURNS TEXT LANGUAGE SQL STABLE AS
$$SELECT coalesce(current_setting('request.jwt.claim.role', true),(current_setting('request.jwt.claims', true)::jsonb ->> 'role'))::text$$;

CREATE OR REPLACE FUNCTION auth.email() RETURNS TEXT LANGUAGE SQL STABLE AS
$$select coalesce(current_setting('request.jwt.claim.email', true),(current_setting('request.jwt.claims', true)::jsonb ->> 'email'))::TEXT$$;

-- usage on auth functions to API roles
GRANT USAGE ON SCHEMA auth TO anon, authenticated, service_role;

-- Supabase super admin
-- CREATE USER supabase_auth_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
GRANT ALL PRIVILEGES ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA auth TO supabase_auth_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA auth TO supabase_auth_admin;

ALTER USER supabase_auth_admin SET search_path = "auth";
ALTER TABLE "auth".users OWNER TO supabase_auth_admin;
ALTER TABLE "auth".refresh_tokens OWNER TO supabase_auth_admin;
ALTER TABLE "auth".audit_log_entries OWNER TO supabase_auth_admin;
ALTER TABLE "auth".instances OWNER TO supabase_auth_admin;
ALTER TABLE "auth".schema_migrations OWNER TO supabase_auth_admin;

ALTER FUNCTION auth.uid OWNER TO supabase_auth_admin;
ALTER FUNCTION auth.role OWNER TO supabase_auth_admin;
ALTER FUNCTION auth.email OWNER TO supabase_auth_admin;
GRANT EXECUTE ON FUNCTION "auth"."uid"() TO PUBLIC;
GRANT EXECUTE ON FUNCTION "auth"."role"() TO PUBLIC;
GRANT EXECUTE ON FUNCTION "auth"."email"() TO PUBLIC;






-----------------------------------------
--- name: 03-storage-schema
-----------------------------------------
CREATE SCHEMA IF NOT EXISTS storage AUTHORIZATION supabase_admin;

GRANT USAGE ON SCHEMA storage TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA storage GRANT ALL ON TABLES TO postgres, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA storage GRANT ALL ON FUNCTIONS TO postgres, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA storage GRANT ALL ON SEQUENCES TO postgres, anon, authenticated, service_role;

CREATE TABLE "storage"."buckets"
(
    "id"         text not NULL,
    "name"       text NOT NULL,
    "owner"      uuid,
    "created_at" timestamptz DEFAULT now(),
    "updated_at" timestamptz DEFAULT now(),
    CONSTRAINT "buckets_owner_fkey" FOREIGN KEY ("owner") REFERENCES "auth"."users" ("id"),
    PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "bname" ON "storage"."buckets" USING BTREE ("name");

CREATE TABLE "storage"."objects"
(
    "id"               uuid NOT NULL DEFAULT extensions.uuid_generate_v4(),
    "bucket_id"        text,
    "name"             text,
    "owner"            uuid,
    "created_at"       timestamptz   DEFAULT now(),
    "updated_at"       timestamptz   DEFAULT now(),
    "last_accessed_at" timestamptz   DEFAULT now(),
    "metadata"         jsonb,
    CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets" ("id"),
    CONSTRAINT "objects_owner_fkey" FOREIGN KEY ("owner") REFERENCES "auth"."users" ("id"),
    PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "bucketid_objname" ON "storage"."objects" USING BTREE ("bucket_id", "name");
CREATE INDEX name_prefix_search ON storage.objects (name text_pattern_ops);

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

CREATE FUNCTION storage.foldername(name text) RETURNS text[] LANGUAGE plpgsql AS $function$
DECLARE
    _parts text[];
BEGIN
    select string_to_array(name, '/') into _parts;
    return _parts[1:array_length(_parts, 1) - 1];
END
$function$;

CREATE FUNCTION storage.filename(name text) RETURNS text LANGUAGE plpgsql AS $function$
DECLARE
    _parts text[];
BEGIN
    select string_to_array(name, '/') into _parts;
    return _parts[array_length(_parts, 1)];
END
$function$;

CREATE FUNCTION storage.extension(name text) RETURNS text LANGUAGE plpgsql AS $function$
DECLARE
    _parts    text[];
    _filename text;
BEGIN
    select string_to_array(name, '/') into _parts;
    select _parts[array_length(_parts, 1)] into _filename;
    -- @todo return the last part instead of 2
    return split_part(_filename, '.', 2);
END
$function$;

CREATE FUNCTION storage.search(prefix text, bucketname text, limits int DEFAULT 100, levels int DEFAULT 1,offsets int DEFAULT 0)
    RETURNS TABLE
            (
                name             text,
                id               uuid,
                updated_at       TIMESTAMPTZ,
                created_at       TIMESTAMPTZ,
                last_accessed_at TIMESTAMPTZ,
                metadata         jsonb
            )
    LANGUAGE plpgsql AS $function$
DECLARE
    _bucketId text;
BEGIN
    -- will be replaced by migrations when server starts
    -- saving space for cloud-init
END
$function$;

-- create migrations table
-- https://github.com/ThomWright/postgres-migrations/blob/master/src/migrations/0_create-migrations-table.sql
-- we add this table here and not let it be auto-created so that the permissions are properly applied to it
CREATE TABLE IF NOT EXISTS storage.migrations
(
    id          integer PRIMARY KEY,
    name        varchar(100) UNIQUE NOT NULL,
    hash        varchar(40)         NOT NULL, -- sha1 hex encoded hash of the file name and contents, to ensure it hasn't been altered since applying the migration
    executed_at timestamp DEFAULT current_timestamp
);

-- CREATE USER supabase_storage_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
GRANT ALL PRIVILEGES ON SCHEMA storage TO supabase_storage_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA storage TO supabase_storage_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA storage TO supabase_storage_admin;
ALTER USER supabase_storage_admin SET search_path = "storage";
ALTER TABLE "storage".objects OWNER TO supabase_storage_admin;
ALTER TABLE "storage".buckets OWNER TO supabase_storage_admin;
ALTER TABLE "storage".migrations OWNER TO supabase_storage_admin;
ALTER FUNCTION "storage".foldername(text) OWNER TO supabase_storage_admin;
ALTER FUNCTION "storage".filename(text)   OWNER TO supabase_storage_admin;
ALTER FUNCTION "storage".extension(text) OWNER TO supabase_storage_admin;
ALTER FUNCTION "storage".search(text,text,int,int,int) OWNER TO supabase_storage_admin;



-----------------------------------------
--- name: 04-post-setup
-----------------------------------------
ALTER ROLE postgres SET search_path TO "\$user",public,extensions;
CREATE OR REPLACE FUNCTION extensions.notify_api_restart()
    RETURNS event_trigger
    LANGUAGE plpgsql
AS
$$
BEGIN
    NOTIFY ddl_command_end;
END;
$$;
CREATE EVENT TRIGGER api_restart ON ddl_command_end
EXECUTE PROCEDURE extensions.notify_api_restart();
COMMENT ON FUNCTION extensions.notify_api_restart IS 'Sends a notification to the API to restart. If your database schema has changed, this is required so that Supabase can rebuild the relationships.';

-- Trigger for pg_cron
CREATE OR REPLACE FUNCTION extensions.grant_pg_cron_access()
    RETURNS event_trigger
    LANGUAGE plpgsql
AS
$$
DECLARE
    schema_is_cron bool;
BEGIN
    schema_is_cron = (SELECT n.nspname = 'cron'
                      FROM pg_event_trigger_ddl_commands() AS ev
                               LEFT JOIN pg_catalog.pg_namespace AS n
                                         ON ev.objid = n.oid);

    IF schema_is_cron
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

    END IF;

END;
$$;
CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end WHEN TAG IN ('CREATE SCHEMA')
EXECUTE PROCEDURE extensions.grant_pg_cron_access();
COMMENT ON FUNCTION extensions.grant_pg_cron_access IS 'Grants access to pg_cron';

-- Supabase dashboard user
-- CREATE ROLE dashboard_user NOSUPERUSER CREATEDB CREATEROLE REPLICATION;
GRANT ALL ON DATABASE postgres TO dashboard_user;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT ALL ON SCHEMA extensions TO dashboard_user;
GRANT ALL ON SCHEMA storage TO dashboard_user;
GRANT ALL ON ALL TABLES IN SCHEMA auth TO dashboard_user;
GRANT ALL ON ALL TABLES IN SCHEMA extensions TO dashboard_user;
-- GRANT ALL ON ALL TABLES IN SCHEMA storage TO dashboard_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA auth TO dashboard_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA storage TO dashboard_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA extensions TO dashboard_user;
GRANT ALL ON ALL ROUTINES  IN SCHEMA auth TO dashboard_user;
GRANT ALL ON ALL ROUTINES  IN SCHEMA storage TO dashboard_user;
GRANT ALL ON ALL ROUTINES  IN SCHEMA extensions TO dashboard_user;


-----------------------------------------
-- name: 05-reset-auth
-----------------------------------------
-- ALTER ROLE authenticator inherit;
-- alter role authenticator superuser;
GRANT pgsodium_keyholder to service_role;

---