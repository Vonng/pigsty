----------------------------------------------------------------------
-- File      :   pg-init-business.sql
-- Ctime     :   2020-12-21
-- Mtime     :   2020-12-21
-- Desc      :   business schema baseline
-- Path      :   /pg/tmp/pg-init-business.sql
-- Author    :   Vonng(fengruohang@outlook.com)
-- Copyright (C) 2018-2022 Ruohang Feng
----------------------------------------------------------------------

--==================================================================--
--                            executions                            --
--==================================================================--
-- psql template1 -AXtwqf /pg/tmp/pg-init-business.sql
-- this sql scripts is responsible for create business roles and databases


--==================================================================--
--                              Users                               --
--==================================================================--
-- default roles
{% for user in pg_users %}
CREATE USER "{{ user.username }}";
{% endfor %}

{% for user in pg_users %}
--------------------------
-- {{ user.username }}
--------------------------
{% if 'password' in user %}
{% if user.password == '' %}ALTER ROLE "{{ user.username }}" PASSWORD NULL;
{% else %}ALTER ROLE "{{ user.username }}" PASSWORD '{{ user.password }}';{% endif %}
{% endif %}
{% if 'options' in user %}ALTER ROLE "{{ user.username }}" {{ user.options }};{% endif %}

{% if 'comment' in user %}COMMENT ON ROLE "{{ user.username }}" IS '{{ user.comment }}';{% endif %}

{% if 'groups' in user %}
{% for group in user.groups %}
GRANT "{{ group }}" TO "{{ user.username }}";
{% endfor %}
{% endif %}

{% endfor %}


--==================================================================--
--                            Databases                             --
--==================================================================--
{% for database in pg_databases %}
CREATE DATABASE "{{ database.name }}";

-- admin role have create privilege
REVOKE CREATE ON DATABASE "{{ database.name }}" FROM PUBLIC;
GRANT CREATE ON DATABASE "{{ database.name }}" TO "dbrole_admin";

-- if owner is set, revoke public connect privilege
{% if 'owner' in database %}
-- setup owner
ALTER DATABASE "{{ database.name }}" OWNER TO {{ database.owner }};

-- revoke public connect
REVOKE CONNECT ON DATABASE "{{ database.name }}" FROM PUBLIC;

-- replicator, monitor have connect privilege
GRANT CONNECT ON DATABASE "{{ database.name }}" TO "{{ pg_replication_username }}";
GRANT CONNECT ON DATABASE "{{ database.name }}" TO "{{ pg_monitor_username }}";

-- admin and dbowner have connect privilege with grant option
GRANT CONNECT ON DATABASE "{{ database.name }}" TO "{{ pg_admin_username }}" WITH GRANT OPTION;
GRANT CONNECT ON DATABASE "{{ database.name }}" TO "{{ database.owner }}" WITH GRANT OPTION;
{% endif %}

{% endfor %}


{% for database in pg_databases %}
--------------------------
-- database: {{ database.name }}
--------------------------
-- connect to database {{ database.name }}
\c {{ database.name }}

-- create schemas
{% if 'schemas' in database %}{% for schema_name in database.schemas %}
CREATE SCHEMA IF NOT EXISTS "{{ schema_name }}";
{% endfor %}{% endif %}

-- revoke public schema creation
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
GRANT CREATE ON SCHEMA public TO "dbrole_admin"; -- admin can create objects

-- create extensions
{% if 'extensions' in database %}{% for extension in database.extensions %}
CREATE EXTENSION IF NOT EXISTS "{{ extension.name }}"{% if 'schema' in extension %} WITH SCHEMA "{{ extension.schema }}"{% endif %};
{% endfor %}{% endif %}

-- alter databaes parameters
{% if 'parameters' in database %}{% for key, value in database.parameters.items() %}
ALTER DATABASE "{{ database.name }}" SET {{ key }} = {{ value }};
{% endfor %}{% endif %}


{% endfor %}

