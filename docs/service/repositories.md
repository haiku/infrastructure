# Haiku Repositories

Haiku Repositories are made up of two components:

  * repo definitions
  * a bunch of packages

> Under the hood of our infrastructure are a complex map of
> symlinks / redirects. Most of these (besides ```currrent``` symlinks) are for
> compatibility with existing clients.

## Repository Prefix

Generally our repositories follow the layout below:

  * (name)/(branch)/(architecture)/(version)

**Examples:**

  * https://eu.hpkg.haiku-os.org/haiku/master/x86_64/current (symlink to latest build)
  * https://eu.hpkg.haiku-os.org/haiku/master/x86_64/r1~alpha4_pm_hrev52112
  * https://eu.hpkg.haiku-os.org/haiku/master/x86_64/r1~alpha4_pm_hrev52114
  * https://eu.hpkg.haiku-os.org/haiku/r1beta1/x86_gcc2/r1~alpha4_pm_hrev52114
  * https://eu.hpkg.haiku-os.org/haiku/master/x86_gcc2/current (for haikuports it's just a single repo named current)

## Repository Layout

### Haiku (Simple, one package directory per version)

  * repo
    * Binary repo definition. Contains inventory of all packages within repo.
    * Contains checksums of all packages referenced.
    * Used by clients for upgrades
  * repo.info
    * Plaintext repo definition. Used for debugging/reference only.
  * repo.sig
    * Signature of repo. Used for validation of packages.
  * repo.sha256
    * sha256 checksum of repo above
  * packages
    * directory containing hpkgs
    * Used by clients for upgrades

**Example:**

  * https://eu.hpkg.haiku-os.org/haiku/master/x86_64/current/packages/haiku-r1~beta1_hrev52295_129-1-x86_64.hpkg
  * https://eu.hpkg.haiku-os.org/haiku/master/x86_64/current/repo
    * repo points to https://eu.hpkg.haiku-os.org/haiku/master/x86_64/current/packages/haiku-r1~beta1_hrev52295_129-1-x86_64.hpkg

### Haikuports (complex, one package directory shared by versions)

> In this model, all packages are within a "shared" package directory.
> Packages not defined in repo are not visible to repo/version consumers.

  * repo
    * Repo Definition. Contains inventory of all packages within repo.
    * Contains checksums of all packages referenced.
    * Used by clients for upgrades
  * repo.info
    * Plaintext repo definition. Used for debugging/reference only.
  * repo.sig
    * Signature of repo. Used for validation of packages.
  * repo.sha256
    * sha256 checksum of repo above
  * ../packages
    * directory containing hpkgs

**Example:**

  * https://eu.hpkg.haiku-os.org/haiku/master/packages/haiku-r1~beta1_hrev52295_129-1-x86_64.hpkg
  * https://eu.hpkg.haiku-os.org/haiku/master/x86_64/current/repo
    * repo points to https://eu.hpkg.haiku-os.org/haiku/master/packages/haiku-r1~beta1_hrev52295_129-1-x86_64.hpkg
