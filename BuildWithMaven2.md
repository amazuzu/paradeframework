## Project Structure ##

```
CoolFlexApp/  
  bin-debug
  html-template
  libs/
    org/
      amazuzu/
        ioc/
          parade/
            parade/
              0.3.4/
                parade-0.3.4.swc   
  src
  pom.xml
```

## POM Example ##
```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<parent>
		<groupId>org.yourdomain.coolsoft</groupId>
		<artifactId>BestApp</artifactId>
		<version>1.0.0</version>
	</parent>
	<artifactId>bestapp</artifactId>
	<name>Your successfull app</name>
	<packaging>swf</packaging>
	<version>0.99</version>
	<repositories>
		<repository>
			<id>flexmojos-repository</id>
			<url>http://repository.sonatype.org/content/groups/public/</url>
		</repository>

		<repository>
			<id>your-local-repository</id>
			<url>file://${basedir}/libs</url>
		</repository>
	</repositories>
	<pluginRepositories>
		<pluginRepository>
			<id>flexmojos-repository</id>
			<url>http://repository.sonatype.org/content/groups/public/</url>
		</pluginRepository>
	</pluginRepositories>

	<build>
		<finalName>final-release</finalName>
		<sourceDirectory>src</sourceDirectory>
		<plugins>
			<plugin>
				<groupId>org.sonatype.flexmojos</groupId>
				<artifactId>flexmojos-maven-plugin</artifactId>
				<version>3.5.0</version>

				<extensions>true</extensions>
				<configuration>
					<sourceFile>MainPage.mxml</sourceFile>

					<keepAs3Metadatas>
						<keepAs3Metadata>Inject</keepAs3Metadata>
						<keepAs3Metadata>ParadeInitialize</keepAs3Metadata>
					</keepAs3Metadatas> 

				</configuration>
			</plugin>

		</plugins>
	</build>

	<dependencies>
		<dependency>
			<groupId>com.adobe.flex.framework</groupId>
			<artifactId>flex-framework</artifactId>
			<version>3.2.0.3958</version>
			<type>pom</type>
		</dependency>

                <!-- you must use this coolest logger -->
		<dependency>
			<groupId>com.room13.slf4fx</groupId>
			<artifactId>slf4fx</artifactId>
			<version>1</version>
			<type>swc</type>
		</dependency>
                <!-- and sure this cool IOC -->
		<dependency>
			<groupId>org.amazuzu.ioc.parade</groupId>
			<artifactId>parade</artifactId>
			<version>0.3.4</version>
			<type>swc</type>
		</dependency>

	</dependencies>
</project>
```