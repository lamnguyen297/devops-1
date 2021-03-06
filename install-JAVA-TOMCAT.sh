#!/bin/bash
# -------
# Script to configure and setup Maven, Ant, Java, Tomcat, Database, Jenkins
#
# -------

TOMCAT8_VERSION=8.5.29
MAVEN_VERSION=3.3.9
ANT_VERSION=1.9.10
export DEVOPS_HOME=/home/devops
export BASE_INSTALL=/home/ubuntu/devops
export TMP_INSTALL=/tmp/devops-install
export CATALINA_HOME=$DEVOPS_HOME/tomcat
export DEVOPS_USER=devops
export DEFAULTDB=MA

export APTVERBOSITY="-qq -y"
export DEFAULTYESNO="y"

export TOMCAT_DOWNLOAD=http://mirrors.viethosting.com/apache/tomcat/tomcat-8/v$TOMCAT8_VERSION/bin/apache-tomcat-$TOMCAT8_VERSION.tar.gz
export JDBCPOSTGRESURL=https://jdbc.postgresql.org/download
export JDBCPOSTGRES=postgresql-42.1.4.jar
export JDBCMYSQLURL=https://dev.mysql.com/get/Downloads/Connector-J
export JDBCMYSQL=mysql-connector-java-5.1.43.tar.gz

export APACHEMAVEN=https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
export APACHEANT=https://www.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz
export JAVA8URL=http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jdk-8u161


# Color variables
txtund=$(tput sgr 0 1)          # Underline
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgre=${txtbld}$(tput setaf 2) #  red
bldblu=${txtbld}$(tput setaf 4) #  blue
bldwht=${txtbld}$(tput setaf 7) #  white
txtrst=$(tput sgr0)             # Reset
info=${bldwht}*${txtrst}        # Feedback
pass=${bldblu}*${txtrst}
warn=${bldred}*${txtrst}
ques=${bldblu}?${txtrst}

echoblue () {
  echo "${bldblu}$1${txtrst}"
}
echored () {
  echo "${bldred}$1${txtrst}"
}
echogreen () {
  echo "${bldgre}$1${txtrst}"
}

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echogreen "Begin running...."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo


URLERROR=0

for REMOTE in $TOMCAT_DOWNLOAD $JDBCPOSTGRESURL/$JDBCPOSTGRES $JDBCMYSQLURL/$JDBCMYSQL \
				$APACHEMAVEN $APACHEANT
do
        wget --spider $REMOTE --no-check-certificate >& /dev/null
        if [ $? != 0 ]
        then
                echored "Please fix this URL: $REMOTE and try again later"
                URLERROR=1
        fi
done

if [ $URLERROR = 1 ]
then
    echo
    echored "Please fix the above errors and rerun."
    echo
    exit
fi

# Create temporary folder for storing downloaded files
if [ ! -d "$TMP_INSTALL" ]; then
  mkdir -p $TMP_INSTALL
fi

# Create home directory for application instance
if [ ! -d "$DEVOPS_HOME" ]; then
  mkdir -p $DEVOPS_HOME
fi

cd $TMP_INSTALL

##
# MAVEN 3.3.9
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Maven is a build automation tool used primarily for Java projects "
echo "You will also get the option to install this build tool"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install MAVEN build tool${ques} [y/n] " -i "$DEFAULTYESNO" installmaven

if [ "$installmaven" = "y" ]; then
  echogreen "Installing Maven"
  echo "Downloading Maven..."
  curl -# -o $TMP_INSTALL/apache-maven-$MAVEN_VERSION.tar.gz $APACHEMAVEN
  echo "Extracting..."
  sudo tar -xf $TMP_INSTALL/apache-maven-$MAVEN_VERSION.tar.gz -C $TMP_INSTALL
  sudo mv $TMP_INSTALL/apache-maven-$MAVEN_VERSION $TMP_INSTALL/maven
  sudo mv $TMP_INSTALL/maven $DEVOPS_HOME
  cat << EOF > /etc/profile.d/maven.sh
#!/bin/sh
export MAVEN_HOME=$DEVOPS_HOME/maven
export M2_HOME=$DEVOPS_HOME/maven
export M2=$DEVOPS_HOME/maven/bin
export PATH=$PATH:$DEVOPS_HOME/maven/bin
EOF

  sudo chmod a+x /etc/profile.d/maven.sh
  source /etc/profile.d/maven.sh
  echo
  echogreen "Finished installing Maven"
  echo  
