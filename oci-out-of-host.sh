n=0
until [ "$n" -ge 10080 ]
do
	terraform apply -auto-approve && break
	n=$((n+1))
	echo "Retry Attempt — $n"
	sleep 8
done