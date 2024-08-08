# Copyright (c) 2015-2019 carmera.com
#
# Data Access Layer for CLI
#
import sys

from sqlalchemy import create_engine, text
import sqlalchemy


# Class that connects with both Redshift and Postgres
class DBConnection:
    """Used for connections and queries to a Redshift or Postgres database."""

    def __init__(self, passw, database = 'test', username = 'postgres', server = 'localhost', port = 5432) -> object:
        """Create an instance of Redshift or Postgres Connection.  Set object instance variables so can work with multiple connections
        ----------
        passw: string -     The password for the user to connect to Redshift and Postgres
        username: string -  The user for the user to connect to Redshift and Postgres
        server: string -    The server for the user to connect to Redshift and Postgres
        database: string -  The database for the user to connect to Redshift and Postgres
        port: int -         The port for the user to connect to Redshift and Postgres
        """

        self.username = username
        self.database = database
        self.port = port
        self.passw = passw
        self.server = server


    def __enter__(self):
        """Connect when entering the runtime context.
        Returns a Reference to a Redshift or Postgres Connection instance
        """
        self.conn = self.connect(self.username, self.passw, self.server, self.port, self.database)
        return self

    def __exit__(self, *args):
        """Close the connection to the database when leaving the runtime context."""
        self.conn.close()

    def connect(self, username, passw, server, port, database):
        """Create a new connection to the database.
        Returns Connection to the database.
        """

        # test if password not entered and if so exit cleanly
        if passw == 'none':
            sys.exit("\nERROR:  No password supplied using -p argument and PGPASSWORD environment variable is not set.\n")

        db_string = "postgresql://%s:%s@%s:%s/%s" % (username, passw, server, port, database)
        db_engine = create_engine(db_string)

        # return conn
        try:
            conn = db_engine.connect()
        except Exception as e:
            print(e)
            sys.exit()
        return conn


    def execute(self, cmd):
        """ Execute Query on the database.
        """

        # use SQL Alchemy transaction
        trans = self.conn.begin()
        try:
            result = self.conn.execute(text(cmd))
        except Exception as e:
            print(f' Exception: {e}')

        trans.commit()
        return result


    def execute_file (self, path_to_file):
        """ Execute Query stored in a file on the database.
        """
        file = open(path_to_file)
        escaped_sql = sqlalchemy.text(file.read())

        # use SQL Alchemy transaction
        trans = self.conn.begin()
        result = self.conn.execute(escaped_sql)
        trans.commit()
        return result
