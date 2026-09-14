cask "tunebox" do
  version "0.1.10,11"
  sha256 "c18c85b9004fe8c3aa45ca2d24895af65a0ab4e95804be47ae3a716d89f52980"

  url "https://github.com/duvanherfi/tunebox/releases/download/v#{version.csv.first}/tunebox-#{version.csv.first}+#{version.csv.second}.dmg"
  name "Tunebox"
  desc "Music player that reads the YouTube Music catalogue through InnerTube"
  homepage "https://github.com/duvanherfi/tunebox"

  # The version carries the build number after a comma because that is the
  # number an install goes by. Left to itself livecheck would read the tag and
  # answer 0.1.6, which never matches, so it reads the asset name instead — the
  # same place the in-app updater reads it from.
  livecheck do
    url :url
    regex(/tunebox[._-]v?(\d+(?:\.\d+)+)\+(\d+)\.dmg/i)
    strategy :github_latest do |json, regex|
      json["assets"]&.map do |asset|
        match = asset["name"]&.match(regex)
        next if match.blank?

        "#{match[1]},#{match[2]}"
      end
    end
  end

  # No `depends_on macos:` here. The app deploys against 10.15, and Homebrew has
  # disabled every symbol older than :big_sur — brew itself no longer runs on
  # those releases — so a floor it refuses to name is a floor it never checks.

  app "tunebox.app"

  # The app keeps its library, downloads and play log under its own bundle id,
  # and its session cookies in the keychain, which `zap` cannot reach — those
  # have to go by hand from Keychain Access if you want no trace left.
  zap trash: [
    "~/Library/Application Support/com.tunebox.tunebox",
    "~/Library/Caches/com.tunebox.tunebox",
    "~/Library/HTTPStorages/com.tunebox.tunebox",
    "~/Library/Preferences/com.tunebox.tunebox.plist",
    "~/Library/Saved Application State/com.tunebox.tunebox.savedState",
  ]
end
