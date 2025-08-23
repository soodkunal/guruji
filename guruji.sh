#!/bin/bash

# ==========================================================================="
# This script is used to demonstrate Guru ji, 
# Kindly read the README.md file for further details

# Load environment variables
# Load environment variables safely
if [ -f .env ]; then
  set -o allexport
  source .env
  set +o allexport
  echo "[DEBUG] G8_ELAB_KEY is loaded: ${G8_ELAB_KEY:0:5}******"
else
  echo "[ERROR] .env file not found!"
fi

# Basic Functions
function g8_banner(){
	echo "  + ------------------------------"
    echo "  + Script Version: $G8_VER"
    G8_DT=`date +"%d-%b-%y_%H-%M-%S"`
    echo "  + Date of release: $G8_DT"
    G8_BUILD_SYS="$(grep -oP '(?<=^PRETTY_NAME=")[^"]+' /etc/os-release)-$(cat /etc/machine-id)-$(hostname)-$(whoami)"
    echo "  + Build Name: $G8_BUILD_SYS"
    echo "  + Author: Mr Kunal Sood"
    echo "  + Project: Towards submission of final project of B.Tech IV Year"
    echo "  + Project Mentors: Dr. Usha Batra, Mr. Alok Sinha"
	echo "  + ------------------------------"
}

function g8_check_root(){
	# Check if the script is being run as root
	if [ "$EUID" -ne 0 ]; then
		echo "   + !! Error: This script must be run as root."
		g8_exit_error
	fi

	# If running as root, continue with the rest of the script
	echo "  + Running as root. Continuing execution..."

}

function g8_update() {
	
	#Function to update the system
	echo "  + Fixing any broken db....."
	DEBIAN_FRONTEND=noninteractive apt -y --fix-broken install < /dev/null >/dev/null
	
	echo "  + Updating....."
	DEBIAN_FRONTEND=noninteractive apt-get -qq update
	echo "  + Upgrading....."
	DEBIAN_FRONTEND=noninteractive  apt-get -qq --yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade < /dev/null >/dev/null
	echo "  + Cleaning....."
	DEBIAN_FRONTEND=noninteractive apt-get -qq -y autoremove < /dev/null >/dev/null
	apt-get -qq -y autoremove
	apt-get -qq clean
}

function g8_install_base(){
	echo "   + Installing apt-utils"
	DEBIAN_FRONTEND=noninteractive apt-get -qq install -y apt-utils < /dev/null > /dev/null
	#apt-get -qq install -y apt-utils

	echo "   + Installing base packages"
	DEBIAN_FRONTEND=noninteractive apt-get -qq install -y git mc vim-nox unzip lsof dialog mysql-client  curl gnupg-agent  libgd-dev libdbi-perl libdbd-mysql-perl openssh-server sshpass sshfs qemu-guest-agent ca-certificates < /dev/null > /dev/null

	# Install iptools
	g8_install_iptools
}

function g8_install_iptools(){
	echo "   + Installing iptools"
    DEBIAN_FRONTEND=noninteractive apt-get -qq install -y nmap traceroute mrtg extlinux acpi arp-scan nethogs update-notifier-common ntp ntpdate openvpn network-manager-openvpn  net-tools < /dev/null > /dev/null
	# nfs-common removed from above installation, as it was giving errors at time of first boot.
}

function g8_check_internet(){
	# Check internet connectivity by pinging 4.2.2.2 three times
	if ping -c 3 4.2.2.2 > /dev/null 2>&1; then
		echo "  + Internet connection is available. Continuing execution..."
	else
		g8_exit_
	fi
}

function ensure_sqlite() {
    echo " + Checking if sqlite3 is installed..."
    
    if ! command -v sqlite3 >/dev/null 2>&1; then
        echo " - sqlite3 not found."

        read -p " ? sqlite3 is required. Do you want to install it now? (y/n): " confirm

        if [[ "$confirm" != "y" ]]; then
            echo " !! sqlite3 is required but not installed. Exiting."
            exit 1
        fi

        echo " + Installing sqlite3..."
        sudo apt-get update
        sudo apt-get install -y sqlite3 || {
            echo " !! Failed to install sqlite3. Exiting."
            exit 1
        }

        echo " + sqlite3 installed successfully."
    else
        echo " + sqlite3 already present."
    fi
}

# ------------------- Database Setup -------------------
function setup_database() {
    g8_banner
    ensure_sqlite

    echo " + Initializing database at: $DB_FILE"

    if [ ! -f "$DB_FILE" ]; then
        echo " !! Database file not found: $DB_FILE"
        echo " + Creating new database..."
        sqlite3 "$DB_FILE" <<EOF
CREATE TABLE IF NOT EXISTS professors (
    professor_id TEXT PRIMARY KEY,
    professor_name TEXT,
    age INTEGER,
    gender TEXT,
    accent TEXT
);
CREATE TABLE IF NOT EXISTS voice_ids (
    professor_id TEXT PRIMARY KEY,
    voice_id TEXT
);
EOF
        echo " + Database created successfully."
    else
        echo " + Database already exists."
    fi
}

function display_database() {
	g8_banner
    ensure_sqlite
    
    echo " >> Checking database at: $DB_FILE"

    if [ ! -f "$DB_FILE" ]; then
        echo " !! Database file not found: $DB_FILE"
        echo " >> Please create it first using: ./guruji.sh -setup_database"
        return 1
    fi

    echo "=============================="
    echo " Tables in guruji.db"
    echo "=============================="
    tables=$(sqlite3 "$DB_FILE" ".tables")

    if [ -z "$tables" ]; then
        echo " !! No tables found in database."
        return 0
    fi

    for table in $tables; do
        echo ""
        echo "=============================="
        echo " Table: $table"
        echo "=============================="
        sqlite3 -header -column "$DB_FILE" "SELECT * FROM $table;" 2>/dev/null || {
            echo " (Error reading table: $table)"
        }
    done
}


