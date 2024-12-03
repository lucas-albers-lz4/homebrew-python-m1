#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# ANSI color codes for better visual feedback
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # Reset color

# Version configuration for Python formulas
# Format: "short_version:full_version"
# These versions are tracked and managed by this script
PYTHON_VERSIONS=(
    "3.11:3.11.10"
    "3.12:3.12.7"
    "3.13:3.13.0"
)

# Tap configuration
export UPSTREAM_TAP="homebrew/core"            # Source of Python formulas
LOCAL_TAP="lucas-albers-lz4/python-m1"  # Our local tap for M1-optimized versions
TEMP_TAP="lucas-albers-lz4/python-temp" # Temporary tap for formula processing

# Utility functions for consistent logging
log_error() { echo -e "${RED}ERROR: $1${NC}" >&2; }
log_success() { echo -e "${GREEN}SUCCESS: $1${NC}"; }
log_info() { echo -e "${YELLOW}INFO: $1${NC}"; }

# Sets up clean homebrew taps for formula management
setup_taps() {
    log_info "Setting up taps..."
    brew untap "${LOCAL_TAP}" 2>/dev/null || true
    brew untap "${TEMP_TAP}" 2>/dev/null || true
    
    # Ensure clean slate by removing any leftover tap files
    rm -rf "$(brew --prefix)/Library/Taps/lucas-albers-lz4" 2>/dev/null || true
    
    brew tap-new "${LOCAL_TAP}"
    brew tap-new "${TEMP_TAP}"
}

# Downloads Python formulas from homebrew-core
download_formulas() {
    local temp_path
    temp_path="$(brew --repository "${TEMP_TAP}")/Formula"
    
    for version_pair in "${PYTHON_VERSIONS[@]}"; do
        local short_version="${version_pair%%:*}"
        local formula_file="${temp_path}/python@${short_version}.rb"
        local url="https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/p/python@${short_version}.rb"
        
        log_info "Downloading Python ${short_version} formula from: ${url}"
        
        # HTTP request with status code validation
        local http_response
        if ! http_response=$(curl -s -w "%{http_code}" -o "${formula_file}" "${url}") || [[ "${http_response}" != "200" ]]; then
            log_error "Failed to download Python ${short_version} formula"
            log_error "URL: ${url}"
            log_error "HTTP Status: ${http_response}"
            return 1
        fi
        
        # Validate formula content
        if ! grep -q "class PythonAT${short_version//./} < Formula" "${formula_file}"; then
            log_error "Invalid formula content for Python ${short_version}"
            log_error "URL: ${url}"
            log_error "Formula file: ${formula_file}"
            return 1
        fi
        
        log_success "Successfully downloaded Python ${short_version} formula"
    done
    
    # Initialize git repository for version tracking
    local repo_path
    repo_path="$(brew --repository "${TEMP_TAP}")"
    cd "${repo_path}" || exit 1
    git add Formula/python@3.*.rb
    git commit -m "Add Python formulas"
}

# Extracts specific Python versions from formulas
extract_versions() {
    for version_pair in "${PYTHON_VERSIONS[@]}"; do
        local short_version="${version_pair%%:*}"
        local full_version="${version_pair#*:}"
        
        log_info "Extracting Python ${short_version} version ${full_version}..."
        if ! brew extract --version="${full_version}" "${TEMP_TAP}/python@${short_version}" "${LOCAL_TAP}"; then
            log_error "Failed to extract Python ${short_version}"
            return 1
        fi
    done
}

# Checks for divergence between local and upstream formulas
check_divergence() {
    local main_tap_path
    main_tap_path="$(brew --repository "${LOCAL_TAP}")"
    
    for version_pair in "${PYTHON_VERSIONS[@]}"; do
        local short_version="${version_pair%%:*}"
        local full_version="${version_pair#*:}"
        local github_url="https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/p/python@${short_version}.rb"
        local homebrew_formula="python@${short_version}"
        local output_dir="${main_tap_path}/upstream_compare"
        
        mkdir -p "${output_dir}"
        
        # Fetch and compare upstream version
        log_info "Fetching GitHub upstream formula for Python ${short_version}..."
        if ! curl -s -o "${output_dir}/github_${homebrew_formula}.rb" "${github_url}"; then
            log_error "Failed to fetch GitHub upstream from: ${github_url}"
            continue
        fi
        
        # Compare with local installed version
        local cellar_path="/opt/homebrew/Cellar/python@${short_version}/${full_version}*/.brew/python@${short_version}.rb"
        local local_formula
        local_formula=$(find "${cellar_path}" -type f 2>/dev/null | head -n 1)
        
        if [[ -f "${local_formula}" ]]; then
            log_info "Copying local formula for Python ${short_version}..."
            cp "${local_formula}" "${output_dir}/local_${homebrew_formula}.rb"
            log_success "Downloaded both versions for Python ${short_version}"
        else
            log_error "Local formula not found at: ${cellar_path}"
        fi
    done
    
    log_info "Formula files saved in: ${output_dir}"
}

# Main execution function with command handling
main() {
    local command="${1:-setup}"
    
    case "${command}" in
        "setup")
            setup_taps
            if ! download_formulas; then
                exit 1
            fi
            if ! extract_versions; then
                exit 1
            fi
            if ! brew untap "${TEMP_TAP}"; then
                exit 1
            fi
            log_success "Setup completed successfully"
            ;;
        "check")
            check_divergence
            ;;
        *)
            echo "Usage: ${0} [setup|check]"
            exit 1
            ;;
    esac
}

main "${@}"