import os
import re

import requests
from requests import Response

data_dir: str = os.environ.get("JELLYFIN_DATA_DIR") or os.path.abspath("./")
url: str = (
    os.environ.get("M3U_URL") or "http://mafreebox.freebox.fr/freeboxtv/playlist.m3u"
)

playlist_path: str = os.path.join(data_dir, "playlist.m3u")
final_path: str = os.path.join(data_dir, "freebox.m3u")

resp: Response = requests.get(url, timeout=10)
resp.raise_for_status()

def convert_to_proxy(line: str) -> str:
    match = re.search(r'service=(\d+)(?:&flavour=(.*))?', line)
    if match:
        service_id = match.group(1)
        flavour = match.group(2)
        if flavour:
            return f"rtsp://127.0.0.1:8554/freebox_{service_id}_{flavour}\n"
        else:
            return f"rtsp://127.0.0.1:8554/freebox_{service_id}\n"
    return line

with open(playlist_path, "w") as file:
    _ = file.write(resp.text)

with open(final_path, "w") as w_file:
    _ = w_file.write("#EXTM3U\n")
    with open(playlist_path, "r") as r_file:
        keep_line: bool = False
        written_channels: set[int] = set()
        while line := r_file.readline():
            if keep_line:
                # line = convert_to_proxy(line)
                _ = w_file.write(line)
                keep_line = False
            elif "(HD)" in line or "(TNT)" in line:
                line = line.replace(" (HD)", "").replace(" (TNT)", "")
                match = re.match(r"#EXTINF:\d+,(?P<entry>\d+)", line)
                channel_nb: int | None = int(match.group("entry")) if match else None
                if channel_nb and channel_nb not in written_channels:
                    keep_line = True
                    _ = w_file.write(line)
                    written_channels.add(channel_nb)

os.remove(playlist_path)
