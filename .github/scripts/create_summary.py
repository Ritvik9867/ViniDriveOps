#!/usr/bin/env python3

import argparse
import json
import sys
from datetime import datetime

def create_markdown_summary(logs_content):
    """Create a markdown summary of the workflow fix attempt."""
    try:
        with open(logs_content, 'r') as f:
            logs = json.load(f)
        
        summary = []
        summary.append("# Workflow Fix Attempt Summary\n")
        
        # Add timestamp
        summary.append(f"Generated at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}\n")
        
        # Add workflow details
        summary.append(f"## Workflow Details")
        summary.append(f"- **Name:** {logs['workflow_name']}")
        summary.append(f"- **Run ID:** {logs['run_id']}")
        summary.append(f"- **Status:** {logs['status']}\n")
        
        # Add job summaries
        summary.append("## Job Results")
        for job in logs['jobs']:
            summary.append(f"### {job['name']}")
            summary.append(f"Status: {job['status']}")
            
            # Add step details
            summary.append("\n#### Steps:")
            for step in job['steps']:
                status_emoji = "✅" if step['status'] == 'success' else "❌"
                summary.append(f"{status_emoji} {step['name']}")
                
                if step['status'] == 'failure' and 'log_content' in step:
                    summary.append("\n<details><summary>Error Logs</summary>\n")
                    summary.append("```")
                    # Limit log content to avoid extremely long summaries
                    log_preview = step['log_content'][:2000]
                    if len(step['log_content']) > 2000:
                        log_preview += "\n... (truncated)"
                    summary.append(log_preview)
                    summary.append("```\n</details>\n")
            
            summary.append("")
        
        return "\n".join(summary)
        
    except Exception as e:
        print(f"Error creating summary: {str(e)}", file=sys.stderr)
        return None

def main():
    parser = argparse.ArgumentParser(description='Create workflow fix summary')
    parser.add_argument('--logs', required=True, help='Path to workflow logs')
    parser.add_argument('--output', required=True, help='Output markdown file')
    
    args = parser.parse_args()
    
    summary = create_markdown_summary(args.logs)
    if not summary:
        sys.exit(1)
    
    try:
        with open(args.output, 'w') as f:
            f.write(summary)
        print(f"Successfully created summary at {args.output}")
        sys.exit(0)
    except Exception as e:
        print(f"Error writing summary: {str(e)}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
