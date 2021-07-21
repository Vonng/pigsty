--============================================================--
--                    Cleanup Commands                         -
--============================================================--
-- postgis required
CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
CREATE SCHEMA IF NOT EXISTS isd;
DROP TABLE IF EXISTS isd.china_fences;
DROP TABLE IF EXISTS isd.world_fences;

DROP TABLE IF EXISTS isd_station;
DROP TABLE IF EXISTS isd_history;
DROP TABLE IF EXISTS isd_elements;
DROP TABLE IF EXISTS isd_mwcode;

DROP TABLE IF EXISTS isd_hourly;
DROP TABLE IF EXISTS isd_daily;
DROP TABLE IF EXISTS isd_monthly;
DROP TABLE IF EXISTS isd_yearly;

DROP FUNCTION IF EXISTS wind16(_i NUMERIC);
DROP FUNCTION IF EXISTS wind8(_i NUMERIC);
DROP FUNCTION IF EXISTS mwcode_name(mw_code text);
DROP FUNCTION IF EXISTS china_geojson(codes INTEGER[]);
DROP FUNCTION IF EXISTS world_geojson(scale TEXT, codes TEXT[]);
DROP FUNCTION IF EXISTS create_isd_hourly_partition(_year INTEGER, _upper INTEGER);
DROP FUNCTION IF EXISTS refresh_isd_latest();

--============================================================--
--                    Meta Table Schema                        -
--============================================================--


------------------------------------------------
-- isd_station
--   Station meta data
------------------------------------------------
CREATE TABLE public.isd_station
(
    station    VARCHAR(12) PRIMARY KEY,
    usaf       VARCHAR(6) GENERATED ALWAYS AS (substring(station, 1, 6)) STORED,
    wban       VARCHAR(5) GENERATED ALWAYS AS (substring(station, 7, 5)) STORED,
    name       VARCHAR(32),
    country    VARCHAR(2),
    province   VARCHAR(2),
    icao       VARCHAR(4),
    location   GEOMETRY(POINT),
    longitude  NUMERIC GENERATED ALWAYS AS (Round(ST_X(location)::NUMERIC, 6)) STORED,
    latitude   NUMERIC GENERATED ALWAYS AS (Round(ST_Y(location)::NUMERIC, 6)) STORED,
    elevation  NUMERIC,
    period     daterange,
    begin_date DATE GENERATED ALWAYS AS (lower(period)) STORED,
    end_date   DATE GENERATED ALWAYS AS (upper(period)) STORED
);

COMMENT ON TABLE isd_station IS 'Integrated Surface Data (ISD) dataset station history';
COMMENT ON COLUMN isd_station.station IS 'Primary key of isd station, 11 char, usaf+wban';
COMMENT ON COLUMN isd_station.usaf IS 'Air Force station ID. May contain a letter in the first position.';
COMMENT ON COLUMN isd_station.wban IS 'NCDC WBAN number';
COMMENT ON COLUMN isd_station.name IS 'Station name';
COMMENT ON COLUMN isd_station.country IS 'FIPS country ID (2 char)';
COMMENT ON COLUMN isd_station.province IS 'State for US stations (2 char)';
COMMENT ON COLUMN isd_station.icao IS 'ICAO ID';
COMMENT ON COLUMN isd_station.location IS '2D location of station';
COMMENT ON COLUMN isd_station.longitude IS 'longitude of the station';
COMMENT ON COLUMN isd_station.latitude IS 'latitude of the station';
COMMENT ON COLUMN isd_station.elevation IS 'altitude of the station';
COMMENT ON COLUMN isd_station.begin_date IS 'Beginning Period Of Record (YYYYMMDD). There may be reporting gaps within the P.O.R.';
COMMENT ON COLUMN isd_station.end_date IS 'Ending Period Of Record (YYYYMMDD). There may be reporting gaps within the P.O.R.';
COMMENT ON COLUMN isd_station.period IS 'range of [begin,end] peroid';

-- indexes
CREATE INDEX ON isd_station (usaf);
CREATE INDEX ON isd_station (wban);
CREATE INDEX ON isd_station (name);
CREATE INDEX ON isd_station (icao);
CREATE INDEX ON isd_station (begin_date);
CREATE INDEX ON isd_station (end_date);
CREATE INDEX ON isd_station USING GIST (location);
CREATE INDEX ON isd_station USING GIST (period);


------------------------------------------------
-- isd_history
--   Station historic observation summary
------------------------------------------------
CREATE TABLE public.isd_history
(
    station      VARCHAR(12),
    year         DATE,
    usaf         VARCHAR(6) GENERATED ALWAYS AS (substring(station, 1, 6)) STORED,
    wban         VARCHAR(5) GENERATED ALWAYS AS (substring(station, 7, 5)) STORED,
    country      VARCHAR(2), -- materialized 2 char country code
    active_month INTEGER,    -- how many month have more than 1 observation record ?
    total        INTEGER NOT NULL,
    m1           INTEGER,
    m2           INTEGER,
    m3           INTEGER,
    m4           INTEGER,
    m5           INTEGER,
    m6           INTEGER,
    m7           INTEGER,
    m8           INTEGER,
    m9           INTEGER,
    m10          INTEGER,
    m11          INTEGER,
    m12          INTEGER,
    PRIMARY KEY (station, year)
);

COMMENT ON TABLE isd_history IS 'ISD观测记录清单表';
COMMENT ON COLUMN isd_history.station IS 'station name: usaf(6) + wban(5)';
COMMENT ON COLUMN isd_history.year IS 'observe year';
COMMENT ON COLUMN isd_history.usaf IS 'Air Force station ID(6). May contain a letter in the first position';
COMMENT ON COLUMN isd_history.wban IS 'NCDC WBAN number, 5char';
COMMENT ON COLUMN isd_history.country IS '2位国家代码，缺省值为NA';
COMMENT ON COLUMN isd_history.active_month IS '当年存在观测记录的月份数量';
COMMENT ON COLUMN isd_history.total IS '当年记录数';
COMMENT ON COLUMN isd_history.m1 IS '1月份记录数';
COMMENT ON COLUMN isd_history.m2 IS '2月份记录数';
COMMENT ON COLUMN isd_history.m3 IS '3月份记录数';
COMMENT ON COLUMN isd_history.m4 IS '4月份记录数';
COMMENT ON COLUMN isd_history.m5 IS '5月份记录数';
COMMENT ON COLUMN isd_history.m6 IS '6月份记录数';
COMMENT ON COLUMN isd_history.m7 IS '7月份记录数';
COMMENT ON COLUMN isd_history.m8 IS '8月份记录数';
COMMENT ON COLUMN isd_history.m9 IS '9月份记录数';
COMMENT ON COLUMN isd_history.m10 IS '10月份记录数';
COMMENT ON COLUMN isd_history.m11 IS '11月份记录数';
COMMENT ON COLUMN isd_history.m12 IS '12月份记录数';

