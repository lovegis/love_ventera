# run commands against DB as postgres user using postgres password entered

# pre-requirement 1 - create 'gis_dba' role to own created database in requirement 1
psql -f src/sql/gis_dba_role.create.sql postgresql://postgres:pg_password_to_replace@localhost:5434

# requirement 1 a - create the DB
psql -f src/sql/ventera_db.create.sql postgresql://postgres:pg_password_to_replace@localhost:5434

# requirement 1 b - create PostGIS extension
python src/venpy.py db_object_creation postgis_extension.create.sql

# requirement 2 performed manually to download the data and copy to data/colorado_county.geojson

# pre-requirement 3 - create a 'states' schema to contain all additionally created objects
python src/venpy.py db_object_creation states_schema.create.sql

# requirement 3 - use GDAL ogr2ogr command to load colorado_county.geojson into states.colorado_county table
python src/venpy.py import_data colorado_county

# requirements 4-7 (documented in function_county_process.create.sql).  This function can be used for additional states.
python src/venpy.py db_object_creation function_county_process.create.sql
python src/venpy.py db_execute_sql "SELECT states.county_process('colorado_county')"
