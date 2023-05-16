# © Copyright IBM Corporation 2023
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# Use an official JDK image
FROM maven:3.8-openjdk-18 as BUILD

# Copy the application source code
COPY src /usr/src/app/src
COPY docs /usr/src/app/docs
COPY pom.xml /usr/src/app

# Run maven to build the application
RUN mvn -f /usr/src/app/pom.xml clean package 

FROM openjdk:19-jdk-alpine3.16

COPY --from=BUILD /usr/src/app/target/test-infinite-scale-0.0.1-SNAPSHOT-jar-with-dependencies.jar /app.jar
COPY docs /docs

CMD ["java", "-Xms512m", "-Xmx1024m", "-cp", "/app.jar", "com.ibm.demo.StartTests"]