-- indexes
CREATE UNIQUE INDEX ON isd_history (station, year);
CREATE INDEX ON isd_history (year, country);
CREATE INDEX ON isd_history (usaf);


------------------------------------------------
-- isd_elements
--   Meteorology elements dictionary
------------------------------------------------
CREATE TABLE public.isd_elements
(
    id       TEXT PRIMARY KEY,
    name     TEXT,
    name_cn  TEXT,
    coverage NUMERIC,
    section  TEXT
);

COMMENT ON TABLE public.isd_elements IS 'ISD气象要素释义表';
COMMENT ON COLUMN public.isd_elements.id IS '气象要素标识';
COMMENT ON COLUMN public.isd_elements.name IS '气象要素名称';
COMMENT ON COLUMN public.isd_elements.name_cn IS '气象要素中文名称';
COMMENT ON COLUMN public.isd_elements.coverage IS '气象要素数据覆盖率';
COMMENT ON COLUMN public.isd_elements.section IS '气象要素所属类别';


------------------------------------------------
-- isd_mwcode
--   Weather code used by ISD MW fields
------------------------------------------------
CREATE TABLE isd_mwcode
(
    code  VARCHAR(2) PRIMARY KEY,
    name  VARCHAR(8),
    brief TEXT
);

COMMENT ON TABLE isd_mwcode IS 'ISD MW字段两位天气代码';
COMMENT ON COLUMN isd_mwcode.code IS '2 digit code from 00-99';
COMMENT ON COLUMN isd_mwcode.name IS 'short description in chinese';
COMMENT ON COLUMN isd_mwcode.brief IS 'origin description text';


------------------------------------------------
-- world_fences
--   GeoFence from eurostats
------------------------------------------------
CREATE TABLE public.world_fences
(
    id            VARCHAR(2) PRIMARY KEY,
    name          VARCHAR(64),
    name_raw      VARCHAR(160),
    name_cn       VARCHAR(16),
    name_cn_short VARCHAR(16),
    iso2          VARCHAR(2),
    iso3          VARCHAR(3),
    fence60m      GEOMETRY,
    fence20m      GEOMETRY,
    fence10m      GEOMETRY,
    fence3m       GEOMETRY,
    fence1m       GEOMETRY
);

COMMENT ON TABLE public.world_fences IS '2020年世界行政区划地理围栏表,欧盟统计用';
COMMENT ON COLUMN public.world_fences.id IS '两位国家代码';
COMMENT ON COLUMN public.world_fences.name IS '英文国家名称';
COMMENT ON COLUMN public.world_fences.name_raw IS '本地语言表示的国家名称';
COMMENT ON COLUMN public.world_fences.name_cn IS '中文官方名称';
COMMENT ON COLUMN public.world_fences.name_cn_short IS '中文简写名称';
COMMENT ON COLUMN public.world_fences.iso2 IS 'ISO2位代码';
COMMENT ON COLUMN public.world_fences.iso3 IS 'ISO3位代码';
COMMENT ON COLUMN public.world_fences.fence60m IS '地理围栏1:60000000';
COMMENT ON COLUMN public.world_fences.fence20m IS '地理围栏1:20000000';
COMMENT ON COLUMN public.world_fences.fence10m IS '地理围栏1:10000000';
COMMENT ON COLUMN public.world_fences.fence3m IS '地理围栏1:3000000';
COMMENT ON COLUMN public.world_fences.fence1m IS '地理围栏1:1000000';

-- indexes
CREATE INDEX IF NOT EXISTS world_fences_iso2_idx ON public.world_fences USING btree (iso2);
CREATE INDEX IF NOT EXISTS world_fences_iso3_idx ON public.world_fences USING btree (iso3);
CREATE INDEX IF NOT EXISTS world_fences_name_cn_idx ON public.world_fences USING btree (name_cn);
CREATE INDEX IF NOT EXISTS world_fences_name_cn_short_idx ON public.world_fences USING btree (name_cn_short);
CREATE INDEX IF NOT EXISTS world_fences_name_idx ON public.world_fences USING btree (name);
CREATE INDEX IF NOT EXISTS world_fences_fence10m_idx ON public.world_fences USING gist (fence10m);
CREATE INDEX IF NOT EXISTS world_fences_fence1m_idx ON public.world_fences USING gist (fence1m);
CREATE INDEX IF NOT EXISTS world_fences_fence20m_idx ON public.world_fences USING gist (fence20m);
CREATE INDEX IF NOT EXISTS world_fences_fence3m_idx ON public.world_fences USING gist (fence3m);
CREATE INDEX IF NOT EXISTS world_fences_fence60m_idx ON public.world_fences USING gist (fence60m);


------------------------------------------------
-- china_fences
--   GeoFence from China MCN
------------------------------------------------
CREATE TABLE public.china_fences
(
    id          INTEGER NOT NULL,
    adcode      VARCHAR(6),
    name        VARCHAR(20),
    center      VARCHAR(20),
    population  NUMERIC,
    area        NUMERIC,
    area_code   VARCHAR(4),
    post_code   VARCHAR(6),
    region_type VARCHAR(6),
    province    VARCHAR(8),
    city        VARCHAR(16),
    fence       GEOMETRY
);

COMMENT ON TABLE public.china_fences IS '中国民政部行政区划地理围栏2018';
COMMENT ON COLUMN china_fences.id IS '6位县级行政区划代码，主键';
COMMENT ON COLUMN china_fences.adcode IS '6位县级行政区划代码';
COMMENT ON COLUMN china_fences.name IS '行政区划名称';
COMMENT ON COLUMN china_fences.center IS '行政区划中心';
COMMENT ON COLUMN china_fences.population IS '行政区划人口';
COMMENT ON COLUMN china_fences.area IS '地区面积';
COMMENT ON COLUMN china_fences.area_code IS '地区代码（区号）';
COMMENT ON COLUMN china_fences.post_code IS '邮政编码';
COMMENT ON COLUMN china_fences.region_type IS '地区类型（后缀，等级）';
COMMENT ON COLUMN china_fences.province IS '所属省份';
COMMENT ON COLUMN china_fences.city IS '所属城市';
COMMENT ON COLUMN china_fences.fence IS '地理边界';

-- indexes
CREATE INDEX ON china_fences (adcode);
CREATE INDEX ON china_fences (area_code);
CREATE INDEX ON china_fences (name);
CREATE INDEX ON china_fences (post_code);
CREATE INDEX ON china_fences USING gist (fence);



