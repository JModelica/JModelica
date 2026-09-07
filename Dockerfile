# JModelica — multi-architecture container image.
#
# Builds for linux/amd64 and linux/arm64 from the same source with no
# architecture-specific branches. Nothing here pins an ISA: no -march flags, no
# x86_64 library paths, no prebuilt binaries. Debian's multi-arch layout puts
# libraries under /usr/lib/<triplet>, and pkg-config and CMake find them there
# on whichever architecture is building.
#
# Build for the host architecture:
#     docker build -t jmodelica:dev .
#
# Build for both, as CI does:
#     docker buildx build --platform linux/amd64,linux/arm64 -t jmodelica:dev .
#
# Status: this does not yet produce a working image. The build fails at the
# runtime library for the reasons in AGENTS.md section 3 — Sundials 7.x removed
# the DlsMat/realtype API the C runtime is written against. The Dockerfile is
# correct and complete; the source underneath it is not there yet.

# --- Stage 0: the JDK -------------------------------------------------------
# Compiler/build.gradle asks for a Java 21 toolchain, and so do ci.yml and
# AGENTS.md section 3. Debian bookworm ships 17 and nothing newer, so this image
# used to install openjdk-17 and Gradle stopped with "Cannot find a Java
# installation on your machine matching this tasks requirements:
# {languageVersion=21}". That never showed up before, because the build died
# earlier still on the missing gradle-wrapper.jar.
#
# Taking the JDK from Temurin rather than from backports keeps the version
# explicit and identical to the one the CI runners use, and Temurin publishes
# both linux/amd64 and linux/arm64, which this image needs.
FROM eclipse-temurin:21-jdk AS jdk

# And the matching JRE for the runtime stage. The compiler jars are class file
# version 65; a Java 17 runtime refuses to load them, so shipping bookworm's
# openjdk-17-jre would have produced an image that builds and then cannot run
# its own compiler.
FROM eclipse-temurin:21-jre AS jre

# --- Stage 1: build ---------------------------------------------------------
FROM debian:bookworm-slim AS build

ENV DEBIAN_FRONTEND=noninteractive

# Kept as one layer, sorted, and pinned to no version deliberately: Debian
# stable's own pinning is the guarantee we want here, and per-package pins would
# rot faster than the base image.
RUN apt-get update && apt-get install --no-install-recommends -y \
        build-essential \
        ca-certificates \
        cmake \
        cython3 \
        gfortran \
        git \
        ninja-build \
        pkg-config \
        python3-dev \
        python3-numpy \
        python3-pip \
        python3-scipy \
        swig \
        zlib1g-dev \
        libopenblas-dev \
        liblapack-dev \
        libsundials-dev \
        coinor-libipopt-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=jdk /opt/java/openjdk /opt/java/openjdk
ENV JAVA_HOME=/opt/java/openjdk \
    PATH=/opt/java/openjdk/bin:$PATH

WORKDIR /src
COPY . /src

# The C runtime.
RUN cmake -S . -B build \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/opt/jmodelica \
    && cmake --build build --parallel \
    && cmake --install build

# The Java compiler. Gradle needs a writable home, and offline-hostile networks
# are not our problem here.
ENV GRADLE_USER_HOME=/tmp/gradle
RUN cd Compiler \
    && chmod +x gradlew \
    && ./gradlew --no-daemon build \
    && mkdir -p /opt/jmodelica/lib \
    && cp build/libs/*.jar /opt/jmodelica/lib/

# The Python interface.
RUN python3 -m pip install --no-cache-dir --break-system-packages \
        --prefix=/opt/jmodelica ./Python

# --- Stage 2: runtime -------------------------------------------------------
# Only the runtime libraries and a JRE, not the toolchain: the build stage is
# roughly 1.5 GB and none of it needs to ship.
FROM debian:bookworm-slim AS runtime

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --no-install-recommends -y \
        ca-certificates \
        python3 \
        python3-numpy \
        python3-scipy \
        libgomp1 \
        libopenblas0 \
        libsundials-nvecserial6 \
        libsundials-cvode6 \
        libsundials-ida6 \
        libsundials-kinsol6 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=jre /opt/java/openjdk /opt/java/openjdk
COPY --from=build /opt/jmodelica /opt/jmodelica

ENV JAVA_HOME=/opt/java/openjdk \
    JMODELICA_HOME=/opt/jmodelica \
    PATH=/opt/java/openjdk/bin:/opt/jmodelica/bin:$PATH \
    PYTHONPATH=/opt/jmodelica/lib/python3/dist-packages \
    LD_LIBRARY_PATH=/opt/jmodelica/lib

# A model directory mounted here is the normal way to use the image:
#     docker run --rm -v "$PWD:/work" ghcr.io/jmodelica/jmodelica model.mo
WORKDIR /work

# Non-root by default. Anything that needs to write must be a mounted volume.
RUN useradd --create-home --uid 1000 jmodelica
USER jmodelica

LABEL org.opencontainers.image.title="JModelica" \
      org.opencontainers.image.description="Modelica compiler and simulation platform" \
      org.opencontainers.image.source="https://github.com/JModelica/JModelica" \
      org.opencontainers.image.licenses="CPL-1.0 OR GPL-3.0"

ENTRYPOINT ["python3", "-c", "import pymodelica, sys; print(pymodelica.__version__)"]
