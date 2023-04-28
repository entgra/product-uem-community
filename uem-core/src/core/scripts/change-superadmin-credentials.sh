#!/bin/bash

echo ""
echo "----------------------------------------"
echo "Entgra IoT Server Super Admin Credentials Changing tool"
echo "----------------------------------------"

##################################### Super Admin Credentials Change ####################################

echo ""
echo ">>> Change current super admin username and password of the IoT server"

echo ""
echo "Please enter the old username and password of the IoTS super Admin"
echo "if you are trying out IoTS for the first time username/password will be 'admin/admin'"
echo "Old Username : "
read val1;
echo "Old Password : "
read val2;

while [[ -z $val1 || -z $val2 ]]; do #if $val1 is a zero length String
    echo "Username or Password couldn't be empty, Hence Re-Enter old username and password of IoTS Super Admin"
    echo "Old Username : "
    read val1;
    echo "Old Password : "
    read val2;
done

echo ""
echo "Please enter the new password of the IoTS super admin"
echo "New Username : "
read val3;
echo "New Password : "
read val4;

while [[ -z $val3 || -z $val4 ]]; do #if $val2 is a zero length String
    echo "Username or Password couldn't be empty, Hence Re-Enter new username and password of IoTS Super Admin"
    echo "New Username : "
    read val3;
    echo "New Password : "
    read val4;
done

username = "admin"
password = "admin"

echo "Changing <IoT_HOME>/repository/conf/deployment.toml"
sed -i -e 's/username = "'$val1'"/username = "'$val3'"/g' ../repository/conf/deployment.toml
sed -i -e 's/password = "'$val2'"/password = "'$val4'"/g' ../repository/conf/deployment.toml
echo "Completed!!"

echo ""
echo "Configuration Completed!!!"
