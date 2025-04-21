#!/bin/bash

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# Function to display the simplified explanation of Cubic Slashing
display_explanation() {
    echo ""
    echo -e "${GREEN}--------------------------------------------${RESET}"
    echo -e "${BLUE}Purpose of This Tool:${RESET}"
    echo -e "${GREEN}--------------------------------------------${RESET}"
    echo -e "${WHITE}This tool helps stakers understand Namada's unique ${YELLOW}Cubic Slashing${RESET} system, which penalizes validators based on their ${YELLOW}voting power.${RESET}"
    echo -e "${WHITE}It helps you assess ${YELLOW}risks${RESET}, ${GREEN}rewards${RESET}, and encourages ${WHITE}decentralized staking${RESET} by spreading your stake across smaller validators.${RESET}"
    echo -e "${GREEN}--------------------------------------------${RESET}"
    echo ""

    echo -e "${GREEN}------------------------------------${RESET}"
    echo -e "${BLUE}How Does Namada Slashing Work?${RESET}"
    echo -e "${GREEN}------------------------------------${RESET}"
    echo -e "${WHITE}1. Think of ${RED}slashing${RESET} as a penalty: the more ${MAGENTA}marbles (stake)${RESET} a validator controls, the harsher the penalty if they misbehave.${RESET}"
    echo -e "${WHITE}2. When misbehavior happens, the validator is ${WHITE}frozen${RESET} – no one can withdraw their ${MAGENTA}marbles${RESET} until it's resolved.${RESET}"
    echo -e "${WHITE}3. The penalty ${RED}increases${RESET} if the validator controls more ${MAGENTA}marbles${RESET}, encouraging ${RED}fair play${RESET}.${RESET}"
    echo -e "${WHITE}4. The penalty is ${WHITE}delayed${RESET}, giving others time to ${YELLOW}react${RESET} and protect their stake.${RESET}"
    echo -e "${WHITE}5. Validators can ${WHITE}return${RESET} after proving they’re ready to follow the ${RED}rules${RESET} again.${RESET}"
    echo -e "${GREEN}------------------------------------${RESET}"
    echo ""

    echo -e "${GREEN}------------------------------------${RESET}"
    echo -e "${BLUE}Why Stake with Small Validators?${RESET}"
    echo -e "${GREEN}------------------------------------${RESET}"
    echo -e "${WHITE}1. Think of a ${MAGENTA}big jar${RESET}: if it falls, everyone loses more. Spread your stake across ${MAGENTA}many jars${RESET} (smaller validators).${RESET}"
    echo -e "${WHITE}2. Spreading your ${MAGENTA}marbles${RESET} across ${MAGENTA}jars${RESET} protects your ${YELLOW}investment${RESET} and strengthens the ${WHITE}network${RESET}.${RESET}"
    echo -e "${WHITE}3. ${WHITE}Decentralization${RESET} keeps the ${WHITE}network${RESET} secure and balanced.${RESET}"
    echo -e "${WHITE}4. Supporting smaller validators like ${WHITE}Grand Valley${RESET} promotes ${WHITE}stability${RESET} for Namada ${GREEN}(tnam1qyplu8gruqmmvwp7x7kd92m6x4xpyce265fa05r6)${RESET}"
    echo -e "${WHITE}5. Don’t put all your ${MAGENTA}marbles${RESET} in one ${MAGENTA}jar${RESET} – spread them for ${YELLOW}safety${RESET}!${RESET}"
    echo -e "${GREEN}------------------------------------${RESET}"
    echo ""
    echo -e "${GREEN}Let's Buidl Namada Together${RESET}"
    echo ""
}

# Function to install dependencies
install_dependencies() {
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}curl is not installed. Installing...${RESET}"
        sudo apt-get update && sudo apt-get install -y curl
    fi

    if ! command -v jq &> /dev/null; then
        echo -e "${RED}jq is not installed. Installing...${RESET}"
        sudo apt-get update && sudo apt-get install -y jq
    fi
}

# Main menu function
main_menu() {
    while true; do
        clear
        echo -e "${CYAN}Welcome to Namada CSR Monitoring Tool by Grand Valley${RESET}"
        display_explanation
        echo -e "${GREEN}Main menu:${RESET}"
        echo -e "1. Monitor CSR"
        echo -e "2. Back to the Valley of Namada Main Menu"
        read -p "Select an option: " choice

        case $choice in
            1) monitor_csr;;
            2) echo -e "${GREEN}Exiting...${RESET}"; exit 0;;
            *) echo -e "${RED}Invalid option. Try again.${RESET}"; sleep 1;;
        esac
    done
}

