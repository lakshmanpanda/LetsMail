#!/bin/bash

array=()
for (( i=0 ; i<26 ; i++ ))
do
        alphabet=$(printf "\\$(printf '%03o' "$(expr $i + 97)")")
        array+=($alphabet)
done


encode() {
        string=""
        code=""
        for (( i=0 ; i<26 ; i++ ))
        do
                string+=${array[$i]}
                code+=${array[$((($i+$2)%26))]}
        done

        sed -i -e "y/$string/$code/" $1
}

decode() {
        string=""
        code=""
        for (( i=0 ; i<26 ; i++ ))
        do
                string+=${array[$i]}
                code+=${array[$(($(($i-$2))%26))]}
        done

        sed -i -e "y/$string/$code/" $1
}

while [[ 1 ]]
do
f=0
a=0
while [[ $f == 0 ]]
do
	echo '1.Login'
	echo '2.Sign Up'
	echo '3.Exit'
	echo 'Enter your choice:'
	read ch
	if [[ $ch == '1' ]]
	then
		echo 'Enter username:'
		read name
		echo 'Enter password:'
		read pass
		var=$(grep -o $(echo $name'->'$pass) userlog)
		echo $var
		if [[ $var == $(echo $name'->'$pass) ]]
		then
			echo 'Login Successful'
			break
		 else
                        aval=$(grep $(echo $name'->'$pass) adminuser)
                        if [[ $aval == $(echo $name'->'$pass) ]]
                        then
                                f=1
                                a=1
                                echo 'Admin Login Successful'
                        else
                                echo 'Login Unsuccessful'
                        fi
                fi
	elif [[ $ch == '2' ]]
	then
		echo 'Enter username:'
        	read name
	        echo 'Enter new password:'
        	read pass
		echo 'Enter new password again:'
		read newpass
        	var=$(grep -o $(echo $name'->'$pass) userlog)
        	if [[ $pass == $newpass && var != $(echo $name'->'$pass) ]]
		then
			echo 'Enter encryption number:'
			read encrypt
			echo $name'->'$pass'->'$encrypt>>userlog
			mkdir ./message/$name
			echo 'Sign Up Successful'
		else
			echo 'Sign Up Unsuccessful'
		fi
	elif [[ $ch == '3' ]]
	then
		exit -1
	else
		echo 'Invalid Choice!'
	fi
done

if [[ $a == 1 ]]
then
        while [ 1 ]
        do
                echo '1.Entry status'
                echo '2.Exit status'
                echo '3.Create admin user'
		echo '4.Messages sent'
		echo '5.Messages recieved'
                echo '6.Exit'
                echo 'Enter your choice:'
                read ach
                if [[ $ach == 1 ]]
                then
                        #echo $(cat entrylog|head -1)
                        echo $(cat entrylog|grep 'Entry')|sed 's/ E/\nE/g'
                elif [[ $ach == 2 ]]
                then
                        #echo $(cat entrylog|head -1)
                        echo $(cat entrylog|grep 'Exit')|sed 's/ E/\nE/g'
                elif [[ $ach == 3 ]]
                then
                        echo "Username:"
                        read user
                        echo "Password:"
                        read pass
                        echo "New Password:"
                        read newpass
                        val=$(grep $(echo $user'->'$pass) adminuser)
                        if [[ $val != $(echo $user'->'$pass) && $pass == $newpass ]]
                        then
                                echo "$user->$pass">>adminuser
                        else
                                echo 'User already exists or password does not match'
                        fi
		elif [[ $ach == 4 ]]
                then
                        #echo $(cat entrylog|head -1)
                        grep 'sent' entrylog
		elif [[ $ach == 5 ]]
                then
                        #echo $(cat entrylog|head -1)
			grep 'recieved' entrylog
                elif [[ $ach == 6 ]]
                then
                        exit -1
                else
                        echo 'Invalid Choice'
                        exit -1
                fi
        done
fi


year=$(date|cut -f4 -d " ")
month=$(date|cut -f3 -d " ")
date=$(date|cut -f2 -d " ")
day=$(date|cut -f1 -d " ")
time=$(date|cut -f5,6 -d " ")

echo 'Entry '$year','$month','$day','$date','$time','$name>>entrylog

while [[ 1 ]]
do
	echo '1.Display All Messages'
	echo '2.Display Unread Messages'
	echo '3.Send Message' #Send messages with suffix .u to denote unread
	echo '4.Read Message' #After reading file changed to suffix with .r to denote read
	echo '5.Logout'
	echo 'Enter your choice:'
	read mch
	if [[ $mch == '1' ]]
	then
		ls ./message/$name
	elif [[ $mch == '2' ]]
	then
		var=$(find ./message/$name -type f -name '*.u' | wc -l)
		#echo $var
		if [[ $var > 0 ]]
		then
			ls ./message/$name/*.u
		else
			echo 'No unread messages'
		fi
	elif [[ $mch == '3' ]]
	then
		echo 'Enter sender username:'
		read senduser
			
		var=$(cat userlog|grep -o $senduser)
		if [[ $var == $senduser ]]
		then
			echo 'User does not exist'
			continue
		fi
			
		echo 'Enter message topic:'
		read filename
		echo 'Enter the message:'
		echo 'Message from '$name>$filename.u
		cat>>$(echo $filename.u)
		t=$(cat userlog|grep $senduser)
		echo $t>s
		cryptnum=$(cut -f3 -d '>' s)
		rm s
		encode $(echo $filename.u) $cryptnum
		mv $(echo $filename.u) ./message/$senduser

		year=$(date|cut -f4 -d " ")
		month=$(date|cut -f3 -d " ")
		date=$(date|cut -f2 -d " ")
		day=$(date|cut -f1 -d " ")
		time=$(date|cut -f5,6 -d " ")

		echo 'In '$year','$month','$day','$date','$time $name sent message to $senduser>>entrylog
		echo 'In '$year','$month','$day','$date','$time $senduser recieved a message from $name>>entrylog

	elif [[ $mch == '4' ]]
	then
		echo 'Enter message name:'
		read filename
		find=$(ls -1 ./message/$name|grep -o $filename)
		if [[ $find == $filename ]]
                then
			var=$(echo $filename|grep -o '.u')
			v=$(echo '.u')
			echo 'The message is:'
			if [[ $v == $var ]]
			then
				t=$(cat userlog|grep $name)
				echo $t>s
				cryptnum=$(cut -f3 -d '>' s)
				rm s
				decode ./message/$name/$filename $cryptnum
				cat ./message/$name/$filename
				mv ./message/$name/$filename $(echo ./message/$name/$filename|tr '.u' '.r')
			else
				cat ./message/$name/$filename
			fi
		else
			echo 'Message does not exist'
		fi
	elif [[ $mch == '5' ]]
	then
		break
	else
		echo 'Invalid Choice!'
	fi
done
echo 'Exit'
year=$(date|cut -f4 -d " ")
month=$(date|cut -f3 -d " ")
date=$(date|cut -f2 -d " ")
day=$(date|cut -f1 -d " ")
time=$(date|cut -f5,6 -d " ")

echo 'Exit '$year','$month','$day','$date','$time','$name>>entrylog

done
