# Utilizando una imagen base de Python compatible con Debian
FROM python:3.12-bookworm

# Metadatos del mantenedor
LABEL maintainer="Blanco Martin y Asociados SpA. <odoocl@bmya.cl>"

# Usar un shell robusto
SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Configuración de localización
ENV LANG=en_US.UTF-8

# Argumento para arquitectura
ARG TARGETARCH

# Dependencias del sistema y herramientas de desarrollo
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev \
        libldap2-dev \
        libsasl2-dev \
        libssl-dev \
        ca-certificates \
        curl \
        fonts-noto-cjk \
        node-less \
        npm \
        python3-dev \
        python3-psycopg2 \
        xz-utils \
        libcairo2-dev \
        libfreetype6-dev \
        zlib1g-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Agregar repositorio de PostgreSQL y claves de firma
RUN apt-get update && \
    apt-get install -y wget gnupg && \
    wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y postgresql-client-14 && \
    apt-get clean

# Instalar wkhtmltopdf y sus dependencias
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libxrender1 \
        libfontconfig1 \
        libjpeg62-turbo \
        xfonts-75dpi \
        xfonts-base

RUN case "${TARGETARCH}" in \
      "arm64"|"amd64") \
        WKHTML_ARCH="${TARGETARCH}" ;; \
      *) echo "Arquitectura no soportada: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    curl -o wkhtmltox.deb -sSL "https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_${WKHTML_ARCH}.deb" && \
    apt-get install -y --no-install-recommends ./wkhtmltox.deb && \
    rm -rf /var/lib/apt/lists/* wkhtmltox.deb

RUN npm install -g rtlcss && \
    npm install -g webpack@5.77.0 && \
    npm install -g @babel/traverse@7.23.2

# 5.77 y 7.23 repara vulnerabilidades

# Copiar configuraciones y dependencias
COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/
COPY ./odoo_utils.sh /usr/local/bin/odoo_utils.sh
ADD https://raw.githubusercontent.com/odoo/odoo/18.0/requirements.txt /
COPY requirementslocal.txt /

# Hacer el script ejecutable
RUN chmod +x /usr/local/bin/odoo_utils.sh

# Preparar pip y el entorno
RUN pip install --upgrade pip wheel cython && \
    rm -rf /root/.cache/pip && \
    pip install --no-cache-dir -r /requirements.txt && \
    pip install --no-cache-dir -r /requirementslocal.txt && \
    pip install --no-cache-dir --force-reinstall reportlab==4.1.0 pillow==10.2.0 pycairo==1.25.1 rlPyCairo==0.3.0 ipython==8.20.0

# Configurar el backend PIL para reportlab (opcional, puede omitirse si rlPyCairo funciona)
ENV REPORTLAB_RENDERPM_BACKEND=PIL

# Crear usuario y directorios
RUN useradd -ms /bin/bash odoo && \
    mkdir -p /mnt/extra-addons && \
    chown -R odoo /mnt/extra-addons /etc/odoo/odoo.conf

# Configuración de volúmenes y puertos
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]
EXPOSE 8069 8071 8072

# Configuración predeterminada
ENV ODOO_RC=/etc/odoo/odoo.conf

# Script para esperar PostgreSQL
COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Cambiar al usuario odoo
USER odoo

# Entrypoint y comando predeterminado
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo-bin"]