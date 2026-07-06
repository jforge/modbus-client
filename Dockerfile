FROM alpine:3.24.1 AS base
RUN apk upgrade --available --no-cache --update \
    && apk add --no-cache --update \
       python3=3.14.5-r0 \
       py3-pip=26.1.2-r0 \
    # Cleanup APK
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*



# Compiling python modules
FROM base AS builder
RUN apk add --no-cache --update \
      g++=15.2.0-r5 \
      python3-dev=3.14.5-r0 \
    && ln -s /usr/include/locale.h /usr/include/xlocale.h
COPY --chown=root:root FloatToHex /FloatToHex

WORKDIR /FloatToHex

RUN pip3 install --no-cache-dir -r /FloatToHex/requirements.txt --break-system-packages \
    && python3 setup.py install




# Building the docker image with already compiled modules
FROM base
LABEL maintainer="Michael Oberdorf IT-Consulting <info@oberdorf-itc.de>"
LABEL site.local.program.version="1.0.17"

COPY --from=builder /usr/lib/python3.14/site-packages /usr/lib/python3.14/site-packages

RUN apk add --no-cache --update \
      libstdc++=15.2.0-r5 \
      py3-wheel=0.47.0-r0 \
      py3-pandas=3.0.3-r0

COPY --chown=root:root /src /

RUN pip3 install --no-cache-dir -r /requirements.txt --break-system-packages

USER 3748:3748

# Start Server
ENTRYPOINT ["python", "-u", "/app/modbus_client.py"]