--============================================================--
--                    Data Table Schema                        -
--============================================================--

------------------------------------------------
-- isd_hourly
--   hourly observation data
------------------------------------------------
CREATE TABLE IF NOT EXISTS public.isd_hourly
(
    station    VARCHAR(11) NOT NULL, -- station id
    ts         TIMESTAMP   NOT NULL, -- timestamp
    -- 气
    temp       NUMERIC(3, 1),        -- [-93.2,+61.8]
    dewp       NUMERIC(3, 1),        -- [-98.2,+36.8]
    slp        NUMERIC(5, 1),        -- [8600,10900]
    stp        NUMERIC(5, 1),        -- [4500,10900]
    vis        NUMERIC(6),           -- [0,160000]
    -- 风
    wd_angle   NUMERIC(3),           -- [1,360]
    wd_speed   NUMERIC(4, 1),        -- [0,90]
    wd_gust    NUMERIC(4, 1),        -- [0,110]
    wd_code    VARCHAR(1),           -- code that denotes the character of the WIND-OBSERVATION.
    -- 云
    cld_height NUMERIC(5),           -- [0,22000]
    cld_code   VARCHAR(2),           -- cloud code
    -- 水
    sndp       NUMERIC(5, 1),        -- mm 降雪
    prcp       NUMERIC(5, 1),        -- mm 降水
    prcp_hour  NUMERIC(2),           -- 降水时长
    prcp_code  VARCHAR(1),           -- 降水代码
    -- 天
    mw_code    VARCHAR(2),           -- 人工天气观测代码
    aw_code    VARCHAR(2),           -- 自动天气观测代码
    pw_code    VARCHAR(1),           -- 过去一段时间的天气代码
    pw_hour    NUMERIC(2),           -- 过去一段时间天气的时长
    -- 杂
    -- remark     TEXT,
    -- eqd        TEXT,
    data       JSONB
) PARTITION BY RANGE (ts);


ALTER TABLE isd_hourly
    ALTER COLUMN station SET STORAGE MAIN;
ALTER TABLE isd_hourly
    ALTER COLUMN cld_code SET STORAGE MAIN;
ALTER TABLE isd_hourly
    ALTER COLUMN prcp_code SET STORAGE MAIN;
ALTER TABLE isd_hourly
    ALTER COLUMN mw_code SET STORAGE MAIN;
ALTER TABLE isd_hourly
    ALTER COLUMN aw_code SET STORAGE MAIN;
ALTER TABLE isd_hourly
    ALTER COLUMN pw_code SET STORAGE MAIN;
ALTER TABLE isd_hourly
    ALTER COLUMN wd_code SET STORAGE MAIN;

COMMENT ON TABLE isd_hourly IS 'Integrated Surface Data (ISD) station from global hourly dataset';
COMMENT ON COLUMN isd_hourly.station IS '11 char usaf wban station identifier';
COMMENT ON COLUMN isd_hourly.ts IS 'observe timestamp in UTC';
COMMENT ON COLUMN isd_hourly.temp IS '[-93.2,+61.8] temperature of the air';
COMMENT ON COLUMN isd_hourly.dewp IS '[-98.2,+36.8] dew point temperature';
COMMENT ON COLUMN isd_hourly.slp IS '[8600,10900] air pressure relative to Mean Sea Level (MSL).';
COMMENT ON COLUMN isd_hourly.stp IS '[4500,10900] air pressure of station';
COMMENT ON COLUMN isd_hourly.vis IS '[0-160000] horizontal distance at which an object can be seen and identified';
COMMENT ON COLUMN isd_hourly.wd_angle IS '[1-360] angle measured in a clockwise direction';
COMMENT ON COLUMN isd_hourly.wd_speed IS '[0-900] rate of horizontal travel of air past a fixed point';
COMMENT ON COLUMN isd_hourly.wd_gust IS '[0-110] wind gust';
COMMENT ON COLUMN isd_hourly.wd_code IS 'code that denotes the character of the WIND-OBSERVATION.';
COMMENT ON COLUMN isd_hourly.cld_height IS 'the height above ground level';
COMMENT ON COLUMN isd_hourly.cld_code IS 'GF1-1 An indicator that denotes the start of a SKY-CONDITION-OBSERVATION data group.';
COMMENT ON COLUMN isd_hourly.sndp IS '降雪深度，毫米';
COMMENT ON COLUMN isd_hourly.prcp IS '降水，毫米';
COMMENT ON COLUMN isd_hourly.prcp_hour IS '降水时长';
COMMENT ON COLUMN isd_hourly.prcp_code IS '降水代码';
COMMENT ON COLUMN isd_hourly.mw_code IS 'MW1, 人工天气观测代码';
COMMENT ON COLUMN isd_hourly.aw_code IS 'AW1, PRESENT-WEATHER-OBSERVATION automated occurrence identifier';
COMMENT ON COLUMN isd_hourly.pw_code IS 'AY1-1, PAST-WEATHER-OBSERVATION manual atmospheric condition code';
COMMENT ON COLUMN isd_hourly.pw_hour IS 'AY1-3, PAST-WEATHER-OBSERVATION period quantity, 过去一段时间天气的时长';
-- COMMENT ON COLUMN isd_hourly.remark IS 'remark data section';
-- COMMENT ON COLUMN isd_hourly.eqd IS ' element quality data section.';
COMMENT ON COLUMN isd_hourly.data IS 'additional data fields in json format';

-- indexes
CREATE INDEX IF NOT EXISTS isd_hourly_ts_station_idx ON isd_hourly USING btree (ts, station);
CREATE INDEX IF NOT EXISTS isd_hourly_station_ts_idx ON isd_hourly USING btree (station, ts);