# Monitor CSR function
monitor_csr() {
    local current_page=1
    local items_per_page=20  # Changed to 20

    while true; do
        clear

        # Fetch total voting power
        total_voting_power=$(curl -s 'https://indexer-mainnet-namada.grandvalleys.com/api/v1/pos/voting-power' | jq -r '.totalVotingPower')

        # Fetch validator data
        validator_data=$(curl -s 'https://indexer-mainnet-namada.grandvalleys.com/api/v1/pos/validator/all?state=consensus' | jq -r '.[] | "\(.name) \(.votingPower)"')
        sorted_validators=$(echo "$validator_data" | awk '{print $NF, $0}' | sort -nr | cut -d' ' -f2-)

        # Create an array of validators
        IFS=$'\n' read -r -d '' -a validators <<< "$sorted_validators"
        total_validators=${#validators[@]}
        total_pages=$(( (total_validators + items_per_page - 1) / items_per_page ))

        # Display page data
        start_index=$(( (current_page - 1) * items_per_page ))
        end_index=$(( start_index + items_per_page - 1 ))
        [ $end_index -ge $total_validators ] && end_index=$(( total_validators - 1 ))

        echo -e "${GREEN}Total Voting Power (TVP) = $total_voting_power NAM${RESET}"
        echo -e "${CYAN}Page $current_page/$total_pages${RESET}"
        echo -e "${GREEN}No | Validator Name                 | Voting Power (NAM) (vp/tvp %) | Independent CSR (%)${RESET}"
        echo "-------------------------------------------------------------------"

        for i in $(seq $start_index $end_index); do
            name=$(echo "${validators[$i]}" | rev | cut -d' ' -f2- | rev)
            voting_power=$(echo "${validators[$i]}" | awk '{print $NF}')

            # Calculate fractional voting power and CSR
            fractional_voting_power=$(echo "scale=10; $voting_power / $total_voting_power" | bc)
            fractional_voting_power_percentage=$(echo "$fractional_voting_power * 100" | bc -l | awk '{printf "%.2f", $1}')
            cubic_slash_rate=$(echo "scale=10; 9 * ($fractional_voting_power ^ 2)" | bc)
            cubic_slash_rate=$(echo "scale=2; if ($cubic_slash_rate < 0.001) 0.001 else if ($cubic_slash_rate > 1.0) 1.0 else $cubic_slash_rate" | bc)
            cubic_slash_rate_percentage=$(echo "$cubic_slash_rate * 100" | bc -l | awk '{printf "%.2f", $1}')

            printf "%2d | %-30s | %-18s ($fractional_voting_power_percentage) | %s\n" $((i + 1)) "$name" "$voting_power" "$cubic_slash_rate_percentage"
        done

        echo ""
        echo "-------------------------------------------------------------------"
        echo -e "${CYAN}Notes:${RESET}"
        echo -e "${YELLOW}Independent CSR:${RESET} The Independent CSR represents the estimated slashing rate for a validator assuming it is the only one misbehaving with infractions in one window width (3 epochs). It grows proportionally with the validator's voting power, ensuring larger validators face higher penalties for misbehavior, thereby enhancing network security and resilience."
        echo ""
        echo -e "${YELLOW}Example:${RESET} A validator with 10% of TVP could face, minimally, 9% slashing of staked tokens. For a validator with 1000 tokens, 90 could be slashed."
        echo ""
        echo -e "Commands: [${GREEN}n${RESET}] Next Page, [${GREEN}p${RESET}] Previous Page, [${GREEN}s${RESET}] Simulation Tool, [${GREEN}j${RESET}] Jump to Page, [${GREEN}q${RESET}] Quit"
        read -p "Enter command: " command

        case $command in
            n) [ $current_page -lt $total_pages ] && current_page=$((current_page + 1)) || echo -e "${RED}Last page reached.${RESET}";;
            p) [ $current_page -gt 1 ] && current_page=$((current_page - 1)) || echo -e "${RED}First page reached.${RESET}";;
            s) simulate_infractions;;
            j)
                read -p "Enter page number to jump to: " page_number
                if [[ $page_number =~ ^[0-9]+$ ]] && [ $page_number -ge 1 ] && [ $page_number -le $total_pages ]; then
                    current_page=$page_number
                else
                    echo -e "${RED}Invalid page number. Try again.${RESET}"
                fi
                ;;
            q) return;;
            *) echo -e "${RED}Invalid command.${RESET}"; sleep 1;;
        esac
    done
}

