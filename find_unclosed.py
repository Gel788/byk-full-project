#!/usr/bin/env python3

def find_unclosed_divs(filename):
    stack = []
    
    with open(filename, 'r') as f:
        lines = f.readlines()
    
    for i, line in enumerate(lines):
        line = line.strip()
        if line.startswith('<div'):
            stack.append((i+1, line[:50]))
        elif line.startswith('</div>'):
            if stack:
                stack.pop()
            else:
                print(f"Unexpected closing div at line {i+1}: {line}")
    
    print(f"\nUnclosed divs ({len(stack)}):")
    for line_num, content in stack[-10:]:  # Show last 10 unclosed
        print(f"Line {line_num}: {content}")
    
    return len(stack)

if __name__ == "__main__":
    count = find_unclosed_divs("byk-admin/src/app/page.tsx")
    print(f"\nTotal unclosed divs: {count}")