# ------------------- Data Entry -----------------------
function upsert_professor_db_entry() {
	# This function takes the professor information and stores into the database
    local professor_id="$1"
    local professor_name="$2"
    local age="$3"
    local gender="$4"
    local accent="$5"

    echo "[DEBUG] Using DB file: $DB_FILE"
    echo "[DEBUG] Checking if professor exists..."

    local exists=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM professors WHERE professor_id = '$professor_id';")
    echo "[DEBUG] Exists? $exists"

    if [[ "$exists" -eq 1 ]]; then
        echo "[DEBUG] Updating professor..."
        sqlite3 "$DB_FILE" <<EOF
UPDATE professors
SET professor_name = '$professor_name',
    age = '$age',
    gender = '$gender',
    accent = '$accent'
WHERE professor_id = '$professor_id';
EOF
        echo "Professor '$professor_id' updated."
    else
        echo "[DEBUG] Inserting new professor..."
        sqlite3 "$DB_FILE" <<EOF
INSERT INTO professors (professor_id, professor_name, age, gender, accent)
VALUES ('$professor_id', '$professor_name', '$age', '$gender', '$accent');
EOF
        echo "New professor '$professor_id' added."
    fi

    echo "[DEBUG] Current DB contents:"
    sqlite3 "$DB_FILE" "SELECT * FROM professors;"

}

function upsert_voice_id_entry() {
    # This function takes the professor information and stores into the database
    local professor_id="$1"
    local voice_id="$2"

    local exists=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM voice_ids WHERE professor_id = '$professor_id';")

    if [[ "$exists" -eq 1 ]]; then
        sqlite3 "$DB_FILE" <<EOF
UPDATE voice_ids
SET voice_id = '$voice_id'
WHERE professor_id = '$professor_id';
EOF
        echo "Voice ID updated for $professor_id "
    else
        sqlite3 "$DB_FILE" <<EOF
INSERT INTO voice_ids (professor_id, voice_id)
VALUES ('$professor_id', '$voice_id');
EOF
        echo "Voice ID added for '$professor_id'."
    fi

    echo "[DEBUG] Current DB contents:"
    sqlite3 "$DB_FILE" "SELECT * FROM professors;"
}

function g8_elab_del_voice() {
    # Deletes an Eleven Labs voice and removes it from the database using professor_id
	
    local prof_id="$1"

    if [ -z "$prof_id" ]; then
        echo "Error: You must provide a professor ID to delete their voice."
        echo "Usage: g8_elab_del_voice professor_id"
        return 1
    fi

    if [ -z "$G8_ELAB_KEY" ]; then
        echo "Error: G8_ELAB_KEY environment variable is not set."
        return 1
    fi

    local voice_id=$(sqlite3 "$DB_FILE" "SELECT voice_id FROM voice_ids WHERE professor_id = '$prof_id';")

    if [ -z "$voice_id" ]; then
        echo "No voice ID found for professor ID: $prof_id"
        return 1
    fi

    local url="https://api.elevenlabs.io/v1/voices/$voice_id"

    echo "Deleting Eleven Labs voice ID: $voice_id..."

    curl --silent --request DELETE \
        --url "$url" \
        --header "xi-api-key: $G8_ELAB_KEY" \
        --header "Content-Type: application/json"

    sqlite3 "$DB_FILE" "DELETE FROM voice_ids WHERE professor_id = '$prof_id';"

    echo "Voice ID deleted from Eleven Labs and removed from database."
}

function g8_elab_add_voice() {
    # Adds a voice to Eleven Labs using a sample audio file and stores the voice ID in the DB.

    local prof_id="$1"
    local audio_file="$2"

    # Fetch metadata from DB for the professor
    read professor_name age gender accent <<< $(sqlite3 "$DB_FILE" \
        "SELECT professor_name, age, gender, accent FROM professors WHERE professor_id = '$prof_id';")

    local name="${professor_name:-$prof_id}"
    local description="Voice for $professor_name"
    local usecase="narration"

    if [ -z "$prof_id" ] || [ -z "$audio_file" ]; then
        echo "Error: professor_id and audio_file are required."
        return 1
    fi

    if [ ! -f "$audio_file" ]; then
        echo "Error: Audio file '$audio_file' not found."
        return 1
    fi

    if [ -z "$G8_ELAB_KEY" ]; then
        echo "Error: G8_ELAB_KEY (API key) is not set."
        return 1
    fi

    # Prepare JSON metadata
    local labels_json
    labels_json=$(jq -n --arg accent "$accent" --arg age "$age" --arg gender "$gender" --arg usecase "$usecase" \
        '{accent: $accent, age: $age, gender: $gender, usecase: $usecase}')

    echo " Uploading voice to Eleven Labs..."

    response=$(curl --silent --request POST \
        --url "https://api.elevenlabs.io/v1/voices/add" \
        --header "xi-api-key: $G8_ELAB_KEY" \
        --header "Content-Type: multipart/form-data" \
        --form "name=$name" \
        --form "description=$description" \
        --form "labels=$labels_json" \
        --form "files=@$audio_file")

    echo "Response: $response"
    
	# Extract just the voice_id
	voice_id=$(echo "$response" | jq -r '.voice_id // empty')
    #voice_id=$(echo "$response" | jq -r '.voice_id // empty')

    if [ -z "$voice_id" ]; then
    echo "Error: Could not retrieve voice_id from API response."
    echo "Full Response: $response"
    return 1
	fi

	echo "Voice created successfully. Voice ID: $voice_id"
	upsert_voice_id_entry "$prof_id" "$voice_id"

sqlite3 "$DB_FILE" <<EOF
INSERT INTO voice_ids (professor_id, voice_id)
VALUES ('$prof_id', '$voice_id')
ON CONFLICT(professor_id) DO UPDATE SET voice_id=excluded.voice_id;
EOF

echo "Voice ID stored in the database for professor_id=$prof_id."
  
	echo ""
}

