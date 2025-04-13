# Self-Healing CI/CD System Guide

This guide explains how the automated self-healing CI/CD system works and how to monitor its operation.

## System Overview

The self-healing system automatically:
1. Monitors the Flutter CI/CD workflow for failures
2. Analyzes error logs using OpenAI's GPT-4
3. Generates fixes for the workflow file
4. Creates pull requests with corrections
5. Tracks fix attempts

## Setup Requirements

1. **OpenAI API Key**
   - Sign up at https://platform.openai.com
   - Generate an API key
   - Add the key as a GitHub repository secret named `OPENAI_API_KEY`

2. **GitHub Repository Secrets**
   - Go to your repository Settings > Secrets and Variables > Actions
   - Add these secrets:
     - `OPENAI_API_KEY`: Your OpenAI API key
     - `GITHUB_TOKEN`: Automatically provided by GitHub

## How It Works

1. **Monitoring**
   - The system activates when the main Flutter CI/CD workflow fails
   - Triggered by the `workflow_run` event

2. **Analysis & Fix Process**
   - Downloads workflow logs
   - Uses OpenAI to analyze errors and generate fixes
   - Creates a new branch for each fix attempt
   - Commits corrected workflow file
   - Creates a pull request with detailed error summary

3. **Safety Measures**
   - Maximum 5 fix attempts per issue
   - Detailed logging of each attempt
   - Pull requests require manual review

## Monitoring Fix Attempts

1. **View Active Fix Attempts**
   - Go to repository's Pull Requests tab
   - Look for PRs with label `ai-fix-attempt`
   - Each PR includes:
     - Detailed error summary
     - Changes made to workflow file
     - Attempt number

2. **Check Workflow Runs**
   - Go to Actions tab
   - Look for "Self-Healing CI/CD" workflow runs
   - Each run shows:
     - Error analysis
     - Fix attempt details
     - Success/failure status

3. **Review Fix Summaries**
   - Each PR contains a `fix_summary.md`
   - Shows:
     - Timestamp
     - Workflow details
     - Job results
     - Error logs
     - Applied fixes

## Customization

Key configuration in `.github/workflows/self_healing_ci.yml`:
- `MAX_RETRIES`: Maximum fix attempts (default: 5)
- `OPENAI_MODEL`: GPT model to use (default: gpt-4)
- `FIX_BRANCH_PREFIX`: Branch naming prefix

## Troubleshooting

1. **OpenAI API Issues**
   - Verify API key is correctly set in secrets
   - Check OpenAI API status
   - Review workflow logs for API errors

2. **GitHub Permissions**
   - Ensure workflow has write permissions
   - Check repository access settings
   - Verify GitHub token permissions

3. **Fix Attempts Not Working**
   - Check workflow logs for Python script errors
   - Verify log file generation
   - Review OpenAI response content