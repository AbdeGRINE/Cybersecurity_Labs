# BENZIADA Fares Abderraouf, Grine Abderrahmane.
# ESI, SIQ2, SSR.
# LAB2B: GNUPG with PKI.
# March, 2026.

#CA Server OPENSSL Commands (both for method 1 and 2):
----------------------------

# Convert to .pem format:
openssl req -inform DER -in certs/Benzii_client.p10 -out certs/Benzii_client.pem -text

# Sign the request by the CA:
openssl ca -config openssl.cnf -policy policy_anything -out certs/Benzii.pem -infiles certs/Benzii_client.pem

# Convert cacert.pem from PEM to CER:
openssl x509 -outform der -in cacert.pem -out cacert.cer

#Method 2 OPENSSL Commands:
----------------------------

# Generate User Private Key
openssl genrsa -out Benzii_private.key 2048

# Create Certificate Signing Request (CSR)
openssl req -new -key Benzii_private.key -out Benzii_client.pem

# Verify that the User Certificate is signed by the CA:
openssl verify -CAfile cacert.pem Benzii.pem