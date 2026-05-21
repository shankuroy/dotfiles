# bash cheatsheet

## comparisons using `[[ ]]`

| Operator | Meaning                                  | Example                                     |
| :------- | :--------------------------------------- | :------------------------------------------ |
| ==       | Strings are exactly equal                | `[[ "$A" == "$B" ]]`                        |
| !=       | Strings are not equal                    | `[[ "$A" != "$B" ]]`                        |
| <        | Sorts before (alphabetical)              | `[[ "$A" < "$B" ]]`                         |
| >        | Sorts after (alphabetical)               | `[[ "$A" > "$B" ]]`                         |
| -z       | String is empty (Length is Zero)         | `[[ -z "$VAR" ]]`                           |
| -n       | String is NOT empty (Length is Non-zero) | `[[ -n "$VAR" ]]`                           |
| -eq      | Equal to                                 | `[[ $NUM -eq 5 ]]`                          |
| -ne      | Not equal to                             | `[[ $NUM -ne 5 ]]`                          |
| -lt      | Less than                                | `[[ $NUM -lt 10 ]]`                         |
| -le      | Less than or equal to                    | `[[ $NUM -le 10 ]]`                         |
| -gt      | Greater than                             | `[[ $NUM -gt 0 ]]`                          |
| -ge      | Greater than or equal to                 | `[[ $NUM -ge 0 ]]`                          |
| -e       | Exists (File or Directory)               | `[[ -e "data.txt" ]]`                       |
| -f       | Is a regular file                        | `[[ -f "data.txt" ]]`                       |
| -d       | Is a directory                           | `[[ -d "/backup" ]]`                        |
| -s       | Has a size greater than zero             | `[[ -s "log.txt" ]]`                        |
| -r       | Is readable                              | `[[ -r "data.txt" ]]`                       |
| -w       | Is writable                              | `[[ -w "data.txt" ]]`                       |
| -x       | Is executable                            | `[[ -x "script.sh" ]]`                      |
| &&       | Logical AND                              | `[[ -f "$FILE" && -s "$FILE" ]]`            |
| !        | Logical NOT (Invert)                     | `[[ ! -d "/tmp" ]]`                         |
| == \*    | Pattern Matching (Globbing)              | `[[ "$FILE" == *.txt ]]`                    |
| =~       | Regular Expression Match                 | `[[ "$EMAIL" =~ ^[a-z]+@[a-z]+\.[a-z]+$ ]]` |

## simple argument parsing

```bash
#!/usr/bin/env bash

# 1. Set default values
VERBOSE=0
FILE="default_file"

# 2. Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -v|--verbose)
      VERBOSE=1
      shift # Go to next argument
      ;;
    -f|--file)
      # Check if $2 is empty OR if it starts with a hyphen (meaning it's another flag)
      if [[ -z "$2" || "$2" == -* ]]; then
        echo "Error: $1 requires a value." >&2
        exit 1
      fi

      FILE="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [-v|--verbose] [-f|--file <filename>]"
      exit 0
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      # Handle positional arguments (if any)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

# 3. Restore positional arguments (optional)
set -- "${POSITIONAL_ARGS[@]}"

# --- Main Script Logic Below ---
echo "Verbose: $VERBOSE"
echo "File: $FILE"
echo "Positional arguments: $@"
```

## checking for interactivity

```bash
[[ $- == *i* && -t 1 ]]
```

`$-` contains a set of single-letter shell options where `i` indicates the shell is running interactively.

`-t 1` is true when the output is going directly to a terminal display rather than being redirected to a pipe or a file.

So this check passes if the shell is running interactively and the output is not being piped/redirected.

