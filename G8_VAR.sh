		export G8_CGPT_KEY="REMOVED"
		export G8_ELAB_KEY="REMOVED"
		export GPT_API_URL="https://api.openai.com/v1/chat/completions"

		
		echo "  + Initializing environment variables..." 
		export G8_VER=`cat G8_VER`
		export G8_HOME="$HOME"
		export G8_PROJ="guruji"
		export G8_PROJ_DIR="$G8_HOME/$G8_PROJ/anaconda3"
		export G8_VT_DIR="$G8_HOME/$G8_PROJ/video-retalking/"
		export G8_ANACONDA_VER="Anaconda3-2023.09-0-Linux-x86_64.sh"

		# Setup a debug flag, if set errors will be shown
		export G8_DBUG=TRUE

		#setting default elevenlabs ID
		export G8_ELAB_VOICE_ID="pNInz6obpgDQGcFmaJgB"  
		export ELAB_API_URL="https://api.elevenlabs.io/v1/text-to-speech/$G8_ELAB_VOICE_ID"

		# These are vairables for elevenlab functionss
		export G8_ELAB_OP_FORMAT="mp3_44100_128"

		# This is the model to be used in eleven labs
		export G8_ELAB_MODEL="eleven_multilingual_v2"
	
		# Lower Stability: Results in a more dynamic and emotive performance, introducing a broader emotional range. However, setting the stability too low may lead to overly random performances and unintended speech patterns. Higher Stability: Produces a more consistent and monotone output, reducing variability between generations. This setting is suitable for applications requiring uniformity in speech delivery.
		export G8_ELAB_STABILITY=0.8

		# the similarity boost parameter controls how closely the generated speech matches the original voice's characteristics. A higher similarity boost value directs the AI to more faithfully replicate the nuances of the source voice, including its tone, pitch, and unique features. However, if the original audio contains imperfections or background noise, setting the similarity boost too high may cause the AI to reproduce these unwanted elements. Therefore, it's advisable to adjust this parameter carefully to balance voice fidelity with audio quality
		export G8_ELAB_SIMBOOST=0.6

		# style exaggeration, enhances the expressive characteristics of the generated speech by amplifying the original speaker's style. Adjusting this parameter allows for more dynamic and emotive voice outputs. However, increasing the style setting may consume additional computational resources and potentially reduce the stability of the generated speech. Therefore, it's generally recommended to keep this setting at 0 to maintain a balance between expressiveness and stability.
		export G8_ELAB_STYLE=0.5
	
	
		# ChatGPT required variables

		# Default CGPT language, can be changed in meta file
		export G8_DEF_SUBJECT="MedicalScience"
		export G8_DEF_LANG="Hindi"
		export G8_CGPT_LANG="$G8_DEF_LANG"

		# GPT model used for the work
		export G8_CGPT_MODEL="gpt-4o"

		# Chat temperature - more the value, higher hallucination/creativity
		export G8_CGPT_TEMP="0.3"

		# Token size
		export G8_CGPT_MAX_TKN="4096"
		
		# Always add this over-riding role definition in the system prompt
		G8_CGPT_UNI="Shri Vishwakama Skill university"
		G8_CGPT_COUNTRY=""
		G8_CGPT_MOOD="Happy"
		G8_CGPT_TODAY=`date  "+%d %b %y"`
		G8_CGPT_MODE="Non-interactive"
		
		G8_CGPT_ROLE_ADD=" Please always answer in a $G8_CGPT_MOOD tone. Add examples relevant to the context, remember you work for $G8_CGPT_UNI in $G8_CGPT_COUNTRY and you were developed by Globus Eight, and today is $G8_CGPT_TODAY and this is going to be used for a non-interactive session. Do not provide line breaks in output also escape any special characters in the output, Do not use ! in the output text"


		# Common drive for checkpoint folders for video training (Internal)
		export G8_GDOWN="https://drive.google.com/drive/folders/1NDS9sPmuus1H1_dKPkBsQhZu_WAM9vXY?usp=drive_link"

		# Git to clone from video-retalking 
		# Uncomment the desired repo

		# The repo from soodkunal
		# export G8_REPO="https://github.com/soodkunal/video-retalking.git"

		# The public repo is cloned on G8 network
		#  Date of cloning 15-Nov-24, 05:55 hrs
		export G8_REPO="http://git.g8.net:8222/asinha/video-retalking"

		# Orig video-talking
		# export G8_REPO="https://github.com/OpenTalker/video-retalking"	

		#this is the file, that ChatGPT has returned.
		export G8_CGPT_TXT_PATH="$G8_HOME/$G8_PROJ/ops/$G8_PROJ_gpt.txt"

		export DB_FILE="$G8_HOME/G8_PROJ/$G8_PROJ_vox.db"
		export HEADER="prof_id;Prof_name;Prof_description;11labs_id"

		# Operational usage variables


		# DEFAULT VALUES #
		# ============================================== "
		# Define the default values of the prof responses
		echo "  + Setting up default values..." 
		
		# The Professor profile, who is prepariing the class video
		export G8_PROF_UID="usha"

		# URL to initial txt file
		# G8_TXT is the file, provided by prof

		# export G8_TXT_URL="http://lo.g8.net/guruji/g8_txt"
		export G8_TXT_URL="http://lo.g8.net/guruji/"
		
		
		#URL to sample img
		# This seems not to be used in our version numbers
		export G8_IN_SAMPLE_IMG_URL="https://drive.google.com/drive/folders/1lkYtQr7s2pZ-2HQzRRxj7V1RkhC-cmeJ?usp=drive_link"
		#Path to sample audio
		export G8_IN_SAMPLE_AUD_URL="https://drive.google.com/drive/folders/1nmhUhLOQLzCtJRepXd3C6Ky28_BGgKSW?usp=drive_link"
		#Path to sample video

		# Dr Usha video
