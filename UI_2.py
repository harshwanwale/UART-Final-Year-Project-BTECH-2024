import tkinter as tk
from tkinter import ttk
import serial.tools.list_ports
from datetime import datetime
import threading  # Import threading module for concurrent operations

bluetooth = None  # Global variable for the Bluetooth connection

def send_message():
    message = input_msg.get()
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    output_msg.config(state=tk.NORMAL)
    output_msg.insert(tk.END, f'{timestamp} - Sent: {message}\n')
    output_msg.config(state=tk.DISABLED)
    input_msg.delete(0, tk.END)

    # Send data to Bluetooth module
    data_to_send = message  # Send the message entered in the input box
    bluetooth.write(data_to_send.encode('utf-8'))

def receive_data():
    global bluetooth
    while True:
        if bluetooth and bluetooth.in_waiting > 0:
            received_data = bluetooth.read(bluetooth.in_waiting)
            timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            decoded_data = received_data.decode('utf-8')
            output_msg.config(state=tk.NORMAL)
            output_msg.insert(tk.END, f'{timestamp} - Received: {decoded_data}\n')
            output_msg.config(state=tk.DISABLED)
            # hex_data = received_data.hex()  # Convert bytes to hexadecimal string

            # timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            # output_msg.config(state=tk.NORMAL)
            # output_msg.insert(tk.END, f'{timestamp} - Received: {hex_data}\n')
            # output_msg.config(state=tk.DISABLED)

def open_bluetooth_connection(port, baud_rate):
    import serial

    try:
        # Open the Bluetooth connection
        bluetooth = serial.Serial(port=port, baudrate=baud_rate)
        print(f"Bluetooth connection opened on {port} at {baud_rate} baud rate.")
        return bluetooth
    except serial.SerialException as e:
        print(f"Failed to open Bluetooth connection on {port} at {baud_rate} baud rate:", e)
        return None

# Get available COM ports
available_ports = [port.device for port in serial.tools.list_ports.comports()]

# Available baud rates
baud_rates = [9600, 19200, 38400, 57600, 115200]  # Example baud rates

# Create the main window
window = tk.Tk()
window.title("UART COMMUNICATION")
screen_width = window.winfo_screenwidth()
screen_height = window.winfo_screenheight()
window.geometry(f"{screen_width}x{screen_height}")

# Main headline
headline_label = tk.Label(window, text="Software for UART Communication Through Bluetooth Module", font=("Arial", 15, "bold"))
headline_label.pack(pady=10)

# Create left and right frames
left_frame = tk.Frame(window, bg="#fff9d8")
left_frame.place(relx=0.02, rely=0.15, relwidth=0.45, relheight=0.8)

right_frame = tk.Frame(window, bg="#e3f3ff")
right_frame.place(relx=0.49, rely=0.15, relwidth=0.49, relheight=0.8)

input_label = tk.Label(left_frame, text="Enter data to send:", bg="#fff9d8", font=("Arial", 12))
input_label.place(relx=0.1, rely=0.05)
# Left side widgets
input_msg = tk.Entry(left_frame, width=30)
input_msg.place(relx=0.1, rely=0.1)

com_port_label = tk.Label(left_frame, text="Select Port:", bg="#fff9d8", font=("Arial", 12))
com_port_label.place(relx=0.1, rely=0.2, anchor=tk.W)

com_port_combobox = ttk.Combobox(left_frame, width=10, font=("Arial", 10), values=available_ports)
com_port_combobox.place(relx=0.25, rely=0.2, anchor=tk.W)

baud_rate_label = tk.Label(left_frame, text="Baud Rate:", bg="#fff9d8", font=("Arial", 12))
baud_rate_label.place(relx=0.1, rely=0.3, anchor=tk.W)

baud_rate_combobox = ttk.Combobox(left_frame, width=10, font=("Arial", 10), values=baud_rates)
baud_rate_combobox.place(relx=0.25, rely=0.3, anchor=tk.W)
baud_rate_combobox.set(baud_rates[0])  # Set default baud rate

# Right side widgets
output_msg = tk.Text(right_frame, height=20, width=50)
output_msg.place(relx=0.1, rely=0.1)


output_msg.config(state=tk.DISABLED)  # Make the output message console read-only

# Function to handle button click
def handle_connect():
    selected_port = com_port_combobox.get()
    selected_baud_rate = int(baud_rate_combobox.get())
    global bluetooth
    bluetooth = open_bluetooth_connection(selected_port, selected_baud_rate)
    if bluetooth:
        threading.Thread(target=receive_data, daemon=True).start()  # Start receiving data in a separate thread

# Connect button
connect_btn = tk.Button(left_frame, text="Connect", command=handle_connect,bg="red", fg="white")
connect_btn.place(relx=0.1, rely=0.45)

send_btn = tk.Button(left_frame, text="Send", command=send_message,bg="black", fg="white")
send_btn.place(relx=0.3, rely=0.45)

# Start the main loop
window.mainloop()
