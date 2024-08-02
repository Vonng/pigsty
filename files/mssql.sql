ALTER SYSTEM SET babelfishpg_tsql.database_name = 'mssql';

SELECT pg_reload_conf();

CALL sys.initialize_babelfish('dbuser_mssql');
