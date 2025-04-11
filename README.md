# Local Testing Setup

This guide provides instructions for setting up your local environment for testing. Make sure to follow the steps below to get started.

## Prerequisites

Before proceeding with the local testing setup, ensure the following tools are installed on your machine:

1. **GitHub CLI (`gh`)**  
   GitHub CLI is required to interact with GitHub from the command line.
   
   - **Installation**:  
     - On macOS: `brew install gh`
     - On Ubuntu: `sudo apt install gh`
     - On Windows: Follow the installation instructions [here](https://cli.github.com/manual/).

2. **jq**  
   `jq` is a lightweight and flexible command-line JSON processor, which will help with parsing JSON data in testing.

   - **Installation**:  
     - On macOS: `brew install jq`
     - On Ubuntu: `sudo apt install jq`
     - On Windows: Follow the installation instructions [here](https://stedolan.github.io/jq/download/).

## Setting Up for Local Testing

Follow these steps to set up your environment for local testing.

1. **Clone the Repository (if not already cloned)**  
   If you haven't cloned the repository yet, run the following command:
   ```bash
   git clone git@github.com:NiloJr-sun/check-release.git
   cd check-release/testing-local
2. **Run this command**
   ```bash
   For Main Threads: ./check-release.sh PR_LINK
   For Follow up Threads: ./check-release.sh PR_LINK TIME_STAMP
