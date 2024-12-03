class PythonAT3130 < Formula
  desc "Interpreted, interactive, object-oriented programming language"
  homepage "https://www.python.org/"
  url "https://www.python.org/ftp/python/3.13.0/Python-3.13.0.tgz"
  sha256 "12445c7b3db3126c41190bfdc1c8239c39c719404e844babbd015a1bc3fafcd4"
  license "Python-2.0"
  revision 1

  livecheck do
    url "https://www.python.org/ftp/python/"
    regex(%r{href=.*?v?(3\.13(?:\.\d+)*)/?["' >]}i)
  end

  keg_only :versioned_formula

  # conflicts_with "python@3.13", because: "both install Python 3.13 binaries"

  def version
    "3.13.0"
  end

  def version_major
    version.split(".")[0]
  end

  def version_minor
    version.split(".")[1]
  end

  def version_major_minor
    version.split(".")[0..1].join(".")
  end

  # ... rest of the file remains unchanged ...
end