------------------------------------------------
-- isd_daily
--   daily observation summary data
------------------------------------------------
CREATE TABLE IF NOT EXISTS public.isd_daily
(
    -- 主键
    station     VARCHAR(12) NOT NULL, -- 台站号 6USAF+5WBAN
    ts          DATE        NOT NULL, -- 观测日期
    -- 温湿度
    temp_mean   NUMERIC(3, 1),        -- 平均温度 (℃)
    temp_min    NUMERIC(3, 1),        -- 最低温度 ℃
    temp_max    NUMERIC(3, 1),        -- 最高温度 ℃
    dewp_mean   NUMERIC(3, 1),        -- 平均露点 (℃)
    -- 气压
    slp_mean    NUMERIC(5, 1),        -- 海平面气压 (hPa)
    stp_mean    NUMERIC(5, 1),        -- 站点气压 (hPa)
    -- 视距
    vis_mean    NUMERIC(6),           -- 可视距离 (m)
    -- 风速
    wdsp_mean   NUMERIC(4, 1),        -- 平均风速 (m/s)
    wdsp_max    NUMERIC(4, 1),        -- 最大风速 (m/s)
    gust        NUMERIC(4, 1),        -- 最大阵风 (m/s)
    -- 降水/雪
    prcp_mean   NUMERIC(5, 1),        -- 降水量 (mm)
    prcp        NUMERIC(5, 1),        -- 根据降水标记修正后的降水量 (mm)
    sndp        NuMERIC(5, 1),        -- 当日最新上报的雪深 (mm)
    -- 天气现象 FRSHTT (Fog/Rain/Snow/Hail/Thunder/Tornado)
    is_foggy    BOOLEAN,              -- (F)og
    is_rainy    BOOLEAN,              -- (R)ain or Drizzle
    is_snowy    BOOLEAN,              -- (S)now or pellets
    is_hail     BOOLEAN,              -- (H)ail
    is_thunder  BOOLEAN,              --(T)hunder
    is_tornado  BOOLEAN,              -- (T)ornado or Funnel Cloud
    -- 计算各个统计量所使用的观测记录数量
    temp_count  SMALLINT,             -- 用于计算温度统计量的记录数量
    dewp_count  SMALLINT,             -- 用于计算平均露点的记录数量
    slp_count   SMALLINT,             -- 用于计算海平面气压统计量的记录数量
    stp_count   SMALLINT,             -- 用于计算站点气压统计量的记录数量
    wdsp_count  SMALLINT,             -- 用于计算风速统计量的记录数量
    visib_count SMALLINT,             -- 用于计算视距的记录数量
    -- 辅助标记
    temp_min_f  BOOLEAN,              -- 最低温度是统计得出（而非直接上报）
    temp_max_f  BOOLEAN,              -- 同上，最高温度
    prcp_flag   CHAR,                 -- 降水量标记: ABCDEFGHI
    PRIMARY KEY (ts, station)
) PARTITION BY RANGE (ts);

COMMENT ON TABLE isd_daily IS 'ISD每日摘要汇总表';
COMMENT ON COLUMN isd_daily.station IS '台站号 6USAF+5WBAN';
COMMENT ON COLUMN isd_daily.ts IS '观测日期';
COMMENT ON COLUMN isd_daily.temp_mean IS '平均温度 (℃)';
COMMENT ON COLUMN isd_daily.temp_min IS '最低温度 ℃';
COMMENT ON COLUMN isd_daily.temp_max IS '最高温度 ℃';
COMMENT ON COLUMN isd_daily.dewp_mean IS '平均露点 (℃)';
COMMENT ON COLUMN isd_daily.slp_mean IS '海平面气压 (hPa)';
COMMENT ON COLUMN isd_daily.stp_mean IS '站点气压 (hPa)';
COMMENT ON COLUMN isd_daily.vis_mean IS '可视距离 (m)';
COMMENT ON COLUMN isd_daily.wdsp_mean IS '平均风速 (m/s)';
COMMENT ON COLUMN isd_daily.wdsp_max IS '最大风速 (m/s)';
COMMENT ON COLUMN isd_daily.gust IS '最大阵风 (m/s)';
COMMENT ON COLUMN isd_daily.prcp_mean IS '降水量 (mm)';
COMMENT ON COLUMN isd_daily.prcp IS '根据降水标记修正后的降水量 (mm)';
COMMENT ON COLUMN isd_daily.sndp IS '当日最新上报的雪深 (mm)';
COMMENT ON COLUMN isd_daily.is_foggy IS '(F)og';
COMMENT ON COLUMN isd_daily.is_rainy IS '(R)ain or Drizzle';
COMMENT ON COLUMN isd_daily.is_snowy IS '(S)now or pellets';
COMMENT ON COLUMN isd_daily.is_hail IS '(H)ail';
COMMENT ON COLUMN isd_daily.is_thunder IS '(T)hunder';
COMMENT ON COLUMN isd_daily.is_tornado IS '(T)ornado or Funnel Cloud';
COMMENT ON COLUMN isd_daily.temp_count IS '用于计算温度统计量的记录数量';
COMMENT ON COLUMN isd_daily.dewp_count IS '用于计算平均露点的记录数量';
COMMENT ON COLUMN isd_daily.slp_count IS '用于计算海平面气压统计量的记录数量';
COMMENT ON COLUMN isd_daily.stp_count IS '用于计算站点气压统计量的记录数量';
COMMENT ON COLUMN isd_daily.wdsp_count IS '用于计算风速统计量的记录数量';
COMMENT ON COLUMN isd_daily.visib_count IS '用于计算视距的记录数量';
COMMENT ON COLUMN isd_daily.temp_min_f IS '最低温度是统计得出（而非直接上报）';
COMMENT ON COLUMN isd_daily.temp_max_f IS '同上，最高温度';
COMMENT ON COLUMN isd_daily.prcp_flag IS '降水量标记: ABCDEFGHI';

CREATE INDEX ON isd_daily (station, ts);


------------------------------------------------
-- isd_monthly
--   monthly observation summary data
------------------------------------------------
CREATE TABLE IF NOT EXISTS public.isd_monthly
(
    ts           DATE,          -- 月份时间戳,yyyy-mm-01
    station      VARCHAR(11),   -- 11位台站号
    temp_mean    numeric(3, 1), -- 月平均气温
    temp_min     numeric(3, 1), -- 月最低气温
    temp_max     numeric(3, 1), -- 月最高气温
    temp_min_avg numeric(3, 1), -- 月最低气温均值
    temp_max_avg numeric(3, 1), -- 月最高气温均值
    dewp_mean    numeric(3, 1), -- 月平均露点
    dewp_min     numeric(3, 1), -- 月最低露点
    dewp_max     numeric(3, 1), -- 月最高露点
    slp_mean     numeric(5, 1), -- 月平均气压
    slp_min      numeric(5, 1), -- 月最低气压
    slp_max      numeric(5, 1), -- 月最高气压
    prcp_sum     numeric(5, 1), -- 月总降水
    prcp_max     numeric(5, 1), -- 月最大降水
    prcp_mean    numeric(5, 1), -- 月平均降水
    wdsp_mean    numeric(4, 1), -- 月平均风速
    wdsp_max     numeric(4, 1), -- 月最大风速
    gust_max     numeric(4, 1), -- 月最大阵风
    sunny_days   smallint,      -- 月晴天日数
    windy_days   smallint,      -- 月大风日数
    foggy_days   smallint,      -- 月雾天日数
    rainy_days   smallint,      -- 月雨天日数
    snowy_days   smallint,      -- 月雪天日数
    hail_days    smallint,      -- 月冰雹日数
    thunder_days smallint,      -- 月雷暴日数
    tornado_days smallint,      -- 月龙卷日数
    hot_days     smallint,      -- 月高温日数
    cold_days    smallint,      -- 月低温日数
    vis_4_days   smallint,      -- 月能见度4km内日数
    vis_10_days  smallint,      -- 月能见度4-10km内日数
    vis_20_days  smallint,      -- 月能见度10-20km内日数
    vis_20p_days smallint,      -- 月能见度20km上日数
    primary key (ts, station)
) PARTITION BY RANGE (ts);

