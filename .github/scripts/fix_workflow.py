#!/usr/bin/env python3

import argparse
import json
import os
import sys
import yaml
import openai
from pathlib import Path
from github import Github
from datetime import datetime

def load_workflow_file(file_path):
    """Load and parse a workflow YAML file."""
    try:
        with open(file_path, 'r') as f:
            return yaml.safe_load(f)
    except Exception as e:
        print(f"Error loading workflow file: {str(e)}", file=sys.stderr)
        return None

def load_workflow_logs(logs_file):
    """Load workflow logs from JSON file."""
    try:
        with open(logs_file, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading logs file: {str(e)}", file=sys.stderr)
        return None

def analyze_and_fix_workflow(workflow_content, logs_content, model):
    """Use OpenAI to analyze logs and fix workflow issues."""
    try:
        openai.api_key = os.environ['OPENAI_KEY']
        
        # Prepare the prompt
        prompt = f"""
        As an expert in GitHub Actions and Flutter CI/CD, analyze these workflow logs and fix the workflow file.
        Focus on common issues like:
        - Incorrect job dependencies or step order
        - Missing environment variables or secrets
        - Invalid Flutter commands or configurations
        - Caching issues
        - Permission problems
        - Syntax errors
        
        Workflow file:
        {yaml.dump(workflow_content)}
        
        Error logs:
        {json.dumps(logs_content, indent=2)}
        
        Provide the fixed workflow file in YAML format, maintaining the existing structure while fixing the issues.
        Only output the YAML content, nothing else.
        """
        
        # Get AI suggestions
        response = openai.ChatCompletion.create(
            model=model,
            messages=[
                {"role": "system", "content": "You are an expert CI/CD engineer specializing in GitHub Actions and Flutter."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.3,
            max_tokens=4000
        )
        
        # Parse the response
        fixed_workflow = yaml.safe_load(response.choices[0].message.content)
        return fixed_workflow
        
    except Exception as e:
        print(f"Error getting AI suggestions: {str(e)}", file=sys.stderr)
        return None

def commit_fixed_workflow(workflow_file, fixed_content, branch, attempt):
    """Commit the fixed workflow file to a new branch."""
    try:
        # Write the fixed content
        with open(workflow_file, 'w') as f:
            yaml.dump(fixed_content, f, sort_keys=False)
        
        # Stage and commit the changes
        os.system('git config --global user.email "ai-bot@example.com"')
        os.system('git config --global user.name "AI Bot"')
        os.system('git add ' + workflow_file)
        os.system(f'git commit -m "AI: Fix attempt #{attempt} for workflow issues"')
        
        # Push to the fix branch
        os.system(f'git push origin {branch}')
        
        return True
        
    except Exception as e:
        print(f"Error committing fixes: {str(e)}", file=sys.stderr)
        return False

def main():
    parser = argparse.ArgumentParser(description='Analyze and fix GitHub Actions workflow')
    parser.add_argument('--workflow-file', required=True, help='Path to workflow file')
    parser.add_argument('--logs', required=True, help='Path to workflow logs')
    parser.add_argument('--max-retries', required=True, type=int, help='Maximum number of fix attempts')
    parser.add_argument('--openai-model', required=True, help='OpenAI model to use')
    parser.add_argument('--branch', required=True, help='Branch to commit fixes to')
    parser.add_argument('--attempt', required=True, type=int, help='Current fix attempt number')
    
    args = parser.parse_args()
    
    # Check retry limit
    if args.attempt > args.max_retries:
        print(f"Reached maximum retry limit of {args.max_retries}")
        sys.exit(1)
    
    # Load files
    workflow_content = load_workflow_file(args.workflow_file)
    logs_content = load_workflow_logs(args.logs)
    
    if not workflow_content or not logs_content:
        sys.exit(1)
    
    # Get fixes from AI
    fixed_workflow = analyze_and_fix_workflow(
        workflow_content,
        logs_content,
        args.openai_model
    )
    
    if not fixed_workflow:
        sys.exit(1)
    
    # Commit fixes
    success = commit_fixed_workflow(
        args.workflow_file,
        fixed_workflow,
        args.branch,
        args.attempt
    )
    
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
