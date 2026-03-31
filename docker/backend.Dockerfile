# Build stage
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /build
COPY pom.xml .
COPY sm-core ./sm-core
COPY sm-core-model ./sm-core-model
COPY sm-core-modules ./sm-core-modules
COPY sm-shop ./sm-shop
COPY sm-shop-model ./sm-shop-model
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=builder /build/sm-shop/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
