#!/bin/bash

# Function to check if the last command was successful
check_success() {
    if [ $? -ne 0 ]; then
        echo "$1"
        remove_temp_files
        exit 1
    fi
}

check_var() {
    if [ -z "$1" ]; then
        echo "$2"
        remove_temp_files
        exit 1
    fi
}

check_log() {
    if [ $? -ne 0 ]; then
        echo "$1"
    fi
}

# Function to extract deployment YAML
extract_deployment_yaml() {
    # kubectl get deployment "$deployment_name" -o yaml > deployment.yaml
    kubectl get deployment "$deployment_name" -o yaml | \
    yq eval 'del(.metadata, .status)' - > deployment.yaml
    check_success "Failed to extract deployment YAML."
}

# Function to extract pod logs and describe outputs
extract_pod_logs_and_describe() {
    pod_name=$(kubectl get pods | grep "$deployment_name" | awk '{print $1}')
    check_var "$pod_name" "Pod not found"
    kubectl logs "$pod_name" > pod_logs.txt 2>/dev/null
    kubectl describe pod "$pod_name" > pod_describe.txt
    check_success "Failed to describe pod."
    kubectl describe deployment "$deployment_name" > deployment_describe.txt
    check_success "Failed to describe deployment."
}

# Function to extract service YAML
extract_service_yaml() {
    service_name=$(kubectl get svc | grep "$deployment_name" | awk '{print $1}')
    # check if service name exist 
    if [ -z "$service_name" ]; then
        echo "No service found."
        touch service.yaml # just create an empty file, because the prompt will be catting it later.
    else
        kubectl get svc "$service_name" -o yaml > service.yaml
    fi
    # kubectl get svc "$service_name" -o yaml > service.yaml
    # check_log "No service found."
}

# Function to extract relevant node descriptions and labels
extract_nodes_describe() {
    kubectl get nodes -o name | while read node; do
        {
            echo "Node: $node"
            echo "Labels:"
            kubectl get "$node" --show-labels | awk 'NR==2 {print $6}'
            # echo "Conditions:"
            # kubectl describe "$node" | awk '/Conditions:/,/Addresses:/ {print}' | sed 's/^/  /'
            # echo "Allocatable:"
            # kubectl describe "$node" | awk '/Allocatable:/,/System Info:/ {print}' | sed 's/^/  /'
            # echo "Non-terminated Pods:"
            # kubectl describe "$node" | awk '/Non-terminated Pods:/,/Allocated resources:/ {print}' | sed 's/^/  /'
            echo ""
        } >> nodes_describe.txt
    done
    kubectl get nodes >> nodes_describe.txt
    check_success "Failed to describe nodes."
}


# Function to create the prompt for AI analysis
create_prompt() {
    prompt="You are an experienced DevOps engineer specializing in Kubernetes and Linux.
###Instruction###
Provide explanations (starting with 'INFO:') and actionable commands or steps (starting with 'Act:') to solve the problem based on the following context. Each explanation should be related to the context, and each action should be clear and concise. Only include the command in the 'Act' sections without additional explanation.
###Context###
Nodes description:
$(cat nodes_describe.txt)

Deployment YAML:
$(cat deployment.yaml)

Pod logs:
$(cat pod_logs.txt)

Pod description:
$(cat pod_describe.txt)

Deployment description:
$(cat deployment_describe.txt)

Service YAML:
$(cat service.yaml)

User issue description: ${issue_description:-None}
"
}

# Function to call the AI model
call_ai_model() {
    response=$(gum spin --title "Analyzing logs and generating fix..." -- curl -s -X POST http://localhost:11434/api/chat \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg prompt "$prompt" '{"model": "llama3:latest", "messages": [{"role": "user", "content": $prompt}]}')")
    check_success "Failed to make POST request to the AI model."
    response_content=$(echo "$response" | jq -r '.message.content')
    ai_fixes=$(echo "$response_content" | tr -d '\n' | sed 's/Act:/\nAct:/g' | sed 's/INFO:/\nINFO:/g')

    echo -e "\nAI Response:"
    if [ -z "$ai_fixes" ]; then
        echo "Failed to generate fix."
        exit 1
    fi
}

# Function to remove temporary files
remove_temp_files() {
    rm -f deployment.yaml pod_logs.txt pod_describe.txt deployment_describe.txt service.yaml nodes_describe.txt
}

# Main script execution
if [ -z "$1" ]; then
    echo "Usage: $0 <deployment_name> [issue_description]"
    exit 1
fi

deployment_name=$1
issue_description=$2

extract_deployment_yaml
extract_pod_logs_and_describe
extract_service_yaml
extract_nodes_describe
create_prompt
call_ai_model

IFS=$'\n'
declare -a info_messages
declare -a act_commands

for line in $ai_fixes; do
    if [[ "$line" == Act:* ]]; then
        act_commands+=("${line#Act: }")
    elif [[ "$line" == INFO:* ]]; then
        info_messages+=("${line#INFO: }")
    fi
done

for info in "${info_messages[@]}"; do
    # gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Hello, there! Welcome to $(gum style --foreground 212 'Gum')."

    gum style --foreground 212 "$info"
done

echo -e "\nProposed actions:"
for action in "${act_commands[@]}"; do
    gum style --foreground 212 "$action"
done

remove_temp_files