COMMENT ON TABLE isd_monthly IS 'ISD月度统计摘要汇总';
COMMENT ON COLUMN isd_monthly.ts IS '月份时间戳,yyyy-mm-01';
COMMENT ON COLUMN isd_monthly.station IS '11位台站号';
COMMENT ON COLUMN isd_monthly.temp_mean IS '月平均气温';
COMMENT ON COLUMN isd_monthly.temp_min IS '月最低气温';
COMMENT ON COLUMN isd_monthly.temp_max IS '月最高气温';
COMMENT ON COLUMN isd_monthly.temp_min_avg IS '月最低气温均值';
COMMENT ON COLUMN isd_monthly.temp_max_avg IS '月最高气温均值';
COMMENT ON COLUMN isd_monthly.dewp_mean IS '月平均露点';
COMMENT ON COLUMN isd_monthly.dewp_min IS '月最低露点';
COMMENT ON COLUMN isd_monthly.dewp_max IS '月最高露点';
COMMENT ON COLUMN isd_monthly.slp_mean IS '月平均气压';
COMMENT ON COLUMN isd_monthly.slp_min IS '月最低气压';
COMMENT ON COLUMN isd_monthly.slp_max IS '月最高气压';
COMMENT ON COLUMN isd_monthly.prcp_sum IS '月总降水';
COMMENT ON COLUMN isd_monthly.prcp_sum IS '月最大降水';
COMMENT ON COLUMN isd_monthly.prcp_mean IS '月平均降水';
COMMENT ON COLUMN isd_monthly.wdsp_mean IS '月平均风速';
COMMENT ON COLUMN isd_monthly.wdsp_max IS '月最大风速';
COMMENT ON COLUMN isd_monthly.gust_max IS '月最大阵风';
COMMENT ON COLUMN isd_monthly.sunny_days IS '月晴天日数';
COMMENT ON COLUMN isd_monthly.windy_days IS '月大风日数';
COMMENT ON COLUMN isd_monthly.foggy_days IS '月雾天日数';
COMMENT ON COLUMN isd_monthly.rainy_days IS '月雨天日数';
COMMENT ON COLUMN isd_monthly.snowy_days IS '月雪天日数';
COMMENT ON COLUMN isd_monthly.hail_days IS '月冰雹日数';
COMMENT ON COLUMN isd_monthly.thunder_days IS '月雷暴日数';
COMMENT ON COLUMN isd_monthly.tornado_days IS '月龙卷日数';
COMMENT ON COLUMN isd_monthly.hot_days IS '月高温日数';
COMMENT ON COLUMN isd_monthly.cold_days IS '月低温日数';
COMMENT ON COLUMN isd_monthly.vis_4_days IS '月能见度4km内日数';
COMMENT ON COLUMN isd_monthly.vis_10_days IS '月能见度4-10km内日数';
COMMENT ON COLUMN isd_monthly.vis_20_days IS '月能见度10-20km内日数';
COMMENT ON COLUMN isd_monthly.vis_20p_days IS '月能见度20km上日数';

CREATE INDEX IF NOT EXISTS isd_monthly_station_ts_idx ON isd_monthly (station, ts);
COMMENT ON INDEX isd_monthly_station_ts_idx IS '用于加速单Station历史数据查询';

------------------------------------------------
-- isd_yearly
--   yearly observation summary data
------------------------------------------------
CREATE TABLE IF NOT EXISTS public.isd_yearly
(
    ts           DATE,          -- 年份时间戳,yyyy-01-01
    station      VARCHAR(11),   -- 11位台站号
    temp_min     numeric(3, 1), -- 年最低气温
    temp_max     numeric(3, 1), -- 年最高气温
    dewp_min     numeric(3, 1), -- 年最低露点
    dewp_max     numeric(3, 1), -- 年最高露点
    prcp_sum     numeric(8, 1), -- 年总降水
    prcp_max     numeric(5, 1), -- 年最大降水
    wdsp_max     numeric(4, 1), -- 年最大风速
    gust_max     numeric(4, 1), -- 年最大阵风
    sunny_days   smallint,      -- 年晴天日数
    windy_days   smallint,      -- 年大风日数
    foggy_days   smallint,      -- 年雾天日数
    rainy_days   smallint,      -- 年雨天日数
    snowy_days   smallint,      -- 年雪天日数
    hail_days    smallint,      -- 年冰雹日数
    thunder_days smallint,      -- 年雷暴日数
    tornado_days smallint,      -- 年龙卷日数
    hot_days     smallint,      -- 年高温日数
    cold_days    smallint,      -- 年低温日数
    vis_4_days   smallint,      -- 年能见度4km内日数
    vis_10_days  smallint,      -- 年能见度4-10km内日数
    vis_20_days  smallint,      -- 年能见度10-20km内日数
    vis_20p_days smallint,      -- 年能见度20km上日数
    primary key (ts, station)
) PARTITION BY RANGE (ts);;

COMMENT ON TABLE isd_yearly IS 'ISD年度统计摘要汇总';
COMMENT ON COLUMN isd_yearly.ts IS '年份时间戳,yyyy-01-01';
COMMENT ON COLUMN isd_yearly.station IS '11位台站号';
COMMENT ON COLUMN isd_yearly.temp_min IS '年最低气温';
COMMENT ON COLUMN isd_yearly.temp_max IS '年最高气温';
COMMENT ON COLUMN isd_yearly.dewp_min IS '年最低露点';
COMMENT ON COLUMN isd_yearly.dewp_max IS '年最高露点';
COMMENT ON COLUMN isd_yearly.prcp_sum IS '年总降水';
COMMENT ON COLUMN isd_yearly.prcp_max IS '年最大降水';
COMMENT ON COLUMN isd_yearly.wdsp_max IS '年最大风速';
COMMENT ON COLUMN isd_yearly.gust_max IS '年最大阵风';
COMMENT ON COLUMN isd_yearly.sunny_days IS '年晴天日数';
COMMENT ON COLUMN isd_yearly.windy_days IS '年大风日数';
COMMENT ON COLUMN isd_yearly.foggy_days IS '年雾天日数';
COMMENT ON COLUMN isd_yearly.rainy_days IS '年雨天日数';
COMMENT ON COLUMN isd_yearly.snowy_days IS '年雪天日数';
COMMENT ON COLUMN isd_yearly.hail_days IS '年冰雹日数';
COMMENT ON COLUMN isd_yearly.thunder_days IS '年雷暴日数';
COMMENT ON COLUMN isd_yearly.tornado_days IS '年龙卷日数';
COMMENT ON COLUMN isd_yearly.hot_days IS '年高温日数';
COMMENT ON COLUMN isd_yearly.cold_days IS '年低温日数';
COMMENT ON COLUMN isd_yearly.vis_4_days IS '年能见度4km内日数';
COMMENT ON COLUMN isd_yearly.vis_10_days IS '年能见度4-10km内日数';
COMMENT ON COLUMN isd_yearly.vis_20_days IS '年能见度10-20km内日数';
COMMENT ON COLUMN isd_yearly.vis_20p_days IS '年能见度20km上日数';

