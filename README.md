# Simple-one-Time-Pad-encryption

Readme not yet complete. To run:<br>
bash onetimepad.sh

# Usage:
This program can encrypt, decrypt and generate a one time pad
-f: specify the pad file. This is used for the encrypt option (This will also remove the leading charecters in the pad, unless the flag N is used)
-c: this specifies the cyphertext for encrypting or decrypting.



-N: This will NOT remove the leading the leading charecters in the file when decrypting. This is dangerous and if used often, this will degrade the cryptographic utility of this softwware.
-e: This is to encrypt a string. The flage -c and -f are manditory. The flag -o will automatically be set to 0 if not utilized.
-d: This is to decrypt a string. The flage -c and -f are manditory.
-g: This is to generate the one-time pad. The flag -p is manditory.
-p: This is to set the length of the one-time pad when creating it.
-o: This is the offset when decrypting the file, use this in the case that the part of the pad was already used and to decrypt you do not want to use the first -o charecters.

Examples:
To genrate a pad of 1,000 charecters: bash onetimepad.sh -g -f pad.txt -p 1000
To encrypt using pad.txt: bash onetimepad.sh -e -c 'Hello World' -f pad
To decrypt a string using pad.txt: /OneTimePad.sh -d -c "(Cypher text)"  -f pad.txt
