-- Function to run all geoprocessing commands for Ventera Challenge 1.  This can be used to run all states, if desired.

CREATE OR REPLACE FUNCTION states.county_process(_state text)
    RETURNS void
    LANGUAGE plpgsql
AS $func$
DECLARE
    stmt text;
BEGIN
	stmt = E'
	SET search_path TO states, PUBLIC;

-------------------------
	-- Requirement 4:  Create a table of the county centroids:
	CREATE TABLE %s_centroids AS (
		SELECT ogc_fid, label, cnty_fips, ST_Centroid(geom) AS geom
		FROM %s
	);
    -- set primary key
	ALTER TABLE %s_centroids ADD PRIMARY KEY (ogc_fid);
    -- create spatial index using GIST
    CREATE INDEX IF NOT EXISTS %s_centroids_geom_idx
    ON %s_centroids USING gist (geom);

-------------------------
    -- Requirement 5:  Create a table from Buffer(ing) the County Centroids 20 miles (32186.9 meters)
    --   CAST geometry to geography so ST_Buffer can use meters to process distance but cast back to geometry
	CREATE TABLE %s_centroids_buffer AS (
		SELECT ogc_fid, label, cnty_fips, ST_Buffer(geom::geography, 32186.9)::geometry AS geom
		FROM %s_centroids
	);
    -- set primary key
	ALTER TABLE %s_centroids_buffer ADD PRIMARY KEY (ogc_fid);
    -- create spatial index using GIST
    CREATE INDEX IF NOT EXISTS %s_centroids_buffer_geom_idx
    ON %s_centroids_buffer USING gist (geom);

-------------------------
    -- Requirement 6:  Create a table from the dissolve and union of the the buffered County Centroids
	CREATE TABLE %s_buffer_union AS (
	    SELECT (ST_Dump(geom)).geom
	    FROM (SELECT ST_Union(geom) AS geom FROM %s_centroids_buffer) cnty
    );
    -- add a unique integer id for the Primary Key so we can create a foreign key for the child table in the next step
	ALTER TABLE %s_buffer_union ADD COLUMN  %s_buffer_union_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY;
    -- create spatial index using GIST
    CREATE INDEX IF NOT EXISTS %s_buffer_union_geom_idx
    ON %s_buffer_union USING gist (geom);

-------------------------
    --Requirement 7:  Create linestring(s) of all the exterior and interior "rings" of the buffered and union polygons
	CREATE TABLE %s_buffer_lines AS (
	    SELECT %s_buffer_union_id, ST_ExteriorRing((ST_DumpRings(geom)).geom) AS geom
        FROM %s_buffer_union
    );

    -- add a unique integer id for the Primary Key
	ALTER TABLE %s_buffer_lines ADD COLUMN id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY;

	-- add a Foreign Key from the "child" buffer_lines table that references the "parent" buffer_union table polygons
    ALTER TABLE %s_buffer_lines ADD CONSTRAINT %s_buffer_union_id_fk FOREIGN KEY (%s_buffer_union_id)
    REFERENCES %s_buffer_union (%s_buffer_union_id);
    -- create spatial index using GIST
    CREATE INDEX IF NOT EXISTS %s_buffer_lines_geom_idx
    ON %s_buffer_lines USING gist (geom);
    ';

    -- replace all the string placeholders, %s, with the _state argument so the process can by automated for all states
    --   or any polygonal geometry
    stmt = REPLACE(stmt, '%s', _state);

	EXECUTE stmt;
END;
$func$;

ALTER FUNCTION states.county_process(text) OWNER TO gis_dba;
GRANT EXECUTE ON FUNCTION states.county_process(text) TO PUBLIC;