CREATE INDEX IF NOT EXISTS isd_yearly_station_ts_idx ON isd_yearly (station, ts);
COMMENT ON INDEX isd_yearly_station_ts_idx IS '用于加速单Station历史数据查询';


--============================================================--
--                   Function Definition                       -
--============================================================--

------------------------------------------------
-- wind16
--   turn 360 degree angle to 16 compass direction
------------------------------------------------
CREATE OR REPLACE FUNCTION wind16(_i NUMERIC) RETURNS VARCHAR(3) AS
$$
SELECT CASE width_bucket(_i, 0, 360, 16) - 1
           WHEN 0 THEN 'N'
           WHEN 1 THEN 'NNE'
           WHEN 2 THEN 'NE'
           WHEN 3 THEN 'ENE'
           WHEN 4 THEN 'E'
           WHEN 5 THEN 'ESE'
           WHEN 6 THEN 'SE'
           WHEN 7 THEN 'SSE'
           WHEN 8 THEN 'S'
           WHEN 9 THEN 'SSW'
           WHEN 10 THEN 'SW'
           WHEN 11 THEN 'WSW'
           WHEN 12 THEN 'W'
           WHEN 13 THEN 'WNW'
           WHEN 14 THEN 'NW'
           WHEN 15 THEN 'NNW'
           WHEN NULL THEN 'C'
           END;
$$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION wind16(_i NUMERIC) IS '将0-360度转变为16向指南针方位标识';

------------------------------------------------
-- wind8
--   turn 360 degree angle to 8 compass direction
------------------------------------------------
CREATE OR REPLACE FUNCTION wind8(_i NUMERIC) RETURNS VARCHAR(3) AS
$$
SELECT CASE width_bucket(_i, 0, 360, 8) - 1
           WHEN 0 THEN 'N'
           WHEN 1 THEN 'NE'
           WHEN 2 THEN 'E'
           WHEN 3 THEN 'SE'
           WHEN 4 THEN 'S'
           WHEN 5 THEN 'SW'
           WHEN 6 THEN 'W'
           WHEN 7 THEN 'NW'
           WHEN NULL THEN 'C'
           END;
$$ LANGUAGE SQL IMMUTABLE;
COMMENT ON FUNCTION wind8(_i NUMERIC) IS '将0-360度转变为8向指南针方位标识';

------------------------------------------------
-- mwcode_name(mw_code text)
-- turn MW code into text representation
------------------------------------------------
CREATE OR REPLACE FUNCTION mwcode_name(mw_code text) RETURNS TEXT
AS
$$
SELECT CASE mw_code::INTEGER
           WHEN 0 THEN '云不可测'
           WHEN 1 THEN '云渐消散'
           WHEN 2 THEN '天像不变'
           WHEN 3 THEN '云渐成型'
           WHEN 4 THEN '烟遮视线'
           WHEN 5 THEN '雾霭蒙蒙'
           WHEN 6 THEN '灰尘弥漫'
           WHEN 7 THEN '风带灰尘'
           WHEN 8 THEN '风卷尘漫'
           WHEN 9 THEN '沙尘暴'
           WHEN 10 THEN '薄雾弥漫'
           WHEN 11 THEN '薄雾零散'
           WHEN 12 THEN '薄雾成片'
           WHEN 13 THEN '可见闪电'
           WHEN 14 THEN '雨不落地'
           WHEN 15 THEN '雨落地面'
           WHEN 16 THEN '雨落测站'
           WHEN 17 THEN '雷鸣电闪'
           WHEN 18 THEN '雨飑风啸'
           WHEN 19 THEN '漏斗龙卷'
           WHEN 20 THEN '毛毛细雨'
           WHEN 21 THEN '细雨不落'
           WHEN 22 THEN '细雪不落'
           WHEN 23 THEN '细雨冰霜'
           WHEN 24 THEN '毛毛冰雨'
           WHEN 25 THEN '阵雨'
           WHEN 26 THEN '阵雪'
           WHEN 27 THEN '阵冰雹'
           WHEN 28 THEN '雾与冰雾'
           WHEN 29 THEN '雷暴'
           WHEN 30 THEN '轻沙暴渐缓'
           WHEN 31 THEN '轻沙暴维持'
           WHEN 32 THEN '轻沙暴增强'
           WHEN 33 THEN '强沙暴渐缓'
           WHEN 34 THEN '强沙暴维持'
           WHEN 35 THEN '强沙暴增强'
           WHEN 36 THEN '轻飘雪减缓'
           WHEN 37 THEN '重飘雪减缓'
           WHEN 38 THEN '吹雪渐强'
           WHEN 39 THEN '重飘雪走强'
           WHEN 40 THEN '远方有雾'
           WHEN 41 THEN '片状雾'
           WHEN 42 THEN '雾缓天见'
           WHEN 43 THEN '雾缓天蔽'
           WHEN 44 THEN '雾恒天见'
           WHEN 45 THEN '雾恒天蔽'
           WHEN 46 THEN '雾浓天见'
           WHEN 47 THEN '雾浓天蔽'
           WHEN 48 THEN '雾凇天见'
           WHEN 49 THEN '雾凇天蔽'
           WHEN 50 THEN '雷断续毛毛雨'
           WHEN 51 THEN '雷持续毛毛雨'
           WHEN 52 THEN '雷中毛毛雨'
           WHEN 53 THEN '雷中毛雨'
           WHEN 54 THEN '雷大毛毛雨'
           WHEN 55 THEN '雷大毛毛雨'
           WHEN 56 THEN '雷冻小毛毛雨'
           WHEN 57 THEN '雷冻大毛毛雨'
           WHEN 58 THEN '雷轻毛毛雨'
           WHEN 59 THEN '雷重毛毛雨'
           WHEN 60 THEN '雷雨断续轻'
           WHEN 61 THEN '雷雨持续轻'
           WHEN 62 THEN '雷雨断续中'
           WHEN 63 THEN '雷雨持续中'
           WHEN 64 THEN '雷雨断续大'
           WHEN 65 THEN '雷雨持续大'
           WHEN 66 THEN '雷冻雨轻'
           WHEN 67 THEN '雷冻雨重'
           WHEN 68 THEN '雷冻雪轻'
           WHEN 69 THEN '雷冻雪重'
           WHEN 70 THEN '雷雪断续轻'
           WHEN 71 THEN '雷雪持续轻'
           WHEN 72 THEN '雷雪断续中'
           WHEN 73 THEN '雷雪持续中'
           WHEN 74 THEN '雷雪断续重'
           WHEN 75 THEN '雷雪持续中'
           WHEN 76 THEN '钻石星尘'
           WHEN 77 THEN '雪粒'
           WHEN 78 THEN '独立大雪花'
           WHEN 79 THEN '冰颗粒'
           WHEN 80 THEN '雷雨轻'
           WHEN 81 THEN '雷雨重'
           WHEN 82 THEN '雷夹特大雨'
           WHEN 83 THEN '雷雨夹雪轻'
           WHEN 84 THEN '雷雨夹雪重'
           WHEN 85 THEN '雷雪轻'
           WHEN 86 THEN '雷雪重'
           WHEN 87 THEN '小冰雹'
           WHEN 88 THEN '大冰雹'
           WHEN 89 THEN '无雷冰雹轻'
           WHEN 90 THEN '无雷冰雹重'
           WHEN 91 THEN '轻雨带阵雷'
           WHEN 92 THEN '重雨带阵雷'
           WHEN 93 THEN '轻雪带阵雷'
           WHEN 94 THEN '重雪带阵雷'
           WHEN 95 THEN '雷暴雨无冰雹'
           WHEN 96 THEN '雷暴夹冰雹'
           WHEN 97 THEN '雷暴带雨无雹'
           WHEN 98 THEN '雷暴夹沙暴'
           WHEN 99 THEN '重雷暴夹冰雹'
           ELSE '' END;
