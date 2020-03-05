# Dockerfile para UD03 DEAW
# A partir de la imagen tar de Nora
# Alumno Eduardo Hernández García Retoque

FROM imagen-ud3:latest

# Responsable del fichero
LABEL \
	version="1.0" \
	description="Ubuntu18.04 + Apache2 + TE01 UDO3 (Proftpd + OpenSSL + SSH + Git)" \
	creationDate="16-01-2020" \
	maintainer="edhernandez.birt.eus"

# Ejecutamos comandos

RUN \
	apt-get install proftpd --yes \
	&& apt-get install openssl --yes\
	&& apt-get install unzip --yes \ 
	&& apt-get install ssh --yes \
	&& apt-get install git --yes 

# Copiamos ficheros necesarios

# COPY configs.ftp, certificados etc...
COPY SSH-key/deaw03_te1 /etc
COPY sshd_config /etc/ssh 
COPY proftpd.conf /etc/proftpd 
COPY tls.conf /etc/proftpd 
COPY proftpd.key /etc/ssl/private/proftpd.key 
COPY proftpd.crt /etc/ssl/certs/proftpd.crt


RUN \
	useradd -m -d /var/www/html/sitio1 -p $(openssl passwd -1 edu1) -s /usr/sbin/nologin edu1 \
	&& useradd -m -d /var/www/html/sitio2 -p $(openssl passwd -1 edu2) -s /bin/bash edu2 \
	&& useradd -m -d /home/edu -p $(openssl passwd -1 edu) -s /bin/bash edu \
	&& chown -hR edu1 /var/www/html/sitio1 \
	&& chown -hR edu2 /var/www/html/sitio2 \	
	&& mkdir /home/edu/proyecto-git \ 
	&& echo edu2 >> /etc/ftpusers \
	&& eval "$(ssh-agent -s)" \
	&& chmod 700 /etc/deaw03_te1 \
	&& ssh-add /etc/deaw03_te1 \
	&& ssh-keyscan -H github.com >> /etc/ssh/ssh_known_hosts \
	&& git clone git@github.com:deaw-birt/deaw03-te1-ftp-anonimo.git /home/edu/proyecto-git \
	#Para que el usuario edu tenga permiso en el proyecto-git he tenido que lanzar el chown tras git clone
	&& sleep 10 \
	&& chown -hR edu /home/edu/proyecto-git 


# Exponemos puertos (modificar)
EXPOSE 20 21 33 80 443 50000-50030

# NO OLVIDAR ARRANCAR SERVICIOS
# service apache2 start
# service proftpd start
# service ssh start