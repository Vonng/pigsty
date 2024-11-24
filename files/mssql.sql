-- License   :   AGPLv3 @ https://pigsty.io/docs/about/license
-- Copyright :   2018-2024  Ruohang Feng / Vonng (rh@vonng.com)

ALTER SYSTEM SET babelfishpg_tsql.database_name = 'mssql';

SELECT pg_reload_conf();

CALL sys.initialize_babelfish('dbuser_mssql');
