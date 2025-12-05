# --------------------------------------------------------------------------------
# BUILD PHASE
# --------------------------------------------------------------------------------
FROM maven:3.9.6-amazoncorretto-17 AS build

# Defines the working directory within the container
WORKDIR /app

# Copie the pom file
COPY pom.xml .

# Download dependencies
RUN mvn -q dependency:go-offline

# Copie the code
COPY src /app/src

# Compile the project and generate the JAR
RUN mvn clean package -DskipTests


# --------------------------------------------------------------------------------
# RUNTIME PHASE
# --------------------------------------------------------------------------------
# Lighter and safer base image
# FROM eclipse-temurin:17-jre-focal (testing)
FROM amazoncorretto:17-alpine


#USER nonroot

# Sets the working directory
WORKDIR /app

# Copies the compiled JAR from the BUILD PHASE
COPY --from=build /app/target/*.jar app.jar

# The Actuator uses port 8080 by default, and ECS/Fargate needs to know this
ENV PORT 8080
EXPOSE 8080

ARG SPRING_DATASOURCE_USERNAME
ARG SPRING_DATASOURCE_PASSWORD

ENV SPRING_DATASOURCE_USERNAME=$SPRING_DATASOURCE_USERNAME
ENV SPRING_DATASOURCE_PASSWORD=$SPRING_DATASOURCE_PASSWORD


# Sets the execution command
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