function g8_elab_txt2vox(){
	# This function will covert the provided text in G8_GPT_TXT to voice of prof, by G8_PROF profile ID	
	
	
	# This is a working URL, to be re-created using variables
	#~ curl --request POST   
		#~ --url 'https://api.elevenlabs.io/v1/text-to-speech/9BWtsMINqrJLrRacOk9x?output_format=mp3_44100_128'   
		#~ --header 'Content-Type: application/json'   
		#~ --header 'xi-api-key: sk_054cb28e447214de104e239a543f22b6a914cc3d279d982e'   
		#~ --data '{"text": "Hello buddy, how are you doing today","voice_settings": {"stability": 1,"similarity_boost": 1,"style": 0.5} }' 
		#~ --output "abc.mp3"	

	#G8_ELAB_VOICE_ID="9BWtsMINqrJLrRacOk9x"
	# Prompt user to enter the professor ID
    read -p "Enter Professor ID: " prof_id

    if [ -z "$prof_id" ]; then
        echo "Error: No Professor ID provided."
        return 1
    fi

    # Check if the database exists
    if [ ! -f "$DB_FILE" ]; then
        echo "Error: Database file '$DB_FILE' does not exist."
        return 1
    fi

    # Fetch professor details and voice_id
    read professor_name age gender accent <<< $(sqlite3 "$DB_FILE" \
        "SELECT professor_name, age, gender, accent FROM professors WHERE professor_id = '$prof_id';")

    voice_id=$(sqlite3 "$DB_FILE" \
        "SELECT voice_id FROM voice_ids WHERE professor_id = '$prof_id';")

    if [[ -z "$professor_name" || -z "$voice_id" ]]; then
        echo "Error: No valid professor or voice ID found for '$prof_id'."
        return 1
    fi

    echo " + Using the following profile for synthesis:"
    echo "   > Name    : $professor_name"
    echo "   > Age     : $age"
    echo "   > Gender  : $gender"
    echo "   > Accent  : $accent"
    echo "   > Voice ID: $voice_id"

    # Default/fallback text for debug
    [ "$G8_DBUG" = "TRUE" ] && G8_TXT="$G8_GPT_TXT" || G8_TXT="We are running in a debug mode."

    G8_ELAB_VOICE_ID="$voice_id"
    G8_ELAB_URL="https://api.elevenlabs.io/v1/text-to-speech/$G8_ELAB_VOICE_ID?output_format=$G8_ELAB_OP_FORMAT"
    G8_ELAB_API_HDR="xi-api-key: $G8_ELAB_KEY"

    G8_ELAB_CURL_OPT="--request POST --output \"$G8_OPS_AUDIO_FILE\" --silent"
    G8_ELAB_CURL_HDR="--header 'Content-Type: application/json' --header '$G8_ELAB_API_HDR'"
    G8_ELAB_CURL_URL="--url '$G8_ELAB_URL'"
    G8_ELAB_CURL_DATA_VSET="\"stability\": $G8_ELAB_STABILITY, \"similarity_boost\": $G8_ELAB_SIMBOOST, \"style\": $G8_ELAB_STYLE"
    G8_ELAB_CURL_DATA="--data '{\"text\": \"$G8_TXT\",\"voice_settings\": {$G8_ELAB_CURL_DATA_VSET} }'"

    G8_CMD="curl $G8_ELAB_CURL_OPT \\
        $G8_ELAB_CURL_URL \\
        $G8_ELAB_CURL_HDR \\
        $G8_ELAB_CURL_DATA"

    [ "$G8_DBUG" = "TRUE" ] && echo "$G8_CMD"

    eval "$G8_CMD"

    echo "  + Audio file created: $G8_OPS_AUDIO_FILE"

    [ "$G8_DBUG" = "TRUE" ] && celluloid "$G8_OPS_AUDIO_FILE"
}

function g8_var_init(){
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    if [ -f "$SCRIPT_DIR/G8_VAR.sh" ]; then
        source "$SCRIPT_DIR/G8_VAR.sh"
    else
        echo "ERROR: G8_VAR.sh not found at $SCRIPT_DIR"
        exit 1
    fi

    # Debugging output
    echo "DEBUG: G8_HOME=$G8_HOME"
    echo "DEBUG: G8_PROJ_DIR=$G8_PROJ_DIR"
    echo "DEBUG: G8_REPO=$G8_REPO"
}

function g8_help(){
	echo "=============================================================="
    echo "Usage: $0 [option]"
    echo "Part A"
    echo "-anaconda       		: Setup the Anaconda environment only."
    echo "-setup_video_env      		: Build the entire project."
    echo "-setup_clone_base_audio_files 	: Create a clonable library by giving a small audio clip."
	echo ""
	echo "----------------------------------------------"
    echo "Part B"
    echo "-do_step1 	: This gets the input text file/URL for the lecture from the professor and saves it loclly"
    echo "-do_step2 	: This enhaces the input file taken from step1 and returns it"
    echo "-do_step3 	: This takes the file from step2 and converts it into the audio of the professor"
    echo "-do_step4 | \\
 -mk_final_video |\\
 -final 	: Input-output from eleven labs(audio); uploads to video-retalking; final output file"
    echo "do_step5 	: View the final output"
	echo ""
	echo "----------------------------------------------"
	echo "For testing"
	echo "-elab_test_txt2vox 		: Set G8_DBUG TRUE, it should give an voice output"
	echo "-elab_profid_2_voiceid	: Set G8_DBUG TRUE, This will get us the voiceID for a given profid"
    echo "No option       	: Display this help message."
	echo "=============================================================="
}

function g8_chk_fl(){
    # This function is to check if the file provided in $1 exists or not
    export G8_ERROR="File not found"
    echo "   + Checking for $1"
    # Check if $G8_abcd file exists
    if [[ -f "$1" ]]; then
        echo "File $1 found. Continuing..."
        # Continue with the rest of your script
    else

        echo "Error: File $1 not found. $G8_ERROR"
        g8_exit_error
    fi
}

function g8_exit_error(){
    # This function exits when the script encounters an error and exits
    exit 1
}

# Part A

function g8_do_init(){
	# This function checks all the data, and does the required steps, update, installs etc

	# Check if /etc/$G8_PROJ exists
	if [ -e "/etc/$G8_PROJ" ]; then
		echo "  + $G8_PROJ signature exists. Continuing without initialization."
	else
		# Leaving our signature
		echo "   + !! $G8_PROJ signature missing, going deep.."

		g8_check_root
		# Updates the system
		g8_update
		g8_install_base

		# install required kit for video (will be different for different systemts)

		# Takes a long time, have patience
		
		DEBIAN_FRONTEND=noninteractive apt-get install -qq -y nvidia-cuda-toolkit 

		# This cleans anything run from previous run
		rm -rf "$G8_HOME/$G8_PROJ/in"
		rm -rf "$G8_HOME/$G8_PROJ/ops"
		rm -rf "$G8_HOME/$G8_PROJ/out"
		rm -rf "${G8_VT_DIR}"

		# This creates new paths
		mkdir -p "$G8_HOME/$G8_PROJ"
		mkdir -p "$G8_HOME/$G8_PROJ/ops"
		mkdir -p "$G8_HOME/$G8_PROJ/in"
		mkdir -p "$G8_HOME/$G8_PROJ/out"	
		mkdir -p "${G8_VT_DIR}"
		echo "  + Leaving our signature...."
		echo  "$G8_VER" > "/etc/$G8_PROJ"
	fi
	echo " + Script run completed with do_init flag"
}

