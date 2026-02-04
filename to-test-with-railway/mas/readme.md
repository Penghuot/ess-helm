ASUS@LAPTOP-NTMEL27D MINGW64 /d/Internship2/ess test/testing-latest/mas
$ docker build --no-cache -t local-mas .
[+] Building 25.4s (18/18) FINISHED   



docker run --rm -it \
  -p 8080:8080 \
  -e MAS_PUBLIC_BASE=http://localhost:8080/ \
  -e MAS_DATABASE_URI="postgresql://mas:maspass@host.docker.internal:5434/mas" \
  -e MAS_MATRIX_HOMESERVER=localhost \
  -e MAS_MATRIX_ENDPOINT=http://host.docker.internal:8008 \
  -e MAS_MATRIX_SHARED_SECRET='localnMXMz-q1xtz3t&~r+hetzWs,0O*VZ:QXIfuKmbNFC7tEt0Tq4xsharedsecret123' \
  -e MAS_CLIENT_ID=0000000000000000000SYNAPSE \
  -e MAS_CLIENT_SECRET=localclientsecret123 \
  -e MAS_ENCRYPTION_KEY="$(openssl rand -hex 32)" \
  -e MAS_SIGNING_KEY="-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIEESHxOh58JxiSsc7ripo/f0CxpLy36M9tJWnJmI4YvjoAoGCCqGSM49
AwEHoUQDQgAE3LPKIHA2pk8I2qUMlPjLEUPIhPDmXYyFm3GrHIqb19eM0cEvC7Er
TOBezK7hdwfArnRhMrqeyY2KZAMB0g5oSw==
-----END EC PRIVATE KEY-----" \
  -e MAS_EMAIL_DOMAIN=localhost \
  local-mas