#		export G8_IN_SAMPLE_VID_URL="https://drive.google.com/file/d/1Rh6D7uWcOkLfSHrDwQexYW3cwWo-67jX/view?usp=sharing"	
		# ALok sinha video
		#export G8_IN_SAMPLE_VID_URL="https://drive.google.com/file/d/133J1luSd1vphjBmYAbl6OTDYzlcIbvOk/view?usp=sharing"	
		export G8_IN_SAMPLE_VID_URL="http://lo.g8.net/guruji/g8_sample_video.mp4"

		#Path to metadat for txt file
		export G8_MTDT_URL="https://drive.google.com/file/d/1M95l9-k1jn_Q_oCysRnth1EkbLkbG9On/view?usp=sharing"

		# Directory/Path values
		# Now we define local paths the input data
		# ============================================== "

		#IN#
		# This is where the INPUTS - recevied via URL or command line response, is downloaded and stored
		# This is the name of the local file that contains initial professor text
		export G8_IN_PROF_TXT="$G8_HOME/$G8_PROJ/input/g8_in_$G8_PROF_NAME_$$.txt"
		# G8_IN_SAMPLE_IMG is the image file of the professor
		export G8_IN_SAMPLE_IMG="$G8_HOME/$G8_PROJ/in/g8_in_$G8_PROF_NAME_$$.jpg"
		# G8_IN_SAMPLE_AUD is the file that has audio sample from professor
		export G8_IN_SAMPLE_AUD="$G8_HOME/$G8_PROJ/in/g8_in_$G8_PROF_NAME_$$.mp3"
		# This is the sample video file of the professors, to be used for eventual cloning
		export G8_IN_SAMPLE_VID="$G8_HOME/$G8_PROJ/in/g8_in_$G8_PROF_NAME.mp4"
		#This is the sample metadata file that has to be used as input for 
		#making transcript according to the audience
		export G8_IN_MTDT="$G8_HOME/$G8_PROJ/input/g8_in_$G8_PROF_NAME_$$.txt"
		#OPS#
		# These are the operations or intermediate files created
		# This is the name of the local file that chat GPT enhances and outputs
		export G8_OPS_GPT_TXT="$G8_HOME/$G8_PROJ/ops/g8_ops_gpt_$G8_PROF_NAME_$$.txt"

		# This is the intermediate complete audio file recieved from eleven labs
		export G8_OPS_AUDIO_FILE="$G8_HOME/$G8_PROJ/ops/g8_ops_11lab_$G8_PROF_NAME_$$.wav"
		# This is input metadata for txt file
		export g8_OPS_MTDT="${G8_HOME}/$G8_PROJ/ops/g8_ops_mtdt_$G8_PROF_NAME.md"

		#OUT#
		# These path to output files
		#Path to Final Output Lecture
		export G8_OUTPUT_LECTURE_FILE="out/g8_out_$G8_PROF_NAME.mp4"
		
