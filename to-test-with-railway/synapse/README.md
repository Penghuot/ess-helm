docker build --no-cache -t local-synapse .


docker run -d --name synapse \
  -p 8008:8008 \
  --link synapse-db \
  -e SYNAPSE_SERVER_NAME=localhost:8008 \
  -e SYNAPSE_PUBLIC_BASEURL=http://localhost:8008/ \
  -e SYNAPSE_DB_USER=synapse \
  -e SYNAPSE_DB_PASSWORD=synapsepass \
  -e SYNAPSE_DB_HOST=host.docker.internal \
  -e SYNAPSE_DB_PORT=5433 \
  -e SYNAPSE_DB_NAME=synapse \
  -e SYNAPSE_REGISTRATION_SHARED_SECRET=nMXMz-q1xtz3t&~r+hetzWs,0O*VZ:QXIfuKmbNFC7tEt0Tq4x \
  -e SYNAPSE_MACAROON_SECRET_KEY=$(openssl rand -hex 32) \
  -e SYNAPSE_FORM_SECRET=$(openssl rand -hex 32) \
  local-synapse



docker run -d --name synapse \
  -p 8008:8008 \
  --link synapse-db \
  -e SYNAPSE_SERVER_NAME=localhost:8008 \
  -e SYNAPSE_PUBLIC_BASEURL=http://localhost:8008/ \
  -e SYNAPSE_DB_USER=synapse \
  -e SYNAPSE_DB_PASSWORD=synapsepass \
  -e SYNAPSE_DB_HOST=host.docker.internal \
  -e SYNAPSE_DB_PORT=5433 \
  -e SYNAPSE_DB_NAME=synapse \
  -e SYNAPSE_REGISTRATION_SHARED_SECRET='nMXMz-q1xtz3t&~r+hetzWs,0O*VZ:QXIfuKmbNFC7tEt0Tq4x' \
  -e SYNAPSE_MACAROON_SECRET_KEY="$(openssl rand -hex 32)" \
  -e SYNAPSE_FORM_SECRET="$(openssl rand -hex 32)" \
  local-synapse


    -e SYNAPSE_ENABLE_REGISTRATION=true \