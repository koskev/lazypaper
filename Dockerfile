FROM rust:1.70 as lazymc_builder
RUN git clone https://github.com/timvisee/lazymc /usr/src/lazymc
WORKDIR /usr/src/lazymc
RUN cargo install --path .



FROM openjdk:17-slim as papermc_builder
ARG PAPERMC_VERSION=1.20.2
RUN apt-get update \
    && apt-get install -y git \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /papermc
RUN git config --global user.email "you@example.com" \
    && git config --global user.name "Your Name" \
    && git clone https://github.com/PaperMC/Paper -b ${PAPERMC_VERSION} /papermc
WORKDIR /papermc
RUN ./gradlew applyPatches && ./gradlew createReobfBundlerJar && mv /papermc/build/libs/paper-bundler*.jar /papermc/server.jar && ls -hal /papermc/build/libs


FROM openjdk:17-slim
RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*
COPY --from=lazymc_builder /usr/local/cargo/bin/lazymc /usr/bin/
COPY --from=papermc_builder /papermc/server.jar /usr/bin/
COPY entrypoint.sh /entrypoint.sh
WORKDIR /papermc
CMD ["/entrypoint.sh"]
