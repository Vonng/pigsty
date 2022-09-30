-------------------------------------------------------------------------
-- Top level namespace covid
-------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS app;
SET search_path TO app,public;

DROP TABLE IF EXISTS app.covid;
CREATE TABLE app.covid
(
    date         DATE,
    country_code VARCHAR(2) NOT NULL,
    country      TEXT,
    who_region   TEXT,
    new_cases    INTEGER,
    cum_cases    INTEGER,
    new_death    INTEGER,
    cum_death    INTEGER,
    PRIMARY KEY (date, country_code)
);
COMMENT ON TABLE app.covid IS 'WHO Coronavirus Disease (COVID-19) Historic Data by country';

CREATE INDEX ON app.covid (date);
CREATE INDEX ON app.covid (country_code);
CREATE INDEX ON app.covid (date, country_code);



CREATE SCHEMA IF NOT EXISTS app;
CREATE TABLE app.world
(
    id            INTEGER    NOT NULL PRIMARY KEY, -- iso3166 数值国家代码，主键
    iso2          VARCHAR(3) NOT NULL UNIQUE,      -- iso3166 2位字符国家代码，唯一
    iso3          VARCHAR(3) NOT NULL UNIQUE,      -- iso3166 3位字符国家代码，唯一
    ison          VARCHAR(3) NOT NULL UNIQUE,      -- iso3166 3位数字国家代码，唯一
    name          VARCHAR(64) UNIQUE,              -- 标准英文地名，唯一
    name_local    varchar(256) UNIQUE,             -- 本地语言名称，唯一
    name_en       VARCHAR(64) UNIQUE,              -- 英文名称，唯一
    name_cn       VARCHAR(64) UNIQUE,              -- 中文名称，唯一
    name_fr       VARCHAR(64),                     -- 法文名称
    name_ru       VARCHAR(64),                     -- 俄文名称
    name_es       VARCHAR(64),                     -- 西班牙语名称
    name_ar       VARCHAR(64),                     -- 阿拉伯文名称
    tld           VARCHAR(3),                      -- 顶级域名
    lang          VARCHAR(5)[],                    -- 使用的语言
    currency      VARCHAR(3)[],                    -- 三位货币代码，多种为数组
    cur_name      VARCHAR(32)[],                   -- 货币英文全称，多种为数组
    cur_code      VARCHAR(3)[],                    -- 货币数值代码，多种为数组
    dial          VARCHAR(18),                     -- 国际拨号代码
    wmo           VARCHAR(2),                      -- 世界气象组织代码/WMO
    itu           VARCHAR(3),                      -- 国际电信联盟代码/ITU
    ioc           VARCHAR(3) UNIQUE,               -- 国际奥委会代码/IOC
    fifa          VARCHAR(16) UNIQUE,              -- 国际足联代码/FIFA
    gaul          VARCHAR(6) UNIQUE,               -- 国际粮农组织代码/FAO
    edgar         VARCHAR(2) UNIQUE,               -- 美国证监会代码/SEC
    marc          VARCHAR(16),                     -- 美国国会图书馆代码
    fips          VARCHAR(32),                     -- 联邦信息处理代码/FIPS
    m49           VARCHAR(3),                      -- 联合国M49区划代码
    m49_marco_id  VARCHAR(3),                      -- M49 宏观地理区域编码
    m49_marco     VARCHAR(8),                      -- M49 宏观地理区域英文名
    m49_middle_id VARCHAR(3),                      -- M49 中间地理区域编码
    m49_middle    VARCHAR(16),                     -- M49 中间地理区域英文名
    m49_sub_id    VARCHAR(3),                      -- M49 地理亚区编码
    m49_sub       VARCHAR(32),                     -- M49 地理亚区英文名
    is_ldc        BOOLEAN,                         -- LDC，是否为最不发达作家
    is_lldc       BOOLEAN,                         -- LLDC，是否为内陆发展中国家
    is_sids       BOOLEAN,                         -- SIDS，是否为小岛屿发展中国家
    is_developed  BOOLEAN,                         -- 是否为发达国家
    is_sovereign  BOOLEAN,                         -- 是否为主权国家
    remark        VARCHAR(32),                     -- 备注：主权状态
    continent     VARCHAR(2),                      -- 二位大洲名称
    capital       VARCHAR(32),                     -- 首都英文名
    center        Geometry(Point, 4326),           -- 地理中心位置点
    fence         Geometry                         -- 1:6千万地理围栏（均不包含争议地区）
);
CREATE INDEX ON app.world (iso2);
CREATE INDEX ON app.world USING Gist(fence);