simulate_infractions() {
    echo ""
    echo -e "${CYAN}Cubic Slashing Rate Simulation Tool${RESET}"
    echo -e "${YELLOW}Notes:${RESET} This tool simulates the Cubic Slashing Rate (CSR) for validators based on their infractions in a specific window width (3 epochs). The simulation considers the infractions of all validators within the window width, calculates the total fractional voting power impacted by the infractions, and estimates the potential slashing amount for each validator based on their voting power. The larger the voting power, the more significant the potential slashing amount. This simulation helps you understand the risks associated with validator infractions and can guide your staking decisions."
    echo ""

    declare -A validators
    total_voting_power=$(curl -s 'https://indexer-mainnet-namada.grandvalleys.com/api/v1/pos/voting-power' | jq -r '.totalVotingPower')

    while true; do
        # Step 1: Input validator name
        read -p "Enter validator name (or 'done' to finish): " validator_name
        if [[ "${validator_name,,}" == "done" ]]; then
            break
        fi

        # Fetch validator voting power from the API
        vp=$(curl -s "https://indexer-mainnet-namada.grandvalleys.com/api/v1/pos/validator/all?state=consensus" | jq -r --arg name "$validator_name" '.[] | select(.name == $name) | .votingPower')
        if [[ -z "$vp" ]]; then
            echo -e "${RED}Validator not found. Try again.${RESET}"
            continue
        fi

        # Step 2: Input epoch for infractions
        while true; do
            read -p "Enter the epoch with infractions for ${validator_name}: " epoch
            if [[ $epoch =~ ^[0-9]+$ ]]; then
                break
            else
                echo -e "${RED}Invalid input. Please enter a valid epoch number.${RESET}"
            fi
        done

        # Step 3: Input infractions for the specified epoch
        while true; do
            read -p "Enter infractions for ${validator_name} in epoch ${epoch}: " infractions
            if [[ $infractions =~ ^[0-9]+$ && $infractions -gt 0 ]]; then
                break
            else
                echo -e "${RED}Invalid input. Please enter a valid positive number of infractions.${RESET}"
            fi
        done

        # Store validator information
        validators["$validator_name,$epoch"]="$vp,$infractions"
        echo -e "${GREEN}Validator ${validator_name} added with infractions in epoch ${epoch}.${RESET}"
    done

    # Display the collected data
    echo -e "\n${CYAN}Simulation Input Summary:${RESET}"
    for key in "${!validators[@]}"; do
        IFS=',' read -r name epoch <<< "$key"
        IFS=',' read -r vp infractions <<< "${validators[$key]}"
        echo -e "${YELLOW}- ${name}${RESET} | ${GREEN}Epoch:${RESET} ${epoch} | ${RED}Infractions:${RESET} ${infractions} | ${BLUE}Voting Power:${RESET} ${vp}"
    done

    # Calculate CSR for each validator
    echo -e "\n${CYAN}Calculating CSR...${RESET}"
    declare -A csr_results
    declare -A slashed_nam

    for key in "${!validators[@]}"; do
        IFS=',' read -r name epoch <<< "$key"
        IFS=',' read -r vp infractions <<< "${validators[$key]}"
        
        # Calculate Fractional Voting Power (FVP) and Fraction Total Voting Power (FTVP)
        fvp=$(echo "scale=10; $vp / $total_voting_power" | bc)
        ftvp=$(echo "scale=10; $fvp * $infractions" | bc)

        # Inside-Window-Width Validators Fraction Total VP (IWWVFTVP)
        iwwvftvp=0
        for check_key in "${!validators[@]}"; do
            IFS=',' read -r check_name check_epoch <<< "$check_key"
            if (( check_epoch >= epoch - 1 && check_epoch <= epoch + 1 )) && [[ "$check_name" != "$name" ]]; then
                IFS=',' read -r check_vp check_infractions <<< "${validators[$check_key]}"
                check_fvp=$(echo "scale=10; $check_vp / $total_voting_power" | bc)
                check_ftvp=$(echo "scale=10; $check_fvp * $check_infractions" | bc)
                iwwvftvp=$(echo "scale=10; $iwwvftvp + $check_ftvp" | bc)
            fi
        done
        iwwvftvp=$(echo "scale=10; $iwwvftvp + $ftvp" | bc)

        # Calculate CSR
        csr=$(echo "scale=10; 9 * ($iwwvftvp^2)" | bc)
        csr=$(echo "scale=10; if ($csr < 0.001) 0.001 else if ($csr > 1.0) 1.0 else $csr" | bc)
        csr_percentage=$(echo "$csr * 100" | bc -l | awk '{printf "%.2f", $1}')

        # Calculate Slashed NAM
        slashed_nam["$name"]=$(echo "scale=2; $csr * $vp" | bc)

        # Store CSR result for the current validator
        csr_results["$name"]=$csr_percentage
    done

    # Display CSR and slashed NAM results
    for name in "${!csr_results[@]}"; do
        echo -e "Validator: ${BLUE}$name${RESET}, CSR: ${RED}${csr_results[$name]}%${RESET}, Slashed NAM: ${RED}${slashed_nam[$name]} NAM${RESET}"
    done

    echo -e "\n${GREEN}Diversify your delegations to minimize risk and support smaller validators!${RESET}"
    read -p "Press Enter to return to the Monitor CSR menu..."
}

# Ensure dependencies are installed
install_dependencies

# Start the script
main_menu
