sed -i 's\pg_password_to_replace\$1\g' src/love_ventera_run.sh
sed -i 's\pg_password_to_replace\$1\g' src/docker_run.sh

sed -i 's\gis_dba_password_to_replace\$2\g' src/sql/gis_dba_role.create.sql
sed -i 's\gis_dba_password_to_replace\$2\g' src/venpy.py
