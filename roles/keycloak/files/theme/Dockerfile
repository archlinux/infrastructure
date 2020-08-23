FROM jboss/keycloak

USER root

RUN microdnf update -y && microdnf install -y vim && microdnf clean all

RUN sed -i 's|<cacheThemes>true</cacheThemes>|<cacheThemes>false</cacheThemes>|' /opt/jboss/keycloak/standalone/configuration/standalone.xml
RUN sed -i 's|<cacheTemplates>true</cacheTemplates>|<cacheTemplates>false</cacheTemplates>|' /opt/jboss/keycloak/standalone/configuration/standalone.xml
RUN sed -i 's|<staticMaxAge>2592000</staticMaxAge>|<staticMaxAge>-1</staticMaxAge>|' /opt/jboss/keycloak/standalone/configuration/standalone.xml
