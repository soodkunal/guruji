# guruji

# Basic requirements
  OS - This script is tested on : Ubuntu numbat (24.04-1) 
	If Ubuntu desktop version is included, it takes less time to install nvidia tool kit (but install size is 6GB)
  Hardware
	Disk - 64 GB or more (Ideally 128GB)
		- Anaconda/others are upwards of 25GB

# =======================
<ul>
	<li>guruji.sh: Main Project Script run with ./guruji.sh -help</li>
	<li>G8_VER: Contains current version number</li>
	<li>guruji.py: Contains the python code for cloning the voice and getting transcript(to be merged)</li>
	<li>README.md: This file</li>
	<li>TODO.md: Tasks to be done</li>
	<li>audio_vox.db: Eleven labs ID database for our project/li>
	<li>G8_VAR.sh: Contains definition of all variables, being used in the app</li>
</ul>

# =======================
<ul>
    <li>Script Version: 1.3
    <li>Date of release: 19-November-2024
    <li>Author: Mr Kunal Sood, Mr Nishant
    <li>Project: Towards submission of final project of B.Tech III Year
    <li>Project Mentors: Dr. Usha Batra, Mr. Alok Sinha
</ul>

# =======================
# This script is used to demonstrate Guru ji, 
  This has two parts
  <ul>
	<li>Part A - Basic setup, creation of library of voices</li>
	<li>Part B - Operational flow - text to video</li>
   </ul>

# =======================
#  Part A Script flow - *Setup*
	# Usually executed by the admin
	# Step 1: Install Linux packages on raw linux system
	# Step 2: Setup Anaconda
	# Step 3: Setup video-talking environment
	# Step 4: Clone base audio files (
# Part B - Operations Script flow 
		# Always execute by the professor
		#~ Step 1: Receive txt file from prof 
		#~ - Prof provides a text script for the topic
				#~ - This is picked up from a google drive link
				#~ - G8_PROF_TXT=""
		# Step 2: Convert received script into lecture format
			#~ - Text script is sent to Chat GPT --> 
			#~ - Recieve a lecture script 
		#~ Step 2-a: (Optional) 
			#~ - MULTI LANG Translate into hindi
		#~ Step 3: Convert Text to speech
			#~ - Use a cloned audio file in part A script(from the voice sample in row 27 above)
			#~ - Send to elevenlabs, 
			#~ - Receive audio file 
		#~ Step 4: Send audio file to video cloning, final video
		#~ Step 5: sample the created video 
	
	# Command to run on staging server 
	ssh -p 5222 asinha@192.168.4.222 "cd /home/asinha/Cloud/dev/guruji && git add -A && git commit -m \"Updated from remote\" && git push origin master" && git pull && ./guruji.sh -do_voice && scp -P 5222 "ops/g8_audio.mp3" "asinha@192.168.4.222:/home/asinha/Downloads/g8_audio_mp3"
git config --global credential.helper 'cache --timeout=604800'

V 2.0 - Open for release
	a. Date: 19-Nov
	b. Known bugs
		- The video setup is buggy
		- Voice, and all initial works.
