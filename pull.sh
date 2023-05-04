DIR="/var/www/html/"
# init
# look for empty dira
if [ -d "$DIR" ]
then
	if [ "$(ls -A $DIR)" ]; then
     cd /var/www/html/ && git pull
     echo "Pulled"
	else
    echo "$DIR is Empty, pulling."
    git clone $ghurl /var/www/html/
	fi
else
	echo "Directory $DIR not found."
fi