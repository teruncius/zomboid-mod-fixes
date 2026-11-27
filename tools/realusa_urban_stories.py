"""Write the list of Real USA's Forest story zones that lie in towns.

Real USA lays 14x14 ZoneStory zones named Forest in town parks and along the
roads. Vanilla rolls its forest stories in them (camps with tents, hunter and
hermit camps, burials), which don't fit in a town. A zone counts as in a town
when at least MIN_BUILDINGS buildings have a room within MARGIN tiles of it:
the map's rural zones have at most four, nearly all of them none.

Usage: python3 -I tools/realusa_urban_stories.py <Real USA mod folder> <output .lua>
"""

import collections
import glob
import os
import re
import struct
import sys

MARGIN = 100
MIN_BUILDINGS = 5
BIN = 64
MAP_DIR = "common/media/maps/Real USA Country"
SENTINELS = "42/media/lua/server/RealUSA/RUSA_StoriesData.lua"


def read_buildings(path, cell_x, cell_y):
    """The rooms of each building of a lotheader, as (x0, y0, x1, y1) bounds.

    Mirrors IsoMetaGrid$MetaGridLoaderThread.loadCell (42.21). A building's
    emptyoutside rooms only count when it has no other rooms, as in
    IsoMetaChunk.getBuildingsIntersecting.
    """
    with open(path, "rb") as f:
        data = f.read()
    pos = 4 if data[:4] == b"LOTH" else 0

    def read_int():
        nonlocal pos
        value = struct.unpack_from("<i", data, pos)[0]
        pos += 4
        return value

    def read_line():
        nonlocal pos
        end = data.index(b"\n", pos)
        line = data[pos:end]
        pos = end + 1
        return line.decode("latin-1").strip()

    version = read_int()
    for _ in range(read_int()):
        read_line()
    if version == 0:
        pos += 1
    read_int()
    read_int()
    if version == 0:
        read_int()
    else:
        read_int()
        read_int()

    rooms = []
    for _ in range(read_int()):
        name = read_line()
        read_int()
        rects = []
        for _ in range(read_int()):
            x, y, w, h = read_int(), read_int(), read_int(), read_int()
            x += cell_x * 256
            y += cell_y * 256
            rects.append((x, y, x + w, y + h))
        for _ in range(read_int()):
            read_int()
            read_int()
            read_int()
        bounds = None
        if rects:
            bounds = (min(r[0] for r in rects), min(r[1] for r in rects),
                      max(r[2] for r in rects), max(r[3] for r in rects))
        rooms.append((name == "emptyoutside", bounds))

    buildings = []
    for _ in range(read_int()):
        inside, outside = [], []
        for _ in range(read_int()):
            empty, bounds = rooms[read_int()]
            if bounds:
                (outside if empty else inside).append(bounds)
        if inside or outside:
            buildings.append(tuple(inside or outside))
    return buildings


def main():
    mod, out = sys.argv[1], sys.argv[2]
    map_dir = os.path.join(mod, MAP_DIR)

    bins = collections.defaultdict(list)
    count = 0
    for path in glob.glob(os.path.join(map_dir, "*.lotheader")):
        cell_x, cell_y = map(int, os.path.basename(path)[:-len(".lotheader")].split("_"))
        for rooms in read_buildings(path, cell_x, cell_y):
            count += 1
            keys = set()
            for x0, y0, x1, y1 in rooms:
                for bx in range(x0 // BIN, x1 // BIN + 1):
                    for by in range(y0 // BIN, y1 // BIN + 1):
                        keys.add((bx, by))
            for key in keys:
                bins[key].append(rooms)

    def buildings_near(x, y, w, h):
        x0, y0, x1, y1 = x - MARGIN, y - MARGIN, x + w + MARGIN, y + h + MARGIN
        found = set()
        for bx in range(x0 // BIN, x1 // BIN + 1):
            for by in range(y0 // BIN, y1 // BIN + 1):
                for rooms in bins.get((bx, by), ()):
                    if any(r[0] < x1 and r[2] > x0 and r[1] < y1 and r[3] > y0 for r in rooms):
                        found.add(rooms)
        return len(found)

    with open(os.path.join(mod, SENTINELS)) as f:
        sentinels = set(
            tuple(map(int, m.groups()))
            for m in re.finditer(r'\{ "ZoneStory", "Forest", (\d+), (\d+), (\d+), (\d+) \}', f.read()))

    zone = re.compile(r'\{ name = "Forest", type = "ZoneStory", x = (\d+), y = (\d+), z = 0, '
                      r'width = (\d+), height = (\d+) \}')
    total = 0
    urban = []
    with open(os.path.join(map_dir, "objects.lua")) as f:
        for m in zone.finditer(f.read()):
            total += 1
            rect = tuple(map(int, m.groups()))
            if rect not in sentinels and buildings_near(*rect) >= MIN_BUILDINGS:
                urban.append(rect)

    with open(os.path.join(mod, "42/mod.info")) as f:
        version = re.search(r"^modversion=(.*)$", f.read(), re.M).group(1).strip()

    with open(out, "w") as f:
        f.write(f"-- Real USA's Forest story zones in towns, written by tools/realusa_urban_stories.py from\n"
                f"-- Real USA {version} (do not edit by hand): {len(urban)} of its {total} Forest zones have at\n"
                f"-- least {MIN_BUILDINGS} buildings within {MARGIN} tiles. x, y, width, height of each zone in turn.\n"
                f"-- Used by zz_ModFixes_RealUSAStories.lua.\n\n"
                f"ModFixesRealUSAUrbanStories = {{\n")
        for i in range(0, len(urban), 4):
            f.write("    " + " ".join(f"{x}, {y}, {w}, {h}," for x, y, w, h in urban[i:i + 4]) + "\n")
        f.write("}\n")
    print(f"{count} buildings, {len(urban)} of {total} Forest story zones in towns")


main()
