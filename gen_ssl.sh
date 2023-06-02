#!/bin/bash
mkdir certs

# Root CA
echo "Creating CA certificate and key"
openssl req -new -x509 -keyout certs/ca.key -out certs/ca.crt -days 365 -subj "/CN=Sample CA/OU=US/O=US/ST=US/C=US" -passout pass:my_pass

echo "Creating Truststore"
keytool -keystore certs/kafka.truststore.jks -alias CARoot -import -file certs/ca.crt -storepass my_pass -keypass my_pass -noprompt

# Node certs
echo "Creating node key"
keytool -keystore certs/kafka.keystore.jks -alias kafka -validity 365 -genkey -keyalg RSA -dname "cn=kafka, ou=US, o=US, c=US" -storepass my_pass -keypass my_pass
echo "Creating certificate sign request"
keytool -keystore certs/kafka.keystore.jks -alias kafka -certreq -file certs/tls.srl -storepass my_pass -keypass my_pass
echo "Signing certificate request using self-signed CA"
openssl x509 -req -CA certs/ca.crt -CAkey certs/ca.key \
    -in certs/tls.srl -out certs/tls.crt \
    -days 365 -CAcreateserial \
    -passin pass:my_pass
echo "Adding Ca certificate to the keystore"
keytool -keystore certs/kafka.keystore.jks -alias CARoot -import -file certs/ca.crt -storepass my_pass -keypass my_pass -noprompt
echo "Adding signed certificate"
keytool -keystore certs/kafka.keystore.jks -alias kafka -import -file certs/tls.crt -storepass my_pass -keypass my_pass -noprompt

# Cleanup
#rm certs/tls.crt certs/tls.srl
