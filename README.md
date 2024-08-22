<div align="center">
    <img src="./logo.jpg" alt="KubeNinja Logo" style="width: 300px; height: 300px; object-fit: cover;">
    <p>KubeNinja, an AI-powered tool that analyzes and fixes Kubernetes deployment issues based on logs and configurations.</p>
</div>

---
KubeNinja leverages the `llama3:latest` model from `ollama` to diagnose and suggest fixes for Kubernetes deployment issues, ensuring that your Kubernetes environment is running smoothly.

## Features
- Analyzes Kubernetes deployment configurations and logs.
- Provides detailed explanations of issues and actionable commands to resolve them.
- Interactive prompt for user input and confirmations.
- Enhances user experience with modern, interactive UI using `gum`.

## Prerequisites

1. **Install `ollama`**:
   - Download and install `ollama` from [ollama's official website](https://www.ollama.com/download).
   - Ensure that `ollama` is running and accessible at `http://localhost:11434`.
   - Pull the `latest` version of the `llama3` model with the following command:
        ```bash
        ollama pull llama3:latest
        ```
2. **Install `gum` (Optional for Enhanced UI/UX)**:
    - If you want to use the `gum` enhanced script:
      ```bash
        # macOS or Linux
        brew install gum

        # Arch Linux (btw)
        pacman -S gum

        # Windows (via WinGet or Scoop)
        winget install charmbracelet.gum
        scoop install charm-gum
      ```
    - More installation methods [here](https://github.com/charmbracelet/gum#Installation).

## Why Two Scripts?

To cater to different user preferences and environments, we provide three versions of the script:

1. **Bash Script without Dependencies (`script.sh`)**:
    - For users who prefer a bash script without any additional dependencies. This version has a basic user interface and functionality.

2. **Bash Script with `gum` (`gumscript.sh`)**:
    - For users who want a significantly enhanced user experience with a modern, interactive UI. This version requires the `gum` tool to be installed.

You can choose the version that best fits your needs and preferences.

## Installation

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/Osama-Yusuf/KubeNinja.git
    cd KubeNinja
    ```

2. **Make the Script Executable**:
    ```bash
    chmod +x gumscript.sh
    ```

3. **Install Dependencies**:
    - Ensure you have `jq` installed for processing JSON responses:
      ```bash
      sudo apt-get install jq
      ```

4. **Add the Script to your bin directory**:
    ```bash
    sudo cp gumscript.sh /usr/local/bin/kubeninja
    ```

## Usage

To analyze and fix Kubernetes deployment issues, run the script:

```bash
kubeninja mydeployment
```

#### Script Workflow

1. Prompt for the deployment name and optional issue description.
2. Extract and analyze Kubernetes deployment configurations and logs.
3. Call the AI model to generate explanations and actionable commands.
4. Prompt the user to confirm or execute the suggested actions.

### Detailed Steps

1. **Prompt for Deployment Name and Issue Description**:
    * The script prompts for the deployment name and an optional issue description.
2. **Extract Kubernetes Configurations and Logs**:
    * The script extracts relevant configurations and logs from the Kubernetes cluster.
3. **Generate Explanations and Actions**:
    * The script sends the extracted data to the AI model `llama3:latest` from `ollama` to generate explanations and actionable commands.
4. **Interactive Confirmation**:
    * The script prompts you to confirm or execute the suggested actions.

## Example

Here is an example of how the AI-generated explanation and action might look:

```text
INFO: The deployment is stuck due to a missing config map.
Act: kubectl create configmap my-config --from-literal=key1=value1
```

## Contributing

Contributions are welcome! Please fork the repository and create a pull request with your changes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contact

For any inquiries or support, please contact [Osama Yusuf](https://github.com/Osama-Yusuf).
