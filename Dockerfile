
  FROM debian:bookworm-slim AS build

  RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential g++ make ca-certificates libssl-dev zlib1g-dev \
   && rm -rf /var/lib/apt/lists/*

  WORKDIR /app
  COPY . .
  RUN make -j2 CPPFLAGS+=" -std=gnu++11"
  RUN if [ ! -f gb.conf ]; then : > gb.conf; fi; \
      if [ ! -f hosts.conf ]; then printf "# The Gigablast host configuration file.\n# Tells us what hosts are participating in the distributed search engine.\n\n0 5998 7000 8000 9000 127.0.0.1 127.0.0.1 /app/\n\nnum-mirrors: 0\n\n# Format:\n# hostId dnsPort httpsPort httpPort udpPort ip1 ip2 workingDir\n" > hosts.conf; fi; \
      mkdir -p /app/opt; \
      if ls /app/*.dat >/dev/null 2>&1; then cp /app/*.dat /app/opt/; fi; \
      if [ -f /app/coll.main.0 ]; then cp /app/coll.main.0 /app/opt/; fi

  FROM debian:bookworm-slim

  RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates libssl3 zlib1g \
   && rm -rf /var/lib/apt/lists/*

  WORKDIR /app
  COPY --from=build /app/gb /app/gb
  COPY --from=build /app/gb.conf /app/gb.conf
  COPY --from=build /app/hosts.conf /app/hosts.conf
  COPY --from=build /app/html /app/html
  COPY --from=build /app/gb.pem /app/gb.pem
  COPY --from=build /app/opt/ /app/

  EXPOSE 8000 7000
  CMD ["./gb", "-d", "-f"]