$$ LANGUAGE SQL;
COMMENT ON FUNCTION mwcode_name(mw_code text) IS '将2位数字MW天气代码转化为人类可读字符串';

------------------------------------------------
-- create_isd_hourly_partition
--    create yearly partition of isd_hourly
------------------------------------------------
CREATE OR REPLACE FUNCTION create_isd_hourly_partition(_year INTEGER, _upper INTEGER DEFAULT NULL) RETURNS TEXT AS
$$
DECLARE
    -- _part_name TEXT := CASE _upper WHEN NULL THEN format('isd_hourly_%s', _year) ELSE format('isd_hourly_%s_%s', _year,_upper) END;
    _part_name TEXT := format('isd_hourly_%s', _year);
    _part_lo   DATE := make_date(_year, 1, 1);
    -- _part_hi   DATE := CASE _upper WHEN NULL THEN make_date(_year + 1, 1, 1) ELSE make_date(_upper, 1, 1) END;
    _part_hi   DATE := coalesce(make_date(_upper, 1, 1), make_date(_year + 1, 1, 1));
    _sql       TEXT := format(
            $sql$
            CREATE TABLE IF NOT EXISTS %s PARTITION OF public.isd_hourly FOR VALUES FROM ('%s') TO ('%s');
            COMMENT ON TABLE %s IS 'isd_hourly partition from %s to %s';
            $sql$
        , _part_name, _part_lo, _part_hi, _part_name, _part_lo, _part_hi);
BEGIN
    RAISE NOTICE '%', _sql;
    EXECUTE _SQL;
    RETURN _part_name;
END;
$$
    LANGUAGE PlPGSQL
    VOLATILE;
COMMENT ON FUNCTION create_isd_hourly_partition(_year INTEGER, _upper INTEGER) IS 'create yearly partition of isd_hourly';

------------------------------------------------
-- world_geojson
-- get geojson of world map
-- arg1 (optional): scale 1m 3m 10m 20m 60m(default)
-- arg2 (optional): country code array
-- return: geojson
-------------------
-- example: get 1:10000000 US fence geojson
-- SELECT world_geojson('10m', codes=>ARRAY['US']);
------------------------------------------------
CREATE OR REPLACE FUNCTION world_geojson(scale TEXT DEFAULT '60m', codes TEXT[] DEFAULT NULL) RETURNS JSON AS
$$
BEGIN
    IF codes IS NULL THEN
        RETURN (SELECT row_to_json(fc) AS data
                FROM (
                         SELECT '{
                           "type": "world_fences",
                           "properties": {
                             "name": "urn:ogc:def:crs:EPSG::4326"
                           }
                         }'::JSON                                 AS crs
                              , 'FeatureCollection'               AS type
                              , array_to_json(array_agg(feature)) AS features
                         FROM (
                                  SELECT 'feature'                                                                   AS type
                                       , ST_AsGeoJSON(
                                          CASE scale
                                              WHEN '60m' THEN fence60m
                                              WHEN '20m' THEN fence20m
                                              WHEN '10m' THEN fence10m
                                              WHEN '3m' THEN fence3m
                                              WHEN '1m' THEN fence1m
                                              ELSE fence1m END
                                      , 3,
                                          1)::json                                                                   AS geometry
                                       , (SELECT row_to_json(t)
                                          FROM (SELECT id, iso2, iso3, name, name_raw, name_cn, name_cn_short) AS t) AS properties
                                  FROM world_fences
                              ) feature
                     ) fc);
    ELSE
        RETURN (SELECT row_to_json(fc) AS data
                FROM (
                         SELECT '{
                           "type": "world_fences",
                           "properties": {
                             "name": "urn:ogc:def:crs:EPSG::4326"
                           }
                         }'::JSON                                 AS crs
                              , 'FeatureCollection'               AS type
                              , array_to_json(array_agg(feature)) AS features
                         FROM (
                                  SELECT 'feature'                                                                   AS type
                                       , ST_AsGeoJSON(
                                          CASE scale
                                              WHEN '60m' THEN fence60m
                                              WHEN '20m' THEN fence20m
                                              WHEN '10m' THEN fence10m
                                              WHEN '3m' THEN fence3m
                                              WHEN '1m' THEN fence1m
                                              ELSE fence1m END
                                      , 3,
                                          1)::json                                                                   AS geometry
                                       , (SELECT row_to_json(t)
                                          FROM (SELECT id, iso2, iso3, name, name_raw, name_cn, name_cn_short) AS t) AS properties
                                  FROM world_fences
                                  WHERE id = ANY (codes)
                              ) feature
                     ) fc);
    END IF;
