 Fase 1: El Problema del Túnel Cloudflare (Conectividad)
Empezamos con un problema fundamental: el túnel cloudflared no podía conectarse a Cloudflare.

El síntoma: Los logs mostraban errores como i/o timeout y no se podía establecer la conexión. Inicialmente, pensamos que era un problema de configuración o que el puerto 7844 (usado por QUIC) estaba bloqueado por el firewall de tu servidor (UFW).

La solución fallida: Desactivamos UFW y revisamos iptables, pero el problema persistía. Después de una profunda investigación, descubrimos que Cloudflare WARP estaba instalado y activo en tu servidor. WARP enruta todo el tráfico a través de su propia VPN. Esto creaba un conflicto, ya que el túnel estaba intentando conectarse a Cloudflare a través de la propia VPN de Cloudflare, lo que podría crear un bucle o bloqueo.

La solución real: Detuvimos y deshabilitamos el servicio warp-svc. Una vez que WARP dejó de redirigir el tráfico, la conectividad de red volvió a la normalidad.

🚀 Fase 2: Configuración e Instalación del Nuevo Túnel
Tras asegurar la conectividad, procedimos a instalar un túnel "remotamente gestionado" desde el panel de Cloudflare Zero Trust, que es la forma más moderna y recomendada por Cloudflare.

Creación desde el panel: Accedimos a one.dash.cloudflare.com y creamos un nuevo túnel llamado erpadso. Este método guarda la configuración en la nube, permitiendo gestionarlo sin necesidad de archivos config.yml en el servidor.

Autenticación y token: Como parte del proceso de creación desde el panel, generamos un nuevo token de autenticación para el túnel. Este token (eyJhIjoi...) es la "llave" que permite a cloudflared autenticarse con el túnel correcto.

Instalación y prueba: Ejecutamos el comando con el nuevo token en el servidor y confirmamos que el túnel se conectaba exitosamente usando el protocolo QUIC.

Servicio persistente: Para asegurar que el túnel se reiniciara automáticamente si el servidor se reinicia, creamos un servicio systemd (/etc/systemd/system/cloudflared.service) que ejecuta cloudflared con el token correspondiente.

🌐 Fase 3: Configuración del Enrutamiento DNS
Con el túnel corriendo, el siguiente paso fue decirle a Cloudflare qué tráfico enviar a través de él.

Registros DNS: En el panel de Cloudflare, en la sección DNS → Records, creamos los registros CNAME necesarios:

adsoerp.online apuntando a b496cddc-e118-49f5-89d4-1641656bedf1.cfargotunnel.com.

www.adsoerp.online apuntando al mismo túnel.

ssh.adsoerp.online apuntando al mismo túnel.

Estos registros, con el proxy status en naranja, aseguran que todo el tráfico web pase por la red de Cloudflare.

Rutas en el túnel (Public Hostname): Dentro del túnel erpadso, creamos las reglas de "Public Hostname" que enlazan el dominio con el servicio interno:

adsoerp.online → http://localhost:80

www.adsoerp.online → http://localhost:80

🔐 Fase 4: El Bucle de Redirecciones (HTTP → HTTPS → HTTP → ...)
Este fue el problema más complejo y que nos llevó más tiempo. El sitio entraba en un bucle infinito de redirecciones.

El síntoma: El navegador mostraba el error ERR_TOO_MANY_REDIRECTS y curl mostraba redirecciones 301 en un ciclo.

Investigación: Usamos curl -I para ver las cabeceras de redirección. Vimos que la redirección la generaba Apache (el servidor web), no tu aplicación PHP.

El culpable: Encontramos que el archivo de configuración del sitio por defecto de Apache (/etc/apache2/sites-available/000-default.conf) contenía una regla RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]. Esta regla forzaba una redirección a HTTPS para TODOS los sitios. Cuando Cloudflare recibía la petición, la enviaba a tu servidor por HTTP (internamente) y Apache, al ver que era HTTP, la redirigía a HTTPS. Esto creaba un bucle con Cloudflare.

La solución: Desactivamos el sitio 000-default.conf con sudo a2dissite 000-default.conf y aseguramos que solo el archivo de configuración de tu sitio (adsoerp.online.conf) estuviera activo. Luego, limpiamos también los archivos .htaccess que pudieran tener reglas similares y recargamos Apache.

🛡️ Fase 5: Ajustes Finales y Verificación
Prueba con test.php: Creamos un archivo PHP simple (/var/www/html/test.php) que solo mostraba el contenido de las variables de servidor. Al acceder a él, confirmamos que HTTP/2 200 OK y que Cloudflare enviaba correctamente las cabeceras HTTP_CF_VISITOR y HTTP_X_FORWARDED_PROTO.

Configuración de Cloudflare SSL: Finalmente, aseguramos que la configuración de SSL/TLS en Cloudflare estuviera en "Full (strict)" para garantizar la máxima seguridad en la conexión entre Cloudflare y tu servidor.

📋 Resumen de Comandos Clave
Para detener el bucle en Apache:

bash
sudo a2dissite 000-default.conf
sudo a2ensite adsoerp.online.conf
sudo systemctl reload apache2
Para verificar conectividad:

bash
curl -I https://adsoerp.online/test.php
Para revisar el estado del servicio:

bash
sudo systemctl status cloudflared
sudo systemctl status apache2
Con todo esto, hemos logrado:

Establecer un túnel Cloudflare estable y rápido usando QUIC.

Enrutar correctamente tu dominio adsoerp.online a tu servidor Apache local.

Resolver el bucle de redirecciones que rompía el acceso a tu sitio.

Asegurar que toda la conexión sea gestionada de forma segura por Cloudflare.