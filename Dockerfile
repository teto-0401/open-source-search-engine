
  FROM debian:bookworm-slim AS build

  RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential g++ make ca-certificates libssl-dev zlib1g-dev \
   && rm -rf /var/lib/apt/lists/*

  WORKDIR /app
  COPY . .
  RUN make -j2 CPPFLAGS+=" -std=gnu++03"

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
  COPY --from=build /app/*.dat /app/ || true
  COPY --from=build /app/coll.main.0 /app/coll.main.0 || true

  EXPOSE 8000 7000
  CMD ["./gb", "-d", "-f"]