function g8_setup_anaconda(){
	# Anaconda should NOT be setup as root, it should always be run as user, hence let's check if we are being called as root, if yes exit.
	if [ "$EUID" -eq 0 ]; then
		echo "   + !!Error: This script cannot be run as root."
		g8_exit_error
	fi

	# Check if /etc/$G8_PROJ exists
	# This shows, if we have already run the Step 1 - basic linux, if not, go back and install PartA, Step1
	if [ -e "/etc/$G8_PROJ" ]; then
		echo "  + $G8_PROJ signature exists. Continuing without initialization."
	else
		# Leaving our signature
		echo "   + !! $G8_PROJ signature missing. Please install basic Linux systems 1st 
		sudo $0 -init"
	fi

	# If anaconda is already installed exit by givint alert
	if [ -d "$HOME/anaconda3" ]; then
		echo "   + !!Anaconda is already installed. If you want to force install Anaconda again, run (without quoutes)
		\"rm -rf $HOME/anaconda3 && $0 -A_step_1\""
		g8_exit_error
	fi

	echo " ----------------------------------------------------------------"
    echo "  + Need to install Anaconda, starting anaconda installation..."
    echo "    + Please review license terms by pressing ENTER"
    echo "    + Please accept license terms, by typing yes"
    echo "    + Please press ENTER, to select default path"
    echo "    + Please type yes, to auto-activate the conda environment"
	echo " ----------------------------------------------------------------"
	sleep 3
    cd "$G8_HOME"
	# IF anaconda finds ~/Downloads, it will fail, hence we need to remove it first
	rm -rf "$G8_HOME/anaconda3"
    curl -k -s "https://repo.anaconda.com/archive/${G8_ANACONDA_VER}" -o anaconda.sh
    chmod a+x anaconda.sh
    if ./anaconda.sh; then
        echo "   + Anaconda installed successfully."
        echo "    + We need to logout and log in again..."
        echo "    + After relogging in, please run conda --version"
        g8_exit_success
    else
        echo "   + !!Anaconda installation failed. Please check the logs and retry."
        g8_exit_error
	fi
}

function g8_exit_success(){
	# Exit the program
	echo " + Exiting the script"
	echo " --------------------------"
	exit 0
}

function g8_setup_video_env(){
	# This function downloads the required cloning software
    echo "  + Cloning the repository and setting up the project environment..."
    rm -rf "$G8_VT_DIR"
    rm -rf "$G8_PROJ_DIR/envs/video-retalking/*"
    echo "$G8_PROJ_DIR/envs/video-retalking/*"
    git clone "$G8_REPO" "$G8_VT_DIR"
    cd "$G8_VT_DIR"

	# Always activating conda on login
	conda config --set auto_activate_base true

	# Some basic config for conda
	conda config --add channels defaults
    echo "  + Updating conda....."
	conda update -n base -c defaults conda -y

    # Creating and activating the Conda environment
    echo "  + Creating Conda environment 'video_retalking'..."
    echo "   + First delete existing video_retalking"
    rm -rf "$G8_HOME/anaconda3/envs/video_retalking"
    conda create -n video_retalking -y python=3.10
    if [ $? -ne 0 ]; then
        echo "   + !!Error: Failed to create Conda environment. Exiting..."
        g8_exit_error
    fi

    echo "  + Activating the Conda environment 'video_retalking'..."
	cd "$G8_HOME"
	# Initialize Conda for this script
    source "$G8_HOME/anaconda3/etc/profile.d/conda.sh"
    conda init bash
    conda activate video_retalking
    if [ $? -ne 0 ]; then
        echo "   + !!Error: Failed to activate Conda environment. Exiting..."
        g8_exit_error
    fi

    # Install initial packages
    echo "  + Installing ffmpeg...."
	conda install ffmpeg -y
  
	# sometimes, pip may not install all that is required by cuda
	# Install this on Sep 23 version 
	# pip install torch==1.9.0+cu111 torchvision==0.10.0+cu111 -f https://download.pytorch.org/whl/torch_stable.html
	# Alternate step
	echo "  + Installing pytorch, cuda, nvidia et all"
	conda install -y pytorch==1.13.1 torchvision==0.14.1  torchaudio==0.13.1 cudatoolkit=11.7 pytorch-cuda=11.7 -c pytorch -c nvidia
	# The above steps are documented at  https://stackoverflow.com/questions/75751907/oserror-cuda-home-environment-variable-is-not-set-please-set-it-to-your-cuda-i
    pip install cmake
    conda install -c conda-forge dlib
	pip install gdown 


    # Install Python requirements
    echo "  + Installing Python dependencies from requirements.txt..."
	cd "$G8_VT_DIR"
    pip install -r requirements.txt
    if [ $? -ne 0 ]; then
        echo "Failed to install Python packages. Exiting..."
        exit 1
    fi
}

function g8_get_checkpoints(){
    echo "  + Downloading necessary samples for running the project..."
    mkdir -p "${G8_VT_DIR}"
    cd "${G8_VT_DIR}"

	#This central system is not available
    gdown --folder "$G8_GDOWN"
    echo "Check video and audio samples in the respective directories."
}

