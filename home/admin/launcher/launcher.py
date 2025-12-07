from flask import Flask, render_template, redirect, url_for, send_from_directory
import os
import subprocess

app = Flask(__name__)

rom_dir = '/home/admin/ROMs'
marquee_dir = '/home/admin/Marquees'

# List all ROMs, check for matching marquees
def get_rom_list():
    files = os.listdir(rom_dir)
    roms = []
    for f in files:
        name, ext = os.path.splitext(f)
        if ext.lower() not in ['.zip']: #, '.nes', '.sfc', '.smc']:
            continue
        marquee = None
        for ext2 in ['.jpg', '.png', '.jpeg']:
            image_path = os.path.join(marquee_dir, f"{name}{ext2}")
            if os.path.isfile(image_path):
                marquee = f"{name}{ext2}"
                break
        roms.append({
            'file': f,
            'display_name': name,
            'marquee': marquee
        })
    return sorted(roms, key=lambda x: x['display_name'].lower())

@app.route("/")
def index():
    roms = get_rom_list()
    return render_template("index.html", roms=roms)

@app.route("/launch/<rom_file>")
def launch(rom_file):
    # Kill any running retroarch processes
    subprocess.run(["killall", "-9", "retroarch"])
    rom_path = os.path.join(rom_dir, rom_file)
    # Adjust this to your specific retroarch core:
    subprocess.Popen([
        "/opt/retropie/emulators/retroarch/bin/retroarch-wrapped",
        "--verbose", "--log-file", "/tmp/ra.log",
        "-L", "/opt/retropie/libretrocores/lr-fbneo/fbneo_libretro.so",
        rom_path
    ])
    return redirect(url_for('index'))

@app.route("/marquees/<filename>")
def marquee_file(filename):
    return send_from_directory(marquee_dir, filename)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=3333)
