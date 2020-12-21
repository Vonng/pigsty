----------------------------------------------------------------------
-- File      :   pg-init-business.sql
-- Ctime     :   2020-12-21
-- Mtime     :   2020-12-21
-- Desc      :   business schema baseline
-- Path      :   /pg/tmp/pg-init-business.sql
-- Author    :   Vonng(fengruohang@outlook.com)
-- Copyright (C) 2018-2020 Ruohang Feng
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
{% if 'owner' in database %}ALTER DATABASE "{{ database.name }}" OWNER TO {{ database.owner }};{% endif %}

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

-- create extensions
{% if 'extensions' in database %}{% for extension in database.extensions %}
CREATE EXTENSION IF NOT EXISTS "{{ extension.name }}"{% if 'schema' in extension %}WITH SCHEMA "{{ extension.schema }}"{% endif %};
{% endfor %}{% endif %}

-- alter databaes parameters
{% if 'parameters' in database %}{% for key, value in database.parameters.items() %}
ALTER DATABASE "{{ database.name }}" SET {{ key }} = {{ value }};
{% endfor %}{% endif %}


{% endfor %}

