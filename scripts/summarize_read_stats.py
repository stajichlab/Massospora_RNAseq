#!/usr/bin/env python3

import os
import re
import glob
import argparse
from collections import defaultdict
import pandas as pd

def parse_stats_file(filepath):
    """Parse a stats file and extract the scaffold total (read count)."""
    try:
        with open(filepath, 'r') as f:
            for line in f:
                if 'Main genome scaffold total:' in line:
                    # Extract the number from the line
                    match = re.search(r'Main genome scaffold total:\s+(\d+)', line)
                    if match:
                        return int(match.group(1))
        return 0
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return 0

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(
        description='Summarize read statistics from stats files into a table.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Example usage:
  %(prog)s -i results/stats
  %(prog)s --input-dir /path/to/stats/folder
        '''
    )
    parser.add_argument(
        '-i', '--input-dir',
        default='results/stats',
        help='Directory containing stats files (default: results/stats)'
    )
    
    args = parser.parse_args()
    
    # Directory containing stats files
    stats_dir = args.input_dir
    
    # Check if directory exists
    if not os.path.isdir(stats_dir):
        print(f"Error: Directory '{stats_dir}' does not exist.")
        return 1
    
    # Dictionary to store data: {prefix: {organism: count}}
    data = defaultdict(dict)
    
    # Pattern for stats files
    pattern = os.path.join(stats_dir, '*.txt')
    
    # Read all stats files
    for filepath in glob.glob(pattern):
        filename = os.path.basename(filepath)
        
        match = re.match(r'(MCIC_\S+_\d+)_(\w+)\.fq\.stats\.txt', filename)
        if match:
            prefix = match.group(1)
            organism = match.group(2)
            
            # Parse the stats file
            count = parse_stats_file(filepath)
            
            # Store in data dictionary
            data[prefix][organism] = count
    
    # Convert to DataFrame
    df = pd.DataFrame(data).T
    
    # Sort by index (sample names)
    df = df.sort_index()
    
    # Sort columns alphabetically
    df = df.reindex(sorted(df.columns), axis=1)
    
    # Display the table
    print("\nRead Statistics Summary (Counts)")
    print("=" * 80)
    print(df.to_string())
    
    # Save to CSV
    output_file = os.path.join(stats_dir, 'summary_table.csv')
    df.to_csv(output_file)
    print(f"\n\nTable saved to: {output_file}")
    
    # Also save as tab-separated
    output_tsv = os.path.join(stats_dir, 'summary_table.tsv')
    df.to_csv(output_tsv, sep='\t')
    print(f"Table saved to: {output_tsv}")
    
    # Calculate percentage table
    # Calculate row sums (total reads per sample)
    row_totals = df.sum(axis=1)
    
    # Calculate percentages (divide each value by row total and multiply by 100)
    df_percent = df.div(row_totals, axis=0) * 100
    
    # Round to 2 decimal places
    df_percent = df_percent.round(2)
    
    # Display the percentage table
    print("\n\nRead Statistics Summary (Percentages)")
    print("=" * 80)
    print(df_percent.to_string())
    
    # Save percentage table to CSV
    output_percent_file = os.path.join(stats_dir, 'summary_percent_table.csv')
    df_percent.to_csv(output_percent_file)
    print(f"\n\nPercentage table saved to: {output_percent_file}")
    
    # Also save as tab-separated
    output_percent_tsv = os.path.join(stats_dir, 'summary_percent_table.tsv')
    df_percent.to_csv(output_percent_tsv, sep='\t')
    print(f"Percentage table saved to: {output_percent_tsv}")
    
    return 0

if __name__ == '__main__':
    exit(main())
