encrypt(){
	[ -z ${charecters+x} ] && echo "please specify a string of charecters to encrypt using the -c option." && exit 5
	[ -z ${file+x} ] && echo "please specify the pad file with the -f option." && exit 5
	[[ "$unsafemode" = "y" ]] && echo "WARNING: You are running this in an unsafe mode. Remove the -N flag to return to normal operation. Press enter to continue " && read x
	text="$charecters"

	pad=$(head -c $((${#text} * 3)) ${file})

	padnum=1
	for ((i = 0; i < (${#text}); i++)); do

		# textnum is the ascii converted text to be encrypted. this is converted to the ascii number

		textnum=$(LC_CTYPE=C printf '%d' "'${text:i:1}")

		pads=$((padnum*3-3+1))
		pade=$((padnum*3))

		currentpadnum=$(printf "$pad" | cut -c${pads}-${pade})

		textnum=$((10#$textnum))
		currentpadnum=$((10#$currentpadnum))
		encrypted=$(((currentpadnum + textnum) % 1000))

		unset cursor
		[ $encrypted -lt 100 ] && cursor="0"
		[ $encrypted -lt 10 ] && cursor+="0"
	
		printf "${cursor}${encrypted}" 

		[ ${#text} -ge ${#pad}  ] && >&2 echo 'ran out of pad' && exit

		((padnum++))
	done
	[[ "$unsafemode" = "y" ]] || (tail +$(((${#text} * 3) +1 ))c $file > $file.truncated && mv $file.truncated $file)

}

decrypt(){
	[ -z ${charecters+x} ] && echo "please specify a string of charecters to decrypt using the -c option." && exit 5
	[ -z ${file+x} ] && echo "please specify the pad file with the -f option." && exit 5
	[ -z ${offset+x} ] && offset=0

	cyphertext="$charecters"

	pad=$(head -c $(((${#cyphertext} + $offset) * 3)) ${file})

	padnum=$((1+$offset))

	x=0
	for ((i = $offset; i < ($offset + ${#cyphertext}); i+=3)); do
		# textnum is the ascii converted text to be encrypted. this is converted to the ascii number
		textnum=${cyphertext:x:3}
		((x+=3))
		pads=$((padnum*3-3+1))
		pade=$((padnum*3))
		currentpadnum=$(printf "$pad" | cut -c${pads}-${pade})

		textnum=$((10#$textnum))
		currentpadnum=$((10#$currentpadnum))
		decrypted=$(((textnum - currentpadnum)))

		if [ $decrypted -lt 0 ]; then
			#decrypted=$(echo "$decrypted*(-1)" | bc)
			decrypted=$(echo "$decrypted+1000" | bc)
		fi
		[ $decrypted -lt 10 ] && hex="0${decrypted}" || hex="${decrypted}"
		printf "\x$(printf %x $decrypted)"

		[ ${#cyphertext} -ge ${#pad}  ] && >&2 echo 'ran out of pad' && exit

		((padnum++))
	done
}

usage(){
	printf "Usage: Using the one-time pad, this program can encrypt, decrypt and generate (the pad)\n\
\nThe main options are: \n\
-e: This is to encrypt a string. The flage -c and -f are manditory. The flag -o will automatically be set to 0 if not utilized.\n\
-d: This is to decrypt a string. The flage -c and -f are manditory.\n\
-g: This is to generate the one-time pad. The flag -p is manditory.\n\n\
-f: specify the file. This is used for the encrypt option (This will remove the leading charecters in the pad, unless the flag N is used)\n\
-o: This is the offset when decrypting the file, un the case that the pad was already used, it may not start at the first charecter.\n\
-c: this specifies the string for encrypting or decrypting.\n\
-N: This will NOT remove the leading the leading charecters in the file. This is dangerous and if used often, this will degrade the cryptographic utility of this softwware\n\
-p: This is to set the length of the one-time pad when creating it.\n\n\
Examples:\n\
To genrate a pad: bash onetimepad.sh -g -f pad.txt -p 1000\n\
To encrypt using pad.txt: bash onetimepad.sh -e -c 'Hello World' -f pad.txt\n\
To decrypt a string using pad.txt: "


}

generate(){

	[ -z ${file+x} ] && echo "please specify a file to write the pad to with -f option." && exit 5
	[ -z ${padsize+x} ] && echo "please specify the rough pad size (In ascii charecters) with the -p option." && exit 5
	echo "Creating the pad: $file with the rough size of $padsize charecters."


	#while [ $(wc -c pad | awk '{print $1}') -lt $((padsize*3)) ]; do 
	while [ $(($(wc -c ${file} | awk '{print $1}'))) -lt $((padsize*3)) ]; do 
		od  -N1000 -d /dev/urandom |sha512sum| egrep -o '[0-9.]+' | tr -d "\n" 
	done > "$file"
}

action=''
offset=0
while [ $# -gt 0 ]; do
	case $1 in
		-f) file=$2; shift ;;
		-o) offset=$2; shift  ;;
		-s) string=$2; shift  ;;
		-c) charecters=$2; shift  ;;
		-p) padsize=$2; shift  ;;
		-N) unsafemode='y'; shift  ;;
		-e) action+='e'; shift  ;;
		-d) action+='d'; shift  ;;
		-g) action+='g'; shift  ;;
		 *) shift  ;;
	esac
done

[ "$action" = "e" ] && encrypt
[ "$action" = "d" ] && decrypt
[ "$action" = "g" ] && generate
[ -z "$action" ] && usage

echo 
