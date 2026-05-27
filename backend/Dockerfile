from eclipse-temurin:21-jdk

WORKDIR /app

copy target/gestion-evenements-1.0.0.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"] 