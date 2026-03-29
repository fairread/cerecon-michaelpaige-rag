import os
import sys
import subprocess
import time

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def print_header():
    print("======================================================")
    print(" ENTERPRISE MULTIMODAL RAG - ASSESSMENT SUITE")
    print("======================================================")
    print(" [Architecture: FastAPI | React | Azure AI | MLOps]")
    print("======================================================\n")

def run_script(path):
    print(f"\n[EXEC] Running {os.path.basename(path)}...\n")
    try:
        # Pass the same python executable to ensure venv persistence
        subprocess.run([sys.executable, path], check=True)
    except Exception as e:
        print(f"\n[!] Execution failed: {e}")
    input("\nPress Enter to return to menu...")

def launch_full_stack():
    print("\n[EXEC] Launching Full-Stack Demo (FastAPI + React)...")
    print(" [Note] This will boot the Orchestrator to manage parallel processes.\n")
    try:
        # Use orchestrator.py which is in the same folder
        subprocess.run([sys.executable, "orchestrator.py"], check=True)
    except KeyboardInterrupt:
        print("\n[!] Full-Stack Demo terminated by user.")
    except Exception as e:
        print(f"\n[!] Launch failed: {e}")
    input("\nPress Enter to return to menu...")

def main_menu():
    while True:
        clear_screen()
        print_header()
        print(" Please select an assessment mode to evaluate:")
        print(" 1. [PUBLIC INGESTION] - Live Open-Source Data Demo (Wikipedia)")
        print(" 2. [ENTERPRISE SYNC]  - O365, Rate Limiting & Tombstone Logic")
        print(" 3. [MLOPS EVALUATION] - RAGAS Quality Metrics (Faithfulness/Relevance)")
        print(" 4. [FULL-STACK DEMO]  - Launch FastAPI Backend + React Frontend")
        print(" 5. [INTERACTIVE]       - Launch Jupyter Notebook (for Sandbox testing)")
        print(" 6. [EXIT]             - Close Assessment Suite")
        print("\n------------------------------------------------------")
        
        choice = input("\n Selection (1-6): ")
        
        if choice == '1':
            run_script("../backend/extractors/public_data_ingestor.py")
        elif choice == '2':
            run_script("../backend/extractors/enterprise_o365_extractor.py")
        elif choice == '3':
            run_script("../backend/evaluators/ragas_evaluator.py")
        elif choice == '4':
            launch_full_stack()
        elif choice == '5':
            print("\n[EXEC] Launching Jupyter Lab/Notebook...")
            try:
                subprocess.run(["jupyter", "notebook", "demo_pipeline.ipynb"], shell=True)
            except Exception as e:
                print(f"[!] Requirements missing: {e}")
                input("\nPress Enter to return...")
        elif choice == '6':
            print("\nExiting Assessment Suite. Thank you!")
            break
        else:
            print("\n[!] Invalid selection. Please try again.")
            time.sleep(1)

if __name__ == "__main__":
    # Ensure current working directory is the demo folder for relative pathing
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    main_menu()
