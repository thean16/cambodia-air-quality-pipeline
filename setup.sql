-- ============================================
-- AirQualityDB Setup Script
-- Run once to recreate the full database schema
-- ============================================

-- 1. Create database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'AirQualityDB')
BEGIN
    CREATE DATABASE AirQualityDB;
    PRINT 'AirQualityDB created';
END
ELSE
    PRINT 'AirQualityDB already exists';
GO

-- 2. Enable mixed authentication mode (SQL Server + Windows Auth)
-- Required so airuser (SQL login) can connect, not just Windows accounts
USE master;
EXEC xp_instance_regwrite 
    N'HKEY_LOCAL_MACHINE', 
    N'Software\Microsoft\MSSQLServer\MSSQLServer',
    N'LoginMode', 
    REG_DWORD, 
    2;
PRINT 'Mixed auth enabled — restart SQL Server service for this to take effect';
GO

-- 3. Create login + database user with full permissions
USE master;
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'airuser')
BEGIN
    CREATE LOGIN airuser 
    WITH PASSWORD = 'Air@12345',
         CHECK_POLICY = OFF,
         CHECK_EXPIRATION = OFF;
    PRINT 'Login airuser created';
END
ELSE
    PRINT 'Login airuser already exists';

USE AirQualityDB;
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'airuser')
BEGIN
    CREATE USER airuser FOR LOGIN airuser;
    PRINT 'User airuser created';
END
ELSE
    PRINT 'User airuser already exists';

ALTER ROLE db_owner ADD MEMBER airuser;
PRINT 'Permissions granted to airuser';
GO

-- 4. Create all tables
USE AirQualityDB;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CleanedAirQuality')
CREATE TABLE dbo.CleanedAirQuality (
    id                    INT IDENTITY(1,1) PRIMARY KEY,
    city                  NVARCHAR(100),
    latitude              FLOAT,
    longitude             FLOAT,
    datetime              DATETIME2,
    aqi                   FLOAT,
    pm25                  FLOAT,
    pm10                  FLOAT,
    co                    FLOAT,
    no2                   FLOAT,
    so2                   FLOAT,
    o3                    FLOAT,
    created_at            DATETIME2,
    date                  DATE,
    hour                  INT,
    month                 INT,
    air_quality_category  NVARCHAR(100)
);

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CitySummary')
CREATE TABLE dbo.CitySummary (
    city           NVARCHAR(100),
    avg_pm25       FLOAT,
    max_pm25       FLOAT,
    total_records  INT
);

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PollutantAvg')
CREATE TABLE dbo.PollutantAvg (
    city      NVARCHAR(100),
    avg_pm25  FLOAT,
    avg_pm10  FLOAT,
    avg_co    FLOAT,
    avg_no2   FLOAT,
    avg_so2   FLOAT,
    avg_o3    FLOAT
);

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CategoryDistribution')
CREATE TABLE dbo.CategoryDistribution (
    air_quality_category  NVARCHAR(100),
    count                 INT
);

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DangerousAirQuality')
CREATE TABLE dbo.DangerousAirQuality (
    city                  NVARCHAR(100),
    air_quality_category  NVARCHAR(100),
    dangerous_count       INT
);

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LatestCityAirQuality')
CREATE TABLE dbo.LatestCityAirQuality (
    city                  NVARCHAR(100),
    datetime              DATETIME2,
    aqi                   FLOAT,
    pm25                  FLOAT,
    pm10                  FLOAT,
    air_quality_category  NVARCHAR(100)
);

PRINT 'All tables created';
GO

-- ============================================
-- Verification (run anytime to check status)
-- ============================================

-- Confirm tables + airuser permissions
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

SELECT dp.name, dp.type_desc, rp.name AS role
FROM sys.database_principals dp
JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
JOIN sys.database_principals rp ON drm.role_principal_id = rp.principal_id
WHERE dp.name = 'airuser';

-- Row counts per table
SELECT 'CleanedAirQuality'    AS table_name, COUNT(*) AS rows FROM dbo.CleanedAirQuality
UNION ALL
SELECT 'CitySummary',         COUNT(*) FROM dbo.CitySummary
UNION ALL
SELECT 'PollutantAvg',        COUNT(*) FROM dbo.PollutantAvg
UNION ALL
SELECT 'DangerousAirQuality', COUNT(*) FROM dbo.DangerousAirQuality;