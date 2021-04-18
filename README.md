# TODO Application with Quarkus

This is an example application based on a Todo list where the different tasks are created, read, updated, or deleted from the database. Default this application for convenience purposes uses an in-memory database called H2 that allows you to run this application without depending on an external database being available. However, the H2 database is not supported to run in native mode, so before you do the native compilation, you will have to switch to the `postgresql`  branch. 

## Quarkus MicroPofile metrics How to
1. Add smallrye dependencies
```xml
       <dependency>
            <groupId>io.quarkus</groupId>
            <artifactId>quarkus-smallrye-metrics</artifactId>
        </dependency>
```
2. Add metric for your rest api method
```java
   @GET
    @Path("/{id}")
    @Counted(name= "getOneTask", description = "How many get method being triggered.")
    @Timed(name = "getOneTaskTimer", description = "How long get one task perform", unit = MetricUnits.MILLISECONDS)
    public Todo getOne(@PathParam("id") Long id) {  ...  }
 
    @GET
    @Path("/{number}")
    @Produces(MediaType.TEXT_PLAIN)
    @Counted(name = "performedChecks", description = "How many primality checks have been performed.")
    @Timed(name = "checksTimer", description = "A measure of how long it takes to perform the primality test.", unit = MetricUnits.MILLISECONDS)
    public String checkIfPrime(@PathParam("number") long number) {...}
```
3. Configure quarkus to export metrics to /metrics

By default MicroProfile would export metrics at /q/metrics instead of **/metrics**.
Since prometheus is expecting endpint /metrics, we must explicit configure quarkus to change the metric rest path

```properties
#application.properties
quarkus.smallrye-metrics.path=/metrics
```

## Build and deploy it into a VM machine
```bash
#Execute on my laptop
mvn quarkus:dev
#Test my metrics is actual exporting
curl http://localhost:8080/metrics|grep Prime
application_io_quarkus_sample_PrimeNumberChecker_checksTimer_rate_per_second gauge
application_io_quarkus_sample_PrimeNumberChecker_checksTimer_rate_per_second 9.49227920251454E-4
...

podman build -f src/main/docker/Dockerfile.ubi . -t quay.io/rzhang/quarkus:todo-app-jvm-11-nodb
# log into my target virtual machine
ssh 192.168.2.10
podman run -d --name todo-app -p 8080:8080 quay.io/rzhang/quarkus:todo-app-jvm-11-nodb
```
## Branches:
* `master` - use H2 (in memory), no native support
* `postgresql` - use posgresql, support native mode 
* `openshift-monitor-external-service` -trim unecessary code for my articles "OpenShift monitoring for external service"

## Compile and run on a JVM

```bash
mvn package
java -jar target/todo-backend-1.0-SNAPSHOT-runner.jar
```

Then, open: http://localhost:8080/

## Development mode

```bash
mvn quarkus:dev
```
Then, open: http://localhost:8080/

## Compile to Native and run with PostgresSQL ( in a container )

Compile:
```bash
git checkout --track origin/postgresql
mvn clean package -Pnative
```
Run:
```bash
docker run --ulimit memlock=-1:-1 -it --rm=true --memory-swappiness=0 \
    --name postgres-quarkus-rest-http-crud \
    -e POSTGRES_USER=restcrud \
    -e POSTGRES_PASSWORD=restcrud \
    -e POSTGRES_DB=rest-crud \
    -p 5432:5432 postgres:10.5
target/todo-backend-*-runner
```
## Other links

- http://localhost:8080/health (Show the build in Health check for the datasource)
- http://localhost:8080/metrics (Show the default Metrics)
- http://localhost:8080/openapi (The OpenAPI Schema document in yaml format)
- http://localhost:8080/swagger-ui (The Swagger UI to test out the REST Endpoints)
- http://localhost:8080/graphql/schema.graphql (The GraphQL Schema document)
- http://localhost:8080/graphql-ui/ (The GraphiQL UI to test out the GraphQL Endpoint)
- http://localhost:8080/q/dev/ (Show dev ui)
