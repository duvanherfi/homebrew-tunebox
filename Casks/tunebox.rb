cask "tunebox" do
  version "0.1.6,7"
  sha256 "bc64706e844d68ba92366eeb123ce0b7d1d823555d8785d418d325c5c7cc1222"

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

  depends_on macos: :catalina

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
