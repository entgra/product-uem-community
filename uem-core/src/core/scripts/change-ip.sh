#!/bin/bash

echo ""
echo "----------------------------------------"
echo "Entgra IoT Server IP configuration tool"
echo "----------------------------------------"

##################################### IP configs related to core ####################################

echo ""
echo ">>> Step 1: Change current IP address of the IoT server"

echo ""
echo "Please enter the IoT Core IP that you need to replace (if you are trying out IoT server for the first time this will be localhost)"
read -r val1;

while [[ -z $val1 ]]; do #if $val1 is a zero length String
    echo "Please enter the IoT Core IP that you need to replace (if you are trying out IoT server for the first time this will be localhost)"
    read -r val1;
done

echo ""
echo "Please enter your current IP"
read -r val2;

while [[ -z $val2 ]]; do #if $val2 is a zero length String
    echo "Please enter your current IP"
    read -r val2;
done

echo "--------------------------------------"
echo "All your " + "$val1" + " IP's are replaced with " + "$val2" ;
echo "--------------------------------------"

echo "Changing <IoT_HOME>/repository/conf/deployment.toml"
sed -i -e 's/'"$val1"'/'"$val2"'/g' ../repository/conf/deployment.toml
echo "Completed!!"

echo "Changing <IoT_HOME>/bin/iot-server.sh"
sed -i -e 's/'"$val1"'/'"$val2"'/g' ../bin/iot-server.sh
echo "Completed!!"

echo "Changing <IoT_HOME>/bin/iot-server.bat"
sed -i -e 's/'"$val1"'/'"$val2"'/g' ../bin/iot-server.bat
echo "Completed!!"

echo ""
echo "-----------------------------------------------"
echo "Generating SSL certificates for the IoT Server"
echo "-----------------------------------------------"
echo ""

B_SUBJ=''
C_SUBJ=''
A_SUBJ=''
SAN_NAMES=''
slash='/'
equal='='

buildSubject(){
    if [ "$1" = "CN" ]; then
        echo "Please provide Common Name "
        read -r val
        while [[ -z $val ]]; do #if $val is a zero length String
            echo "Common name(your server IP/hostname) cannot be null. Please enter the Common name."
            read -r val;
        done
        if [ -n "$val" ]; then    #This is true if $val is not empty (If $val is not a non zero length String)
            if [ "$3" = "C" ]; then
                C_SUBJ="$C_SUBJ$slash$1$equal$val"
                return
                elif [ "$3" = "B" ]; then
                B_SUBJ="$B_SUBJ$slash$1$equal$val"
                return
                else
                A_SUBJ="$A_SUBJ$slash$1$equal$val"
                return
            fi
        fi
    fi

    echo "Please provide ""$2"". Press Enter to skip."
    read -r val;
    if [ -n "$val" ]; then  #If $val is not a zero length String; This is same as if[ -n $val]; then
        if [ "$3" = "C" ]; then
            C_SUBJ="$C_SUBJ$slash$1$equal$val"
            return
        elif [ "$3" = "B" ]; then
            B_SUBJ="$B_SUBJ$slash$1$equal$val"
            return
        elif [ "$3" = "S" ]; then
            SAN_NAMES="DNS:$val$4$SAN_NAMES"
            buildSubject 'SAN' 'SAN' 'S' ','
            return
        else
            A_SUBJ="$A_SUBJ$slash$1$equal$val"
            return
        fi
    fi
}

if [ -d "tmp" ]; then
  rm -rf tmp
fi

mkdir tmp

echo ''
echo '=======Enter Values for IoT Core SSL Certificate======='

buildSubject 'C' 'Country' 'C'
buildSubject 'ST' 'State' 'C'
buildSubject 'L' 'Location' 'C'
buildSubject 'O' 'Organization' 'C'
buildSubject 'OU' 'Organizational Unit' 'C'
buildSubject 'emailAddress' 'Email Address' 'C'
buildSubject 'CN' 'Common Name' 'C'
buildSubject 'SAN' 'SAN' 'S'

echo ""
echo 'Provided IoT Core SSL Subject : ' "$C_SUBJ"

echo 'If you have a different IoT Core Keystore password please enter it here. Press Enter to use the default password.'
read -r -s password
if [ -n "$password" ]; then
    SSL_PASS=$password
else
    SSL_PASS="wso2carbon"
fi

echo ""
echo "Generating SSL Certificate for IoT Core"
openssl genrsa -out ./tmp/c.key 4096
openssl req -new -key ./tmp/c.key -out ./tmp/c.csr  -subj "$C_SUBJ"
if [ -z "$SAN_NAMES" ]; then
    openssl x509 -req -days 730 -in ./tmp/c.csr -signkey ./tmp/c.key -set_serial 044324884 -sha256 -out ./tmp/c.crt
else
    openssl x509 -req -extfile <(printf "subjectAltName=%s" "$SAN_NAMES") -days 730 -in ./tmp/c.csr -signkey ./tmp/c.key -set_serial 044324884 -sha256 -out ./tmp/c.crt
fi

echo "Export to PKCS12"
openssl pkcs12 -export -out ./tmp/CKEYSTORE.p12 -inkey ./tmp/c.key -in ./tmp/c.crt -name "wso2carbon" -password pass:$SSL_PASS

echo "Export PKCS12 to JKS"
keytool -importkeystore -srckeystore ./tmp/CKEYSTORE.p12 -srcstoretype PKCS12 -destkeystore ../repository/resources/security/wso2carbon.jks -deststorepass wso2carbon -srcstorepass wso2carbon -noprompt
keytool -importkeystore -srckeystore ./tmp/CKEYSTORE.p12 -srcstoretype PKCS12 -destkeystore ../repository/resources/security/client-truststore.jks -deststorepass wso2carbon -srcstorepass wso2carbon -noprompt

echo ""
echo "Setting up the public certificate for the default idp"
if hash tac; then
    VAR=$(keytool -exportcert -alias wso2carbon -keystore ../repository/resources/security/wso2carbon.jks -rfc -storepass wso2carbon | tail -n +2 | tac | tail -n +2 | tac | tr -cd "[:print:]");
else
    VAR=$(keytool -exportcert -alias wso2carbon -keystore ../repository/resources/security/wso2carbon.jks -rfc -storepass wso2carbon | tail -n +2 | tail -r | tail -n +2 | tail -r | tr -cd "[:print:]"); fi

echo ""
echo "Printing certificate"
echo "-----------------------"
echo "$VAR"

echo ""
echo "Configuration Completed!!!"
