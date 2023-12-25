#!/bin/bash -x


if [ ! -e lazymc.toml ]
then
  lazymc config generate
fi

echo "eula=true" > eula.txt

# Add RAM options to Java options if necessary
if [[ -n $MC_RAM ]]
then
  JAVA_OPTS="-Xms${MC_RAM} -Xmx${MC_RAM} $JAVA_OPTS"
fi

JAR_NAME="/usr/bin/server.jar"
NEW_COMMAND="java -server ${JAVA_OPTS} -jar ${JAR_NAME} nogui"
echo $NEW_COMMAND

sed -i -e "s@command = .*@command = \"${NEW_COMMAND}\"@g" lazymc.toml


lazymc
