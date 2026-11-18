{
  writeShellApplication,
  openssh,
  libnotify,
  curl,
  jq,
}:

# Forwards Beat Saber OneClick links (BeatSaver, BeatLeader, ScoreSaber, playlists)
# to a Steam Frame over SSH and opens them there, so BSManager on the Frame does the
# download, and shows the install progress as a notification.
# Usage: beatsaber-oneclick <ssh-host> <url>
writeShellApplication {
  name = "beatsaber-oneclick";
  runtimeInputs = [
    openssh
    libnotify
    curl
    jq
  ];
  text = ''
    remote_script=${./remote.sh}
  ''
  + builtins.readFile ./beatsaber-oneclick.sh;
}
