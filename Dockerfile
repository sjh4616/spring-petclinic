FROM openjdk:17-oracle 
ARG JAR_PATH=target/*.jar
COPY ${JAR_PATH} spring-petclinic.jar
EXPOSE 8080
CMD ["java", "-jar", "spring-petclinic.jar"]
