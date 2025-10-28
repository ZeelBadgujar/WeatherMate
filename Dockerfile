# Use official Tomcat image
FROM tomcat:9.0

# Remove default ROOT app and deploy your WAR
RUN rm -rf /usr/local/tomcat/webapps/ROOT
COPY dist/WeatherMate.war /usr/local/tomcat/webapps/ROOT.war

# Expose port 8080
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]