else
  echo "Skipping install of Maven"
  echo
fi  
  
  
##
# ANT 1.9.9
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "ANT is a tool used for controlling build process "
echo "You will also get the option to install this tool"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install ANT tool${ques} [y/n] " -i "$DEFAULTYESNO" installant

if [ "$installant" = "y" ]; then
  echogreen "Installing Ant"
  echo "Downloading Ant..."
  curl -# -o $TMP_INSTALL/apache-ant-$ANT_VERSION.tar.gz $APACHEANT
  echo "Extracting..."
  sudo tar -xf $TMP_INSTALL/apache-ant-$ANT_VERSION.tar.gz -C $TMP_INSTALL
  sudo mv $TMP_INSTALL/apache-ant-$ANT_VERSION $TMP_INSTALL/ant
  sudo mv $TMP_INSTALL/ant $DEVOPS_HOME
  cat << EOF > /etc/profile.d/ant.sh
#!/bin/sh
export ANT_HOME=$DEVOPS_HOME/ant
export PATH=$PATH:$DEVOPS_HOME/ant/bin
EOF

  chmod a+x /etc/profile.d/ant.sh
  source /etc/profile.d/ant.sh
  echo
  echogreen "Finished installing Ant"
  echo  
else
  echo "Skipping install of Ant"
  echo
fi

##
# Java 8 SDK
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install Java JDK."
echo "This will install Oracle Java 8 version of Java. If you prefer OpenJDK"
echo "you need to download and install that manually."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install Oracle Java 8${ques} [y/n] " -i "$DEFAULTYESNO" installjdk
if [ "$installjdk" = "y" ]; then
  echoblue "Installing Oracle Java 8. Fetching packages..."

  JDK_VERSION=`echo $JAVA8URL | rev | cut -d "/" -f1 | rev`

  declare -a PLATFORMS=("-linux-x64.tar.gz")

  for platform in "${PLATFORMS[@]}"
  do
     wget -c --header "Cookie: oraclelicense=accept-securebackup-cookie" "${JAVA8URL}${platform}" -P $TMP_INSTALL
     ### curl -C - -L -O -# -H "Cookie: oraclelicense=accept-securebackup-cookie" "${JAVA8URL}${platform}"
  done
  sudo mkdir /usr/java
  sudo tar xvzf $TMP_INSTALL/jdk-8u161-linux-x64.tar.gz -C /usr/java
  
  JAVA_DEST=jdk1.8.0_161
  export JAVA_HOME=/usr/java/$JAVA_DEST/
  sudo update-alternatives --install /usr/bin/java java ${JAVA_HOME%*/}/bin/java 1
  sudo update-alternatives --install /usr/bin/javac javac ${JAVA_HOME%*/}/bin/javac 1

  echo
  echogreen "Finished installing Oracle Java 8"
  echo
else
  echo "Skipping install of Oracle Java 8"
  echored "IMPORTANT: You need to install other JDK and adjust paths for the install to be complete"
  echo
fi

##
# System devops user
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "You need to add a system user that runs the tomcat Devops instance."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Add devops system user${ques} [y/n] " -i "$DEFAULTYESNO" adddevops
if [ "$adddevops" = "y" ]; then
  sudo adduser --system --disabled-login --disabled-password --group $DEVOPS_USER
  echo
  echogreen "Finished adding devops user"
  echo
else
  echo "Skipping adding devops user"
  echo
fi

##
# Tomcat
##
export TOMCAT_HTTP_PORT=8888
export TOMCAT_SHUTDOWN_PORT=8885
export TOMCAT_AJP_PORT=8889
export TOMCAT_HTTPS_PORT=8443
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Tomcat is a web application server."
echo "You will also get the option to install jdbc lib for Postgresql or MySql/MariaDB."
echo "Install the jdbc lib for the database you intend to use."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install Tomcat${ques} [y/n] " -i "$DEFAULTYESNO" installtomcat

