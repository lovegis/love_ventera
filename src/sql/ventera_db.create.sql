-- Create Database with ownership gis_dba
CREATE DATABASE ventera
    WITH 
    OWNER = gis_dba
    ENCODING = 'UTF8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

GRANT ALL ON DATABASE ventera TO gis_dba;
GRANT TEMPORARY, CONNECT ON DATABASE ventera TO PUBLIC;

