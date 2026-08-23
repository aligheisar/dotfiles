pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    function generateFromArtwork(url) {
        if (!url || url === "")
            return;

        let path = url;

        if (path.startsWith("file://"))
            path = decodeURIComponent(path.substring(7));

        process.exec(["update-colors", path]);
    }

    Process {
        id: process
    }
}
