# --------------------------------------------------------------------------------
# BUILD PHASE
# --------------------------------------------------------------------------------
FROM maven:3.9.6-amazoncorretto-17 AS build

# Defines the working directory within the container
WORKDIR /app

# Copies the build files from Maven
COPY pom.xml .
COPY src /app/src

# Compile the project and generate the JAR
RUN mvn clean package -DskipTests


# --------------------------------------------------------------------------------
# RUNTIME PHASE
# --------------------------------------------------------------------------------
# Lighter and safer base image
FROM openjdk:17-jdk-slim

#USER nonroot

# Sets the working directory
WORKDIR /app

# Copies the compiled JAR from the BUILD PHASE
COPY --from=build /app/target/*.jar app.jar

# The Actuator uses port 8080 by default, and ECS/Fargate needs to know this
ENV PORT 8080
EXPOSE 8080

# Sets the execution command
ENTRYPOINT ["java", "-jar", "/app/app.jar"]