FROM rust:1.71 as builder

RUN USER=root cargo new --bin backend
WORKDIR /backend

COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml
RUN cargo build --release
RUN rm src/*.rs
COPY ./src ./src

RUN cargo build --release --bin backend

FROM gcr.io/distroless/cc AS runtime
WORKDIR /backend
COPY --from=builder /backend/target/release/backend /usr/local/bin
ENTRYPOINT ["./usr/local/bin/app"]
