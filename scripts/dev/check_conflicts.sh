#!/bin/bash

# Update to work from scripts/dev directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TAP_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

get_tap_name() {
    local tap_name=""
    
    # Change to tap root before git operations
    cd "${TAP_ROOT}" || exit 1
    
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local git_url
        git_url=$(git remote get-url origin 2>/dev/null)
        if [[ ${git_url} =~ github\.com[/:]([^/]+)/([^/.]+) ]]; then
            tap_name="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
            tap_name="${tap_name//homebrew-/}"
            echo "${tap_name}"
            return 0
        fi
    fi
    
    local parent_dir
    local current_dir
    parent_dir=$(basename "$(dirname "${TAP_ROOT}")")
    current_dir=$(basename "${TAP_ROOT}")
    
    parent_dir="${parent_dir//homebrew-/}"
    current_dir="${current_dir//homebrew-/}"
    
    if [[ ${parent_dir} == "Homebrew" || ${parent_dir} == "homebrew"* ]]; then
        tap_name="${parent_dir}/${current_dir}"
    else
        tap_name="${current_dir}"
    fi
    
    tap_name="${tap_name//homebrew-/}"
    echo "${tap_name}"
}

check_formula_conflicts_and_dependencies() {
    local tap_dir="${1:-${TAP_ROOT}}"
    local formulas=()
    local keg_only_formulas=()

    # Find all formula files
    while IFS= read -r formula_file; do
        formulas+=("$(basename "${formula_file}" .rb)")
    done < <(find "${tap_dir}/Formula" -name "*.rb")

    # Check each formula
    for formula in "${formulas[@]}"; do
        local formula_file="${TAP_ROOT}/Formula/${formula}.rb"
        
        # Check if formula is keg-only
        if grep -q "keg_only" "${formula_file}"; then
            keg_only_formulas+=("${formula}")
        fi
    done

    # Print installation instructions
    printf "\n# Install all formulas:\n"
    if [[ ${#keg_only_formulas[@]} -gt 0 ]]; then
        printf "# Note: The following are keg-only formulas and can be installed simultaneously:\n"
        for formula in "${keg_only_formulas[@]}"; do
            printf "brew install --build-from-source %s/Formula/%s.rb\n" "${TAP_ROOT}" "${formula}"
        done
    fi

    # Install non-keg-only formulas
    for formula in "${formulas[@]}"; do
        if [[ ! " ${keg_only_formulas[@]} " =~ " ${formula} " ]]; then
            printf "\n# Note: The following formula is not keg-only but should not conflict with keg-only versions:\n"
            printf "brew install --build-from-source %s/Formula/%s.rb\n" "${TAP_ROOT}" "${formula}"
        fi
    done
}

# Get tap name
tap_name=$(get_tap_name)

# Run the conflict and dependency check
check_formula_conflicts_and_dependencies