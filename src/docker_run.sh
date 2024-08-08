docker pull elasticsearch:7.17.15
docker pull geonetwork:4.2

docker network create gn-network

docker run -d --name my-es-host --network gn-network -e "discovery.type=single-node" elasticsearch:7.17.15
docker run --name geonetwork-host --network gn-network -e ES_HOST=my-es-host -e ES_PROTOCOL=http -e ES_PORT=9200 -e GEONETWORK_DB_TYPE=postgres-postgis -e GEONETWORK_DB_HOST=host.docker.internal -e GEONETWORK_DB_PORT=5434 -e GEONETWORK_DB_NAME=geonetwork -e GEONETWORK_DB_USERNAME=postgres -e GEONETWORK_DB_PASSWORD=pg_password_to_replace -e GEONETWORK_DB_CONNECTION_PROPERTIES=search_path=geonetwork,public -p 8080:8080 geonetwork:4.2