END;
$$ STABLE LANGUAGE PlPGSQL
   PARALLEL SAFE;
COMMENT ON FUNCTION world_geojson(scale TEXT, codes TEXT[]) IS 'generate geojson from world_fences';

------------------------------------------------
-- china_geojson
-- get geojson of china map
-- arg1 (optional): scale 1m 3m 10m 20m 60m(default)
-- arg2 (optional): country code array
-- return: geojson
-------------------
-- example: get china fences
-- SELECT china_geojson(ARRAY[110101]);
------------------------------------------------
CREATE OR REPLACE FUNCTION china_geojson(codes INTEGER[] DEFAULT NULL) RETURNS JSON AS
$$
BEGIN
    IF codes IS NULL THEN
        RETURN (SELECT row_to_json(fc) AS data
                FROM (
                         SELECT '{
                           "type": "china_fences",
                           "properties": {
                             "name": "urn:ogc:def:crs:EPSG::4326"
                           }
                         }'::JSON                                 AS crs
                              , 'FeatureCollection'               AS type
                              , array_to_json(array_agg(feature)) AS features
                         FROM (
                                  SELECT 'feature'                       AS type
                                       , ST_AsGeoJSON(fence, 6, 1)::json AS geometry
                                       , (SELECT row_to_json(t)
                                          FROM (SELECT id,
                                                       name,
                                                       center,
                                                       area_code,
                                                       post_code,
                                                       region_type,
                                                       province,
                                                       city) AS t)       AS properties
                                  FROM china_fences
                              ) feature
                     ) fc);
    ELSE
        RETURN (SELECT row_to_json(fc) AS data
                FROM (
                         SELECT '{
                           "type": "china_fences",
                           "properties": {
                             "name": "urn:ogc:def:crs:EPSG::4326"
                           }
                         }'::JSON                                 AS crs
                              , 'FeatureCollection'               AS type
                              , array_to_json(array_agg(feature)) AS features
                         FROM (
                                  SELECT 'feature'                       AS type
                                       , ST_AsGeoJSON(fence, 6, 1)::json AS geometry
                                       , (SELECT row_to_json(t)
                                          FROM (SELECT id,
                                                       name,
                                                       center,
                                                       area_code,
                                                       post_code,
                                                       region_type,
                                                       province,
                                                       city) AS t)       AS properties
                                  FROM china_fences
                                  WHERE id = ANY (codes)
                              ) feature
                     ) fc);
    END IF;
END;
$$ STABLE LANGUAGE PlPGSQL
   PARALLEL SAFE;
COMMENT ON FUNCTION china_geojson(codes INTEGER[]) IS 'generate geojson from china_fences';


------------------------------------------------
-- refresh_isd_latest
-- recalculate latest parition of isd_monthly and isd_yearly from isd_daily_latest
------------------------------------------------
CREATE OR REPLACE FUNCTION refresh_isd_latest() RETURNS VOID AS
$$
TRUNCATE isd_monthly_latest;
INSERT INTO isd_monthly_latest
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
FROM isd_daily_latest
GROUP by date_trunc('month', ts), station
ORDER BY 1, 2;

TRUNCATE isd_yearly_latest;
INSERT INTO isd_yearly_latest
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
FROM isd_monthly_latest
GROUP by date_trunc('year', ts), station
ORDER BY 1, 2;

$$ LANGUAGE SQL;

COMMENT ON FUNCTION refresh_isd_latest() IS 'recalculate latest partition of isd_monthly and isd_yearly';


-------------------------------------------------
-- create isd_hourly partitions
-------------------------------------------------

-----------------------------------
-- cleanup all isd_hourly partitions
-----------------------------------
DO
$$
    DECLARE
        _relname TEXT;
    BEGIN
        FOR _relname IN SELECT relname FROM pg_class WHERE relname ~ '^isd_hourly_\d{4}$'
            LOOP
                RAISE NOTICE 'DROP TABLE %s;', _relname;
                EXECUTE 'DROP TABLE IF EXISTS ' || _relname || ';';
            END LOOP;
    END
$$;

-----------------------------------
-- create all isd_hourly partitions
-- which are:
--    isd_hourly_1900 : [1900, 1950)
--    isd_hourly_1950 : [1950, 1960)
--    isd_hourly_1950 : [1950, 1960)
--    isd_hourly_1950 : [1950, 1960)
-----------------------------------
-- three merged partition: 50year, 10year, 10year
SELECT create_isd_hourly_partition(1900, 1950); -- 20 GB
SELECT create_isd_hourly_partition(1950, 1960); -- 47 GB
SELECT create_isd_hourly_partition(1960, 1970); -- 41 GB

-- the rest are yearly partition: from 1970 (10GB) to 2020 (41GB)
SELECT create_isd_hourly_partition(year::INTEGER)
FROM generate_series(1970, 2020) year;



-------------------------------------------------
-- create isd_daily / monthly / yearly partitions
-------------------------------------------------
CREATE TABLE IF NOT EXISTS isd_daily_stable PARTITION OF isd_daily FOR VALUES FROM ('1900-01-01') TO ('2021-01-01');
CREATE TABLE IF NOT EXISTS isd_daily_latest PARTITION OF isd_daily FOR VALUES FROM ('2021-01-01') TO (MAXVALUE);
COMMENT ON TABLE isd_daily_stable IS 'ISD年度摘要汇总表(稳定历史数据，2021前)';
COMMENT ON TABLE isd_daily_latest IS 'ISD年度摘要汇总表(最近一年数据，2021后)';

CREATE TABLE IF NOT EXISTS isd_monthly_stable PARTITION OF isd_monthly FOR VALUES FROM ('1900-01-01') TO ('2021-01-01');
CREATE TABLE IF NOT EXISTS isd_monthly_latest PARTITION OF isd_monthly FOR VALUES FROM ('2021-01-01') TO (MAXVALUE);
COMMENT ON TABLE isd_monthly_stable IS 'ISD年度摘要汇总表(稳定历史数据，2021前)';
COMMENT ON TABLE isd_monthly_latest IS 'ISD年度摘要汇总表(最近一年数据，2021后)';

CREATE TABLE IF NOT EXISTS isd_yearly_stable PARTITION OF isd_yearly FOR VALUES FROM ('1900-01-01') TO ('2021-01-01');
CREATE TABLE IF NOT EXISTS isd_yearly_latest PARTITION OF isd_yearly FOR VALUES FROM ('2021-01-01') TO (MAXVALUE);
COMMENT ON TABLE isd_yearly_stable IS 'ISD年度摘要汇总表(稳定历史数据，2021前)';
COMMENT ON TABLE isd_yearly_latest IS 'ISD年度摘要汇总表(最近一年数据，2021后)';

