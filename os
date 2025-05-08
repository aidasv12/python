import os
import tkinter as tk
from tkinter import ttk

def get_cpu_info():
    model_name = ""
    cpu_cores = 0
    freq = ""

    with open("/proc/cpuinfo") as f:
        for line in f:
            if "model name" in line and not model_name:
                model_name = line.strip().split(":")[1].strip()
            if "cpu MHz" in line and not freq:
                freq = line.strip().split(":")[1].strip() + " MHz"
            if line.startswith("processor"):
                cpu_cores += 1
    return model_name, cpu_cores, freq

def get_memory_info():
    mem_total = 0
    mem_free = 0
    with open("/proc/meminfo") as f:
        for line in f:
            if "MemTotal" in line:
                mem_total = int(line.split()[1]) // 1024  # MB
            elif "MemFree" in line:
                mem_free = int(line.split()[1]) // 1024  # MB
    return mem_total, mem_free

def get_top_processes():
    processes = []
    for pid in filter(str.isdigit, os.listdir('/proc')):
        try:
            with open(f"/proc/{pid}/stat") as f:
                data = f.read().split()
                name = data[1].strip("()")
                cpu_time = int(data[13]) + int(data[14])  # utime + stime
                processes.append((name, cpu_time))
        except Exception:
            continue
    # گرفتن ۵ فرایند با بیشترین مصرف CPU
    top = sorted(processes, key=lambda x: x[1], reverse=True)[:5]
    return top

def update_info():
    cpu_model, cores, freq = get_cpu_info()
    total_mem, free_mem = get_memory_info()
    top_procs = get_top_processes()

    cpu_label.config(text=f"CPU: {cpu_model}\nCores: {cores}, Freq: {freq}")
    mem_label.config(text=f"Memory: {total_mem} MB total / {free_mem} MB free")

    proc_list.delete(0, tk.END)
    for name, cpu in top_procs:
        proc_list.insert(tk.END, f"{name}: {cpu} ticks")

# رابط گرافیکی
root = tk.Tk()
root.title("System Monitor (from /proc)")
root.geometry("500x400")

cpu_label = ttk.Label(root, text="Loading CPU info...", justify="left")
cpu_label.pack(pady=10)

mem_label = ttk.Label(root, text="Loading memory info...", justify="left")
mem_label.pack(pady=10)

ttk.Label(root, text="Top 5 CPU-consuming processes:").pack()
proc_list = tk.Listbox(root, height=5, width=50)
proc_list.pack(pady=5)

refresh_button = ttk.Button(root, text="Refresh", command=update_info)
refresh_button.pack(pady=15)

update_info()
root.mainloop()
