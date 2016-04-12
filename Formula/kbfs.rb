# Sourced from https://raw.githubusercontent.com/keybase/homebrew-beta/master/kbfs.rb
class Kbfs < Formula
  desc "Keybase FS"
  homepage "https://keybase.io/"

  url "https://github.com/keybase/kbfs-beta/archive/v1.0.2.tar.gz"
  sha256 "02cd648aab463c1962fd6544ac1cedee8f85b4eebc2b0b7421c7301a3bd5aa78"

  head "https://github.com/keybase/kbfs-beta.git"
  version "1.0.2"

  depends_on "go" => :build
  # Needed for third-party go dependencies that use hg, in particular
  # code.google.com/p/rsc/qr.
  depends_on "hg" => :build
  depends_on "keybase"
  #depends_on :osxfuse

  # bottle do
  #   cellar :any_skip_relocation
  #   sha256 "d10ab44eb7153fb6041dbc5250eb4fdfe2e4e35e7f77a18e188675d8ab92865b" => :yosemite
  #   root_url "https://github.com/keybase/kbfs-beta/releases/download/v1.0.0-16"
  # end

  def install
    ENV["GOPATH"] = buildpath
    ENV["GOBIN"] = buildpath
    ENV["GO15VENDOREXPERIMENT"] = "0"
    system "mkdir", "-p", "src/github.com/keybase/"
    # system "mv", "client", "src/github.com/keybase/"
    system "mv", "kbfs", "src/github.com/keybase/"

    system "go", "get", "github.com/keybase/kbfs/kbfsfuse"
    system "go", "build", "-a", "-tags", "production brew", "-o", "kbfs", "github.com/keybase/kbfs/kbfsfuse"

    bin.install "kbfs"
  end

  def post_install
    mount_dir = "#{ENV['HOME']}/Keybase"
    system "mkdir", "-p", mount_dir
    system "keybase", "launchd", "install", "homebrew.mxcl.kbfs", "#{opt_bin}/kbfs", mount_dir
  end

  test do
    system "#{bin}/kbfs", "--version"
  end
end
