#!/bin/bash
# ============================================================
# BENZIADA Fares, Grine Abderrahmane.
# SIQ2, SSR, LAB 2: PKI OpenSSL (Linux).
# Minimal OpenSSL Commands Script.
# ESI, March, 2026.
# ============================================================
#We suppose that all services are running in the same VM.

HOME=/root/ca

# ─────────────────────────────────────────────────────────────
# STEP 1 — PREPARE openssl.cnf
# Copy and configure the OpenSSL configuration file
# ─────────────────────────────────────────────────────────────

# Copy the default OpenSSL config into our working directory
cp /etc/pki/tls/openssl.cnf $HOME/

# Fix the DIR path to point to our CA directory
sed -i 's|./demoCA|/root/ca|g'    $HOME/openssl.cnf
sed -i 's|/etc/pki/CA|/root/ca|g' $HOME/openssl.cnf

# Add SAN support in [ v3_req ] section:
#   subjectAltName = @alt_names
#
# Add at the end of the file:
#   [ alt_names ]
#   DNS.1 = www.esi.dz
#   DNS.2 = *.esi.dz
#
# Edit manually with:
#vi $HOME/openssl.cnf

# ─────────────────────────────────────────────────────────────
# STEP 2 — CREATE THE CERTIFICATION AUTHORITY (CA)
# Generates a self-signed CA certificate + protected private key
# ─────────────────────────────────────────────────────────────
openssl req -new -x509 -extensions v3_ca \
    -keyout $HOME/private/cakey.pem \
    -out    $HOME/cacert.pem \
    -days   3650 \
    -config $HOME/openssl.cnf

# Display the root certificate
openssl x509 -text -in $HOME/cacert.pem

# ─────────────────────────────────────────────────────────────
# STEP 3 — CREATE THE WEB SERVER KEY PAIR AND CSR
# Generates the server private key + Certificate Signing Request
# Common Name must be: www.esi.dz
# ─────────────────────────────────────────────────────────────
openssl req -config $HOME/openssl.cnf \
    -new \
    -extensions v3_req \
    -keyout $HOME/private/webkey.pem \
    -out    $HOME/certs/newreq.pem

# ─────────────────────────────────────────────────────────────
# STEP 4 — SIGN THE CSR WITH THE CA
# The CA private key signs the CSR to produce the final certificate
# ─────────────────────────────────────────────────────────────
openssl ca -config $HOME/openssl.cnf \
    -policy     policy_anything \
    -extensions v3_req \
    -out        $HOME/certs/webcert.pem \
    -infiles    $HOME/certs/newreq.pem

# ─────────────────────────────────────────────────────────────
# STEP 5 — VERIFY THE CERTIFICATE CHAIN
# Confirms webcert.pem was correctly signed by our CA
# Expected output: certs/webcert.pem: OK
# ─────────────────────────────────────────────────────────────
openssl verify -CAfile $HOME/cacert.pem \
    $HOME/certs/webcert.pem

# Display the web server certificate
openssl x509 -text -in $HOME/certs/webcert.pem

# Verify SAN field is present (required by modern browsers)
openssl x509 -text -in $HOME/certs/webcert.pem \
    | grep -A 3 "Subject Alternative"

# ─────────────────────────────────────────────────────────────
# STEP 6 — REMOVE PASSPHRASE FROM THE SERVER PRIVATE KEY
# Apache needs an unencrypted key to start without user input
# ─────────────────────────────────────────────────────────────
openssl rsa -in  $HOME/private/webkey.pem \
            -out $HOME/private/webkey-clear.pem

# ─────────────────────────────────────────────────────────────
# STEP 7 — TEST THE SSL CONNECTION
# Verifies the full SSL handshake with the web server
# ─────────────────────────────────────────────────────────────
openssl s_client -connect www.esi.dz:443 --state

# ============================================================
# END OF SCRIPT
# ============================================================
