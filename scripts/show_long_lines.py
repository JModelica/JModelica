import sys


def show_long_lines(filename):
    """Display lines from the file longer than 72 characters."""
    try:
        with open(filename, "r") as file:
            for line_number, line in enumerate(file, start=1):
                if len(line) > 72 and line.lstrip()[0] not in "cC*!":
                    print(f"{line_number}: {line}")
    except FileNotFoundError:
        print("File not found. Please check the file path and try again.")
    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py filename")
    else:
        filename = sys.argv[1]
        show_long_lines(filename)
