FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copiar pubspec antes del código
COPY pubspec.yaml .

RUN flutter pub get

# Copiar todo el proyecto
COPY . .

# Asegurar soporte Web
RUN flutter config --enable-web

# Evitar problemas de permisos en pub cache
ENV PUB_CACHE=/tmp/.pub_cache

# Crear la carpeta web si el proyecto no la tiene
RUN test -d web || flutter create . --platforms=web

RUN flutter pub get
RUN flutter build web --release

# ======= Stage Nginx =========
FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]