# Guru Ji Smart 21st Century Next Gen. AI-Based Professor

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
	<li>README.md: This file</li>
	<li>TODO.md: Tasks to be done</li>
	<li>guruji.db: Eleven labs ID database for our project/li>
	<li>G8_VAR.sh: Contains definition of all variables, being used in the app</li>
</ul>

# =======================
<ul>
    <li>Script Version: 3.1.2
    <li>Date of release: 19-November-2024
    <li>Author: Mr Kunal Sood, Mr Nishant
    <li>Project: Towards submission of final project of B.Tech IV Year
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
<h4>Part A: Setup Flow (Admin Tasks)</h4>
<p>This is the initial setup, typically performed only once by an admin.</p>
<ol>
  <li><strong>Install Dependencies</strong>: Install all required packages on the Linux system.</li>
  <li><strong>Set Up Anaconda</strong>: Configure the project's Conda environment.</li>
  <li><strong>Configure Video Environment</strong>: Prepare the specific tools and models needed for video synthesis.</li>
  <li><strong>Create Database</strong>: Initialize the database and add profiles for each professor, including their name and unique voice ID for cloning.</li>
</ol>

# =======================
<h4>Part B: Operations Flow (Professor Tasks)</h4>
<p>This is the main process for creating a video.</p>
<ol>
	  <li><strong>Submit Script</strong>: The professor provides a text script for the lecture topic, which the system fetches from a source like a Google Drive link.</li>
	  <li><strong>Enhance Script</strong>: The raw text is sent to <strong>ChatGPT</strong> to be expanded and formatted into a proper lecture script. An optional step can translate the script into other languages (e.g., Hindi).</li>
	  <li><strong>Generate Audio</strong>: The enhanced text is sent to a text-to-speech service like <strong>ElevenLabs</strong>, using the professor's pre-cloned voice to generate the lecture's audio track.</li>
	  <li><strong>Synthesize Video</strong>: The final audio track is combined with the professor's avatar to generate the complete video lecture. &#x1F3AC;</li>
	  <li><strong>Review</strong>: The final video is ready for playback and review.</li>
</ol>

# =======================
<h3>How to Run</h3>
<ol>
  <li><strong>Open your terminal.</strong></li>
  <li>
    <strong>Clone the repository</strong>:
    <pre><code>git clone git@github.com:soodkunal/guruji.git</code></pre>
  </li>
  <li>
    <strong>Navigate into the directory</strong>:
    <pre><code>cd guruji</code></pre>
  </li>
  <li>
    <strong>Make the script executable</strong>:
    <pre><code>chmod 755 guruji.sh</code></pre>
  </li>
  <li>
    <strong>Run the script</strong> with the action you want to perform. You'll need to run the setup steps first, followed by the operational steps.
    <br>
    <em>Example: To set up the Anaconda environment</em>
    <pre><code>./guruji.sh -anaconda</code></pre>
    <em>Example: To generate the final video (Step B4)</em>
    <pre><code>./guruji.sh -mk_final_video</code></pre>
  </li>
</ol>

# =======================
Setup & Initialization
<ul>
	<li><code>./guruji.sh -init | -reset | -A_step_1</code>: Initializes or resets the project environment. This creates the necessary directories and prepares the workspace for a fresh run.</li>
	<li><code>./guruji.sh -anaconda | -A_step_2</code>: Sets up the project's Conda environment, installing all required Python packages and dependencies.</li>
	<li><code>./guruji.sh -setup_video_env | -A_step_3</code>: Configures the environment specifically for video synthesis and downloads the necessary pre-trained model checkpoints.</li>
</ul>

# =======================
Database Management
<ul>
	<li><code>./guruji.sh -setup_database</code>: Initializes the database to store professor and voice information.</li>
	<li><code>./guruji.sh -add_professor_interactive</code>: Starts an interactive prompt to add a new professor's details (e.g., name, avatar path) to the database.</li>
	<li><code>./guruji.sh -add_voice_interactive</code>: Starts an interactive prompt to add a new voice ID and associate it with a professor in the database.</li>
	<li><code>./guruji.sh -show_database</code>: Displays the current records of all professors and voices stored in the database.</li>
</ul>

# =======================
Main Video Generation
<ul>
	<li><code>./guruji.sh -do_step1 | -B_step_1</code>: <strong>(Input Processing)</strong> Takes the initial text script from the professor and prepares it as the input for the next step.</li>
	<li><code>./guruji.sh -do_step2 | -B_step_2</code>: <strong>(Text Enhancement)</strong> Sends the script to a GPT model to expand and format it into a complete lecture text.</li>
	<li><code>./guruji.sh -do_step3 | -B_step_3</code>: <strong>(Text-to-Speech)</strong> Converts the GPT-enhanced lecture text into a speech audio file (<code>.wav</code>) using the selected professor's cloned voice.</li>
	<li><code>./guruji.sh -do_step4 | -mk_final_video | -final | -B_step_4</code>: <strong>(Video Synthesis)</strong> Generates the final lecture video by combining the professor's avatar with the generated audio.</li>
	<li><code>./guruji.sh -do_step5 | -B_step_5</code>: <strong>(Playback)</strong> Plays the final generated video file for immediate review.</li>
</ul>

# =======================
Utilities & Other Commands
<ul>
	<li><code>./guruji.sh -elab_add_voice</code>: A utility to add a new voice sample to the voice cloning service (e.g., ElevenLabs).</li>
	<li><code>./guruji.sh -elab_del_voice</code>: A utility to delete a voice sample from the voice cloning service.</li>
	<li><code>./guruji.sh -clear_time</code>: Manually clears the run timestamp, which can be used to force regeneration of content on the next run.</li>
	<li><code>./guruji.sh -help</code>: Displays the help message, listing all available commands and their functions.</li>
</ul>

# =======================
## Flowchart

```mermaid
flowchart TD

    A[Open Terminal] --> B[Clone Repository: git clone git@github.com:soodkunal/guruji.git]
    B --> C[Navigate into Directory: cd guruji]
    C --> D[Make Script Executable: chmod 755 guruji.sh]
    D --> E{Choose Action}

    %% Setup & Initialization
    E --> F1[Setup & Initialization]
    F1 --> F2["-init / -reset / -A_step_1: Initialize or reset environment"]
    F1 --> F3["-anaconda / -A_step_2: Setup Conda environment & dependencies"]
    F1 --> F4["-setup_video_env / -A_step_3: Configure video env & download models"]

    %% Database Management
    E --> G1[Database Management]
    G1 --> G2["-setup_database: Init professor & voice DB"]
    G1 --> G3["-add_professor_interactive: Add professor details"]
    G1 --> G4["-add_voice_interactive: Add voice & link to professor"]
    G1 --> G5["-show_database: View DB records"]

    %% Main Video Generation
    E --> H1[Main Video Generation]
    H1 --> H2["-do_step1 / -B_step_1: Input Processing"]
    H2 --> H3["-do_step2 / -B_step_2: Text Enhancement with GPT"]
    H3 --> H4["-do_step3 / -B_step_3: Text-to-Speech (Voice Cloning)"]
    H4 --> H5["-do_step4 / -mk_final_video / -final / -B_step_4: Video Synthesis"]
    H5 --> H6["-do_step5 / -B_step_5: Playback"]

    %% Utilities
    E --> I1[Utilities & Other Commands]
    I1 --> I2["-elab_add_voice: Add voice to cloning service"]
    I1 --> I3["-elab_del_voice: Delete voice from service"]
    I1 --> I4["-clear_time: Clear run timestamp"]
    I1 --> I5["-help: Show all commands"]

