#!/bin/bash
#Passing flags to the variable
while getopts u:t: flag
do 
	case "${flag}" in
		u) url=${OPTARG};;
		t) token=${OPTARG};;
	esac
done

#Installing required tools
echo "--------------------------------------------------------------";
echo "Installing required tools";
echo -e "--------------------------------------------------------------\n";
sudo apt install amass subfinder ffuf httpx-toolkit naabu &> /dev/null;
sh -c "sudo cp Resources/aquatone /usr/bin/aquatone";
echo "--------------------------------------------------------------";
echo -e "--------------------------------------------------------------\n";


#simple message of What this tool does
echo "Tools used in here are : ";
echo "		1.crt.sh => To find subdomains from similar ssl certificates";
echo "		2.github-subdomains.py => To find subdomains from github of the target domain";
echo "		3.amass => Use amass to find subdomain";
echo "		4.subfinder => Use subfinder to find subdomain";
echo "		5.ffuf => use ffuf for bruteforcing subdomain";
echo "		6.httpx => use httpx for checking active subdomains";
echo "     	     	7.naabu => use naabu for checking open ports of active subdomains";
echo "		8.aquatone => use aquatone for taking screenshot of active subdomains\n";



#Using crt.sh for finding subdomain from ssl certificate
echo "--------------------------------------------------------------";
echo "1. Using crt.sh with $url";
echo -e "--------------------------------------------------------------\n";


echo "Subdomain found for $url with crt.sh are ===>";

mkdir $url 2> /dev/null;
cd $url;
mkdir Output 2> /dev/null;
sh -c "curl https://crt.sh -s -X POST -d 'q=$url' > result.txt";
grep result.txt -e "[^'\"]*\.$url" | tr '<TD>/' ' ' | tr 'BR' '\n' | sed '/^$/d' | tr -d '[:blank:]' | sort -u > Output/crt.txt;
cat Output/crt.txt;
echo "--------------------------------------------------------------";
#echo "Results are saved to $url/Output/crt.txt";
rm -r result.txt;
echo -e "--------------------------------------------------------------\n";


#Using github-subdomains.py for finding subdomain from github page
echo "2. Using github-subdomains.py for finding subdomains from github of $url";
echo -e "--------------------------------------------------------------\n";
echo "Subdomains found for $url with github-subdomains.py tool are ===>";
sh -c "python3 ../Resources/github-subdomains.py -d $url -t $token | sort -u > fun.txt";
cat fun.txt | grep -v 'HTTPSConnectionPool' > Output/github.txt;
rm -r fun.txt;
cat Output/github.txt;
echo "---------------------------------------------------------------";
#echo "Results are saved to $url/Output/github.txt";
echo -e "---------------------------------------------------------------\n";


#Using amass for finding subdomains
echo "3. Using amass to find subdomains";
echo -e "---------------------------------------------------------------\n";
echo "Subdomains found for $url with amass is :";
sh -c "amass enum -passive -d $url |sort -u > Output/amass.txt";
cat Output/amass.txt;
echo "---------------------------------------------------------------";
#echo "Results are saved to $url/Output/amass.txt";
echo -e "---------------------------------------------------------------\n";



#Using subfinder for finding subdomains
echo "4. Using subfinder to find subdomains";
echo -e "---------------------------------------------------------------\n";
echo "Subdomains found for $url with subfinder is :";
sh -c "subfinder -d $url |sort -u > Output/subfinder.txt";
cat Output/subfinder.txt;
echo "---------------------------------------------------------------";
#echo "Results are saved to $url/Output/.txt";
echo -e "---------------------------------------------------------------\n"; 



#Using ffuf for bruteforcing subdomains with seclist subdomains-top1million-5000 wordlist
echo "5. Using ffuf for bruteforcing subdomain";
echo "Subdomains found for $url with bruteforcing are ===>";
sh -c "ffuf -w ../Resources/wordlist.txt:FUZZ -u https://FUZZ.$url -c -t 100 -o result.txt";
cat result.txt | jq | grep "\"url" | tr "\"," " " | sed -e "s/url/ /g" | tr -d "[:blank:]" | sed -e "s/:https:\/\///g" | grep -v 'FUZZ' | sort -u > Output/ffuf.txt;
cat Output/ffuf.txt;
echo "---------------------------------------------------------------";
#echo -e "Results are saved to $url/Output/ffuf.txt\n";
rm -r result.txt;
echo "--------------------------------------------------------------";
echo -e "-----------------FINISHED ENUMERATING SUBDOMAINS-------------------------------------\n";


#Merging all the 4 files into a single file and sorting them for duplicate results
cat Output/crt.txt Output/github.txt Output/amass.txt Output/subfinder.txt Output/ffuf.txt | sort -u > Output/all-subdomains.txt;
echo "--------------------------------------------------------------";
echo -e "All the subdomains are saved to $url/Output/all-subdomains.txt";
echo -e "--------------------------------------------------------------\n";
cat Output/all-subdomains.txt;
rm -r Output/crt.txt Output/github.txt Output/amass.txt Output/subfinder.txt Output/ffuf.txt;


#Filtering active subdomains using httpx tool
echo -e "--------------------------------------------------------------\n";
echo -e "Filtering active subdomains out of all the subdomains\n";
echo -e "--------------------------------------------------------------\n";
sh -c "httpx -list Output/all-subdomains.txt -silent > Output/active-subdomains.txt";
echo "All active Subdomains found for $url are ===>";
echo -e "--------------------------------------------------------------\n";
cat Output/active-subdomains.txt;
echo -e "--------------------------------------------------------------";
echo "Results of all the active subdomain are saved to $url/Output/active-subdomains.txt";
echo -e "--------------------------------------------------------------";


#Using naabu to find out all the open ports of active subdomains
echo -e "--------------------------------------------------------------\n";
echo -e "-------------PORT SCANNING with naabu-------------------------\n";
cat Output/active-subdomains.txt | sed "s/https:\/\///g" | sed "s/http:\/\///g" > http.txt;
sh -c "naabu -l http.txt > Output/open-ports.txt";
rm -r http.txt;
echo -e "--------------------------------------------------------------";
echo -e "Open ports result are saved to $url/Output/open-ports.txt";
echo -e "--------------------------------------------------------------\n";


#Using aquatone for taking screenshot of active subdomains
echo -e "--------------------Taking Screenshot of active subdomains of $url------------\n";
mkdir screenshot;
cat Output/active-subdomains.txt | aquatone -out screenshot;
echo -e "Results of screenshots are saved to $url/screenshot/aquatone_report.html \n";
sh -c "firefox screenshot/aquatone_report.html";

echo -e "---------------------------THANK YOU FOR USING ME----------------------------------\n";

