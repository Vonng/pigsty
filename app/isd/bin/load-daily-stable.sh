#!/usr/bin/env bash
set -uo pipefail

#==============================================================#
# File      :   load-isd-daily.sh
# Mtime     :   2020-11-03
# Desc      :   Load ISD daily Dataset (specific year) to database
# Path      :   bin/load-isd-daily.sh
# Author    :   Vonng(fengruohang@outlook.com)
# Depend    :   curl
# Usage     :   bin/load-isd-daily.sh [pgurl=isd] [year=2020]
#==============================================================#
PROG_DIR="$(cd $(dirname $0) && pwd)"
PROG_NAME="$(basename $0)"
PROJ_DIR=$(dirname $PROG_DIR)

# PGURL specify target database connection string
PGURL=${1-'isd'}
PARSER="${PROJ_DIR}/bin/isdd"
DATA_DIR="${PROJ_DIR}/data/daily"

function log_info (){
    [ -t 2 ] && printf "\033[0;32m[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\033[0m\n" 1>&2 || printf "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\n" 1>&2
}

# get year record count
log_info "truncate isd.daily_stable"
psql ${PGURL} -AXtwqc 'TRUNCATE isd.daily_stable;'

log_info "load data to isd.daily_stable"
cat ${DATA_DIR}/isd_daily_stable.csv.gz | pv | gzip -d | psql ${PGURL} -AXtwc 'COPY isd.daily_stable FROM STDIN CSV HEADER;'

log_info "calculate isd.monthly_stable from isd.daily_stable"
psql ${PGURL} -AXtwq <<-'EOF'
TRUNCATE isd.monthly_stable;
INSERT INTO isd.monthly_stable
SELECT date_trunc('month', ts)                                                    AS ts,           -- 月份
       station,                                                                                    -- 站号
       round(avg(temp_mean) ::NUMERIC, 1)::NUMERIC(3, 1)                          AS temp_mean,    -- 月平均气温
       round(min(temp_min) ::NUMERIC, 1) ::NUMERIC(3, 1)                          AS temp_min,     -- 月最低气温均值
       round(max(temp_max) ::NUMERIC, 1) ::NUMERIC(3, 1)                          AS temp_max,     -- 月最高气温均值
       round(avg(temp_min) ::NUMERIC, 1) ::NUMERIC(3, 1)                          AS temp_min_avg, -- 月最低气温均值
       round(avg(temp_max) ::NUMERIC, 1) ::NUMERIC(3, 1)                          AS temp_max_avg, -- 月最高气温均值
       round(avg(dewp_mean) ::NUMERIC, 1)::NUMERIC(3, 1)                          AS dewp_mean,    -- 月平均露点
       round(min(dewp_mean) ::NUMERIC, 1) ::NUMERIC(3, 1)                         AS dewp_min,     -- 月最低露点
       round(max(dewp_mean) ::NUMERIC, 1) ::NUMERIC(3, 1)                         AS dewp_max,     -- 月最高露点
       round(avg(slp_mean) ::NUMERIC, 1) ::NUMERIC(5, 1)                          AS slp_mean,     -- 月平均气压
       round(min(slp_mean) ::NUMERIC, 1) ::NUMERIC(5, 1)                          AS slp_min,      -- 月最低气压
       round(max(slp_mean) ::NUMERIC, 1) ::NUMERIC(5, 1)                          AS slp_max,      -- 月最高气压
       round(sum(prcp_mean) ::NUMERIC, 1) ::NUMERIC(5, 1)                         AS prcp_sum,     -- 月总降水
       round(max(prcp_mean) ::NUMERIC, 1) ::NUMERIC(5, 1)                         AS prcp_max,     -- 月最大降水
       round(avg(prcp_mean) ::NUMERIC, 1) ::NUMERIC(5, 1)                         AS prcp_mean,    -- 月平均降水
       round(avg(wdsp_mean) ::NUMERIC, 1) ::NUMERIC(4, 1)                         AS wdsp_mean,    -- 月平均风速
       round(max(wdsp_max) ::NUMERIC, 1) ::NUMERIC(4, 1)                          AS wdsp_max,     -- 月最大风速
       round(max(gust) ::NUMERIC, 1) ::NUMERIC(4, 1)                              AS gust_max,     -- 月最大阵风
       count(*) FILTER ( WHERE NOT is_foggy AND NOT is_rainy AND NOT is_snowy
           AND NOT is_hail AND NOT is_thunder AND NOT is_tornado) ::SMALLINT      AS sunny_days,   -- 月晴天日数
       count(*) FILTER ( WHERE wdsp_max >= 17.2) ::SMALLINT                       AS windy_days,   -- 月大风日数
       count(*) FILTER (WHERE is_foggy) ::SMALLINT                                AS foggy_days,   -- 月雾天日数
       count(*) FILTER (WHERE is_rainy) ::SMALLINT                                AS rainy_days,   -- 月雨天日数
       count(*) FILTER (WHERE is_snowy) ::SMALLINT                                AS snowy_days,   -- 月雪天日数
       count(*) FILTER (WHERE is_hail) ::SMALLINT                                 AS hail_days,    -- 月冰雹日数
       count(*) FILTER (WHERE is_thunder) ::SMALLINT                              AS thunder_days, -- 月雷暴日数
       count(*) FILTER (WHERE is_tornado) ::SMALLINT                              AS tornado_days, -- 月龙卷日数
       count(*) FILTER ( WHERE temp_max >= 30 ) ::SMALLINT                        AS hot_days,     -- 月高温日数
       count(*) FILTER ( WHERE temp_min < 0 ) ::SMALLINT                          AS cold_days,    -- 月低温日数
       count(*) FILTER ( WHERE vis_mean >= 0 AND vis_mean < 4000 ) ::SMALLINT     AS vis_4_days,   -- 月能见度4km内日数
       count(*) FILTER ( WHERE vis_mean >= 4000 AND vis_mean < 10000)::SMALLINT   AS vis_10_days,  -- 能见度4-10km时间占比百分数
       count(*) FILTER ( WHERE vis_mean >= 10000 AND vis_mean < 20000 )::SMALLINT AS vis_20_days,  -- 能见度10-20km时间占比百分数
       count(*) FILTER ( WHERE vis_mean >= 20000 )::SMALLINT                      AS vis_20p_days  -- 能见度20km+时间占比百分数
