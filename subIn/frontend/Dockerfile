FROM ghcr.io/cirruslabs/flutter:stable AS dev

WORKDIR /app

COPY pubspec.yaml ./
RUN flutter pub get

COPY . .

EXPOSE 3000
CMD ["flutter", "run", "-d", "web-server", "--web-port", "3000", "--host", "0.0.0.0"]

FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

COPY pubspec.yaml ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

FROM nginx:alpine AS prod
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
