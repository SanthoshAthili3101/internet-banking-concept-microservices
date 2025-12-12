# ==============================
# STAGE 1: Build the Application
# ==============================
# Use the official Gradle image with Java 21 to build the artifact
FROM gradle:8.7.0-jdk21-alpine AS builder

WORKDIR /app

# Copy the source code into the builder container
COPY . .

# Build the JAR file inside the container
# We skip tests here to speed up the build (tests should run in CI pipeline before this)
RUN gradle clean build -x test --no-daemon

# ==============================
# STAGE 2: Secure Runtime
# ==============================
# Use a lightweight Java 21 Runtime (JRE) for production
FROM eclipse-temurin:21-jre-alpine

# SECURITY: Create a non-root user 'spring'
RUN addgroup -S spring && adduser -S spring -G spring

WORKDIR /app

# Copy the built JAR from the 'builder' stage
# Note: Gradle puts jars in build/libs/
COPY --from=builder /app/build/libs/*.jar app.jar

# SECURITY: Change ownership to the non-root user
RUN chown spring:spring app.jar

# Switch to non-root user
USER spring

# Expose the port (Matches your old file)
EXPOSE 8083

# ENTRYPOINT
# We removed '-Dspring.profiles.active=docker'. 
# In K8s, we will inject this via an Environment Variable later.
ENTRYPOINT ["java", "-jar", "app.jar"]