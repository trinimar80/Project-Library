import json
import sys

def show_bandit_results(filepath):
    print("\n" + "="*60)
    print("BANDIT RESULTS")
    print("="*60)
    print(f"{'Archivo':<30} | {'Línea':<6} | {'Tipo':<15} | {'Descripción'}")
    print("-"*90)
    
    with open(filepath, 'r') as f:
        data = json.load(f)
    
    for result in data.get('results', []):
        filename = result.get('filename', '').split('/')[-1]
        line = result.get('line_number', '')
        test_id = result.get('test_id', '')
        message = result.get('issue_text', '').replace('\n', ' ')[:50]
        print(f"{filename:<30} | {line:<6} | {test_id:<15} | {message}")

def show_pylint_results(filepath):
    print("\n" + "="*60)
    print("PYLINT RESULTS")
    print("="*60)
    print(f"{'Archivo':<30} | {'Línea':<6} | {'Tipo':<15} | {'Descripción'}")
    print("-"*90)
    
    with open(filepath, 'r') as f:
        data = json.load(f)
    
    for result in data:
        filename = result.get('module', '').split('/')[-1] + '.py'
        line = result.get('line', '')
        msg_id = result.get('message-id', '')
        message = result.get('message', '').replace('\n', ' ')[:50]
        if message:
            print(f"{filename:<30} | {line:<6} | {msg_id:<15} | {message}")

if __name__ == "__main__":
    show_bandit_results('code_analysis/task3_bandit.json')
    show_pylint_results('code_analysis/task3_pylint.json')
    show_bandit_results('code_analysis/task7_bandit.json')
    show_pylint_results('code_analysis/task7_pylint.json')