FROM isd.daily_stable
GROUP by date_trunc('month', ts), station
ORDER BY 1, 2;
EOF

log_info "calculate isd.yearly_stable from isd.monthly_stable"
psql ${PGURL} -AXtwq <<-'EOF'
TRUNCATE isd.yearly_stable;
INSERT INTO isd.yearly_stable
SELECT date_trunc('year', ts)::DATE AS ts,           -- 年份
       station,                                      -- 站号
       min(temp_min)                AS temp_min,     -- 年最低气温
       max(temp_max)                AS temp_max,     -- 年最高气温
       min(dewp_min)                AS dewp_min,     -- 年最低露点
       max(dewp_max)                AS dewp_max,     -- 年最高露点
       sum(prcp_sum)                AS prcp_sum,     -- 年总降水
       max(prcp_max)                AS prcp_max,     -- 年最大降水
       max(wdsp_max)                AS wdsp_max,     -- 年最大风速
       max(gust_max)                AS gust_max,     -- 年最大阵风
       sum(sunny_days)              AS sunny_days,   -- 年晴天日数
       sum(windy_days)              AS windy_days,   -- 年大风日数
       sum(foggy_days)              AS foggy_days,   -- 年雾天日数
       sum(rainy_days)              AS rainy_days,   -- 年雨天日数
       sum(snowy_days)              AS snowy_days,   -- 年雪天日数
       sum(hail_days)               AS hail_days,    -- 年冰雹日数
       sum(thunder_days)            AS thunder_days, -- 年雷暴日数
       sum(tornado_days)            AS tornado_days, -- 年龙卷日数
       sum(hot_days)                AS hot_days,     -- 年高温日数
       sum(cold_days)               AS cold_days,    -- 年低温日数
       sum(vis_4_days)              AS vis_4_days,   -- 年能见度4km内日数
       sum(vis_10_days)             AS vis_10_days,  -- 年能见度4-10km内日数
       sum(vis_20_days)             AS vis_20_days,  -- 年能见度10-20km内日数
       sum(vis_20p_days)            AS vis_20p_days  -- 年能见度20km上日数
FROM isd.monthly_stable
GROUP by date_trunc('year', ts), station
ORDER BY 1, 2;
EOF

