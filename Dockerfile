FROM rust:1.70 as lazymc_builder
RUN git clone https://github.com/timvisee/lazymc /usr/src/lazymc
WORKDIR /usr/src/lazymc
RUN cargo install --path .



FROM openjdk:17-slim as papermc_builder
# 1.20.4
ARG PAPERMC_VERSION=d960bdc1734e8074ec23fa0779bdff5a2cc56a5454fe71fe332616532814a85a
RUN apt-get update \
    && apt-get install -y git \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /papermc
RUN git config --global user.email "you@example.com" \
    && git config --global user.name "Your Name" \
    && git clone https://github.com/PaperMC/Paper /papermc \
    && cd /papermc && git checkout ${PAPERMC_VERSION}
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
