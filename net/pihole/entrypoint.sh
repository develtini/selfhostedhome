#!/bin/bash

echo ">> Entrypoint iniciado"

# Ejecutar el script principal de Pi-hole
echo ">> Ejecutando Pi-hole start.sh"
/usr/bin/start.sh "$@"

# Comprobar si Pi-hole terminó correctamente
if [ $? -ne 0 ]; then
  echo "❌ Error al lanzar Pi-hole"
  exit 1
fi

# Lanzar dnsdist en segundo plano
echo ">> Lanzando dnsdist"
/usr/sbin/dnsdist -C /etc/dnsdist.conf &

echo "✅ dnsdist lanzado con PID $!"

# Evitar que el contenedor salga si todo fue exitoso
wait -n