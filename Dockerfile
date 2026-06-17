FROM python:3.12-slim-bookworm

ARG UID=1000
ARG GID=1000

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    libffi-dev \
    libncurses-dev \
    libusb-1.0-0 \
    libusb-dev \
    avrdude \
    stm32flash \
    dfu-util \
    libnewlib-arm-none-eabi \
    gcc-arm-none-eabi \
    binutils-arm-none-eabi \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid "${GID}" klipper \
    && useradd --uid "${UID}" --gid "${GID}" --create-home --shell /bin/bash klipper \
    && adduser klipper dialout 2>/dev/null || true

RUN mkdir -p /opt/klipper /home/moonraker/printer_data/config && chown -R klipper:klipper /home/klipper /opt/klipper

COPY --chown=klipper:klipper . /opt/klipper/

USER klipper
WORKDIR /opt/klipper

ENV PYTHONDIR=/home/klipper/klippy-env

RUN python3 -m venv "${PYTHONDIR}" \
    && "${PYTHONDIR}/bin/pip" install --no-cache-dir -r scripts/klippy-requirements.txt

VOLUME ["/home/moonraker/printer_data/config"]
EXPOSE 7125

ENTRYPOINT ["/home/klipper/klippy-env/bin/python"]
CMD ["/opt/klipper/klippy/klippy.py", "-I", "/tmp/printer", "-a", "/tmp/klippy_uds", \
     "-l", "/tmp/klippy.log", "/home/moonraker/printer_data/config/printer.cfg"]
