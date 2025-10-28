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
FROM eclipse-temurin:17-jre-focal

#USER nonroot

# Sets the working directory
WORKDIR /app

# Inserting the Agent into the Container
ADD https://dtdg.co/latest-java-tracer /app/dd-java-agent.jar

# Copies the compiled JAR from the BUILD PHASE
COPY --from=build /app/target/*.jar app.jar

# The Actuator uses port 8080 by default, and ECS/Fargate needs to know this
ENV PORT 8080
EXPOSE 8080

ARG SPRING_PROFILES_ACTIVE
ENV SPRING_PROFILES_ACTIVE=$SPRING_PROFILES_ACTIVE

# Build args para receber as variáveis do RDS
ARG SPRING_DATASOURCE_URL
ARG SPRING_DATASOURCE_USERNAME
ARG SPRING_DATASOURCE_PASSWORD

# Exporta como variáveis de ambiente para o Spring Boot
ENV SPRING_DATASOURCE_URL=$SPRING_DATASOURCE_URL
ENV SPRING_DATASOURCE_USERNAME=$SPRING_DATASOURCE_USERNAME
ENV SPRING_DATASOURCE_PASSWORD=$SPRING_DATASOURCE_PASSWORD

# Sets the execution command
#ENTRYPOINT ["java", "-jar", "/app/app.jar"]
ENTRYPOINT ["java", "-javaagent:/app/dd-java-agent.jar", "-jar", "/app/app.jar"]