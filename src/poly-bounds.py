#!/usr/bin/python

# Determine the bounds (min x, min y, max x, max y) of a POLY file
# The bounds can be used as input parameter for render_list_geo.pl

import argparse
from shapely.geometry import MultiPolygon, Polygon


def parse_poly(lines):
    """ Parse an Osmosis polygon filter file.

        Accept a sequence of lines from a polygon file, return a shapely.geometry.MultiPolygon object.

        http://wiki.openstreetmap.org/wiki/Osmosis/Polygon_Filter_File_Format
    """
    in_ring = False
    coords = []

    for (index, line) in enumerate(lines):
        if index == 0:
            # first line is junk.
            continue

        elif index == 1:
            # second line is the first polygon ring.
            coords.append([[], []])
            ring = coords[-1][0]
            in_ring = True

        elif in_ring and line.strip() == 'END':
            # we are at the end of a ring, perhaps with more to come.
            in_ring = False

        elif in_ring:
            # we are in a ring and picking up new coordinates.
            ring.append(map(float, line.split()))

        elif not in_ring and line.strip() == 'END':
            # we are at the end of the whole polygon.
            break

        elif not in_ring and line.startswith('!'):
            # we are at the start of a polygon part hole.
            coords[-1][1].append([])
            ring = coords[-1][1][-1]
            in_ring = True

        elif not in_ring:
            # we are at the start of a polygon part.
            coords.append([[], []])
            ring = coords[-1][0]
            in_ring = True

    return MultiPolygon(coords)


def read_polygon(poly_filename):
    with open(poly_filename) as f:
        return f.readlines()


def main(poly_filename):
    data = read_polygon(poly_filename)
    geom = parse_poly(data)

    minx = geom.bounds[0]
    miny = geom.bounds[1]
    maxx = geom.bounds[2]
    maxy = geom.bounds[3]

    print '-x', minx,'-y', miny, '-X', maxx, '-Y', maxy


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("poly_filename")
    args = parser.parse_args()

    main(args.poly_filename)