COMMENT ON TABLE   app.world               IS '世界行政区划代码表';
COMMENT ON COLUMN  app.world.id            IS 'iso3166 数值国家代码，主键';
COMMENT ON COLUMN  app.world.iso2          IS 'iso3166 2位字符国家代码，唯一';
COMMENT ON COLUMN  app.world.iso3          IS 'iso3166 3位字符国家代码，唯一';
COMMENT ON COLUMN  app.world.ison          IS 'iso3166 3位数字国家代码，唯一';
COMMENT ON COLUMN  app.world.name          IS '标准英文地名，唯一';
COMMENT ON COLUMN  app.world.name_local    IS '本地语言名称，唯一';
COMMENT ON COLUMN  app.world.name_en       IS '英文名称，唯一';
COMMENT ON COLUMN  app.world.name_cn       IS '中文名称，唯一';
COMMENT ON COLUMN  app.world.name_fr       IS '法文名称';
COMMENT ON COLUMN  app.world.name_ru       IS '俄文名称';
COMMENT ON COLUMN  app.world.name_es       IS '西班牙语名称';
COMMENT ON COLUMN  app.world.name_ar       IS '阿拉伯文名称';
COMMENT ON COLUMN  app.world.tld           IS '顶级域名';
COMMENT ON COLUMN  app.world.lang          IS '使用的语言';
COMMENT ON COLUMN  app.world.currency      IS '三位货币代码，多种为数组';
COMMENT ON COLUMN  app.world.cur_name      IS '货币英文全称，多种为数组';
COMMENT ON COLUMN  app.world.cur_code      IS '货币数值代码，多种为数组';
COMMENT ON COLUMN  app.world.dial          IS '国际拨号代码';
COMMENT ON COLUMN  app.world.wmo           IS '世界气象组织代码/WMO';
COMMENT ON COLUMN  app.world.itu           IS '国际电信联盟代码/ITU';
COMMENT ON COLUMN  app.world.ioc           IS '国际奥委会代码/IOC';
COMMENT ON COLUMN  app.world.fifa          IS '国际足联代码/FIFA';
COMMENT ON COLUMN  app.world.gaul          IS '国际粮农组织代码/FAO';
COMMENT ON COLUMN  app.world.edgar         IS '美国证监会代码/SEC';
COMMENT ON COLUMN  app.world.marc          IS '美国国会图书馆代码';
COMMENT ON COLUMN  app.world.fips          IS '联邦信息处理代码/FIPS';
COMMENT ON COLUMN  app.world.m49           IS '联合国M49区划代码';
COMMENT ON COLUMN  app.world.m49_marco_id  IS 'M49 宏观地理区域编码';
COMMENT ON COLUMN  app.world.m49_marco     IS 'M49 宏观地理区域英文名';
COMMENT ON COLUMN  app.world.m49_middle_id IS 'M49 中间地理区域编码';
COMMENT ON COLUMN  app.world.m49_middle    IS 'M49 中间地理区域英文名';
COMMENT ON COLUMN  app.world.m49_sub_id    IS 'M49 地理亚区编码';
COMMENT ON COLUMN  app.world.m49_sub       IS 'M49 地理亚区英文名';
COMMENT ON COLUMN  app.world.is_ldc        IS 'LDC，是否为最不发达作家';
COMMENT ON COLUMN  app.world.is_lldc       IS 'LLDC，是否为内陆发展中国家';
COMMENT ON COLUMN  app.world.is_sids       IS 'SIDS，是否为小岛屿发展中国家';
COMMENT ON COLUMN  app.world.is_developed  IS '是否为发达国家';
COMMENT ON COLUMN  app.world.is_sovereign  IS '是否为主权国家';
COMMENT ON COLUMN  app.world.remark        IS '备注：主权状态';
COMMENT ON COLUMN  app.world.continent     IS '二位大洲名称';
COMMENT ON COLUMN  app.world.capital       IS '首都英文名';
COMMENT ON COLUMN  app.world.center        IS '地理中心位置点';
COMMENT ON COLUMN  app.world.fence         IS '1:6千万地理围栏（均不包含争议地区）';


-- COPY app.covid FROM 'data/covid.csv' CSV HEADER;
-- COPY app.world FROM 'data/world.csv' CSV HEADER;

-- INSERT INTO app.covid SELECT * FROM covid.country_history;

DROP VIEW IF EXISTS app.covid_map;
CREATE OR REPLACE VIEW app.covid_map AS
SELECT date, country_code, country, who_region, new_cases, cum_cases, new_death, cum_death,
       id, iso2, iso3, ison, name, name_local, name_en, name_cn, name_fr, name_ru, name_es, name_ar,
       tld, lang, currency, cur_name, cur_code, dial, wmo, itu, ioc, fifa, gaul, edgar, marc, fips,
       m49, m49_marco_id, m49_marco, m49_middle_id, m49_middle, m49_sub_id, m49_sub,
       is_ldc, is_lldc, is_sids, is_developed, is_sovereign, remark, continent, capital,
       center, fence FROM
(SELECT DISTINCT ON (country_code) *
FROM app.covid ORDER BY country_code,date DESC) s
LEFT OUTER JOIN app.world w ON s.country_code = w.iso2
ORDER BY who_region, country;