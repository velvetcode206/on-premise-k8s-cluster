# Build Stage
FROM node:22-alpine AS builder

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN apk add --no-cache openjdk21 bash git curl \ 
&& corepack enable

WORKDIR /app
COPY pnpm-lock.yaml pnpm-workspace.yaml package.json nx.json /app
COPY packages/getting-started ./packages/getting-started
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

WORKDIR /app
RUN --mount=type=cache,target=/root/.gradle pnpm exec nx run getting-started:build -- --no-daemon

# Run Stage
FROM eclipse-temurin:21-jre-alpine AS runner

WORKDIR /app
COPY --from=builder /app/packages/getting-started/build/quarkus-app/ ./quarkus-app/

EXPOSE 8080
CMD ["java", "-jar", "quarkus-app/quarkus-run.jar"]
