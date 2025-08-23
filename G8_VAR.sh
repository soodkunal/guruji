		export G8_CGPT_KEY="$Open_AI_API_KEY"
		export G8_ELAB_KEY="$ELAB_API_KEY"
		export G8_REPO="https://github.com/soodkunal/video-retalking.git"
		export GPT_API_URL="https://api.openai.com/v1/chat/completions"
		export ELAB_API_URL="https://api.elevenlabs.io/v1/text-to-speech/$G8_ELABS_VOICE_ID"
		export G8_GDOWN="https://drive.google.com/drive/folders/1zBiUk2J5iX0n7Gs7KR2WB1YjzkhlGf4V?usp=drive_link"
		echo "  + Initializing environment variables..." 
		export G8_VER=`cat G8_VER`
		export G8_HOME="$HOME"
		export G8_PROJ="guruji/guruji"
		export G8_PROJ_DIR="$G8_HOME/$G8_PROJ"
		export G8_VT_DIR="$G8_HOME/$G8_PROJ/video-retalking/"
		export G8_ANACONDA_VER="Anaconda3-2023.09-0-Linux-x86_64.sh"

		# Setup a debug flag, if set errors will be shown
		export G8_DBUG=TRUE

		# setting default elevenlabs ID
		export G8_ELABS_VOICE_ID="pNInz6obpgDQGcFmaJgB"  
		G8_ELAB_OP_FORMAT="mp3_44100_128"
		G8_ELAB_STABILITY=1
		G8_ELAB_SIMBOOST=1
		G8_ELAB_STYLE=0.5

		export DB_FILE="$G8_HOME/G8_PROJ/guruj.db"
		
		# Ensure project folder exists
		mkdir -p "$G8_HOME/G8_PROJ"
		mkdir -p "$G8_PROJ_DIR/input"
		mkdir -p "$G8_PROJ_DIR/ops"
		mkdir -p "$G8_PROJ_DIR/out"

		export HEADER="prof_id;Prof_name;Prof_description;11labs_id"

		# ==== PROFESSOR LOGIC STARTS HERE ====
		if [ ! -f "$DB_FILE" ]; then
			echo " [WARNING] Database file not found: $DB_FILE"
			echo " Please create the database first using:"
			echo "   ./guruji.sh -setup_database"
			echo " Using default professor (ID=0, NAME=default)..."
			prof_id=0
			prof_name="default"
		else
			echo -n "Enter Professor ID (press Enter for default=0): "
			read prof_id
			if [ -z "$prof_id" ]; then
				prof_id=0
				prof_name="default"
				echo "  + Using default professor: $prof_id ($prof_name)"
			else
				exists=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM professors WHERE professor_id='$prof_id';")
				if [ "$exists" -eq 0 ]; then
					echo "[ERROR] Professor with ID '$prof_id' does not exist in database!"
					exit 1
				fi

				prof_name=$(sqlite3 "$DB_FILE" "SELECT professor_name FROM professors WHERE professor_id='$prof_id';")
				if [ -z "$prof_name" ]; then
					echo "[ERROR] Professor ID '$prof_id' exists, but name is empty."
					exit 1
				fi
				echo "  + Using professor: $prof_id ($prof_name)"
			fi
		fi

		export G8_PROF_ID="$prof_id"
		export G8_PROF_NAME="$prof_name"

		# Generate timestamp for unique file naming
		timestamp=$(date +%Y%m%d_%H%M%S)

		# Define ALL file paths
		export G8_IN_PROF_TXT="${G8_PROJ_DIR}/input/g8_in_${G8_PROF_ID}_${G8_PROF_NAME}_${timestamp}.txt"
		export G8_IN_MTDT="${G8_PROJ_DIR}/input/g8_in_${G8_PROF_ID}_${G8_PROF_NAME}_${timestamp}.json"
		export G8_OPS_GPT_TXT="${G8_PROJ_DIR}/ops/g8_ops_gpt_${G8_PROF_ID}_${G8_PROF_NAME}_${timestamp}.txt"
		export G8_OPS_AUDIO_FILE="${G8_PROJ_DIR}/ops/g8_ops_11lab_${G8_PROF_ID}_${G8_PROF_NAME}_${timestamp}.wav"
		export G8_OUTPUT_LECTURE_FILE="${G8_PROJ_DIR}/out/g8_out_${G8_PROF_ID}_${G8_PROF_NAME}_${timestamp}.mp4"

		echo "  + File paths initialized successfully."
		# ==== PROFESSOR LOGIC ENDS HERE ====
