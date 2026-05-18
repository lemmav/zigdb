# Basic Zig Dockerfile
FROM alpine:3.19 AS builder

RUN apk add --no-cache curl xz && \
    curl -L https://zig.mirror.mschae23.de/zig/zig-x86_64-linux-0.16.0.tar.xz | \
    tar -xJ -C /usr/local && \
    ln -s /usr/local/zig-x86_64-linux-0.16.0/zig /usr/local/bin/zig

WORKDIR /app

COPY build.zig build.zig.zon* ./
COPY src/ src/

RUN zig build -Doptimize=ReleaseSafe

FROM alpine:3.19 AS server

COPY --from=builder /app/zig-out/bin/server /server

RUN adduser -D -H ziguser
USER ziguser

CMD ["/server", "--", "-p", "8080"]


FROM alpine:3.19 AS client

COPY --from=builder /app/zig-out/bin/client /client

RUN adduser -D -H ziguser
USER ziguser

CMD ["/client", "--", "-p", "8080"]