# Do patch on the grpc-java
#rm ~/.m2/repository/io/grpc/grpc-netty-shaded/1.38.0/grpc-netty-shaded-1.38.0.jar
#mvn install:install-file -Dfile=grpc-netty-shaded-build/grpc-netty-shaded-1.38.0.jar -DgroupId=io.grpc -DartifactId=grpc-netty-shaded -Dversion=1.38.0 -Dpackaging=jar

# Compile if the source code is changed
mvn compile

# Run the method
mvn exec:java \
	-Dexec.cleanupDaemonThreads=false \
	-Dexec.mainClass="sample.Sample"