function g8_clone_base_audio_file(){
    # This script createsone time audio file for a given professor file
    # This is created on eleven labs and returns the audio file library ID
    # The audio file will be used to generate the final
    # Lecture file in the respective professor name
    echo "  + Now creating clone base file for a professor"
    # Set up G8_HOME if not already defined
    
    # Step 1: Check if DB file exists, create if not
    if [ ! -f "$DB_FILE" ]; then
        echo "Database file not found. Creating a new one."
        mkdir -p "$(dirname "$DB_FILE")" || { echo "Error creating directory"; exit 1; }
        echo "$HEADER" > "$DB_FILE"
    fi

    # Step 2: Request and validate unique prof_id
    while true; do
        read -rp "Enter prof_id: " prof_id
        prof_id="${prof_id//[ -;]/}"  # Remove spaces, hyphens, and semicolons
        if grep -q "^$prof_id;" "$DB_FILE"; then
            echo "Error: prof_id already exists in the database. Please enter a unique ID."
        else
            break
        fi
    done

    # Step 3: Request and validate Prof_name
    while true; do
        read -rp "Enter Prof_name (max 40 characters): " Prof_name
        Prof_name="${Prof_name//;/}"  # Remove semicolons
        if [ ${#Prof_name} -le 40 ]; then
            break
        else
            echo "Error: Prof_name exceeds 40 characters. Please enter again."
        fi
    done

    # Step 4: Request and validate Prof_description
    while true; do
        read -rp "Enter Prof_description (max 200 characters): " Prof_description
        Prof_description="${Prof_description//;/}"  # Remove semicolons
        if [ ${#Prof_description} -le 200 ]; then
            break
        else
            echo "Error: Prof_description exceeds 200 characters. Please enter again."
        fi
    done

    # Step 5: Request and validate URL
    while true; do
        read -rp "Enter URL for Tobecloned_base_audio (leave blank to keep current): " url
        url="${url//;/}"  # Remove semicolons
        if [ -z "$url" ]; then
            break  # Keep the existing value
        elif [[ "$url" =~ ^https?:// ]]; then
            G8_IN_SAMPLE_AUD="$url"
            break
        else
            echo "Error: Invalid URL format. Please enter a valid URL."
        fi
    done


    # Step 6: Run function and capture the returned value
	# if 
	
	if [ ! -e "$DB_FILE" ]; then
		echo "   + !!DB_FILE does not exist. Executing commands..."
		echo "#$prof_id;$Prof_name;$Prof_description;$G8_VOX_ID" > "$DB_FILE"
	fi

    G8_VOX_ID=$(g8_11lab_clone_voice)
    if [ -n "$G8_VOX_ID" ]; then
        # Add new record to DB if function succeeded
        echo "  + Record added to $DB_FILE"
    else
        echo "   + !!Error: g8_11lab_clone_voice function failed"
        g8_exit_error
    fi

    # Step 8: Display all collected values and the added record
    echo "Collected values:"
    echo "prof_id: $prof_id"
    echo "Prof_name: $Prof_name"
    echo "Prof_description: $Prof_description"
    echo "G8_IN_SAMPLE_AUD: $G8_IN_SAMPLE_AUD"
    echo "G8_VOX_ID: $G8_VOX_ID"

    echo "Record added:"
    tail -n 1 "$DB_FILE"
}

function g8_11lab_clone_voice() {
    # Clones a voice on Eleven Labs using a sample URL and returns the voice_id

    if [[ -z "$G8_ELAB_KEY" ]]; then
        echo "Error: G8_ELAB_KEY is not set (API Key)."
        return 1
    fi

    if [[ -z "$G8_IN_SAMPLE_AUD" ]]; then
        echo "Error: G8_IN_SAMPLE_AUD (sample URL) is not set."
        return 1
    fi

    echo " + Sending voice clone request to Eleven Labs..."

    # Prepare labels JSON
    local labels_json
    labels_json=$(jq -n \
        --arg accent "$accent" \
        --arg age "$age" \
        --arg gender "$gender" \
        --arg usecase "education" \
        '{
            accent: $accent,
            age: $age,
            gender: $gender,
            usecase: $usecase
        }')

    # Make API request
    response=$(curl --silent --request POST \
        --url "https://api.elevenlabs.io/v1/voices/add" \
        --header "xi-api-key: $G8_ELAB_KEY" \
        --header "Content-Type: application/json" \
        --data @- <<EOF
{
  "name": "$Prof_name",
  "description": "$Prof_description",
  "labels": $labels_json,
  "samples": ["$G8_IN_SAMPLE_AUD"]
}
EOF
)

    echo " + Response received from Eleven Labs."
    echo "$response"

    # Extract voice_id
    G8_VOX_ID=$(echo "$response" | jq -r '.voice_id // empty')

    if [ -z "$G8_VOX_ID" ]; then
        echo "Error: Failed to retrieve voice_id from response."
        return 1
    fi

    echo " + Voice cloned successfully. Voice ID: $G8_VOX_ID"
    echo "$G8_VOX_ID"
}

# Part B
function g8_step1_get_from_prof() {
    echo " + Step 1: Gathering Lecture Inputs from Professor"
	 # --- DEBUGGING LINE ---
    echo "[DEBUG] Inside Step 1, the path is: '$G8_IN_PROF_TXT'"
    
    # Show metadata example
    echo "--------------------------------------------------"
    echo "📄 Example Metadata JSON (save as .json file):"
    echo '{
  "audience_type": "School",
  "age": "10-15",
  "gender": "both",
  "language": "English",
  "stream": "Science",
  "substream": "Physics",
  "ambience": "classroom",
  "delivery": "slide-deck",
  "culture": "Indian"
}'
    echo "--------------------------------------------------"
    echo "Please make sure your metadata follows the above format."
    echo ""

    read -p "Enter Professor ID: " G8_PROF_ID
    # read -p "Enter Professor Name: " G8_PROF_NAME

    read -p "Enter URL to download the lecture text file: " G8_TXT
    [ -z "$G8_TXT" ] && echo " ! Error: No URL provided for text." && return 1

    read -p "Enter URL to download the metadata file (JSON): " G8_MTDT
    [ -z "$G8_MTDT" ] && echo " ! Error: No URL provided for metadata." && return 1

    # Function to handle Google Drive links
	convert_gdrive_link() {
		local url="$1"
		if [[ "$url" =~ drive.google.com/file/d/([^/]+)/view ]]; then
			local file_id="${BASH_REMATCH[1]}"
			echo "https://drive.google.com/uc?export=download&id=$file_id"
		else
			echo "$url"  # return original if not Google Drive
		fi
	}

	# Convert URLs if needed
	G8_TXT=$(convert_gdrive_link "$G8_TXT")
	G8_MTDT=$(convert_gdrive_link "$G8_MTDT")

	# Define filenames
	#G8_IN_PROF_TXT="./input/${G8_PROF_ID}_lecture.txt"
	#G8_IN_MTDT="./input/${G8_PROF_ID}_metadata.json"

	echo " + Downloading text file to: $G8_IN_PROF_TXT"
	wget -q --show-progress -O "$G8_IN_PROF_TXT" "$G8_TXT" || { echo " ! Failed to download text."; return 1; }

	echo " + Downloading metadata file to: $G8_IN_MTDT"
	wget -q --show-progress -O "$G8_IN_MTDT" "$G8_MTDT" || { echo " ! Failed to download metadata."; return 1; }

	echo " + Metadata downloaded. Displaying contents..."
	cat "$G8_IN_MTDT"

    if [ -f "$G8_IN_MTDT" ]; then
        echo "---------- Parsed Metadata ----------"
        jq -r '
        "Audience Type: \(.audience_type // "N/A")\n" +
        "Age Range: \(.age // "N/A")\n" +
        "Gender: \(.gender // "N/A")\n" +
        "Language: \(.language // "N/A")\n" +
        "Stream: \(.stream // "N/A")\n" +
        "Substream: \(.substream // "N/A")\n" +
        "Ambience: \(.ambience // "N/A")\n" +
        "Delivery Mode: \(.delivery // "N/A")\n" +
        "Cultural Context: \(.culture // "None")"
        ' "$G8_IN_MTDT"
        echo "-------------------------------------"
    else
        echo " ! Error: Metadata file not found after download."
    fi
}

function take_professor_entry_interactive() {
	# This function takes the metadata of the professsor like 
	# professor's id, name, age, gender, accent
    echo "Professor Entry"

    read -p "Enter Professor ID: " professor_id
    read -p "Name: " professor_name
    read -p "Age: " age
    read -p "Gender (male/female/other): " gender
    read -p "Accent (e.g., american): " accent

    if [[ -z "$professor_id" || -z "$professor_name" || -z "$age" || -z "$gender" || -z "$accent" ]]; then
        echo "Error: All fields are required."
        return 1
    fi

    upsert_professor_db_entry "$professor_id" "$professor_name" "$age" "$gender" "$accent"
}

function take_voice_id_entry_interactive() {
	# This function takes the professor id and finds the corresponding voice id of the professor
    echo "Voice ID Setup"

    read -p "Enter Professor ID: " professor_id

    local exists=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM professors WHERE professor_id = '$professor_id';")
    if [[ "$exists" -eq 0 ]]; then
        echo "Error: Professor ID '$professor_id' not found."
        return 1
    fi

    echo "Choose input method for voice ID:"
    select opt in "Upload new voice sample (Eleven Labs)" "Enter voice ID manually" "Cancel"; do
        case $REPLY in
            1)
                read -p "Enter path to audio file: " audio_file
                if [[ ! -f "$audio_file" ]]; then
                    echo "File not found."
                    return 1
                fi

                echo "Fetching professor profile for metadata..."
                local accent=$(sqlite3 "$DB_FILE" "SELECT accent FROM professors WHERE professor_id = '$professor_id';")
                local age=$(sqlite3 "$DB_FILE" "SELECT age FROM professors WHERE professor_id = '$professor_id';")
                local gender=$(sqlite3 "$DB_FILE" "SELECT gender FROM professors WHERE professor_id = '$professor_id';")

                local voice_id=$(g8_elab_add_voice "$professor_id" "$audio_file" "" "" "$accent" "$age" "$gender")

                if [[ -n "$voice_id" ]]; then
                    upsert_voice_id_entry "$professor_id" "$voice_id"
                else
                    echo "Voice creation failed."
                    return 1
                fi
                return 0
                ;;

            2)
                read -p "Enter voice ID: " voice_id
                if [[ -z "$voice_id" ]]; then
                    echo "Voice ID is required."
                    return 1
                fi
                upsert_voice_id_entry "$professor_id" "$voice_id"
                return 0
                ;;

            3)
                echo "Operation cancelled."
                return 1
                ;;
            *)
                echo "Invalid selection."
                ;;
        esac
    done
}

function g8_step2_gpt_conv_to_lecture(){
    echo " + Step 2: Converting professor notes & metadata into a lecture using GPT"
    read -p "Enter Professor ID: " prof_id

    # Fetch professor name from DB
    prof_name=$(sqlite3 "$DB_FILE" "SELECT professor_name FROM professors WHERE professor_id=$prof_id;")
    if [ -z "$prof_name" ]; then
        echo "[ERROR] Professor ID $prof_id not found in database."
        return 1
    fi

    # Input files (created in Step 1)
    G8_IN_PROF_TXT="./input/${prof_id}_lecture.txt"
    G8_IN_MTDT="./input/${prof_id}_metadata.json"

    if [ ! -f "$G8_IN_PROF_TXT" ] || [ ! -f "$G8_IN_MTDT" ]; then
        echo " ! Error: One or both input files missing: $G8_IN_PROF_TXT or $G8_IN_MTDT"
        return 1
    fi

    # Read contents
    lecture_content=$(cat "$G8_IN_PROF_TXT")
    metadata_content=$(cat "$G8_IN_MTDT")
    FULL_INPUT="Lecture Content:\n$lecture_content\n\nMetadata:\n$metadata_content"

    # Output filename
    G8_OPS_GPT_TXT="$G8_PROJ_DIR/ops/g8_ops_gpt_${prof_id}_${prof_name}_$(date +%Y%m%d_%H%M%S).txt"

    # JSON payload for GPT
    JSON_PAYLOAD=$(jq -n \
        --arg content "$FULL_INPUT" \
        '{
            model: "gpt-4",
            messages: [
                {role: "system", content: "You are an expert professor creating a structured and age-appropriate lecture from user notes and metadata."},
                {role: "user", content: $content}
            ],
            temperature: 0.7
        }')

    # Call GPT API
    echo " + Sending request to GPT API..."
    RESPONSE=$(curl -s -X POST "$GPT_API_URL" \
        -H "Authorization: Bearer $G8_CGPT_KEY" \
        -H "Content-Type: application/json" \
        -d "$JSON_PAYLOAD")

    # Extract GPT reply
    RESPONSE_TEXT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // "Error: No content returned from GPT."')

    # Save to file
    echo "$RESPONSE_TEXT" > "$G8_OPS_GPT_TXT"
    echo " + Lecture saved to: $G8_OPS_GPT_TXT"

    # Save filename in DB (latest lecture for professor)
    sqlite3 "$DB_FILE" <<EOF
CREATE TABLE IF NOT EXISTS gpt_outputs (
    professor_id INTEGER,
    gpt_file_path TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
DELETE FROM gpt_outputs WHERE professor_id=$prof_id;
INSERT INTO gpt_outputs (professor_id, gpt_file_path) VALUES ($prof_id, '$G8_OPS_GPT_TXT');
EOF
}

function g8_step3_conv_txt_to_wav() {
    echo "  + Converting the lecture text into an audio file..."
    read -p "Enter Professor ID: " prof_id

    # Get professor name
    prof_name=$(sqlite3 "$DB_FILE" "SELECT professor_name FROM professors WHERE professor_id=$prof_id;")
    if [ -z "$prof_name" ]; then
        echo "[ERROR] Professor ID $prof_id not found in database."
        return 1
    fi

    # Get latest text file from DB
    SRC_TXT=$(sqlite3 "$DB_FILE" "SELECT gpt_file_path FROM gpt_outputs WHERE professor_id=$prof_id ORDER BY created_at DESC LIMIT 1;")
    if [ ! -f "$SRC_TXT" ]; then
        echo "[ERROR] No lecture text found for Professor $prof_id ($prof_name). Run Step 2 first."
        return 1
    fi
    echo "  + Using lecture text: $SRC_TXT"

    # Get Voice ID
    voice_id=$(sqlite3 "$DB_FILE" "SELECT voice_id FROM voice_ids WHERE professor_id=$prof_id;")
    if [ -z "$voice_id" ]; then
        echo "[ERROR] No Voice ID found for Professor $prof_id. Run the voice creation step first."
        return 1
    fi
    echo "  + Using Voice ID: $voice_id"

    # Output file
    G8_OPS_AUDIO_FILE="$G8_PROJ_DIR/ops/g8_ops_11lab_${prof_id}_${prof_name}_$(date +%Y%m%d_%H%M%S).wav"

    # Escape text safely
    SAFE_TEXT=$(jq -Rs . < "$SRC_TXT")

    # Call ElevenLabs API and stream audio directly
    echo "  + Sending request to ElevenLabs..."
    curl -s -X POST "https://api.elevenlabs.io/v1/text-to-speech/$voice_id/stream" \
        -H "xi-api-key: $G8_ELAB_KEY" \
        -H "Content-Type: application/json" \
        -H "Accept: audio/wav" \
        --data "{
                  \"text\": $SAFE_TEXT,
                  \"model_id\": \"eleven_multilingual_v2\"
                }" \
        -o "$G8_OPS_AUDIO_FILE"

    # Verify success
    if [ -s "$G8_OPS_AUDIO_FILE" ]; then
        if file "$G8_OPS_AUDIO_FILE" | grep -q "WAVE audio"; then
            echo "  + Audio file saved: $G8_OPS_AUDIO_FILE"

            # Store audio file path in DB
            sqlite3 "$DB_FILE" <<EOF
CREATE TABLE IF NOT EXISTS audio_outputs (
    professor_id INTEGER,
    file_path TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
DELETE FROM audio_outputs WHERE professor_id=$prof_id;
INSERT INTO audio_outputs (professor_id, file_path) VALUES ($prof_id, '$G8_OPS_AUDIO_FILE');
EOF

        else
            echo "[ERROR] File was saved but is not valid audio:"
            head "$G8_OPS_AUDIO_FILE"
            return 1
        fi
    else
        echo "[ERROR] File was empty even after saving. Something went wrong."
        return 1
    fi
}



function g8_run_prog() {
    echo " + Starting Lecture Video Generation Process"

    # Ensure conda is available
    if ! command -v conda &> /dev/null; then
        echo " ! Error: conda is not installed or not available in PATH."
        return 1
    fi

    # Activate conda environment
    echo " + Initializing and activating 'video_retalking' environment..."
    eval "$(conda shell.bash hook)"
    conda activate video_retalking || { echo " ! Failed to activate 'video_retalking' environment."; return 1; }

    # Get user input for video and audio paths
    read -p "Please enter the path to the video sample (e.g., face.mp4): " G8_IN_SAMPLE_VID
    read -p "Please enter the path to the audio sample (e.g., output.mp3): " G8_OPS_AUDIO_FILE
    read -p "Please enter the path for final output (e.g., lecture.mp4): " G8_OUTPUT_LECTURE_FILE

    # Validate input files
    if [[ ! -f "$G8_IN_SAMPLE_VID" ]]; then
        echo " ! Error: Video sample '$G8_IN_SAMPLE_VID' not found."
        return 1
    fi
    if [[ ! -f "$G8_OPS_AUDIO_FILE" ]]; then
        echo " ! Error: Audio sample '$G8_OPS_AUDIO_FILE' not found."
        return 1
    fi

    # Export output variable for external use
    export G8_OUTPUT_LECTURE_FILE

    # Move to the inference directory
    echo " + Changing directory to video retalking project: $G8_VT_DIR"
    cd "$G8_VT_DIR" || { echo " ! Failed to change directory to $G8_VT_DIR"; return 1; }

    # Run the main script
    echo " + Running inference with:"
    echo "    Video: $G8_IN_SAMPLE_VID"
    echo "    Audio: $G8_OPS_AUDIO_FILE"
    echo "    Output: $G8_OUTPUT_LECTURE_FILE"

    python3 inference.py \
        --face "$G8_IN_SAMPLE_VID" \
        --audio "$G8_OPS_AUDIO_FILE" \
        --outfile "$G8_OUTPUT_LECTURE_FILE"

    if [[ $? -eq 0 && -f "$G8_OUTPUT_LECTURE_FILE" ]]; then
        echo " Program executed successfully."
        echo " Lecture video saved to: $G8_OUTPUT_LECTURE_FILE"
    else
        echo " Inference failed or output file was not created."
    fi
}

function g8_video_interactive_playback() {
    echo " + Interactive Video Playback with Voice Control"

    # 1. Backup originals
    G8_ORIG_TRANSCRIPT="${G8_OPS_GPT_TXT}.orig"
    G8_ORIG_VIDEO="${G8_OUTPUT_LECTURE_FILE}.orig"
    cp "$G8_OPS_GPT_TXT" "$G8_ORIG_TRANSCRIPT"
    cp "$G8_OUTPUT_LECTURE_FILE" "$G8_ORIG_VIDEO"

    # 2. Play video in background
    echo " + Playing video. Say 'stop' to pause and regenerate..."
    cvlc --play-and-exit "$G8_OUTPUT_LECTURE_FILE" & 
    VLC_PID=$!

    # 3. Listen for stopword via mic
    echo " + Listening for stopword..."
    STOP_DETECTED=0
    while kill -0 $VLC_PID 2>/dev/null; do
        python3 <<EOF
import speech_recognition as sr
import time
import subprocess
import sys

STOP_WORDS = ["stop", "pause", "guruji", "doubt"]
print(" >> Speak during playback. Say 'stop' or 'update' to regenerate content.")

r = sr.Recognizer()
with sr.Microphone() as source:
    print(" >> Speak during playback. Say a stop word to regenerate content...")
    try:
        audio = r.listen(source, phrase_time_limit=5)
        phrase = r.recognize_google(audio).lower()
        print(f"You said: {phrase}")
        for word in STOP_WORDS:
            if word in phrase:
                exit(1)
    except:
        pass
exit(0)
EOF
        if [[ $? -eq 1 ]]; then
            STOP_DETECTED=1
            echo " ! Stopword detected by user."
            kill -9 $VLC_PID
            break
        fi
        sleep 1
    done

    if [[ "$STOP_DETECTED" -eq 0 ]]; then
        echo " + No stopword detected. Exiting."
        return 0
    fi

    # 4. Get query from mic
    echo " + Listening to your question..."
    QUERY=$(python3 -c '
import speech_recognition as sr
r = sr.Recognizer()
with sr.Microphone() as source:
    print(" > Speak now...")
    audio = r.listen(source, phrase_time_limit=10)
try:
    print(r.recognize_google(audio))
except:
    print("")')

    echo " + You asked: '$QUERY'"

    # 5. Get updated response from OpenAI API (placeholder)
    echo " + Getting response using existing transcript..."
    new_text=$(python3 -c "
from openai import OpenAI
client = OpenAI()
with open('$G8_ORIG_TRANSCRIPT') as f:
    transcript = f.read()
query = '''$QUERY'''
response = client.chat.completions.create(
    model='gpt-4',
    messages=[
        {'role': 'system', 'content': 'You are a professor.'},
        {'role': 'user', 'content': f'Given this lecture transcript:\n{transcript}\n\nRespond to this question: {query}'}
    ])
print(response.choices[0].message.content.strip())
")

    echo "$new_text" > "${G8_OPS_GPT_TXT}.tmp"

    # 6. Generate new voice from GPT response
    echo " + Generating new audio and video..."
    export G8_OPS_GPT_TXT="${G8_OPS_GPT_TXT}.tmp"
    g8_step3_conv_txt_to_wav

    # 7. Generate updated video
    export G8_OUTPUT_LECTURE_FILE="${G8_OUTPUT_LECTURE_FILE}.tmp"
    g8_run_prog

    # 8. Playback updated video
    echo " + Playing updated video..."
    vlc --play-and-exit "$G8_OUTPUT_LECTURE_FILE"

    # 9. Resume original lecture
    echo " + Resuming original lecture..."
    vlc "$G8_ORIG_VIDEO"
}

# =================================================================

echo " + $0 script started...."


# Check if an argument is provided
if [ -z "$1" ]; then
    echo " + !! No argument provided. Displaying help..."
    g8_help
    g8_exit_error
fi

g8_var_init
g8_banner
g8_check_internet

# ---------------------------- CLI Interface ----------------------------
case "$1" in
    -init|-reset|-A_step_1)
        g8_do_init
        ;;
    -anaconda|-A_step_2)
        g8_setup_anaconda
        ;;
    -setup_video_env|-A_step_3)
        g8_setup_video_env
        g8_get_checkpoints
        ;;
    -setup_clone_base_audio_files|-A_step_4)
        g8_clone_base_audio_file 
        ;;
    -add_professor_interactive)
		setup_database
		take_professor_entry_interactive
		;;
	-add_voice_interactive)
		setup_database
		take_voice_id_entry_interactive
		;;
	-setup_database)
        setup_database
        ;;
    -show_database)
		display_database
		;;
    -do_step1|-B_step_1)
        g8_step1_get_from_prof
        g8_chk_fl "$G8_IN_PROF_TXT"
        echo "  + Input file from $G8_TXT is stored in $G8_IN_PROF_TXT"
        ;;
    -do_step2|-B_step_2)
        g8_step2_gpt_conv_to_lecture
        g8_chk_fl "$G8_OPS_GPT_TXT"
        echo "  + GPT has returned an enhanced text file in $G8_OPS_GPT_TXT"
        ;;
    -do_step3|-B_step_3)
        g8_step3_conv_txt_to_wav
        g8_chk_fl "$G8_OPS_AUDIO_FILE"
        echo "  + The professor voice has been cloned and is available here $G8_OPS_AUDIO_FILE"
        ;;
    -do_step4|-mk_final_video|-final|-B_step_4)
        g8_run_prog
        g8_chk_fl "$G8_OUTPUT_LECTURE_FILE"
        echo "  + Final video file stored in $G8_OUTPUT_LECTURE_FILE"
        ;;
    -do_step5|-B_step_5)
        echo "  + Playing the final created file $G8_OUTPUT_LECTURE_FILE"
        g8_video_interactive_playback	
        ;;
    -elab_add_voice)
        g8_elab_add_voice
        ;;
    -elab_del_voice)
        g8_elab_del_voice
        ;;
    -help)
        g8_help
        ;;
    *)
        echo "Usage: ./guruji.sh {setup_database|add_professor|add_voice_id|-do_step1|-do_step2|-do_step3|-do_step4|-final}"
        g8_help
        g8_exit_error
        ;;
esac

echo " + ------------------------------"

