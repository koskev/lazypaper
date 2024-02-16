FROM openjdk:17-slim as lazymc_builder
# Prepare rustup
RUN apt-get update \
    && apt-get install -y curl git build-essential \
    && rm -rf /var/lib/apt/lists/*
ENV CARGO_HOME=/usr/local/cargo
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

ARG LAZYMC_COMMIT=c3ebeb0
RUN git clone https://github.com/koskev/lazymc /usr/src/lazymc && cd /usr/src/lazymc && git checkout ${LAZYMC_COMMIT}
WORKDIR /usr/src/lazymc
RUN $CARGO_HOME/bin/cargo install --path .


FROM openjdk:17-slim as papermc_builder
# 1.20.4
ARG PAPERMC_VERSION=1cda66e3952e520de53a94e160be6a6a99305e70
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
