-- Role: gis_dba: we will use this role to own all objects (tables, sequences, and functions in the database)
-- DROP ROLE IF EXISTS gis_dba;

CREATE ROLE gis_dba WITH
  LOGIN
  SUPERUSER
  INHERIT
  CREATEDB
  CREATEROLE
  NOREPLICATION
  PASSWORD 'gis_dba_password_to_replace';

