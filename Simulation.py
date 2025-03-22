import time

# Frequency thresholds (in ms)
LOW_FREQ_THRESHOLD = 500
MID_FREQ_THRESHOLD = 300
HIGH_FREQ_THRESHOLD = 100

# Action mappings for simulated frequencies
START_FREQ = 200
PRINT_FREQ = 400
ADD_FREQ = 600
SUBTRACT_FREQ = 800
END_FREQ = 1000

# Example state variables for computation
memory = 0

# Function to simulate CPU frequency (using time intervals)
def get_cpu_frequency():
    # Get current time in milliseconds since the epoch
    time_ms = int(time.time() * 1000)
    
    # Use modulo to simulate cycling frequencies
    frequency = time_ms % 1000
    
    # Map the time into frequency ranges (low, mid, high)
    if frequency < LOW_FREQ_THRESHOLD:
        return LOW_FREQ_THRESHOLD  # Simulate low frequency event
    elif frequency < MID_FREQ_THRESHOLD:
        return MID_FREQ_THRESHOLD  # Simulate mid frequency event
    else:
        return HIGH_FREQ_THRESHOLD  # Simulate high frequency event

# Function to process frequency and execute corresponding command
def process_frequency(freq):
    global memory
    
    if freq == START_FREQ:  # START
        print("Program started...")
    elif freq == PRINT_FREQ:  # PRINT
        print(f"Memory: {memory}")
    elif freq == ADD_FREQ:  # ADD
        memory += 10
        print(f"Added 10. New memory value: {memory}")
    elif freq == SUBTRACT_FREQ:  # SUBTRACT
        memory -= 5
        print(f"Subtracted 5. New memory value: {memory}")
    elif freq == END_FREQ:  # END
        print("Program ended.")
    else:
        print(f"Unknown frequency: {freq}")

# Simulate a sequence of CPU frequency-based events
def run_program():
    for _ in range(10):  # Run the program 10 times
        cpu_freq = get_cpu_frequency()
        process_frequency(cpu_freq)  # Process the simulated CPU frequency
        time.sleep(1)  # Simulate a delay (1 second)

# Main entry point
if __name__ == "__main__":
    run_program()
