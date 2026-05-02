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
    apt-get install -y postgresql-client && \
    apt-get clean

# Instalar wkhtmltopdf y sus dependencias
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libxrender1 \
        libfontconfig1 \
        libjpeg62-turbo \
        xfonts-75dpi \
        xfonts-base

RUN if [ -z "${TARGETARCH}" ]; then \
        TARGETARCH="$(dpkg --print-architecture)"; \
    fi; \
    WKHTMLTOPDF_ARCH=${TARGETARCH} && \
    case ${TARGETARCH} in \
    "amd64") WKHTMLTOPDF_ARCH=amd64 && WKHTMLTOPDF_SHA=e9f95436298c77cc9406bd4bbd242f4771d0a4b2  ;; \
    "arm64") WKHTMLTOPDF_SHA=77bc06be5e543510140e6728e11b7c22504080d4  ;; \
    esac \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_${WKHTMLTOPDF_ARCH}.deb \
    && echo ${WKHTMLTOPDF_SHA} wkhtmltox.deb | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Instalar rtlcss para soporte RTL (Right-To-Left)
RUN npm install -g rtlcss

# Copiar configuraciones y dependencias
COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/
COPY ./odoo_utils.sh /usr/local/bin/odoo_utils.sh
ADD https://raw.githubusercontent.com/odoo/odoo/19.0/requirements.txt /
COPY requirementslocal.txt /

# Hacer el script ejecutable
RUN chmod +x /usr/local/bin/odoo_utils.sh

# Preparar pip y el entorno
RUN pip install --upgrade pip wheel && \
    rm -rf /root/.cache/pip && \
    pip install --no-cache-dir -r /requirements.txt && \
    pip install --no-cache-dir -r /requirementslocal.txt

# Crear usuario y directorios con UID/GID específico para compatibilidad con otros contenedores
# UID=107 GID=112 para compatibilidad con Odoo 16 en el mismo servidor
RUN groupadd -g 112 odoo && \
    useradd -m -u 107 -g odoo -s /bin/bash odoo && \
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
