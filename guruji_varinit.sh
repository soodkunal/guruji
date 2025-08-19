function g8_step3_conv_txt_to_wav(){
		# Step 3
		# Requres 
			# Txt file
			# Voice ID
		# This function will convert the text file to audio file
        echo "  + Converting the lecture text into an audio file..."
        # Ask user for Professor ID
		echo -n "Enter Professor ID: "
		read prof_id
		# Validate Professor ID in DB
		prof_exists=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM professors WHERE professor_id='$prof_id';")
		if [ "$prof_exists" -eq 0 ]; then
			echo "[ERROR] Professor with ID '$prof_id' does not exist!"
			return 1
		fi
		# Fetch voice_id from DB
		voice_id=$(sqlite3 "$DB_FILE" "SELECT voice_id FROM voice_ids WHERE professor_id='$prof_id';")
		if [ -z "$voice_id" ]; then
			echo "[ERROR] No voice_id found for professor ID '$prof_id'. Please assign a voice first!"
			return 1
		fi

		echo "  + Using Professor ID: $prof_id with Voice ID: $voice_id"

		# Read GPT text content
		TEXT_CONTENT=$(cat "$G8_OPS_GPT_TXT")
		JSON_PAYLOAD=$(jq -n --arg text "$TEXT_CONTENT" '{
		text: $text,
		voice: $G8_ELABS_VOICE_ID ,    #voice ID
		stability: 0.5,         # Control for voice stability
		similarity: 0.5         # Control for voice similarity
		}')
		RESPONSE=$(curl -s -X POST "$ELAB_API_URl" \
		-H "Authorization: Bearer $G8_ELAB_KEY" \
		-H "Content-Type: application/json" \
		-d "$JSON_PAYLOAD")
		AUDIO_URL=$(echo "$RESPONSE" | jq -r '.audio_url')
		# Download the audio file
		echo "  + Downloading the audio file..."
		curl -s -o "$G8_OPS_AUDIO_FILE" "$AUDIO_URL"
		
}	
function g8_step2_gpt_conv_to_lecture() {
    echo " + Step 2: Converting text and metadata into a lecture using GPT"
	
	# Input files must match step 1 convention
    G8_IN_PROF_TXT="./input/${G8_PROF_ID}_lecture.txt"
    G8_IN_MTDT="./input/${G8_PROF_ID}_metadata.json"
    
    # Ensure input files exist
    if [ ! -f "$G8_IN_PROF_TXT" ] || [ ! -f "$G8_IN_MTDT" ]; then
        echo " ! Error: One or both input files missing: $G8_IN_PROF_TXT or $G8_IN_MTDT"
        return 1
    fi

    # Read content from files
    lecture_content=$(cat "$G8_IN_PROF_TXT")
    metadata_content=$(cat "$G8_IN_MTDT")

    # Construct input message
    FULL_INPUT="Lecture Content:\n$lecture_content\n\nMetadata:\n$metadata_content"

    # Build JSON payload
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
	
    
    # Make API request
    echo " + Sending request to GPT API..."
    RESPONSE=$(curl -s -X POST "$GPT_API_URL" \
        -H "Authorization: Bearer $G8_CGPT_KEY" \
        -H "Content-Type: application/json" \
        -d "$JSON_PAYLOAD")

    # Extract the assistant's reply using jq
    RESPONSE_TEXT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // "Error: No content returned from GPT."')

    # Save response to file
    echo "$RESPONSE_TEXT" > "$G8_OPS_GPT_TXT"

    echo " + Lecture saved to: $G8_OPS_GPT_TXT"
}
