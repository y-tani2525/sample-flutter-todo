FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_HOME=/opt/flutter
ENV PATH=$PATH:$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin

RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Flutter SDK (stable)
RUN git clone https://github.com/flutter/flutter.git \
    -b stable \
    --depth 1 \
    $FLUTTER_HOME

RUN flutter config --no-analytics --enable-web && \
    flutter precache --web

WORKDIR /app

EXPOSE 8080

CMD ["sh", "start.sh"]
