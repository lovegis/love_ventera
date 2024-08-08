import sys, subprocess

#### venpy ####
from data_access import DBConnection

# For simplicity set DB connection settings as global variables (these should be accessed securely through a "vault" or AWS Secrets Manager)
GIS_PASS = 'gis_dba'
GIS_USER = 'gis_dba'
HOST = 'localhost'
PORT = 5434
DATABASE = 'ventera'

def import_data(state_name):
    print(f'Processing state: {state_name}')
    geoj = (f'data\\{state_name}.geojson')

    cmd = f'ogr2ogr -f "PostgreSQL" PG:"host={HOST} dbname={DATABASE} user={GIS_USER} password={GIS_PASS} port={PORT}" -unsetFid ' \
          f'"{geoj}" -nln "states.{state_name}" -lco geometry_name=geom -nlt GeometryZ'

    subprocess.run(cmd)
    return


def db_object_creation(file):
    print(f'Executing file on DB: src\\sql\\{file}')
    with DBConnection(GIS_PASS, DATABASE, GIS_USER, HOST, PORT) as db:
        db.execute_file('src\\sql\\' + file)
        return


def db_execute_sql(script):
    print(f'Executing function on DB: {script}')
    with DBConnection(GIS_PASS, DATABASE, GIS_USER, HOST, PORT) as db:
        db.execute(script)
        return

def main():
    """
    Main function to run the sample python code for Ventera Challenge 1
    """

    func_name = sys.argv[1]
    arg2 = sys.argv[2]

    print(f'Starting {func_name} function with {arg2}.')

    try:
        eval(f'{func_name}(arg2)')
        print(f'{func_name} {arg2} run complete!')
    except Exception as e:
        print(f' Exception: {e}')



if __name__ == '__main__':
    main()
