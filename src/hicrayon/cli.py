import argparse
import sys
from hicrayon.core import process_hic_data

def main():
    parser = argparse.ArgumentParser(
        description="HiCrayon: CLI for Hi-C data processing and SVG generation"
    )
    
    # Arguments
    parser.add_argument("bedgraph", help="Path to input .bedgraph file")
    parser.add_argument("hic_file", help="Path to input .hic or hic.txt file")
    parser.add_argument("-o", "--output", default="plot.svg", help="Output SVG filename")
    parser.add_argument("-r", "--res", type=int, default=250000, help="Resolution (default: 250000)")

    args = parser.parse_args()

    try:
        print(f"Processing {args.bedgraph} at {args.res} resolution...")
        # Call your core logic
        process_hic_data(args.bedgraph, args.hic_file, args.output, args.res)
        print(f"File saved to: {args.output}")
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()