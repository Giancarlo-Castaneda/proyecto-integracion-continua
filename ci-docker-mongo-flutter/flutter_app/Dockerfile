# -------- Stage 1: Build Flutter web app --------
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /work

# Crea un proyecto Flutter Web mínimo
RUN flutter create --platforms=web app
WORKDIR /work/app

# Copia tu main.dart (la UI que llama al backend)
COPY main.dart lib/main.dart

# Asegura soporte web y agrega la dependencia http usada por main.dart
RUN flutter config --enable-web
RUN flutter pub add http

# Compilación release para Web
RUN flutter build web --release

# -------- Stage 2: Serve with Nginx + proxy /api --------
FROM nginx:alpine

# Config Nginx que sirve Flutter y hace proxy /api -> backend:8000
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copia los artefactos compilados
COPY --from=build /work/app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
