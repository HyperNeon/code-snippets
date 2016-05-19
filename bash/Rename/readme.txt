

***Brief Instructions For Using Renaming Scripts***

Warning: These scripts aren't perfect and they have their limitations so please understand how they work before using them. 

* letter_letter.sh
	
	- This script will extract the "export_deliverable.txt" file from every "-all.zip" 
	file in the current folder, rename it using the uppercase same name as the 	
	"-all.zip" folder, run the cedar.sh script, and then remove the "-all.zip" and 
	"-letter.txt" files. 
	
	- USE: Copy the relevant "-all.zip" files from the export folder on /REDACTED/ into
	an empty folder on your local drive. Navigate to the folder and run the 
	letter_letter.sh script. 
	
	EX. ~/Workspace/ops/scripts/Rename/letter_letter.sh

	- LIMITATIONS: Cedar.sh must be located at ~/Workspace/ops/scripts/cedar.sh. This 
	script operates on every "-all.zip" file in the current folder. 

* nwkrename.sh

	- This script renames every file in the current folder with an "NWK_" prefix. 

	- USE: Navigate to the folder containing the files you'd like to rename. Ensure 
	there are no other files in the folder besides the ones you'd like to rename. 
	Run the script nwkrename.sh script. 

	EX. ~/Workspace/ops/scripts/Rename/nwkrename.sh

	- LIMITATIONS: The script renames every file in the current folder. Only the 
	"NWK_" prefix is currently in use. If you'd like to modify the script for
	another prefix simply change swap out NWK for whatever you'd like. 
