# Runtime stage only - uses pre-built JAR
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY artifacts/backend/app.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
