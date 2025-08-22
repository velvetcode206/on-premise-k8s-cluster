FROM node:22-alpine AS builder

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

RUN apk add --no-cache openjdk21 bash git curl

WORKDIR /app
COPY pnpm-lock.yaml pnpm-workspace.yaml package.json nx.json /app
COPY packages/getting-started ./packages/getting-started

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

WORKDIR /app/packages/getting-started
RUN chmod +x ./gradlew

WORKDIR /app
RUN pnpm exec nx run getting-started:build -- --no-daemon --no-build-cache

FROM eclipse-temurin:21-jre-alpine AS runner

WORKDIR /app
COPY --from=builder /app/packages/getting-started/build/libs/*.jar ./app.jar

EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
