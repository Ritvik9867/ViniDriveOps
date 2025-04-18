#!/usr/bin/env python3

import argparse
import json
import sys
from github import Github
from pathlib import Path

def download_workflow_logs(run_id, token, output_file):
    """Download logs from a GitHub Actions workflow run."""
    try:
        # Ensure output directory exists
        output_path = Path(output_file)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Initialize GitHub client
        g = Github(token)
        
        # Get the repository from the environment
        repo_name = f"{g.get_user().login}/ViniDriveOps"
        repo = g.get_repo(repo_name)
        
        # Get the workflow run
        run = repo.get_workflow_run(run_id)
        
        # Get all jobs from the run
        jobs = run.jobs()
        
        logs = {
            'workflow_name': run.workflow.name,
            'run_id': run_id,
            'status': run.conclusion,
            'jobs': []
        }
        
        for job in jobs:
            job_logs = {
                'name': job.name,
                'status': job.conclusion,
                'steps': []
            }
            
            # Get logs for each step
            for step in job.steps:
                step_logs = {
                    'name': step.name,
                    'status': step.conclusion,
                    'number': step.number,
                    'started_at': step.started_at.isoformat() if step.started_at else None,
                    'completed_at': step.completed_at.isoformat() if step.completed_at else None
                }
                
                # Download step logs if available and step has completed
                if step.conclusion is not None:
                    try:
                        log_content = job.get_logs()
                        if log_content:
                            # Limit log content to avoid extremely large files
                            step_logs['log_content'] = log_content[:10000]
                            if len(log_content) > 10000:
                                step_logs['log_content'] += "\n... (truncated)"
                    except Exception as e:
                        print(f"Warning: Could not download logs for step {step.name}: {str(e)}")
                        step_logs['log_content'] = f"Log download failed: {str(e)}"
                
                job_logs['steps'].append(step_logs)
            
            logs['jobs'].append(job_logs)
        
        # Write logs to file
        with open(output_file, 'w') as f:
            json.dump(logs, f, indent=2)
        
        print(f"Successfully downloaded logs to {output_file}")
        return True
        
    except Exception as e:
        print(f"Error downloading logs: {str(e)}")
        
        # Create minimal log file with error information
        error_logs = {
            'error': str(e),
            'workflow_name': 'Unknown',
            'run_id': run_id,
            'status': 'error',
            'jobs': []
        }
        
        try:
            with open(output_file, 'w') as f:
                json.dump(error_logs, f, indent=2)
        except Exception as write_error:
            print(f"Failed to write error log file: {str(write_error)}")
        
        return False

def main():
    parser = argparse.ArgumentParser(description='Download GitHub Actions workflow logs')
    parser.add_argument('--run-id', required=True, help='Workflow run ID')
    parser.add_argument('--token', required=True, help='GitHub token')
    parser.add_argument('--output', required=True, help='Output file path')
    
    args = parser.parse_args()
    
    success = download_workflow_logs(
        run_id=int(args.run_id),
        token=args.token,
        output_file=args.output
    )
    
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
