#!/bin/bash

# ----------------------------------------
# CONFIGURACIÓN
# ----------------------------------------
ACME_FILE="/certs/acme.json"                # Archivo fuente de Traefik
OUTPUT_DIR="/certs"                         # Donde dejar los .pem
CERT_FILE="$OUTPUT_DIR/fullchain.pem"
KEY_FILE="$OUTPUT_DIR/privkey.pem"

TMP_CERT="$(mktemp)"
TMP_KEY="$(mktemp)"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# ----------------------------------------
# VERIFICACIÓN INICIAL
# ----------------------------------------
if [ ! -f "$ACME_FILE" ]; then
  log "[!] Archivo acme.json no encontrado en $ACME_FILE"
  exit 0  # No lo tratamos como error crítico para cron
fi

# ----------------------------------------
# EXTRAER Y COMPARAR
# ----------------------------------------
log "[*] Verificando cambios en certificado para $DOMAIN_DOH..."

extract_cert() {
  local output
  output=$(jq -r --arg domain "$DOMAIN_DOH" '
    .["letsencrypt-cloudflare"].Certificates[] 
    | select(.domain.main == $domain) 
    | .certificate' "$ACME_FILE")

  if [ -n "$output" ] && echo "$output" | base64 --decode > "$1" 2>/dev/null; then
    return 0
  else
    return 1
  fi
}

extract_key() {
  local output
  output=$(jq -r --arg domain "$DOMAIN_DOH" '
    .["letsencrypt-cloudflare"].Certificates[] 
    | select(.domain.main == $domain) 
    | .key' "$ACME_FILE")

  if [ -n "$output" ] && echo "$output" | base64 --decode > "$1" 2>/dev/null; then
    return 0
  else
    return 1
  fi
}


# Intentar extracción
if extract_cert "$TMP_CERT" && extract_key "$TMP_KEY"; then
  log "[✓] Certificado y clave extraídos correctamente."
else
  log "[!] Error al extraer certificado o clave. ¿Dominio correcto o bloque ACME esperado?"
  rm -f "$TMP_CERT" "$TMP_KEY"
  exit 1
fi


# Comparar con archivos actuales
CERT_CHANGED=true
KEY_CHANGED=true

if [ -f "$CERT_FILE" ]; then
  cmp -s "$CERT_FILE" "$TMP_CERT" && CERT_CHANGED=false
fi

if [ -f "$KEY_FILE" ]; then
  cmp -s "$KEY_FILE" "$TMP_KEY" && KEY_CHANGED=false
fi

# ¿Cambió algo?
if $CERT_CHANGED || $KEY_CHANGED; then
  log "[+] Cambios detectados. Actualizando certificados..."
  cp "$TMP_CERT" "$CERT_FILE"
  cp "$TMP_KEY" "$KEY_FILE"
  log "[✓] Certificados actualizados:"
  log "    - $CERT_FILE"
  log "    - $KEY_FILE"
else
  log "[-] No hay cambios en los certificados. Nada que hacer."
fi

# Limpiar temporales
rm -f "$TMP_CERT" "$TMP_KEY"
