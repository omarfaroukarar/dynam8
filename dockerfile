# Use Maven with JDK 17 for building the application
FROM maven:3.8.1-openjdk-17 AS builder

# Set the working directory
WORKDIR /app

# Copy the entire project (including pom.xml) to the working directory
COPY . .

# Build the application, skipping tests for faster build time
RUN mvn clean package -DskipTests

# Use Tomcat 9 with JDK 17 as the base image for deployment
FROM tomcat:9.0.80-jdk17

# Remove the default webapps to avoid conflicts
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR file from the builder stage to the Tomcat webapps directory
COPY --from=builder /app/target/java-servlet-app-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/

# Ensure catalina.sh is executable
RUN chmod +x /usr/local/tomcat/bin/catalina.sh

# Verify if catalina.sh exists and is executable
RUN ls -l /usr/local/tomcat/bin/catalina.sh

# Expose the port on which Tomcat runs
EXPOSE 8080

# Set the command to run Tomcat using /bin/bash for debugging
CMD ["/bin/bash", "-c", "/usr/local/tomcat/bin/catalina.sh run"]
