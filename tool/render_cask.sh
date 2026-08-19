#!/usr/bin/env bash
#
# Point the cask at whatever Tunebox has published:
#
#     tool/render_cask.sh
#
# Reads the latest release of duvanherfi/tunebox through the public API, takes
# the disk image it carries, checksums the file GitHub is actually serving and
# rewrites Casks/tunebox.rb.
#
# This pulls rather than being pushed, and lives here rather than in the app's
# repository, so that publishing a release needs no write access to this repo
# and this repo needs no secret: the workflow's own GITHUB_TOKEN can write here
# and the releases API needs no token at all. The app repository deliberately
# keeps no repository-level secrets — the signing key lives in an environment
# precisely so that no ordinary workflow can read it — and a token that could
# write here would have been the first exception to that.
#
# The whole cask is generated rather than edited in place. There is one app in
# this tap and one thing that changes about it, so a template with holes in it
# would only be a second place for the version to be wrong.
set -euo pipefail

cd "$(dirname "$0")/.."

repo=duvanherfi/tunebox
api="https://api.github.com/repos/$repo/releases/latest"

sha256() {
  if command -v sha256sum >/dev/null; then sha256sum "$1" | cut -d' ' -f1
  else shasum -a 256 "$1" | cut -d' ' -f1
  fi
}

release=$(curl -fsSL -H 'Accept: application/vnd.github+json' "$api")
tag=$(jq -r '.tag_name' <<<"$release")
asset=$(jq -r '[.assets[].name | select(endswith(".dmg"))] | first // empty' <<<"$release")

[[ -n "$asset" ]] || {
  echo "the latest release ($tag) carries no disk image; leaving the cask alone" >&2
  exit 0
}

# tunebox-0.1.6+7.dmg -> 0.1.6 and 7. The build number is what decides whether
# an install is an upgrade, and a GitHub release has nowhere to put it other
# than the file name.
rest=${asset#tunebox-}; rest=${rest%.dmg}
version=${rest%%+*}
build=${rest##*+}
[[ -n "$version" && -n "$build" && "$version" != "$build" ]] || {
  echo "cannot read a version out of '$asset'" >&2
  exit 1
}

url="https://github.com/$repo/releases/download/$tag/$asset"

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
curl -fsSL "$url" -o "$tmp/$asset"
sha=$(sha256 "$tmp/$asset")

mkdir -p Casks
cat > Casks/tunebox.rb <<CASK
cask "tunebox" do
  version "$version,$build"
  sha256 "$sha"

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
  # and its session cookies in the keychain, which \`zap\` cannot reach — those
  # have to go by hand from Keychain Access if you want no trace left.
  zap trash: [
    "~/Library/Application Support/com.tunebox.tunebox",
    "~/Library/Caches/com.tunebox.tunebox",
    "~/Library/HTTPStorages/com.tunebox.tunebox",
    "~/Library/Preferences/com.tunebox.tunebox.plist",
    "~/Library/Saved Application State/com.tunebox.tunebox.savedState",
  ]
end
CASK

echo "$version,$build"