if [ "$installtomcat" = "y" ]; then
  echogreen "Installing Tomcat"
  if [ ! -f "$TMP_INSTALL/apache-tomcat-$TOMCAT8_VERSION.tar.gz" ]; then
	echo "Downloading tomcat..."
	curl -# -o $TMP_INSTALL/apache-tomcat-$TOMCAT8_VERSION.tar.gz $TOMCAT_DOWNLOAD
  fi
  # Make sure install dir exists, including logs dir
  sudo mkdir -p $DEVOPS_HOME/logs
  sudo mkdir -p $CATALINA_HOME
  echo "Extracting..."
  tar xf $TMP_INSTALL/apache-tomcat-$TOMCAT8_VERSION.tar.gz -C $TMP_INSTALL
  sudo mv $TMP_INSTALL/apache-tomcat-$TOMCAT8_VERSION $TMP_INSTALL/tomcat
  sudo rsync -avz $TMP_INSTALL/tomcat $DEVOPS_HOME
  
  # Remove apps not needed
  sudo rm -rf $CATALINA_HOME/webapps/{docs,examples}
  
  # Change server default port
  sudo sed -i "s/8080/$TOMCAT_HTTP_PORT/g" $CATALINA_HOME/conf/server.xml
  sudo sed -i "s/8005/$TOMCAT_SHUTDOWN_PORT/g" $CATALINA_HOME/conf/server.xml
  sudo sed -i "s/8009/$TOMCAT_AJP_PORT/g" $CATALINA_HOME/conf/server.xml
  #sudo sed -i "s/443/$TOMCAT_HTTPS_PORT/g"  $CATALINA_HOME/conf/server.xml
  
  # Change domain tomcat port in nginx config
  hostname=$(basename /etc/letsencrypt/live/*/)
  if [ "$hostname" != "" ]; then
	  sudo sed -i "s/8080/$TOMCAT_HTTP_PORT/g" /etc/nginx/sites-available/$hostname.conf
  fi
  
  # Create Tomcat conf folder
  sudo mkdir -p $CATALINA_HOME/conf/Catalina/localhost

  # Download and copy database connector
  echo
  read -e -p "Install Postgres JDBC Connector${ques} [y/n] " -i "$DEFAULTYESNO" installpg
  if [ "$installpg" = "y" ]; then
	curl -# -O $JDBCPOSTGRESURL/$JDBCPOSTGRES
	sudo mv $JDBCPOSTGRES $CATALINA_HOME/lib
  fi
  echo
  read -e -p "Install Mysql JDBC Connector${ques} [y/n] " -i "$DEFAULTYESNO" installmy
  if [ "$installmy" = "y" ]; then
    cd $TMP_INSTALL
	curl -# -L -O $JDBCMYSQLURL/$JDBCMYSQL
	tar xf $JDBCMYSQL
	cd "$(find . -type d -name "mysql-connector*")"
	sudo mv mysql-connector*.jar $CATALINA_HOME/lib
  fi
  echo
  echogreen "Finished installing Tomcat"
  echo

else
  echo "Skipping install of Tomcat"
  echo
fi

##
# Database
##
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install Database"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Please select on of these : [P]osgresql, [MY]sql, [MA]riadb, [Q]uit " -i "$DEFAULTDB" installdb

    case $installdb in
        "P")
			echo "Choosing posgresql..."
			DB_DRIVER=org.postgresql.Driver
			DB_PORT=5432
			DB_SUFFIX=''
			DB_CONNECTOR=postgresql
            . $BASE_INSTALL/scripts/postgresql.sh
            ;;
        "MY")
			echo "Choosing mysql..."
            . $BASE_INSTALL/scripts/mysql.sh
            ;;
        "MA")
			echo "Choosing mariadb..."
            . $BASE_INSTALL/scripts/mariadb.sh
            ;;
		"Q")
			echo "Quitting..."
			;;
        *) echo invalid option;;
    esac

export DB_SELECTION=$installdb
	
##
# Jenkins
##
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Jenkins is a en source automation server, Jenkins provides hundreds of plugins to support building, deploying and automating any project "
echo "You will also get the option to install this server"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install Jenkins automation server${ques} [y/n] " -i "$DEFAULTYESNO" installjenkins
if [ "$installjenkins" = "y" ]; then
	wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
	sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
	sudo apt-get update
	sudo apt-get -qq -y install jenkins
	sudo systemctl start jenkins
fi




