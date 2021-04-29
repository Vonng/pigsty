----------------------------------------------------------------------
-- File      :   pg-db-{{ database.name }}.sql
-- Path      :   /pg/tmp/pg-db-{{ database.name }}.sql
-- Time      :   {{ '%Y-%m-%d %H:%M' |strftime }}
-- Note      :   managed by ansible, DO NOT CHANGE
-- Desc      :   creation sql script for database {{ database.name }}
----------------------------------------------------------------------


--==================================================================--
--                            EXECUTION                             --
--==================================================================--
-- run as dbsu (postgres by default)
-- createdb -w -p {{ pg_port }} {% if 'owner'      in  database and database.owner != ''      %}-O "{{ database.owner      }}" {% endif %}
{% if 'template'   in  database and database.template != ''   %}-T '{{ database.template   }}' {% endif %}
{% if 'encoding'   in  database and database.encoding != ''   %}-E '{{ database.encoding   }}' {% endif %}
{% if 'locale'     in  database and database.locale != ''     %}-l '{{ database.locale     }}' {% endif %}
{% if 'lc_collate' in  database and database.lc_collate != '' %}--lc-collate '{{ database.lc_collate }}' {% endif %}
{% if 'lc_ctype'   in  database and database.lc_ctype != ''   %}--lc-ctype '{{ database.lc_ctype   }}' {% endif %}
{% if 'tablespace' in  database and database.tablespace != '' %}-D '{{ database.tablespace }}' {% endif %}
'{{ database.name }}';
-- psql {{ database.name }} -p {{ pg_port }} -AXtwqf /pg/tmp/pg-db-{{ database.name }}.sql
{% if 'baseline' in database and database.baseline != '' %}
-- psql {{ database.name }} -p {{ pg_port }} -AXtwqf /pg/tmp/pg-db-{{ database.name }}-baseline.sql
{% endif %}

--==================================================================--
--                         CREATE DATABASE                          --
--==================================================================--
-- create database with following commands
-- CREATE DATABASE "{{ database.name }}" {% if 'owner' in  database and database.owner != '' %}OWNER "{{ database.owner }}" {% endif %}
{% if 'template'   in  database and database.template != ''   %}TEMPLATE "{{ database.template }}" {% endif %}
{% if 'encoding'   in  database and database.encoding != ''   %}ENCODING '{{ database.encoding }}' {% endif %}
{% if 'locale'     in  database and database.locale != ''     %}LOCALE "{{ database.locale }}" {% endif %}
{% if 'lc_collate' in  database and database.lc_collate != '' %}LC_COLLATE "{{ database.lc_collate }}" {% endif %}
{% if 'lc_ctype'   in  database and database.lc_ctype != ''   %}LC_CTYPE "{{ database.lc_ctype }}" {% endif %}
{% if 'tablespace' in  database and database.tablespace != '' %}TABLESPACE "{{ database.tablespace }}" {% endif %}
;
-- following commands are executed within database "{{ database.name }}"


--==================================================================--
--                         ALTER DATABASE                           --
--==================================================================--
-- owner
{% if 'owner' in database and database.owner is not none and database.owner != '' %}
ALTER DATABASE "{{ database.name }}" OWNER TO {{ database.owner }};
{% endif %}

-- tablespace
{% if 'tablespace' in database and database.tablespace != '' %}
ALTER DATABASE "{{ database.name }}" SET TABLESPACE {{ database.tablespace }};
{% endif %}

-- allow connection
{% if 'allowconn' in database and database.allowconn is not none %}
ALTER DATABASE "{{ database.name }}" ALLOW_CONNECTIONS {{ database.allowconn }};
{% endif %}

-- connection limit
{% if 'connlimit' in database and database.connlimit is not none %}
ALTER DATABASE "{{ database.name }}" CONNECTION LIMIT {{ database.connlimit }};
{% endif %}

-- parameters
{% if 'parameters' in database and database.parameters is not none %}
{% for key, value in database.parameters.items() %}
ALTER DATABASE "{{ database.name }}" SET {{ key }} = {{ value }};
{% endfor %}{% endif %}

-- comment
{% if 'comment' in database and database.comment is not none %}
COMMENT ON DATABASE "{{ database.name }}" IS '{{ database.comment }}';
{% else %}
COMMENT ON DATABASE "{{ database.name }}" IS 'business database {{ database.name }}';
{% endif %}


--==================================================================--
--                       REVOKE/GRANT CONNECT                       --
--==================================================================--
{% if 'revokeconn' in database and database.revokeconn == true %}
-- revoke public connect privilege
REVOKE CONNECT ON DATABASE "{{ database.name }}" FROM PUBLIC;

-- replicator, monitor have connect privilege
GRANT CONNECT ON DATABASE "{{ database.name }}" TO "{{ pg_replication_username }}";
GRANT CONNECT ON DATABASE "{{ database.name }}" TO "{{ pg_monitor_username }}";

-- admin have connect privilege with grant option
GRANT CONNECT ON DATABASE "{{ database.name }}" TO "{{ pg_admin_username }}" WITH GRANT OPTION;

-- owner have connect privilege with grant option if exists
{% if 'owner' in  database and database.owner is not none and database.owner != '' %}
GRANT CONNECT ON DATABASE "{{ database.name }}" TO "{{ database.owner }}" WITH GRANT OPTION;
{% endif %}

{% endif %}

--==================================================================--
--                       REVOKE/GRANT CREATE                        --
--==================================================================--
-- revoke create (schema) privilege from public
REVOKE CREATE ON DATABASE "{{ database.name }}" FROM PUBLIC;

-- only admin role have create privilege
GRANT CREATE ON DATABASE "{{ database.name }}" TO "dbrole_admin";

-- revoke public schema creation
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- admin can create objects in public schema
GRANT CREATE ON SCHEMA public TO "dbrole_admin";


--==================================================================--
--                          CREATE SCHEMAS                          --
--==================================================================--
-- create schemas
{% if 'schemas' in database and database.schemas is not none and database.schemas|length > 0 %}{% for schema_name in database.schemas %}
CREATE SCHEMA IF NOT EXISTS "{{ schema_name }}";
{% endfor %}{% endif %}


--==================================================================--
--                        CREATE EXTENSIONS                        --
--==================================================================--
-- create extensions
{% if 'extensions' in database and database.extensions is not none and database.extensions|length > 0 %}{% for extension in database.extensions %}
CREATE EXTENSION IF NOT EXISTS "{{ extension.name }}"{% if 'schema' in extension %} WITH SCHEMA "{{ extension.schema }}"{% endif %};
{% endfor %}{% endif %}


--==================================================================--
--                        PGBOUNCER DATABASE                        --
--==================================================================--
-- database will be added to pgbouncer database list by default,
-- unless pgbouncer is explicitly set to 'false', means hidden database

{% if 'pgbouncer' not in database or database.pgbouncer|bool == true %}
-- Database '{{ database.name }}' will be added to /etc/pgbouncer/database.txt via
-- /pg/bin/pgbouncer-create-db '{{ database.name }}'
{% else %}
-- Database '{{ database.name }}' will NOT be added to /etc/pgbouncer/database.txt
{% endif %}


--==================================================================--