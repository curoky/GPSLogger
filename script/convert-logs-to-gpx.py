#!/usr/bin/env python3
# Copyright (c) 2022-2022 curoky(cccuroky@gmail.com).
#
# This file is part of GPSLogger.
# See https://github.com/curoky/GPSLogger for further info.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import gpxpy.gpx
from pathlib import Path
from dateutil.parser import parse


def main(logPath: Path, gpxPath: Path):
    gpx = gpxpy.gpx.GPX()

    gpx_track = gpxpy.gpx.GPXTrack()
    gpx.tracks.append(gpx_track)

    gpx_segment = gpxpy.gpx.GPXTrackSegment()
    gpx_track.segments.append(gpx_segment)

    # from: =>|k=v,k=v,k=v|k=v,k=v,k=v|...|xxxx
    # to: [ [[k=v,k=v,..],... ], ...]
    records = map(
        lambda x: list(map(lambda y: y.split(','), x)),
        map(lambda x: x.split('|')[1:-1],
            filter(lambda x: x.startswith('=>|'),
                   logPath.read_text().splitlines())))

    for record in records:
        assert len(record) == 1
        point = gpxpy.gpx.GPXTrackPoint()
        for kv in record[0]:
            k, v = kv.split('=')
            match k:
                case 'latitude':
                    point.latitude = float(v)
                case 'longitude':
                    point.longitude = float(v)
                case 'altitude':
                    point.elevation = float(v)
                case 'ellipsoidalAltitude':
                    pass
                case 'horizontalAccuracy':
                    pass
                case 'verticalAccuracy':
                    pass
                case 'course':
                    point.course = float(v)
                case 'courseAccuracy':
                    pass
                case 'speed':
                    point.speed = float(v)
                case 'speedAccuracy':
                    pass
                case 'timestamp':
                    point.time = parse(v)

        gpx_segment.points.append(point)

    gpxPath.write_text(gpx.to_xml())


if __name__ == '__main__':
    main(Path.home() / 'repos/backup/gpx/tracer/gps.log.txt',
         Path.home() / 'repos/backup/gpx/tracer/gps.log.gpx')
